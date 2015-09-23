package CBIL::ISA::StudyAssayEntity::ProtocolApplication;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;


sub addParameterValue { $_[0]->{_parameter_value} = $_[1] }
sub getParameterValue { $_[0]->{_parameter_value} }

sub addPerformer { $_[0]->{_performer} = $_[1] }
sub getPerformer { $_[0]->{_performer} }

sub addDate { $_[0]->{_date} = $_[1] }
sub getDate { $_[0]->{_date} }

sub getParents {
  return ["Source", "Sample", "Extract", "LabeledExtract", "Assay", "GelElectrophoresisAssay", "MSAssay", "NMRAssay", "HybridizationAssay"];
}

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("ParameterValue", "Performer", "Date");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}


1;
