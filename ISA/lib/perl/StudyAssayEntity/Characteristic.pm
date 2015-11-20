package CBIL::ISA::StudyAssayEntity::Characteristic;
use base qw(CBIL::ISA::OntologyTermWithQualifier);

use strict;

sub getParents {
  return ["Source", "Sample", "Extract", "LabeledExtract" ];
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

sub qualifierContextMethod {
  return "addCharacteristic";
}

1;
