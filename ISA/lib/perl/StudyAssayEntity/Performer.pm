package CBIL::ISA::StudyAssayEntity::Performer;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub isNode { return 0; }

# subclasses must consider these
sub getAttributeNames {
  return [];
}

sub getParents {
  return ["ProtocolApplication"];
}


1;
