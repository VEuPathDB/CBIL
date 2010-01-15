package CBIL::TranscriptExpression::DataMunger;

use strict;

use Tie::IxHash;

use CBIL::TranscriptExpression::Error;

sub new {
  my ($class, $args, $requiredParamArrayRef) = @_;

  if(ref($class) eq 'CBIL::TranscriptExpression::DataMunger') {
    CBIL::TranscriptExpression::Error->
        new("try to instantiate an abstract class:  $class")->throw();
  }

  if($requiredParamArrayRef) {
    foreach my $param (@$requiredParamArrayRef) {
      unless($args->{$param}) {
        CBIL::TranscriptExpression::Error->new("Parameter [$param] is missing in the xml file for $class")->throw();
      }
    }
  }

  bless $args, $class; 
}

sub munge {}

sub headerIndexHashRef {
  my ($self, $headerString, $delRegex)  = @_;

  my %rv;

  my @a = split($delRegex, $headerString);
  for(my $i = 0; $i < scalar @a; $i++) {
    my $value = $a[$i];

    $rv{$value} = $i;
  }

  return \%rv;
}

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
