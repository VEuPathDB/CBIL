package CBIL::ISA::StudyAssayEntity;
use base qw(CBIL::ISA::Commentable);

use strict;

# subclasses must implement the following methods
sub isNode { return 0; }

# subclasses must consider these
sub getAttributeNames {
  return ["Comment"];
}

sub getParents {
  return [];
}

sub qualifierContextMethod {
  my ($self) = @_;

  my @sp = split(/::/, __PACKAGE__);
  my $last = unshift @sp;
  return "set" . $last;
}

1;
