use strict;
use warnings;

use lib "$ENV{GUS_HOME}/lib/perl";

use Test::More;
use Test::Exception;
use CBIL::ISA::InvestigationSimple;
use File::Temp qw/tempdir/;
use File::Slurp qw/write_file/;
use File::Path qw/make_path/;
use YAML;


my $dir = tempdir(CLEANUP => 1);
my $studyTsv = <<"EOF";
name	body_habitat	body_product	body_site	collection_date	subject_id	age_in_days_unit_set_on_variable	age_in_years_unit_with_value	Characteristics [specimen] 	data_wrangle
sample_1	Colon	UBERON:feces	Colon	01-01-1991	subject_a	234	2 years	poo	
sample_2	Colon	UBERON:feces	Colon	02-02-1992	subject_a	234	2 years	poo	optional_wrangle_for_sample_2
sample_3	UBERON:oral cavity	UBERON:saliva	UBERON:mouth		subject_b	345	3 years	poo	
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
    <node name="DataTransformation" type="Something after WGS data" suffix="WGS_DT"/>


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
    <edge input="WGS" output="DataTransformation">
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
  <ontologyTerm source_id="MTTMP_1" type="materialType">
    <name>Amplicon sequencing assay</name>
  </ontologyTerm>
  <ontologyTerm source_id="MTTMP_2" type="materialType">
    <name>Whole genome sequencing assay</name>
  </ontologyTerm>
  <ontologyTerm source_id="MTTMP_3" type="materialType">
    <name>Something after WGS data</name>
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
    <function>valueIsOntologyTerm</function>
  </ontologyTerm>
  <ontologyTerm source_id="TMP_DT" type="characteristicQualifier" parent="DataTransformation">
      <name>data_wrangle</name>
  </ontologyTerm>
  <ontologyTerm source_id="OBI_0001169" type="characteristicQualifier" parent="Source">
    <name>age_in_years_unit_with_value</name>
    <function>splitUnitFromValue</function>
    <function>setUnitToYear</function>
  </ontologyTerm>
  <ontologyTerm source_id="TMP_AGE" type="characteristicQualifier" parent="Source" unit="days" >
    <name>age_in_days_unit_set_on_variable</name>
  </ontologyTerm>
  <ontologyTerm source_id="UBERON_0000463" type="characteristicQualifier" parent="Sample">
    <name>body_product</name>
  </ontologyTerm>
  <ontologyTerm source_id="UBERON_0000061" type="characteristicQualifier" parent="Sample">
    <name>body_site</name>
  </ontologyTerm>
  <ontologyTerm source_id="OBI_0100051" type="characteristicQualifier" parent="Sample">
    <name>specimen</name>
  </ontologyTerm>
  <ontologyTerm source_id="TMP_SCD" type="protocolParameter" parent="specimen collection">
    <name>collection_date</name>
  </ontologyTerm>

  <ontologyTerm source_id="TMP_1" type="characteristicQualifier" parent="Assay">
      <name>taxon_abundance</name>
  </ontologyTerm>
  <ontologyTerm source_id="UO_0000036" type="unit">
    <name>years</name>
  </ontologyTerm>
  <ontologyTerm source_id="UO_0000033" type="unit">
    <name>days</name>
  </ontologyTerm>

  <ontologyTerm source_id="UBERON_0001155" type="characteristicValue" parent="characteristicQualifier">
    <name>colon</name>
  </ontologyTerm>

  <ontologyTerm source_id="UBERON_0000167" type="characteristicValue" parent="characteristicQualifier">
    <name>UBERON:oral cavity</name>
  </ontologyTerm>

</ontologymappings>
EOF

write_file("$dir/ontologyMapping.xml", $ontologyMappingXml);
my $ontologyMappingOverride = "";
my $valueMapping = "";
my $onError;
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
  if($suffix eq 'WGS' and $sample ne 'sample_1'){
    return {};
  }
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
my $t = CBIL::ISA::InvestigationSimple->new("$dir/i_Investigation.xml", "$dir/ontologyMapping.xml", $ontologyMappingOverride, $valueMapping, $onError, $isReporterMode, $dateObfuscationFile, $getGetExtraValues);
$t->parseInvestigation;
is(scalar @{$t->getStudies}, 1);
my $study = $t->getStudies->[0];

$t->parseStudy($study);

sub checkStudyHasEntities {
  my ($study, $expectedEntityNames, $testName) = @_;
  my %entityNames;
  $entityNames{$_->getEntityName}{$_->getValue}++ for @{$study->getNodes};
  is_deeply(\%entityNames, $expectedEntityNames, $testName) or diag explain \%entityNames;
}

