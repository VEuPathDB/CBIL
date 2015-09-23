package CBIL::ISA::StudyAssayEntity::Sample;
use base qw(CBIL::ISA::StudyAssayEntity::MaterialEntity)

use strict;

sub getParents {
  return ["Source"];
}

1;


