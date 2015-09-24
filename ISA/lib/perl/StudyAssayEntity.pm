package CBIL::ISA::StudyAssayEntity;
use base qw(CBIL::ISA::Commentable);

use strict;

use Data::Dumper;
use Scalar::Util qw(blessed);

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

  my $className = blessed($self);
  my @sp = split(/::/, $className);


  my $last = pop @sp;

  print STDERR "LAST=$last\n";
  return "set" . $last;
}

sub getValue { $_[0]->{_value} }

sub hasAttributes {
  return scalar @{$_[0]->getAttributeNames()};
}

1;
