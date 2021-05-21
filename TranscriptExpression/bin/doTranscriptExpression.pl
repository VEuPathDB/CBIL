#!/usr/bin/perl

use strict;

use Getopt::Long;
use lib "$ENV{GUS_HOME}/lib/perl";
use CBIL::TranscriptExpression::XmlParser;
use CBIL::TranscriptExpression::Error;

use Data::Dumper;

my ($help, $xmlFile, $mainDirectory, $inputFile, @executableDirectory, $technologyType, $seqIdPrefix, $patch);

&GetOptions('help|h' => \$help,
            'xml_file=s' => \$xmlFile,
            'main_directory=s' => \$mainDirectory,
            'input_file=s' => \$inputFile,
            'executable_path=s' => \@executableDirectory,
            'technology_type=s' => \$technologyType,
            'seq_id_prefix=s' => \$seqIdPrefix,
            'patch' => \$patch,
           );


foreach(@executableDirectory) {
  $ENV{PATH} .= ":$_";
}

unless(-e $xmlFile) {
  &usage("Error:  xml file $xmlFile dies not exist");
}

unless(-d $mainDirectory) {
  &usage("Error:  Main Directory $mainDirectory does not exist.");
}

my $xmlParser = CBIL::TranscriptExpression::XmlParser->new($xmlFile);
my $nodes = $xmlParser->parse();

foreach my $node (@$nodes) {
  my $args = $node->{arguments};
  my $class = $node->{class};

  while ( my ($key, $value) = each(%$args) ) {
    if ($value =~m/^no$/i || $value =~m/^false$/i ) {
      $args->{ $key } = 0;
    }
    elsif ($value =~m/^yes$/i || $value =~m/^true$/i ) {
      $args->{ $key } = 1;
    }
  }

  if (defined $seqIdPrefix) { $args->{seqIdPrefix} = $seqIdPrefix; }
  if ($patch) { $args->{patch} = 1; }

  $args->{mainDirectory} = $mainDirectory;

  unless($args->{inputFile}) {
    $args->{inputFile} = $inputFile;
  }

  eval "require $class";
  CBIL::TranscriptExpression::Error->new($@)->throw() if $@;
  my $dataMunger = eval {
    $class->new($args);
  };

  CBIL::TranscriptExpression::Error->new($@)->throw() if $@;

  $dataMunger->setTechnologyType($technologyType);
  $dataMunger->munge();
}

sub usage {
  my $m = shift;

  print STDERR "$m\n\n" if($m);
  print STDERR "usage:  perl doTranscriptExpression.pl --xml_file <XML> --main_directory <DIR> [--input_file <FILE>] [--seq_id_prefix <SEQ ID PREFIX>] [--patch <use this flag for a patch update>]--help\n";
  exit;
}


1;
