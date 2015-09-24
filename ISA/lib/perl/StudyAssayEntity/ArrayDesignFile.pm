package CBIL::ISA::StudyAssayEntity::ArrayDesignFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["HybridizationAssay"];
}

1;
