package CBIL::ISA::StudyAssayEntity::Provider;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub isNode { return 0; }

# subclasses must consider these
sub getAttributeNames {
  return [];
}

sub getParents {
  return ["Source"];
}


1;
