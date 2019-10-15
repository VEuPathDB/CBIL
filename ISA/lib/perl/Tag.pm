package CBIL::ISA::Tag;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setTag { $_[0]->{_tag} = $_[1] }
sub getTag { $_[0]->{_tag} }




1;
