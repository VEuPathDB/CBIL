package CBIL::TranscriptExpression::DataMunger::QuantitativeMassSpecProfiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

use strict;

use CBIL::TranscriptExpression::Error;

use File::Temp qw/ tempfile /;

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['makePercentiles',
                        'profileSetName',
                        'inputFile'
                       ];

  $args->{outputFile} = '.';
  $args->{samples} = 'PLACEHOLDER';

  my $self = $class->SUPER::new($args, $requiredParams);

  $self->{profileSetDescription} = $self->getProfileSetName();

  return $self;
}


sub munge {
  my ($self) = @_;

  my $outputFile = $self->getInputFile();

  my $makePercentiles = $self->getMakePercentiles;

  my ($tempFh, $tempFn) = tempfile();

  my $pctOutputFile = $outputFile . ".pct";

  my $header = 'TRUE';

  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

if($makePercentiles) {


    dat = read.table("$outputFile", header=$header, sep="\\t", check.names=FALSE, row.names=1);
    dat.samples = list();
    res = list(id=NULL, data=NULL);
    res\$id = as.vector(dat[,1]);
    
    dat\$percentile = percentileMatrix(m=dat);
    write.table(dat\$percentile, file="$pctOutputFile",quote=F,sep="\\t", row.names=row.names(dat));
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
 
