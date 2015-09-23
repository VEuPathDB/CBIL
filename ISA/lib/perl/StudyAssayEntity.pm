package CBIL::ISA::StudyAssayEntity;
use base qw(CBIL::ISA::Commentable);

use strict;


# subclasses must implement the following methods

sub getNodeType { die "All Subclasses of Node must implement getNodeType method"; }


# subclasses must consider these
sub getAttributeQualifiers {
  return ["comment"];
}

sub getParentNodes {
  return [];
}

1;
