package CBIL::ISA::StudyAssayEntity::ArrayDataMatrixFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["HybridizationAssay"];
}

1;
