package CBIL::ISA::StudyAssayEntity::Extract;
use base qw(CBIL::ISA::StudyAssayEntity::MaterialEntity);

use strict;

sub getParents {
  return ["Sample"];
}

1;
