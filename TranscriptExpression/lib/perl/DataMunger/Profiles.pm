package CBIL::TranscriptExpression::DataMunger::Profiles;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use File::Basename;

use CBIL::TranscriptExpression::Error;

#-------------------------------------------------------------------------------

sub getInputFile            { $_[0]->{inputFile} }
sub getOutputFile           { $_[0]->{outputFile} }
sub getSamples              { $_[0]->{samples} }
sub getPathToExecutable     { $_[0]->{pathToExecutable} }

#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['inputFile',
                        'outputFile',
                        'samples',
                        ];

  my $self = $class->SUPER::new($args, $requiredParams);

  my $inputFile = $args->{inputFile};
  unless(-e $inputFile) {
    CBIL::TranscriptExpression::Error->new("input file $inputFile does not exist")->throw();
  }

  return $self;
}


sub munge {
  my ($self) = @_;

  my $samplesRString = $self->makeSamplesRString();

  my $rFile = $self->writeRScript($samplesRString);

  $self->runR($rFile);

  system("rm $rFile");
}


sub runR {
  my ($self, $script) = @_;

  my $executable = $self->getPathToExecutable() ? $self->getPathToExecutable() : 'R';

  my $command = "cat $script  | $executable --no-save ";

  my $systemResult = system($command);

  unless($systemResult / 256 == 0) {
    CBIL::TranscriptExpression::Error->new("Error while attempting to run R:\n$command")->throw();
  }
}

sub writeRScript {
  my ($self, $samples) = @_;

  my $inputFile = $self->getInputFile();
  my $outputFile = $self->getOutputFile();
  my $pctOutputFile = $outputFile . ".pct";

  my $inputFileBase = basename($inputFile);
  my $rFile = "/tmp/$inputFileBase.R";

  open(RCODE, "> $rFile") or die "Cannot open $rFile for writing:$!";

  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

dat = read.table("$inputFile", header=T, sep="\\t");

dat.samples = list();
$samples
#-----------------------------------------------------------------------
reorderedSamples = reorderAndAverageColumns(pl=dat.samples, df=dat);
reorderedSamples\$percentile = percentileMatrix(m=reorderedSamples\$data);

write.table(reorderedSamples\$data, file="$outputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id);
write.table(reorderedSamples\$percentile, file="$pctOutputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id);

quit("no");
RString


  print RCODE $rString;

  close RCODE;

  return $rFile;
}

sub makeSamplesRString {
  my ($self) = @_;

  my $samplesHash = $self->groupListHashRef($self->getSamples());

  my $rv = "";

  # this is an ordered hash
  foreach my $group (keys %$samplesHash) {
    my $samples = $samplesHash->{$group};

    $rv .= "dat.samples[[\"$group\"]] = c(" . join(',', map { "\"$_\""} @$samples ) . ");\n";
  }
  return $rv;
}


1;
