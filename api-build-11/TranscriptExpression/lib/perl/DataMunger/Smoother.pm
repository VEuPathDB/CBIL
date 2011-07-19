package CBIL::TranscriptExpression::DataMunger::Smoother;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use CBIL::TranscriptExpression::Error;

#-------------------------------------------------------------------------------

sub getHasHeader { $_[0]->{hasHeader} }
sub setHasHeader { $_[0]->{hasHeader} = $_[1] }

#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['inputFile',
                        'outputFile',
                        ];

  my $self = $class->SUPER::new($args, $requiredParams);

  my $inputFile = $args->{inputFile};
  unless(-e $inputFile) {
    CBIL::TranscriptExpression::Error->new("input file $inputFile does not exist")->throw();
  }

  my $hasHeader = $args->{hasHeader};

  if(lc($hasHeader) eq 'true') {
    $self->setHasHeader(1);
  }
  elsif(lc($hasHeader) eq 'false') { }
  else {
    CBIL::TranscriptExpression::Error->new("hasHeader arg must be specified as 'true' or 'false'")->throw();
  }

  return $self;
}


sub munge {
  my ($self) = @_;

  my $header = defined($self->getHasHeader()) ? '-header' : '';

  my $inputFile = $self->getInputFile();
  my $outputFile = $self->getOutputFile();

  system("smoother.pl $inputFile $outputFile $header");
}

1;
