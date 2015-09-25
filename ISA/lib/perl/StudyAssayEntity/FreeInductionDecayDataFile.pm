package CBIL::ISA::StudyAssayEntity::FreeInductionDecayDataFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["NmrAssay"];
}

1;
