
package CBIL::Bio::Enzyme::DbRef;

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

   if (ref $A) {
      $M->setDatabase(   $A->{Database});
      $M->setPrimaryId(  $A->{PrimaryId});
      $M->setSecondaryId($A->{SecondaryId});
   }
   else {
      $M->parse($A);
   }

   return $M
}

# ----------------------------------------------------------------------

sub getDatabase    { $_[0]->{Database}   }
sub setDatabase    { $_[0]->{Database}   = $_[1]; $_[0] }

sub getPrimaryId   { $_[0]->{PrimaryId}  }
sub setPrimaryId   { $_[0]->{PrimaryId}  = $_[1]; $_[0] }

sub getSecondaryId { $_[0]->{SecondaryId}  }
sub setSecondaryId { $_[0]->{SecondaryId}  = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of line

   printf STDERR 'initialization through parsing not supported in %s', ref $M;

   return $M

}

# ----------------------------------------------------------------------

1