my $expectedEntityNames = { 
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
  'DataTransformation' => {
        'sample_1 (WGS_DT)' => 1,
        'sample_2 (WGS_DT)' => 1,
        'sample_3 (WGS_DT)' => 1
  },

};
checkStudyHasEntities($study, $expectedEntityNames, "entity IDs");

delete $expectedEntityNames->{'Assay'}{'sample_3 (WGS)'};
delete $expectedEntityNames->{'DataTransformation'}{'sample_3 (WGS_DT)'};
delete $expectedEntityNames->{'DataTransformation'}{'sample_1 (WGS_DT)'};
$study->pruneNodesAndEdges;
checkStudyHasEntities($study, $expectedEntityNames, "entity IDs after pruning");



# numbers depend on the number of times $t->dealWithAllOntologies() got called
my $good = {
  'EUPATH' => {
    'EUPATH_0000591' => 3
  },
  'MTTMP' => {
    'MTTMP_1' => 3,
    'MTTMP_2' => 3,
    'MTTMP_3' => 3
  },
  'OBI' => {
    'OBI_0000257' => 1,
    'OBI_0000626' => 1,
    'OBI_0000659' => 1,
    'OBI_0000671' => 3,
    'OBI_0200000' => 3
  },
  'QUALIFIER' => {
    'OBI_0001169' => 3,
    'OBI_0100051' => 3,
    'TMP_1' => 6,
    'TMP_AGE' => 3,
    'TMP_DT' => 3,
    'TMP_SCD' => 2,
    'UBERON_0000061' => 3,
    'UBERON_0000463' => 3,
    'UBERON_0000466' => 3
  },
  'TMP' => {
    'TMP_SCD' => 1,
  },
  'UBERON' => {
    'UBERON_0000167' => 1,
    'UBERON_0001155' => 2
  },
  'UO' => {
    'UO_0000033' => 3,
    'UO_0000036' => 3
  }
};
subtest "Ontology accessions" => sub {
  my $actual = $t->getOntologyAccessionsHash;
  for my $key (keys %$good){
    my $gk = [sort keys %{$good->{$key}}];
    my $ak =  [sort keys %{$actual->{$key}}];
    is_deeply($gk,$ak, "Keys agree for $key") or diag explain $gk, $ak;
  }
};
#
#diag explain $t->getOntologyAccessionsHash;
my $nodesText = Dump $study->getNodes;
# diag explain $nodesText;
for my $text ("Bacteria:0.9", "Bacteria:0.1", "UBERON:oral cavity", "UBERON:saliva", "UBERON:mouth", "years", "days", "poo"){
  like($nodesText, qr/$text/, "Has: $text");
}
my $edgesText = Dump $study->getEdges;
like($edgesText, qr/01-01-1991/, "Has: 01-01-1991");

my $badDir = "$dir/bad";
make_path $badDir;
my $badStudyTsv = <<"EOF";
name	body_habitat	bad_header
sample_1	body_habitat_not_an_ontology_term_value	bad_header_value
EOF
my $badStudyFile = "badStudy.txt";
my $badInvestigationXml = $investigationXml;
$badInvestigationXml =~ s{$studyFile}{$badStudyFile}g;

write_file("$badDir/$badStudyFile", $badStudyTsv);
write_file("$badDir/i_Investigation.xml", $badInvestigationXml);

my $badT = CBIL::ISA::InvestigationSimple->new("$badDir/i_Investigation.xml", "$dir/ontologyMapping.xml", $ontologyMappingOverride, $valueMapping, $onError, $isReporterMode, $dateObfuscationFile, $getGetExtraValues);

$badT->parseInvestigation;
is(scalar @{$badT->getStudies}, 1, "one bad study");
my $badStudy = $badT->getStudies->[0];
dies_ok {$badT->parseStudy($badStudy)} "Bad study dies with no error handler set";
my @errors;
$badT->setOnError(sub{push @errors, $@;});
$badT->parseStudy($badStudy);
ok(@errors > 0, "Bad study has errors");
ok( (scalar grep {$_=~/bad_header/} @errors), "Bad study: report error about bad header") or diag explain @errors;
ok( (scalar grep {$_=~/body_habitat_not_an_ontology_term_value/} @errors), "Bad study: report error about body_habitat_not_an_ontology_term_value") or diag explain @errors;



my $clinEpiDir = "$dir/clinEpi";
make_path $clinEpiDir;

