package CBIL::ISA::ProtocolParam;
use base qw(CBIL::ISA::OntologyTerm);

use strict;


sub setName {
  my ($self, $name) = @_;
  $self->setTerm($name);
}

sub getName {
  my ($self) = @_;
  return $self->getTerm();
}


1;
