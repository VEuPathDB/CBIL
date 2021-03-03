use strict;
use warnings;

use lib "$ENV{GUS_HOME}/lib/perl";

use Test::More;
use CBIL::ISA::InvestigationSimple;
use File::Temp qw/tempdir/;
use File::Slurp qw/write_file/;


my $dir = tempdir(CLEANUP => 1);
my $studyTsv = <<"EOF";
name	body_habitat	body_product	body_site
s1	Colon	UBERON:feces	Colon
s2	Colon	UBERON:feces	Colon
s3	UBERON:oral cavity	UBERON:saliva	UBERON:mouth
EOF
my $studyFile = "study.txt";
write_file("$dir/$studyFile", $studyTsv);

my $dataset = "DATASET_NAME";
my $investigationXml = <<"EOF";
<investigation identifierRegex="..*" identifierIsDirectoryName="true">
  <study fileName="$studyFile" identifierSuffix="-1" sampleRegex=".+">
    <dataset>$dataset</dataset>

    <node name="Source" type="host" suffix="Source"/>
    <node name="Sample" type="sample from organism"/>
    <node name="Extract" type="DNA extract" suffix="Extract"/>
    <node name="Assay" suffix="Assay"/>
    <node name="DataTransformation" suffix="OTU"/>

    <edge input="Source" output="Sample">
        <protocol>specimen collection</protocol>
    </edge>
    <edge input="Sample" output="Extract">
      <protocol>DNA extraction</protocol>
    </edge>
    <edge input="Extract" output="Assay">
        <protocol>DNA sequencing</protocol>
    </edge>
    <edge input="Assay" output="DataTransformation">
        <protocol>data transformation</protocol>
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
</ontologymappings>
EOF

write_file("$dir/ontologyMapping.xml", $ontologyMappingXml);
my $ontologyMappingOverride = "";
my $valueMapping = "";
my $debug = 0;
my $isReporterMode = 0;
my $dateObfuscationFile = undef;

my $t = CBIL::ISA::InvestigationSimple->new("$dir/i_Investigation.xml", "$dir/ontologyMapping.xml", $ontologyMappingOverride, $valueMapping, $debug, $isReporterMode, $dateObfuscationFile);
$t->parseInvestigation;
is(scalar @{$t->getStudies}, 1);
my $study = $t->getStudies->[0];

$t->parseStudy($study);
$t->dealWithAllOntologies();

done_testing;

