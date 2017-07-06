package CBIL::ISA::OntologyTermWithQualifier;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub setQualifier { $_[0]->{_qualifier} = $_[1] }
sub getQualifier { $_[0]->{_qualifier} }

sub setAlternativeQualifier { $_[0]->{_alternative_qualifier} = $_[1] }
sub getAlternativeQualifier { $_[0]->{_alternative_qualifier} }


1;
