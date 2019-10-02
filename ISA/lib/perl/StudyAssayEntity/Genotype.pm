package CBIL::ISA::StudyAssayEntity::Genotype;
use base qw(CBIL::ISA::StudyAssayEntity::DataEntity);

use strict;

sub setType { $_[0]->{_genotype_type} = $_[1] }
sub getType { $_[0]->{_genotype_type} }

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Type");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}


1;
