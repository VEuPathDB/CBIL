package CBIL::ISA::StudyAssayEntity;
use base qw(CBIL::ISA::Commentable);

use strict;

use Data::Dumper;
use Scalar::Util qw(blessed);

# subclasses must implement the following methods
sub isNode { return 0; }

# subclasses must consider these
sub getAttributeNames {
  my ($self) = @_;

  if($self->isNode()) {
    return ["Comment", "FactorValue"];
  }

  return ["Comment"];
}

sub getParents {
  return [];
}

sub qualifierContextMethod {
  my ($self) = @_;

  return "set" . $self->getEntityName();
}

sub getValue { $_[0]->{_value} }

sub hasAttributes {
  return scalar @{$_[0]->getAttributeNames()};
}


sub hasAttribute {
  my ($self, $attr) = @_;

  my $attributes = $self->getAttributeNames();
  foreach my $possible (@$attributes) {
    return 1 if($attr eq $possible);
  }
  return 0;
}

sub getEntityName {
  my ($self) = @_;

  my $className = blessed($self);
  my @sp = split(/::/, $className);

  return pop @sp;
}


# For Node Entities do the simple check that the value is the same
#  This requires the author of the isatab applied the Node Characteristics correctly
#  All other entity types are attributes and should not be thought of as the same entity
sub equals {
  my ($self, $obj) = @_;

  if($self->isNode() && $self->getEntityName() eq $obj->getEntityName() && $self->getValue() eq $obj->getValue()) {
    return 1;
  }
  return 0;
}


sub addFactorValue {
  my ($self, $factorValue) = @_;

  if($self->isNode()) {
    push @{$self->{_factor_values}}, $factorValue;
  }
  else {
    die "Cannot apply factor value to non node entity";
  }
}
sub getFactorValues { $_[0]->{_factor_values}  || [] }

1;
