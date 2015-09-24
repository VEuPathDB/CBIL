package CBIL::ISA::StudyAssayEntity::Source;
use base qw(CBIL::ISA::StudyAssayEntity::MaterialEntity)

use strict;

sub setProvider { $_[0]->{_provider} = $_[1] }
sub getProvider { $_[0]->{_provider} }

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Provider");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}

1;
