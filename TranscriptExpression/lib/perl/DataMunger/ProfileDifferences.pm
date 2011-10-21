package CBIL::TranscriptExpression::DataMunger::ProfileDifferences;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use CBIL::TranscriptExpression::Error;

use File::Temp qw/ tempfile /;

sub getMinuendFile            { $_[0]->{minuendFile} }
sub getSubtrahendFile         { $_[0]->{subtrahendFile} }

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['outputFile',
                        'minuendFile',
                        'subtrahendFile',
                       ];

  my $self = $class->SUPER::new($args, $requiredParams);

  unless(-e $self->getMinuendFile() && -e $self->getSubtrahendFile()) {
    CBIL::TranscriptExpression::Error->("Missing subtrahend or minuend File")->throw();
  }

  return $self;
}


sub munge {
  my ($self) = @_;

  my $minuendFile = $self->getMinuendFile();
  my $subtrahendFile = $self->getSubtrahendFile();

  my $outputFile = $self->getOutputFile();

  my ($tempFh, $tempFn) = tempfile();

  my $header = 'TRUE';

  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

dat1 = read.table("$minuendFile", header=$header, sep="\\t", check.names=FALSE, row.names=1);
dat2 = read.table("$subtrahendFile", header=$header, sep="\\t", check.names=FALSE, row.names=1);

datDifference = dat1 - dat2;

output = cbind(rownames(dat1), datDifference);

write.table(output, file="$outputFile", quote=FALSE, sep="\\t", row.names=FALSE);

quit("no");
RString

  print $tempFh $rString;

  $self->runR($tempFn);
  unlink($tempFn);
}

1;