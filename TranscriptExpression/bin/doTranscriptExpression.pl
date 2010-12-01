#!/usr/bin/perl

use strict;

use Getopt::Long;

use CBIL::TranscriptExpression::XmlParser;
use CBIL::TranscriptExpression::Error;

my ($help, $xmlFile, $mainDirectory, $inputFile, @executableDirectory);

&GetOptions('help|h' => \$help,
            'xml_file=s' => \$xmlFile,
            'main_directory=s' => \$mainDirectory,
            'input_file=s' => \$inputFile,
            'executable_path=s' => \@executableDirectory,
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

  $args->{mainDirectory} = $mainDirectory;

  unless($args->{inputFile}) {
    $args->{inputFile} = $inputFile;
  }

  eval "require $class";

  my $dataMunger = eval {
    $class->new($args);
  };

  CBIL::TranscriptExpression::Error->new($@)->throw() if $@;

  $dataMunger->munge();
}

sub usage {
  my $m = shift;

  print STDERR "$m\n\n" if($m);
  print STDERR "usage:  perl doTranscriptExpression.pl --xml_file <XML> --main_directory <DIR> [--input_file <FILE>] --help\n";
  exit;
}


1;
