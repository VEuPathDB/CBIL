package CBIL::TranscriptExpression::DataMunger::Profiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Loadable);

use strict;

use File::Basename;

use CBIL::TranscriptExpression::Error;

use Data::Dumper;

use File::Temp qw/ tempfile /;

my $SKIP_SECOND_ROW = 0;
my $LOAD_PROFILE_ELEMENT = 1;
my $PROFILE_CONFIG_FILE_NAME = "insert_study_results_config.txt";

#-------------------------------------------------------------------------------

 sub getSamples                 { $_[0]->{samples} }
 sub setSamples                 { $_[0]->{samples} = $_[1] }

 sub getDyeSwaps                { $_[0]->{dyeSwaps} }
 sub getFindMedian              { $_[0]->{findMedian} }
 sub getPercentileChannel       { $_[0]->{percentileChannel} }

 sub getIsLogged                { $_[0]->{isLogged} }
 sub setIsLogged                { $_[0]->{isLogged} = $_[1]}

 sub getBase                    { $_[0]->{Base} }
 sub setBase                    { $_[0]->{Base} = $_[1]}

 sub getHasRedGreenFiles        { $_[0]->{hasRedGreenFiles} }
 sub getMakePercentiles         { $_[0]->{makePercentiles} }

 sub getIsTimeSeries            { $_[0]->{isTimeSeries} }
 sub getMappingFile             { $_[0]->{mappingFile} }

 sub setPercentileSetPrefix      { $_[0]->{percentileSetPrefix} = $_[1]}

 sub getSourceIdType            { $_[0]->{sourceIdType} }
 sub setSourceIdType            { $_[0]->{sourceIdType} = $_[1]}

sub getIgnoreStdError          { $_[0]->{ignoreStdErrorEstimation} }
#-------------------------------------------------------------------------------

 # Standard Error is Set internally
 sub getMakeStandardError       { $_[0]->{_makeStandardError} }
 sub setMakeStandardError       { $_[0]->{_makeStandardError} = $_[1] }


sub new {
  my ($class, $args, $subclassRequiredParams) = @_;

  my $sourceIdTypeDefault = 'transcript';

  my %requiredParams = ('inputFile', undef,
                        'outputFile', undef,
                        'samples', undef,
                        );

  if($subclassRequiredParams) {
    foreach(@$subclassRequiredParams) {
      $requiredParams{$_}++;
    }
  }

  my @requiredParams = keys %requiredParams;

  unless ($args->{sourceIdType}) {
    $args->{sourceIdType} = $sourceIdTypeDefault;
  }

  if ($args->{isTimeSeries} && $args->{hasRedGreenFiles} && !$args->{percentileChannel}) {
    CBIL::TranscriptExpression::Error->new("Must specify percentileChannel for two channel time series experiments")->throw();
  }
  my $self = $class->SUPER::new($args, \@requiredParams);

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

    if($self->getIsTimeSeries() ){
      # TODO:  Need protocolparam for PercentileChannel and is time series
    }
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
write.table(reorderedSamples\$data, file="$outputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id, col.names=NA);

if($makeStandardError) {
  write.table(reorderedSamples\$stdErr, file="$stdErrOutputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id, col.names=NA);
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

  write.table(reorderedRedSamples\$data, file=paste("$outputFile", ".red", sep=""), quote=F,sep="\\t",row.names=reorderedRedSamples\$id, col.names=NA);
  write.table(reorderedGreenSamples\$data, file=paste("$outputFile", ".green", sep=""), quote=F,sep="\\t",row.names=reorderedGreenSamples\$id, col.names=NA);
}

if($makePercentiles) {
  if($hasRedGreenFiles) {
    reorderedRedSamples\$percentile = percentileMatrix(m=reorderedRedSamples\$data);
    reorderedGreenSamples\$percentile = percentileMatrix(m=reorderedGreenSamples\$data);

    write.table(reorderedRedSamples\$percentile, file=paste("$outputFile", ".redPct", sep=""), quote=F,sep="\\t",row.names=reorderedRedSamples\$id, col.names=NA);
    write.table(reorderedGreenSamples\$percentile, file=paste("$outputFile", ".greenPct", sep=""), quote=F,sep="\\t",row.names=reorderedGreenSamples\$id, col.names=NA);
  } else {
    reorderedSamples\$percentile = percentileMatrix(m=reorderedSamples\$data);
    write.table(reorderedSamples\$percentile, file="$pctOutputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id, col.names=NA);
  }
}

### Here we make individual files
### Header names match gus4 results tables

  samplesDir = ".$outputFile";
  dir.create(samplesDir);

 for(i in 1:ncol(reorderedSamples\$data)) {
   sampleId = colnames(reorderedSamples\$data)[i];

   sample = as.matrix(reorderedSamples\$data[,i]);
   colnames(sample)= c("value");

   if($makeStandardError) {
     stdErrSample = as.matrix(reorderedSamples\$stdErr[,i]);
     colnames(stdErrSample)= c("standard_error");
     
     sample = cbind(sample, stdErrSample);
   }


   if($makePercentiles) {
     if($hasRedGreenFiles) {
       redPctSample = as.matrix(reorderedRedSamples\$data[,i]);
       colnames(redPctSample)= c("percentile_channel1");
       sample = cbind(sample, redPctSample);

       greenPctSample = as.matrix(reorderedGreenSamples\$data[,i]);
       colnames(greenPctSample)= c("percentile_channel2");
       sample = cbind(sample, greenPctSample);

     } else {

       pctSample = as.matrix(reorderedSamples\$percentile[,i]);
       colnames(pctSample)= c("percentile");
       sample = cbind(sample, pctSample);
     }
   }

   write.table(sample, file=paste(samplesDir, "/", sampleId, sep=""),quote=F,sep="\\t",row.names=reorderedSamples\$id, col.names=NA);
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
