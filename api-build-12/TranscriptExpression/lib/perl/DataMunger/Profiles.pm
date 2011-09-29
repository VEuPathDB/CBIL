package CBIL::TranscriptExpression::DataMunger::Profiles;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use File::Basename;

use CBIL::TranscriptExpression::Error;

use File::Temp qw/ tempfile /;

my $loadData = 1;
my $dataFileBase = 'profiles';
my $skipSecondRow = 0;
my $loadProfileElement = 1;
my $PROFILE_CONFIG_FILE_NAME = "insertExpressionProfiles.config";

#-------------------------------------------------------------------------------

 sub getSamples              { $_[0]->{samples} }
 sub getDyeSwaps             { $_[0]->{dyeSwaps} }

 sub getHasRedGreenFiles     { $_[0]->{hasRedGreenFiles} }
 sub getMakePercentiles      { $_[0]->{makePercentiles} }
 sub getMakeStandardError    { $_[0]->{makeStandardError} }
 sub getDoNotLoad            { $_[0]->{doNotLoad} }

 sub getProfileSetName          { $_[0]->{profileSetName} }
 sub getProfileSetDescription   { $_[0]->{profileSetDescription} }

 sub getSourceIdType            { $_[0]->{sourceIdType} }
 sub setSourceIdType            { $_[0]->{sourceIdType} = $_[1]}

 sub getLoadProfileElement      { $_[0]->{loadProfileElement} }
#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;
  my $sourceIdTypeDefault = 'gene';
  my $requiredParams = ['inputFile',
                        'outputFile',
                        'samples',
                        ];
  unless($args->{doNotLoad}) {
    push @$requiredParams, 'profileSetName';
    unless ($args->{sourceIdType}) {
      $args->{sourceIdType} = $sourceIdTypeDefault;
    }
    my $sourceIdType = $args->{sourceIdType};
    my $profileSetName = $args->{profileSetName};
    my $loadProfileElement = ($args->{loadProfileElement}=1) ? '' :' - Skip ApiDB.ProfileElement';
    unless($args->{profileSetDescription}) {
      $args->{profileSetDescription} = "$profileSetName - $sourceIdType $loadProfileElement";
    }
  }
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
  my $doNotLoad = $self->getDoNotLoad(); 

#  unless($doNotLoad){
    $self->createConfigFile();
#  }
}

sub writeRScript {
  my ($self, $samples) = @_;

  my $inputFile = $self->getInputFile();
  my $outputFile = $self->getOutputFile();
  my $pctOutputFile = $outputFile . ".pct";
  my $stdErrOutputFile = $outputFile . ".stderr";

  my $inputFileBase = basename($inputFile);

  my ($rfh, $rFile) = tempfile();

  my $hasDyeSwaps = $self->getDyeSwaps() ? "TRUE" : "FALSE";
  my $hasRedGreenFiles = $self->getHasRedGreenFiles() ? "TRUE" : "FALSE";
  my $makePercentiles = $self->getMakePercentiles() ? "TRUE" : "FALSE";
  my $makeStandardError = $self->getMakeStandardError() ? "TRUE" : "FALSE";

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

if($makeStandardError) {
  write.table(reorderedSamples\$stdErr, file="$stdErrOutputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id);
   }
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

sub createConfigFile{
  my ($self) = @_;
  my $profileString = '';
  my $percentileString = '';
  my $standardErrorString = '';
  my $redPercentileString = '';
  my $greenPercentileString = '';
  my $profileSetName = $self->getProfileSetName;
  my $profileSetDescription= $self->getProfileSetDescription;
  my $profileDataFile = $dataFileBase.".txt";
  my $sourceIdType = $self->getSourceIdType;
  my @profileCols = ($profileDataFile,$profileSetName,$profileSetDescription,$sourceIdType,$skipSecondRow,$loadProfileElement);
  my $mainDir = $self->getMainDirectory();
  my $PROFILE_CONFIG_FILE_LOCATION = $mainDir.$PROFILE_CONFIG_FILE_NAME;
  open(PCFH, "> $PROFILE_CONFIG_FILE_LOCATION") or die "Cannot open file $PROFILE_CONFIG_FILE_NAME for writing: $!";
  $profileString = join("\t",@profileCols);
  print PCFH "$profileString\n";
  if ($self->getMakePercentiles()) {
    my $percentileDataFile = $profileDataFile.".pct";
    my @percentileCols = @profileCols;
    $percentileCols[0] = $percentileDataFile;
    $percentileString = join("\t",@percentileCols);
    print PCFH "$percentileString\n";
  }
  if ($self->getMakeStandardError()) {
    my $standardErrorDataFile = $profileDataFile.".stderr";
    my @standardErrorCols = @profileCols;
    $standardErrorCols[0] = $standardErrorDataFile;
    $standardErrorString = join("\t",@standardErrorCols);
    print PCFH "$standardErrorString\n";
  }
  if ($self->getHasRedGreenFiles()) {
    my $greenDataFile = $profileDataFile.".greenPct";
    my @greenCols = @profileCols;
    $greenCols[0] = $greenDataFile;
    $greenPercentileString = join("\t",@greenCols);
    print PCFH "$greenPercentileString\n";
    my $redDataFile = $profileDataFile.".redPct";
    my @redCols = @profileCols;
    $redCols[0] = $redDataFile;
    $redPercentileString = join("\t",@redCols);
    print PCFH "$redPercentileString\n";
  close PCFH;
  }

  
}
1;
