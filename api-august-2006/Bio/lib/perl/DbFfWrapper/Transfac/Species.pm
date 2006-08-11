
package CBIL::Bio::DbFfWrapper::Transfac::Species;

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

sub getCommon    { $_[0]->{Common}   }
sub setCommon    { $_[0]->{Common}   = $_[1]; $_[0] }

sub getScientific   { $_[0]->{Scientific}  }
sub setScientific   { $_[0]->{Scientific}  = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of line

   # title line
   if ($T =~ /^(.+), (.+)/) {
      $M->setCommon($1);
      $M->setScientific($2);
   }

   elsif ($T =~ /^(.+); (.+)/) {
      $M->setCommon($1);
      $M->setScientific($2);
   }

   # upper case is scientific
   elsif ($T =~ /^([A-Z].+)/) {
      $M->setScientific($1);
   }

   # lower case is common
   elsif ($T =~ /^([a-z].+)/) {
      $M->setCommon($1);
   }

   # unexpected
   else {
      print STDERR "Unexpected Species: '$T'\n";
   }
   return $M

}

# ----------------------------------------------------------------------

1
