package CBIL::ISA::StudyAssayEntity::Assay;
use base qw(CBIL::ISA::StudyAssayEntity::DataEntity CBIL::ISA::StudyAssayEntity::Fileable);

use strict;


sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ();

  my $attrs1 = $self->CBIL::ISA::StudyAssayEntity::DataEntity::getAttributeNames();
  my $attrs2 = $self->CBIL::ISA::StudyAssayEntity::Fileable::getAttributeNames();
  my $attrs = [ @$attrs1, @$attrs2 ];

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}


1;
