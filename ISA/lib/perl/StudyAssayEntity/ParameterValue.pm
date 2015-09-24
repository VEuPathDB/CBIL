package CBIL::ISA::StudyAssayEntity::ParameterValue;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["ProtocolApplication"];
}

sub setUnit { $_[0]->{_unit} = $_[1] }
sub getUnit { $_[0]->{_unit} }

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Unit");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}

1;
