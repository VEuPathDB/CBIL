package CBIL::ISA::StudyAssayEntity::Phenotype;
use base qw(CBIL::ISA::StudyAssayEntity::DataEntity);

use strict;

sub setObservable { $_[0]->{_phenotype_observable} = $_[1] }
sub getObservable { $_[0]->{_phenotype_observable} }

sub setAttribute { $_[0]->{_phenotype_attribute} = $_[1] }
sub getAttribute { $_[0]->{_phenotype_attribute} }

sub setValue { $_[0]->{_phenotype_value} = $_[1] }
sub getValue { $_[0]->{_phenotype_value} }


sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Observable", "Attribute", "Value");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}


1;
