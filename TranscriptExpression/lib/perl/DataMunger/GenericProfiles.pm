package CBIL::TranscriptExpression::DataMunger::GenericProfiles;
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
  
  unless ($args->{isLogged}) {
    $args->{isLogged} = 0;
  }

  my $mainDirectory = $args->{mainDirectory};

  open(FILE, "$mainDirectory/$output") || die "Cannot open file $output for reading $!";
  my $header = <FILE>;
  chomp($header);
  my @samples = split('\t',$header);

  shift(@samples);
  close(FILE);

  my @uniq= ();
  my %seen = ( );
  foreach my $item (@samples) {
    push(@uniq, $item) unless $seen{$item}++;
  }
  unless (scalar @samples == scalar(@uniq)){
    die "sample names must be unique, average samples with the profiles step class before calling this step class";
  }
  $args->{samples} = \@samples;


  my $self = $class->SUPER::new($args, $requiredParams);

  $self->{profileSetDescription} = $self->getProfileSetName();

  return $self;
}


sub munge {
  my ($self) = @_;

  my $inputFile = $self->getOutputFile();
  my $outputFile = $self->getOutputFile();

  my $makePercentiles = $self->getMakePercentiles;

  my ($tempFh, $tempFn) = tempfile();

  my $pctOutputFile = $outputFile . ".pct";

  my $header = 'TRUE';

  my $samples = $self->makeSamplesRString();

  
  my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/profile_functions.R");

if($makePercentiles) {

    dat = read.delim("$outputFile", header=$header, sep="\\t", check.names=FALSE);

   dat.samples = list();
	$samples

    reorderedSamples = reorderAndGetColCentralVal(pl=dat.samples, df=dat);

    reorderedSamples\$percentile = percentileMatrix(m=reorderedSamples\$data);
    write.table(reorderedSamples\$percentile, file="$pctOutputFile",quote=F,sep="\\t",row.names=reorderedSamples\$id, col.names=NA);
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
      # TODO:  Write param for is Time Series
      #$self->createTimeSeriesConfigFile();
    }
}	
}
1;
 
