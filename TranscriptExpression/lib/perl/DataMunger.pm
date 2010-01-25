package CBIL::TranscriptExpression::DataMunger;

use strict;

use Tie::IxHash;

use CBIL::TranscriptExpression::Error;
use CBIL::TranscriptExpression::Utils;

#--------------------------------------------------------------------------------

sub getPathToExecutable     { $_[0]->{pathToExecutable} }
sub setPathToExecutable     { $_[0]->{pathToExecutable} = $_[1] }

sub getOutputFile           { $_[0]->{outputFile} }
sub setOutputFile           { $_[0]->{outputFile} = $_[1] }

sub getBaseLogDir           { $_[0]->{baseLogDir} }
sub setBaseLogDir           { $_[0]->{baseLogDir} = $_[1] }

sub getChecker              { $_[0]->{_checker} }
sub setChecker              { $_[0]->{_checker} = $_[1] }

#--------------------------------------------------------------------------------

sub new {
  my ($class, $args, $requiredParamArrayRef) = @_;

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

  my $executable = $self->getPathToExecutable() ? $self->getPathToExecutable() : 'R';

  my $command = "cat $script  | $executable --no-save ";

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
