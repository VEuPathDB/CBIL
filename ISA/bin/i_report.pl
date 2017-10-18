#!/usr/bin/perl

use strict;
use lib "$ENV{GUS_HOME}/lib/perl";

use CBIL::ISA::InvestigationSimple;

use Getopt::Long;

use Data::Dumper;

my ($help, $investigationFile, $ontologyMappingFile, $ontologyMappingOverrideFile, $valueMappingFile);

&GetOptions('help|h' => \$help,
            'investigation_file=s' => \$investigationFile,
            'ontology_mapping_file=s' => \$ontologyMappingFile,
            'ontology_mapping_override_file=s' => \$ontologyMappingOverrideFile,
            'value_map_file=s' => \$valueMappingFile
    );


unless(-e $investigationFile && -e $ontologyMappingFile && -e $valueMappingFile) {
  die "usage:  i_report --investigation_file <XML> --ontology_mapping_file <XML> --value_map_file <TAB> [--ontology_mapping_override_file <XML>]";
}

my %hash;

my $investigation = CBIL::ISA::InvestigationSimple->new($investigationFile, $ontologyMappingFile, $ontologyMappingOverrideFile , $valueMappingFile, 1);

eval {
  $investigation->parseInvestigation();
};
if($@) {
  die $@;
}

my $studies = $investigation->getStudies();

foreach my $study (@$studies) {

  while($study->hasMoreData()) {

    eval {
      $investigation->parseStudy($study);
      $investigation->dealWithAllOntologies();
    };
    if($@) {
      die $@;
    }

    my $nodes = $study->getNodes();

    foreach my $node (@$nodes) {
      if($node->hasAttribute("MaterialType")) {


        my $characteristics = $node->getCharacteristics();

        foreach my $characteristic (@$characteristics) {

          my $qualifier = $characteristic->getQualifier();
          my $altQualifier = $characteristic->getAlternativeQualifier();

          my $value = $characteristic->getValue();

          next if(scalar keys %{$hash{$qualifier}->{$altQualifier}} > 19);
          next unless $value;

          $hash{$qualifier}->{$altQualifier}->{$value}++;
        }
      }
    }
  }
}



foreach my $qualifier (keys %hash) {
  foreach my $alt (keys %{$hash{$qualifier}}) {
    print "QUALIFIER=$qualifier\n";
    print "  COLUMN=$alt\n";
    foreach my $value (keys %{$hash{$qualifier}->{$alt}}) {
      print "    $value\n";
    }
  }
}



1;
