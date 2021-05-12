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
name	body_habitat	body_product	body_site	collection_date	subject_id
sample_1	Colon	UBERON:feces	Colon	01-01-1991	subject_a
sample_2	Colon	UBERON:feces	Colon	02-02-1992	subject_a
sample_3	UBERON:oral cavity	UBERON:saliva	UBERON:mouth		subject_b
EOF
my $studyFile = "study.txt";
write_file("$dir/$studyFile", $studyTsv);

my $datasetName = "DATASET_NAME";
my $investigationXml = <<"EOF";
<investigation identifierRegex="..*" identifierIsDirectoryName="true">
  <study fileName="$studyFile" identifierSuffix="-1" sampleRegex=".+">
    <dataset>$datasetName</dataset>

    <node name="Source" type="host" suffix="Source" idColumn="subject_id" />
    <node name="Sample" type="sample from organism"/>
    <node isaObject="Assay" name="16s" type="Amplicon sequencing assay" suffix="16s"/>
    <node isaObject="Assay" name="WGS" type="Whole genome sequencing assay" suffix="WGS"/>

    <edge input="Source" output="Sample">
        <protocol>specimen collection</protocol>
    </edge>
    <edge input="Sample" output="16s">
      <protocol>DNA extraction</protocol>
      <protocol>DNA sequencing</protocol>
    </edge>
    <edge input="Sample" output="WGS">
      <protocol>DNA extraction</protocol>
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
  <ontologyTerm source_id="EUPATH_0000606" type="characteristicQualifier" parent="Source">
    <name>subject_id</name>
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

  <ontologyTerm source_id="TMP_1" type="characteristicQualifier" parent="Assay">
      <name>taxon_abundance</name>
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
  sample_1 => "{Bacteria:0.9, Archaea:0.1}",
  sample_2 => "{Bacteria:0.8, Archaea:0.2}",
  sample_3 => "{Bacteria:0.7, Archaea:0.3}",
);

my %abundancesWgs = (
  sample_1 => "{Bacteria:0.1, Archaea:0.9}",
  sample_2 => "{Bacteria:0.2, Archaea:0.8}",
  sample_3 => "{Bacteria:0.3, Archaea:0.7}",
);

my $getExtraValues = sub {
  my ($node) = @_;
  return {} unless $node->isa('CBIL::ISA::StudyAssayEntity::Assay');
  my ($sample, $suffix) = $node->getValue =~ m{^(.*) \((.*)\)$};
  if($suffix eq '16s'){
    return {taxon_abundance => [$abundancesAmplicon{$sample}]};
  } 
  if ($suffix eq 'WGS'){
    return {taxon_abundance => [$abundancesWgs{$sample}]};
  }
  return {};
};
my $getGetExtraValues = sub {
  my ($studyXml) = @_;
  #   diag explain $studyXml;
  my $dataset = $studyXml->{dataset}[0];
  die unless $dataset eq $datasetName;
  return $getExtraValues;
};
my $t = CBIL::ISA::InvestigationSimple->new("$dir/i_Investigation.xml", "$dir/ontologyMapping.xml", $ontologyMappingOverride, $valueMapping, $debug, $isReporterMode, $dateObfuscationFile, $getGetExtraValues);
$t->parseInvestigation;
is(scalar @{$t->getStudies}, 1);
my $study = $t->getStudies->[0];

$t->parseStudy($study);
$t->dealWithAllOntologies();

my %entityNames;
$entityNames{$_->getEntityName}{$_->getValue}++ for @{$study->getNodes};

is_deeply(\%entityNames, {
  'Source' => {
    'subject_a (Source)' => 1,
    'subject_b (Source)' => 1,
  },
  'Sample' => {
    'sample_1' => 1,
    'sample_2' => 1,
    'sample_3' => 1
  },
  'Assay' => {
    'sample_1 (16s)' => 1,
    'sample_1 (WGS)' => 1,
    'sample_2 (16s)' => 1,
    'sample_2 (WGS)' => 1,
    'sample_3 (16s)' => 1,
    'sample_3 (WGS)' => 1
  },
}, "entity IDs") or diag explain \%entityNames;

my $nodesText = Dump $study->getNodes;
for my $text ("Bacteria:0.9", "Bacteria:0.1", "UBERON:oral cavity", "UBERON:saliva", "UBERON:mouth"){
  like($nodesText, qr/$text/, "Has: $text");
}
my $edgesText = Dump $study->getEdges;
like($edgesText, qr/01-01-1991/, "Has: 01-01-1991");
done_testing;


