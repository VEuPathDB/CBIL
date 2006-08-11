
package CBIL::Bio::DbFfWrapper::Transfac::BoundFactor;

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

   $M->parse($A) unless ref $A;

   return $M
}

# ----------------------------------------------------------------------

sub getFactor { $_[0]->{Factor} }
sub setFactor { $_[0]->{Factor} = $_[1]; $_[0] }

sub getQuality { $_[0]->{Quality} }
sub setQuality { $_[0]->{Quality} = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of line

   # matches
   if ($T =~ m/^(T\d{5}); .+ Quality: (.)/) {
     $M->setFactor($1);
     $M->setQuality($2);
   }

   # does not match
   else {
      print STDERR "Unexpected BoundFactor line: '$T'\n";
   }

return $M

}

# ----------------------------------------------------------------------

1
