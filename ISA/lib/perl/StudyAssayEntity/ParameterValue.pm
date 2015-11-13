package CBIL::ISA::StudyAssayEntity::ParameterValue;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["ProtocolApplication"];
}

sub setUnit { $_[0]->{_unit} = $_[1] }
sub getUnit { $_[0]->{_unit} }

sub setQualifier { $_[0]->{_qualifier} = $_[1] }
sub getQualifier { $_[0]->{_qualifier} }

# Reference to an OntologyEntry  object for the protocol Param
sub setProtocolParam { $_[0]->{_protocol_param} = $_[1] }
sub getProtocolParam { $_[0]->{_protocol_param} }


sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Unit");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}

sub qualifierContextMethod {
  return "addParameterValue";
}

1;
