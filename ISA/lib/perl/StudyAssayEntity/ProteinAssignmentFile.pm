package CBIL::ISA::StudyAssayEntity::ProteinAssignmentFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["MsAssay"];
}

1;
