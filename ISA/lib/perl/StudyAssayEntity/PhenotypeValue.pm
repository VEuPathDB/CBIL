package CBIL::ISA::StudyAssayEntity::PhenotypeValue;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return [ "Phenotype" ];
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

sub requiresAccessionedTerm {
  return 0;
}

1;
