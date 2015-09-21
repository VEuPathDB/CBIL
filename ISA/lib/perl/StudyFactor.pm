package CBIL::ISA::StudyFactor;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub setType {
  my ($self, $type) = @_;
  $self->setTerm($type);
}

sub getType {
  my ($self) = @_;
  return $self->getTerm();
}

sub setName { $_[0]->{_name} = $_[1] }
sub getName { $_[0]->{_name} }


1;
