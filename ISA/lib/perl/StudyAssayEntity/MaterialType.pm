package CBIL::ISA::StudyAssayEntity::MaterialType;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["Source", "Sample", "Extract", "LabeledExtract" ];
}

1;
