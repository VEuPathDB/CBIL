#!/usr/bin/perl

use strict;

use Getopt::Long;

use CBIL::TranscriptExpression::XmlParser;
use CBIL::TranscriptExpression::Error;

my ($help, $xmlFile);

&GetOptions('help|h' => \$help,
            'xml_file=s' => \$xmlFile,
           );

unless($xmlFile) {
  &usage("Error:  xml file required.");
}

my $xmlParser = CBIL::TranscriptExpression::XmlParser->new($xmlFile);
my $nodes = $xmlParser->parse();

foreach my $node (@$nodes) {
  my $args = $node->{arguments};
  my $class = $node->{class};

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
  print STDERR "usage:  perl doTranscriptExpression.pl --xml_file <XML> --help\n";
  exit;
}


1;
