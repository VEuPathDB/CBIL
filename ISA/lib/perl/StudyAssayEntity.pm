package CBIL::ISA::StudyAssayEntity;
use base qw(CBIL::ISA::Commentable);

use strict;


# subclasses must implement the following methods
sub isNode { }

# subclasses must consider these
sub getAttributeNames {
  return ["Comment"];
}

sub getParents {
  return [];
}

1;
