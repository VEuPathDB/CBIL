use strict;
use warnings;

use lib "$ENV{GUS_HOME}/lib/perl";

use Test::More;
use CBIL::ISA::InvestigationSimple;
use File::Temp qw/tempdir/;
use File::Slurp qw/write_file/;
use YAML;


my $dir = tempdir(CLEANUP => 1);
my $studyTsv = <<"EOF";
name	body_habitat	body_product	body_site	collection_date
s1	Colon	UBERON:feces	Colon	01-01-1991
s2	Colon	UBERON:feces	Colon 02-02-1992
s3	UBERON:oral cavity	UBERON:saliva	UBERON:mouth	03-03-1993
EOF
my $studyFile = "study.txt";
write_file("$dir/$studyFile", $studyTsv);

my $datasetName = "DATASET_NAME";
my $investigationXml = <<"EOF";
<investigation identifierRegex="..*" identifierIsDirectoryName="true">
  <study fileName="$studyFile" identifierSuffix="-1" sampleRegex=".+">
    <dataset>$datasetName</dataset>

    <node name="Source" type="host" suffix="Source"/>
    <node name="Sample" type="sample from organism"/>
    <node name="Extract" type="DNA extract" suffix="Extract"/>
    <node isaObject="Assay" name="Assay 16S" type="Amplicon sequencing assay" suffix="Assay 16S"/>
    <node isaObject="Assay" name="Assay WGS" type="Whole genome sequencing assay" suffix="Assay WGS"/>
    <node isaObject="DataTransformation" name="DADA2" type="" suffix="Assay WGS"/>

    <edge input="Source" output="Sample">
        <protocol>specimen collection</protocol>
    </edge>
    <edge input="Sample" output="Extract">
      <protocol>DNA extraction</protocol>
    </edge>
    <edge input="Extract" output="Assay 16S">
        <protocol>DNA sequencing</protocol>
    </edge>
    <edge input="Extract" output="Assay WGS">
        <protocol>DNA sequencing</protocol>
    </edge>
  </study>
</investigation>
EOF

write_file("$dir/i_Investigation.xml", $investigationXml);

my $ontologyMappingXml = <<"EOF";
<ontologymappings>
  <ontologyTerm source_id="EUPATH_0000591" type="materialType">
    <name>host</name>
  </ontologyTerm>
  <ontologyTerm source_id="OBI_0000671" type="materialType">
    <name>sample from organism</name>
  </ontologyTerm>
  <ontologyTerm source_id="OBI_0001051" type="materialType">
    <name>DNA extract</name>
  </ontologyTerm>
  <ontologyTerm source_id="MTTMP_1" type="materialType">
    <name>Amplicon sequencing assay</name>
  </ontologyTerm>
  <ontologyTerm source_id="MTTMP_2" type="materialType">
    <name>Whole genome sequencing assay</name>
  </ontologyTerm>

  <ontologyTerm source_id="OBI_0000659" type="protocol">
    <name>specimen collection</name>
  </ontologyTerm>
  <ontologyTerm source_id="OBI_0000257" type="protocol">
    <name>DNA extraction</name>
  </ontologyTerm>
  <ontologyTerm source_id="OBI_0000626" type="protocol">
    <name>DNA Sequencing</name>
  </ontologyTerm>
  <ontologyTerm source_id="OBI_0200000" type="protocol">
    <name>data transformation</name>
  </ontologyTerm>

  <ontologyTerm source_id="UBERON_0000466" type="characteristicQualifier" parent="Source">
    <name>body_habitat</name>
  </ontologyTerm>
  <ontologyTerm source_id="UBERON_0000463" type="characteristicQualifier" parent="Sample">
    <name>body_product</name>
  </ontologyTerm>
  <ontologyTerm source_id="UBERON_0000061" type="characteristicQualifier" parent="Sample">
    <name>body_site</name>
  </ontologyTerm>
  <ontologyTerm source_id="TMP_SCD" type="protocolParameter" parent="specimen collection">
    <name>collection_date</name>
  </ontologyTerm>

  <ontologyTerm source_id="TMP_1" type="characteristicQualifier" parent="Assay 16S">
      <name>abundance_amplicon</name>
    </ontologyTerm>
  <ontologyTerm source_id="TMP_2" type="characteristicQualifier" parent="Assay WGS">
      <name>abundance_wgs</name>
    </ontologyTerm>
</ontologymappings>
EOF

write_file("$dir/ontologyMapping.xml", $ontologyMappingXml);
my $ontologyMappingOverride = "";
my $valueMapping = "";
my $debug = 0;
my $isReporterMode = 0;
my $dateObfuscationFile = undef;

my %abundancesAmplicon = (
  s1 => "{Bacteria:0.9, Archaea:0.1}",
  s2 => "{Bacteria:0.8, Archaea:0.2}",
  s3 => "{Bacteria:0.7, Archaea:0.3}",
);

my %abundancesWgs = (
  s1 => "{Bacteria:0.1, Archaea:0.9}",
  s2 => "{Bacteria:0.2, Archaea:0.8}",
  s3 => "{Bacteria:0.3, Archaea:0.7}",
);

my $addMoreValues = sub {
  my ($valuesHash) = @_;
  #  diag explain $valuesHash;
  my $name = $valuesHash->{name}[0];
  $valuesHash->{abundance_amplicon} = [$abundancesAmplicon{$name}];
  $valuesHash->{abundance_wgs} = [$abundancesWgs{$name}];

  return $valuesHash;
};
my $getAddMoreValues = sub {
  my ($studyXml) = @_;
  #   diag explain $studyXml;
  my $dataset = $studyXml->{dataset}[0];
  die unless $dataset eq $datasetName;
  return $addMoreValues;
};
$getAddMoreValues = undef;
my $t = CBIL::ISA::InvestigationSimple->new("$dir/i_Investigation.xml", "$dir/ontologyMapping.xml", $ontologyMappingOverride, $valueMapping, $debug, $isReporterMode, $dateObfuscationFile, $getAddMoreValues);
$t->parseInvestigation;
is(scalar @{$t->getStudies}, 1);
my $study = $t->getStudies->[0];

$t->parseStudy($study);
$t->dealWithAllOntologies();

my $nodesText = Dump $study->getNodes;
for my $text (qw/UBERON:oral cavity  UBERON:saliva UBERON:mouth/){
  like($nodesText, qr/$text/, "Has: $text");
}
my $edgesText = Dump $study->getEdges;
like($edgesText, qr/01-01-1991/, "Has: 01-01-1991");
done_testing;

