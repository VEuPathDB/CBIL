package CBIL::ISA::Node;

use strict;

sub new {
  my $class = shift;
  return bless {}, $class;
}

sub setNodeType { $_[0]->{_node_type} = $_[1] }
sub getNodeType { $_[0]->{_node_type} }

sub setMaterialType { $_[0]->{_material_type} = $_[1] }
sub getMaterialType { $_[0]->{_material_type} }

sub setProvider { $_[0]->{_provider} = $_[1] }
sub getProvider { $_[0]->{_provider} }

sub setDescription { $_[0]->{_description} = $_[1] }
sub getDescription { $_[0]->{_description} }

sub addCharacteristic { push @{$_[0]->{_characteristics}}, $_[1] }
sub getCharacteristics { $_[0]->{_characteristics} }

1;
