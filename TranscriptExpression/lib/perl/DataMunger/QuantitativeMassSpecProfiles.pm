package CBIL::TranscriptExpression::DataMunger::QuantitativeMassSpecProfiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

use strict;

use CBIL::TranscriptExpression::Error;

use Data::Dumper;

use File::Temp qw/ tempfile /;

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['makePercentiles',
                        'profileSetName',
                        'inputFile'
                       ];

  $args->{outputFile} = $args->{inputFile};
  
  my $output = $args->{outputFile};
  
  open(FILE, "<$output");
  my $header = <FILE>;
  chomp($header);
  my $samples = [];
  push(@$samples , split('\t',$header));

  $args->{samples} = $samples;
  


  my $self = $class->SUPER::new($args, $requiredParams);

  $self->{profileSetDescription} = $self->getProfileSetName();

  return $self;
}


sub munge {
  my ($self) = @_;

  my $outputFile = $self->getOutputFile();

  my $makePercentiles = $self->getMakePercentiles;

  my ($tempFh, $tempFn) = tempfile();

  my $pctOutputFile = $outputFile . ".pct";

  my $header = 'TRUE';

  my $samples = $self->makeSamplesRString();
  
  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

if($makePercentiles) {


    dat = read.table("$outputFile", header=$header, sep="\\t", check.names=FALSE);
    dat.samples = list();
	$samples
    res = list(id=NULL, data=NULL);
    res\$id = as.vector(dat[,1]);
    groupNames = row.names(summary(dat.samples));
		
    dat\$percentile = percentileMatrix(m=dat);
	colnames(dat\$percentile) = groupNames;
    write.table(dat\$percentile, file="$pctOutputFile",quote=F,sep="\\t", row.names=res\$id);
}

quit("no");
RString

  print $tempFh $rString;

  $self->runR($tempFn);

  unlink($tempFn);

  my $doNotLoad = $self->getDoNotLoad(); 
  unless($doNotLoad){
    $self->createConfigFile();
    if($self->getIsTimeSeries() ){
      $self->createTimeSeriesConfigFile();
    }
}	
}
1;
 
