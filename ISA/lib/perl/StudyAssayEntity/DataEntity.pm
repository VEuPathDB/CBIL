package CBIL::ISA::StudyAssayEntity::DataEntity;
use base qw(CBIL::ISA::StudyAssayEntity::Fileable);

=head1

This class has been added to allow Description and Characteristics
attributes (as used in VectorBase PopBio) to be attached to "Assay"
entities.

=cut

use strict;

sub setDescription { $_[0]->{_description} = $_[1] }
sub getDescription { $_[0]->{_description} }

sub addCharacteristic { push @{$_[0]->{_characteristics}}, $_[1] }
sub getCharacteristics { $_[0]->{_characteristics}  || [] }

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Characteristic", "Description", "File");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}

1;
