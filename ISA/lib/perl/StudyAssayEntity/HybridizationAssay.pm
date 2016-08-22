package CBIL::ISA::StudyAssayEntity::HybridizationAssay;
use base qw(CBIL::ISA::StudyAssayEntity::Fileable);

use strict;

sub getParents {
  return ["LabeledExtract"];
}

1;
