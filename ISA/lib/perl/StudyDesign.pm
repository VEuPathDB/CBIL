package CBIL::ISA::StudyDesign;
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


1;
