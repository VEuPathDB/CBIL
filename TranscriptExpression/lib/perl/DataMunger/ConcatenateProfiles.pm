package CBIL::TranscriptExpression::DataMunger::ConcatenateProfiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

use strict;

use CBIL::TranscriptExpression::Error;

use File::Temp qw/ tempfile /;

sub getFileOne            { $_[0]->{fileOne} }
sub getFileTwo            { $_[0]->{fileTwo} }

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['outputFile',
                        'fileOne',
                        'fileTwo',
                        'profileSetName'
                       ];

  $args->{inputFile} = '.';
  $args->{samples} = 'PLACEHOLDER';

  my $self = $class->SUPER::new($args, $requiredParams);

  unless(-e $self->getFileOne() && -e $self->getFileTwo()) {
    CBIL::TranscriptExpression::Error->("Missing Required File")->throw();
  }

  $self->{profileSetDescription} = $self->getProfileSetName();

  return $self;
}


sub munge {
  my ($self) = @_;

  my $fileOne = $self->getFileOne();
  my $fileTwo = $self->getFileTwo();

  my $outputFile = $self->getOutputFile();

  my $outputFileTemp = $outputFile . ".tmp";

  my ($tempFh, $tempFn) = tempfile();

  my $header = 'TRUE';

  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

dat1 = read.table("$fileOne", header=$header, sep="\\t", check.names=FALSE, row.names=1);
dat2 = read.table("$fileTwo", header=$header, sep="\\t", check.names=FALSE, row.names=1);

if(ncol(dat1) != ncol(dat2) || sum(colnames(dat1) == colnames(dat2)) != ncol(dat1) ) {
  stop("Different Columns in input files ... cannot concatenate rows");
}

output = rbind(dat1, dat2)
colnames(output)[1] = paste("ID\\t", colnames(output)[1], sep="");

write.table(output, file="$outputFileTemp", quote=FALSE, sep="\\t", row.names=TRUE);

quit("no");
RString

  print $tempFh $rString;

  $self->runR($tempFn);

  # Now that we have concatenated these together ... make the profiles

  $self->setInputFile($outputFileTemp);
  my $samples = $self->readInputFileHeaderAsSamples(); 
  $self->setSamples($samples);

  $self->SUPER::munge();

  unlink($tempFn, $outputFileTemp);
}

1;