my $clinEpiParticipantsFile = "participants.txt";
my $clinEpiObservationsFile = "observations.txt";
my $clinEpiInvestigationXml = <<EOF;
<investigation identifier="GEMSCC0003" identifierIsDirectoryName="false">
  <study fileName="$clinEpiParticipantsFile" identifierSuffix="-1" allNodesGetDeltas="1">
    <dataset>ISASimple_Gates_GEMS_eda_gems1_case_control_RSRC</dataset>
    <node isaObject="Source" name="ENTITY" type="participant" suffix="" useExactSuffix="true" idColumn="PRIMARY_KEY"/> 
  </study>

  <study fileName="$clinEpiObservationsFile" identiifierSuffix="-1" allNodesGetDeltas="1">
    <dataset>ISASimple_Gates_GEMS_eda_gems1_case_control_RSRC</dataset>
    <node isaObject="Source" name="PARENT" type="participant" suffix="" useExactSuffix="true" idColumn="PARENT"/>  
    <node isaObject="Source" name="ENTITY" type="observation" suffix="" useExactSuffix="true" idColumn="PRIMARY_KEY" idObfuscationFunction="idObfuscateDate1"/>  
    <edge input="PARENT" output="ENTITY">
      <protocol>observationprotocol</protocol>
    </edge>
  </study>
</investigation>
EOF
write_file("$clinEpiDir/i_Investigation.xml", $clinEpiInvestigationXml);
my $clinEpiParticipantsTsv = <<EOF;
PRIMARY_KEY	f4a_cur_nodrink
3010244171	0
EOF
write_file("$clinEpiDir/$clinEpiParticipantsFile", $clinEpiParticipantsTsv);
my $clinEpiObservationsTsv = <<EOF;
PRIMARY_KEY	PARENT	f4b_med_bmiz_f
3010244171_21jun08_out	3010244171	
3010244171_21jun08	3010244171	0
EOF
write_file("$clinEpiDir/$clinEpiObservationsFile", $clinEpiObservationsTsv);

my $clinEpiOntologyMapping = <<EOF;
<ontologymappings>
  <ontologyTerm source_id="EUPATH_0000096" type="materialType">
    <name>participant</name>
  </ontologyTerm>
  <ontologyTerm source_id="EUPATH_0000738" type="materialType">
    <name>observation</name>
  </ontologyTerm>
  <ontologyTerm source_id="BFO_0000015" type="protocol">
    <name>observationprotocol</name>
  </ontologyTerm>
  <ontologyTerm parent="ENTITY" source_id="EUPATH_0015075" type="characteristicQualifier">
    <name>f4a_cur_nodrink</name>
  </ontologyTerm>
  <ontologyTerm parent="ENTITY" source_id="EUPATH_0015129" type="characteristicQualifier">
    <name>f4b_med_bmiz_f</name>
    <function>enforceYesNoForBoolean</function>
  </ontologyTerm>
</ontologymappings>
EOF
write_file("$clinEpiDir/ontologyMapping.xml", $clinEpiOntologyMapping);
my $clinEpiDateObfuscation = <<EOF;
EUPATH_0000096	3010244171	0:0:0:-3:0:0:0
EUPATH_0000738	3010244171_21jun08_out	0:0:0:-3:0:0:0
EUPATH_0000738	3010244171_21jun08	0:0:0:-3:0:0:0
EOF
my $clinEpiDateObfuscationFile = "$clinEpiDir/dateObfuscation.txt";
write_file($clinEpiDateObfuscationFile, $clinEpiDateObfuscation);
my $clinEpiT = CBIL::ISA::InvestigationSimple->new("$clinEpiDir/i_Investigation.xml", "$clinEpiDir/ontologyMapping.xml", $ontologyMappingOverride, $valueMapping, $onError, $isReporterMode, $clinEpiDateObfuscationFile, undef);

$clinEpiT->parseInvestigation;
$clinEpiT->setRowLimit(1);
is(scalar @{$clinEpiT->getStudies}, 2, "Two clinepi studies");
my ($participantsStudy, $observationsStudy) = @{$clinEpiT->getStudies};

$clinEpiT->parseStudy($participantsStudy);
$clinEpiT->dealWithAllOntologies();


is(scalar @{$participantsStudy->getNodes}, 1, "one participant");
is(scalar @{$participantsStudy->getEdges}, 0, "no edges to participant");
my @expectedNodeValues = (
  ["3010244171", "3010244171_21jun08_out"],
  ["3010244171", "3010244171_21jun08"],
);
for my $c (0..1){
  $clinEpiT->parseStudy($observationsStudy);
  $clinEpiT->dealWithAllOntologies();
  my $values = [sort map {$_->getValue()} @{$observationsStudy->getNodes}];
  is_deeply($expectedNodeValues[$c], $values, "Node values as expected");
  is(scalar @{$observationsStudy->getEdges}, 1, "one participant -> observation edge");
}


done_testing;
