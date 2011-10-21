package CBIL::TranscriptExpression::DataMunger::Standardization;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);
use strict;

use Data::Dumper;
use File::Temp qw/ tempfile /;
use CBIL::TranscriptExpression::Error;

#-------------------------------------------------------------------------------

sub getRefColName            { $_[0]->{refColName} }

#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['inputFile'];

  my $self = $class->SUPER::new($args,$requiredParams);

  my $inputFile = $args->{inputFile};

  unless(-e $inputFile) {
    CBIL::TranscriptExpression::Error->new("input file $inputFile does not exist")->throw();
  }
  return $self;
}

sub munge {
  my ($self) = @_;

  $self->SUPER::munge();

  my $rFile = $self->writeStdRScript();
  $self->runR($rFile);

  system("rm $rFile");
}

sub writeStdRScript {
  my ($self) = @_;

  my $inputFile = $self->getOutputFile();
  my $outputFile = $self->getOutputFile();
  my $refColName = $self->getRefColName();

  my ($rfh, $rFile) = tempfile();
  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

dat = read.table("$inputFile", header=T, sep="\\t", check.names=FALSE);
standardizedProfiles = standardizeProfiles(df=dat, refColName=$refColName);
write.table(standardizedProfiles\$data, file="$outputFile",quote=F,sep="\\t",row.names=standardizedProfiles\$id);

quit("no");
RString


  print $rfh $rString;
  close $rfh;
  return $rFile;
}


1;
