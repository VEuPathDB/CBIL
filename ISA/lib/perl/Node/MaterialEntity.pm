package CBIL::ISA::Node::MaterialEntity;
use base qw(CBIL::ISA::Node);

use strict;

sub setDescription { $_[0]->{_description} = $_[1] }
sub getDescription { $_[0]->{_description} }

sub addCharacteristic { push @{$_[0]->{_characteristics}}, $_[1] }
sub getCharacteristics { $_[0]->{_characteristics} }

sub setMaterialType { $_[0]->{_description} = $_[1] }
sub getMaterialType { $_[0]->{_description} }





sub getAttributeQualifiers {
  my ($self) = @_;

  my @attributeQualifiers = ("characteristics", "material_type", "description");

  my $attrs = $self->SUPER::getAttributeQualifiers();

  push @{$attrs}, @attributeQualifiers;
}

1;
