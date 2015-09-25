package CBIL::ISA::StudyAssayEntity::FactorValue;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub setUnit { $_[0]->{_unit} = $_[1] }
sub getUnit { $_[0]->{_unit} }

sub setQualifier { $_[0]->{_qualifier} = $_[1] }
sub getQualifier { $_[0]->{_qualifier} }

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Unit");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}

sub qualifierContextMethod {
  return "addFactorValue";
}


1;
