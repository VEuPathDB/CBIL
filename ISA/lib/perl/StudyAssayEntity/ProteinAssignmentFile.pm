package CBIL::ISA::StudyAssayEntity::ProteinAssignmentFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["MSAssay"];
}

1;
