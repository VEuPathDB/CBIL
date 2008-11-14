
package CBIL::Bio::DbFfWrapper::Transfac::RefLinks;

use strict;

# ----------------------------------------------------------------------

sub new {
   my $C = shift;
   my $A = shift;

   my $m = bless {}, $C;

   $m->init($A);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $M = shift;
   my $A = shift;

   $M->{Cites} = {};
   $M->{Cited} = {};

   return $M
}

# ----------------------------------------------------------------------

sub addLink {
   my $M = shift;
   my $E = shift; # string : id of citing entry
   my $R = shift; # CBIL::Bio::DbFfWrapper::Transfac::Reference : cited reference (with ordinal)

   # entry sites ref with this key
   $M->{Cites}->{$E}->[$R->getOrdinal-1] = $R->getId;

   # reference was cited by this entry
   push(@{$M->{Cited}->{$R->getId}},$E);

   return $M
}

# ----------------------------------------------------------------------

sub getCites {
   my $M = shift;
   my $E = shift; # string : id of citing entry

   return $M->{Cites}->{$E}
}

sub getCited {
   my $M = shift;
   my $R = shift; # CBIL::Bio::DbFfWrapper::Transfac::Reference : cited reference (with ordinal)

   return $M->{Cited}->{$R->getId}
}

# ----------------------------------------------------------------------

1
