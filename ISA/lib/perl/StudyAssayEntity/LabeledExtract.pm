package CBIL::ISA::StudyAssayEntity::LabeledExtract;
use base qw(CBIL::ISA::StudyAssayEntity::MaterialEntity);

use strict;

sub setLabel { $_[0]->{_label} = $_[1] }
sub getLabel { $_[0]->{_label} }


sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Label");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}


sub getParents {
  return ["Extract"];
}

1;
