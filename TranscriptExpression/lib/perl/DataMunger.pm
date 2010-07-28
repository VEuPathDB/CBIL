package CBIL::TranscriptExpression::DataMunger;

use strict;

use Tie::IxHash;

use CBIL::TranscriptExpression::Error;
use CBIL::TranscriptExpression::Utils;

#--------------------------------------------------------------------------------

sub getOutputFile           { $_[0]->{outputFile} }
sub setOutputFile           { $_[0]->{outputFile} = $_[1] }

sub getInputFile            { $_[0]->{inputFile} }
sub setInputFile            { $_[0]->{inputFile} = $_[1] }

sub getMainDirectory        { $_[0]->{mainDirectory} }
sub setMainDirectory        { $_[0]->{mainDirectory} = $_[1] }

sub getChecker              { $_[0]->{_checker} }
sub setChecker { 
  my ($self, $checker) = @_;

  $checker->check();

  $self->{_checker} = $checker;
}

#--------------------------------------------------------------------------------

sub new {
  my ($class, $args, $requiredParamArrayRef) = @_;


  if(my $mainDirectory = $args->{mainDirectory}) {
    chdir $mainDirectory;
  }
  else {
    CBIL::TranscriptExpression::Error->new("Main Directory was not provided")->throw();
  }

  if(ref($class) eq 'CBIL::TranscriptExpression::DataMunger') {
    CBIL::TranscriptExpression::Error->
        new("try to instantiate an abstract class:  $class")->throw();
  }

  CBIL::TranscriptExpression::Utils::checkRequiredParams($requiredParamArrayRef, $args);

  bless $args, $class; 
}

#-------------------------------------------------------------------------------

sub munge {}

#-------------------------------------------------------------------------------

sub runR {
  my ($self, $script) = @_;

  my $command = "cat $script  | R --no-save ";

  my $systemResult = system($command);

  unless($systemResult / 256 == 0) {
    CBIL::TranscriptExpression::Error->new("Error while attempting to run R:\n$command")->throw();
  }
}

#-------------------------------------------------------------------------------

sub groupListHashRef {
  my ($self, $paramValueString) = @_;

  my %rv;
  tie %rv, "Tie::IxHash";

  return \%rv unless($paramValueString);

  unless(ref($paramValueString) eq 'ARRAY') {
    die "Illegal param to method call [groupListParam].  Expected ARRAYREF";
  }

  foreach my $groupSample (@$paramValueString) {
    my ($group, $sample) = split(/\|/, $groupSample);

    push @{$rv{$group}}, $sample;
  }

  return \%rv;
}




1;
