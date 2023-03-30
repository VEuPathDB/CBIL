package CBIL::ISA::StudyAssayEntity::MaterialEntity;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

use Data::Dumper;
sub setDescription { $_[0]->{_description} = $_[1] }
sub getDescription { $_[0]->{_description} }

sub addCharacteristic { push @{$_[0]->{_characteristics}}, $_[1] }
sub getCharacteristics {
  my ($self) = @_;

  my $chars = $self->{_characteristics};
  return [] unless($chars);

  my @rv;
  foreach my $char(@$chars) {
    if($char->isMultiValued()) {
      push @rv, $char->multiValueFactory();
    }
    else {
      push @rv, $char;
    }
  }
  return \@rv;
}

sub setMaterialType { $_[0]->{_material_type} = $_[1] }
sub getMaterialType { $_[0]->{_material_type} }

# @OVERRIDE
sub isNode { return 1}

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Characteristic", "MaterialType", "Description");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}

1;
