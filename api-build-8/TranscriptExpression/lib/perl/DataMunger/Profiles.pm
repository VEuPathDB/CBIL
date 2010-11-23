package CBIL::TranscriptExpression::DataMunger::Profiles;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use File::Basename;

use CBIL::TranscriptExpression::Error;

use File::Temp qw/ tempfile /;


#-------------------------------------------------------------------------------

sub getSamples              { $_[0]->{samples} }
sub getDyeSwaps             { $_[0]->{dyeSwaps} }
sub getHasRedGreenFiles     { $_[0]->{hasRedGreenFiles} }
sub getMakePercentiles      { $_[0]->{makePercentiles} }

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

sub writeRScript {
  my ($self, $samples) = @_;

  my $inputFile = $self->getInputFile();
  my $outputFile = $self->getOutputFile();
  my $pctOutputFile = $outputFile . ".pct";

  my $inputFileBase = basename($inputFile);

  my ($rfh, $rFile) = tempfile();

  my $hasDyeSwaps = $self->getDyeSwaps() ? "TRUE" : "FALSE";
  my $hasRedGreenFiles = $self->getHasRedGreenFiles() ? "TRUE" : "FALSE";
  my $makePercentiles = $self->getMakePercentiles() ? "TRUE" : "FALSE";

  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

dat = read.table("$inputFile", header=T, sep="\\t", check.names=FALSE);

dat.samples = list();
dye.swaps = vector();
$samples
#-----------------------------------------------------------------------

if($hasDyeSwaps) {
  dat = mOrInverse(df=dat, ds=dye.swaps);
}

reorderedSamples = reorderAndAverageColumns(pl=dat.samples, df=dat);
write.table(reorderedSamples\$data, file="$outputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id);

if($hasRedGreenFiles) {
  redDat = read.table(paste("$inputFile", ".red", sep=""), header=T, sep="\\t", check.names=FALSE);
  greenDat = read.table(paste("$inputFile", ".green", sep=""), header=T, sep="\\t", check.names=FALSE);

  if($hasDyeSwaps) {
    newRedDat = swapColumns(t1=redDat, t2=greenDat, ds=dye.swaps);
    newGreenDat = swapColumns(t1=greenDat, t2=redDat, ds=dye.swaps);
  } else {
    newRedDat = redDat;
    newGreenDat = greenDat;
  }

  reorderedRedSamples = reorderAndAverageColumns(pl=dat.samples, df=newRedDat);
  reorderedGreenSamples = reorderAndAverageColumns(pl=dat.samples, df=newGreenDat);

  write.table(reorderedRedSamples\$data, file=paste("$outputFile", ".red", sep=""), quote=F,sep="\\t",row.names=reorderedRedSamples\$id);
  write.table(reorderedGreenSamples\$data, file=paste("$outputFile", ".green", sep=""), quote=F,sep="\\t",row.names=reorderedGreenSamples\$id);
}

if($makePercentiles) {
  if($hasRedGreenFiles) {
    reorderedRedSamples\$percentile = percentileMatrix(m=reorderedRedSamples\$data);
    reorderedGreenSamples\$percentile = percentileMatrix(m=reorderedGreenSamples\$data);

    write.table(reorderedRedSamples\$percentile, file=paste("$outputFile", ".redPct", sep=""), quote=F,sep="\\t",row.names=reorderedRedSamples\$id);
    write.table(reorderedGreenSamples\$percentile, file=paste("$outputFile", ".greenPct", sep=""), quote=F,sep="\\t",row.names=reorderedGreenSamples\$id);
  } else {
    reorderedSamples\$percentile = percentileMatrix(m=reorderedSamples\$data);
    write.table(reorderedSamples\$percentile, file="$pctOutputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id);
  }
}

quit("no");
RString


  print $rfh $rString;

  close $rfh;

  return $rFile;
}

sub makeSamplesRString {
  my ($self) = @_;

  my $samplesHash = $self->groupListHashRef($self->getSamples());
  my $dyeSwapsHash = $self->groupListHashRef($self->getDyeSwaps());

  my $rv = "";

  # this is an ordered hash
  foreach my $group (keys %$samplesHash) {
    my $samples = $samplesHash->{$group};

    $rv .= "dat.samples[[\"$group\"]] = c(" . join(',', map { "\"$_\""} @$samples ) . ");\n\n";
  }

  my $n = 1;
  foreach my $dyeSwap (keys %$dyeSwapsHash) {
    $rv .= "dye.swaps[$n] = \"$dyeSwap\";\n\n";
    $n++;
  }

  return $rv;
}


1;
