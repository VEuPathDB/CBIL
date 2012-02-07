package CBIL::TranscriptExpression::DataMunger::Smoother;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

use strict;

use File::Temp qw/ tempfile /;

use CBIL::TranscriptExpression::Error;

use Data::Dumper;

#-------------------------------------------------------------------------------


sub new {
  my ($class, $args) = @_;

  $args->{samples} = 'PLACEHOLDER';

  my $self = $class->SUPER::new($args);

  my $samples = $self->readInputFileHeaderAsSamples();
  $self->setSamples($samples);

  return $self;
}

sub readInputFileHeaderAsSamples {
  my ($self) = @_;

  my $fn = $self->getInputFile();

  open(FILE, $fn) or die "Cannot open file $fn for reading: $!";

  my $header = <FILE>;
  chomp $header;
  close FILE;

  my @vals = split(/\t/, $header);
  
  # remove the row header column;
  shift @vals;

  return \@vals;
}



sub munge {
  my ($self) = @_;

  my $header = '-header';

  my $inputFile = $self->getInputFile();
  my $outputFile = $self->getOutputFile();

  my ($tempFh, $tempFile) = tempfile();


  my $red = $inputFile . ".red";
  my $green = $inputFile . ".green";
  my $tempRed = $tempFile . ".red";
  my $tempGreen = $tempFile . ".green";

  if($self->getHasRedGreenFiles()) {
    system("cp $red $tempRed");
    system("cp $green $tempGreen");
  }


  system("smoother.pl $inputFile $tempFile $header");

  $self->setInputFile($tempFile);
  $self->SUPER::munge();

  unlink($tempFile, $tempRed, $tempGreen);

}

1;
