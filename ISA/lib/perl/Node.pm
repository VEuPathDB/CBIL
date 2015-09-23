package CBIL::ISA::Node;
use base qw(CBIL::ISA::Commentable);

use strict;


# subclasses must implement the following methods
sub isProtocolApplicationNode { die "All Subclasses of Node must implement isProtocolApplicationNode method";}
sub getNodeType { die "All Subclasses of Node must implement getNodeType method"; }


# subclasses must consider these
sub getAttributeQualifiers {
  return ["comment"];
}

sub getParentNodes {
  return [];
}

1;
