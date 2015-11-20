package CBIL::ISA::OntologyTermWithQualifier;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub setQualifier { $_[0]->{_qualifier} = $_[1] }
sub getQualifier { $_[0]->{_qualifier} }


1;
