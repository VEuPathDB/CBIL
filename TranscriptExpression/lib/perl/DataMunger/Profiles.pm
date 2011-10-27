package CBIL::TranscriptExpression::DataMunger::Profiles;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use File::Basename;

use CBIL::TranscriptExpression::Error;

use Data::Dumper;

use File::Temp qw/ tempfile /;

my $loadData = 1;
my $skipSecondRow = 0;
my $loadProfileElement = 1;
my $PROFILE_CONFIG_FILE_NAME = "expression_profile_config.txt";

#-------------------------------------------------------------------------------

 sub getSamples                 { $_[0]->{samples} }
 sub getDyeSwaps                { $_[0]->{dyeSwaps} }
 sub getFindMedian              { $_[0]->{findMedian} }


 sub getHasRedGreenFiles        { $_[0]->{hasRedGreenFiles} }
 sub getMakePercentiles         { $_[0]->{makePercentiles} }

 sub getDoNotLoad               { $_[0]->{doNotLoad} }

 sub getProfileSetName          { $_[0]->{profileSetName} }
 sub getProfileSetDescription   { $_[0]->{profileSetDescription} }

 sub getSourceIdType            { $_[0]->{sourceIdType} }
 sub setSourceIdType            { $_[0]->{sourceIdType} = $_[1]}

 sub getLoadProfileElement      { $_[0]->{loadProfileElement} }
 
 sub getIgnoreStdError          { $_[0]->{ignoreStdErrorEstimation} }
#-------------------------------------------------------------------------------

 # Standard Error is Set internally
 sub getMakeStandardError       { $_[0]->{_makeStandardError} }
 sub setMakeStandardError       { $_[0]->{_makeStandardError} = $_[1] }


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

  my $ignoreStdError = $self->getIgnoreStdError();

  if ($ignoreStdError == 0) {
    $self->checkMakeStandardError();
  }

  my $rFile = $self->writeRScript($samplesRString);

  $self->runR($rFile);

  system("rm $rFile");
  my $doNotLoad = $self->getDoNotLoad(); 
  unless($doNotLoad){
    $self->createConfigFile();
  }
}

sub checkMakeStandardError {
  my ($self) = @_;
  my $samplesHash = $self->groupListHashRef($self->getSamples());
  
   $self->setMakeStandardError(0);

  foreach my $group (keys %$samplesHash) {
    my $samples = $samplesHash->{$group};
    if(scalar @$samples > 1){
      $self->setMakeStandardError(1);
      last;
    }
  }
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
  my $findMedian = $self->getFindMedian() ? "TRUE" : "FALSE";

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

reorderedSamples = reorderAndGetColCentralVal(pl=dat.samples, df=dat, computeMedian=$findMedian);


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

  reorderedRedSamples = reorderAndGetColCentralVal(pl=dat.samples, df=newRedDat);
  reorderedGreenSamples = reorderAndGetColCentralVal(pl=dat.samples, df=newGreenDat);

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
  my $profileSetName = $self->getProfileSetName();
  my $profileSetDescription= $self->getProfileSetDescription();
  my $profileDataFile = $self->getOutputFile();
  my $expression_profileSetName= $profileSetName;
  my $expression_profileSetDescription = $profileSetDescription;
  my $sourceIdType = $self->getSourceIdType;
  my @baseCols = ($sourceIdType,$skipSecondRow,$loadProfileElement,);
  my @profileCols = ($profileDataFile,$expression_profileSetName,$expression_profileSetDescription,);
   
  my $mainDir = $self->getMainDirectory();
  my $PROFILE_CONFIG_FILE_LOCATION = $mainDir. "/" . $PROFILE_CONFIG_FILE_NAME;
  unless(-e $PROFILE_CONFIG_FILE_LOCATION){
   open(PCFH, "> $PROFILE_CONFIG_FILE_LOCATION") or die "Cannot open file $PROFILE_CONFIG_FILE_NAME for writing: $!"; 
  }
  else {
   open(PCFH, ">> $PROFILE_CONFIG_FILE_LOCATION") or die "Cannot open file $PROFILE_CONFIG_FILE_NAME for writing: $!";
   }
  $profileString = $self->createConfigLine('profile',\@baseCols );
  print PCFH "$profileString\n" ;
  if ($self->getMakePercentiles()) {
    $percentileString = $self->createConfigLine('pct',\@baseCols );
    print PCFH "$percentileString\n";
  }
  if ($self->getMakeStandardError()) {
    $standardErrorString = $self->createConfigLine('stderr',\@baseCols );
    print PCFH "$standardErrorString\n";
  }
  if ($self->getHasRedGreenFiles()) {
    $greenPercentileString = $self->createConfigLine('greenPct',\@baseCols );
    $redPercentileString = $self->createConfigLine('redPct',\@baseCols );
    print PCFH "$greenPercentileString\n$redPercentileString\n";
  close PCFH;
  }
}

sub createConfigLine {
  my ($self,$type,$baseCols) = @_;
  my $dataFileBase = $self->getOutputFile();
  my $profileSetName = $self->getProfileSetName();
  my $profileSetDescription = $self->getProfileSetDescription();
  my $prefix = '';
  if ($type eq 'pct') {
    $prefix = 'percentile - ';}
  elsif ($type eq 'stderr') {
    $prefix = 'standard error - ';}
  elsif ($type eq 'greenPct') {
    $prefix = 'green percentile - ';}
  elsif ($type eq 'redPct') {
    $prefix = 'red percentile - ';}
  else { $prefix = '';}
  if ($prefix) {
    $type = '.' . $type;
  }
  my $dataFile = $dataFileBase . $type;
  my $profileSetName = $prefix . $profileSetName;
  my $profileSetDescription = $prefix . $profileSetDescription;
  my @customCols = ($dataFile, $profileSetName,  $profileSetDescription);
  my @cols = push(@customCols, @$baseCols);
  my $configString = join("\t",@cols);
}
  
1;
