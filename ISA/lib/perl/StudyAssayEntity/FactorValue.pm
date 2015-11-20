package CBIL::ISA::StudyAssayEntity::FactorValue;
use base qw(CBIL::ISA::OntologyTermWithQualifier);

use strict;

sub setUnit { $_[0]->{_unit} = $_[1] }
sub getUnit { $_[0]->{_unit} }

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("Unit");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}

sub qualifierContextMethod {
  return "addFactorValue";
}

# Comment Can apply to any Node in StudyAssay Context
sub getParents {
  return ["Source", "Sample", "Extract", "LabeledExtract", "Assay", "HybridizationAssay", "GelElectrophoresisAssay", "MsAssay", "NmrAssay", "Scan", "Normalization", "DataTransformation", "File", "DataFile"];
}


1;
