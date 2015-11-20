package CBIL::ISA::StudyAssayEntity::Comment;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

# This qualifier is not an ontology term
sub setQualifier { $_[0]->{_qualifier} = $_[1] }
sub getQualifier { $_[0]->{_qualifier} }

sub setValue { $_[0]->{_value} = $_[1] }
sub getValue { $_[0]->{_value} }

sub new {
  my ($class, $args) = @_;
  return bless $args, $class;
}

sub qualifierContextMethod {
  return "addComment";
}

sub isNode { return 0; }

sub getAttributeNames {
  return [];
}

# Comment Can apply to any Node in StudyAssay Context
sub getParents {
  return ["Source", "Sample", "Extract", "LabeledExtract", "Assay", "HybridizationAssay", "GelElectrophoresisAssay", "MsAssay", "NmrAssay", "Scan", "Normalization", "DataTransformation", "File", "DataFile"];
}

sub hasAttributes {
  return 1;
}


1;
