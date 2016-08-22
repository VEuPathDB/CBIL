package CBIL::ISA::StudyAssayEntity::NmrAssay;
use base qw(CBIL::ISA::StudyAssayEntity::Fileable);

use strict;

sub getParents {
  return ["Sample", "Extract", "LabeledExtract"];
}

1;
