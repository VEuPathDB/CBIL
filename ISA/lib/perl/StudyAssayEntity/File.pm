package CBIL::ISA::StudyAssayEntity::File;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub isNode { return 1; }

sub qualifierContextMethod {
  return "addFile";
}

1;

