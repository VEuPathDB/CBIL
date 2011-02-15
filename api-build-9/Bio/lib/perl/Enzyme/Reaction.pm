
package CBIL::Bio::Enzyme::Reaction;

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

   $M->setDescription(undef);

   $M->parse($A) unless ref $A;

   return $M
}

# ----------------------------------------------------------------------

sub getLefthandSide  { $_[0]->{LefthandSide} }
sub setLefthandSide  { $_[0]->{LefthandSide} = $_[1]||[]; $_[0]}

sub getRighthandSide { $_[0]->{RighthandSide} }
sub setRighthandSide { $_[0]->{RighthandSide} = $_[1]||[]; $_[0]}

sub getDescription   { $_[0]->{Description} }
sub setDescription   { $_[0]->{Description} = $_[1]; $_[0] }

sub toString   {
   my $M = shift;

   return $M->getDescription ||
   join(' = ',
        join(' + ', @{$M->getLefthandSide} ),
        join(' + ', @{$M->getRighthandSide} ),
       )
}

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of line

   my @sides = split(/\s+=\s+/, $T);
   if (scalar @sides == 2) {
      my @lhs   = split(/\s+\+\s+/, $sides[0]);
      my @rhs   = split(/\s+\+\s+/, $sides[1]);
      $M->setLefthandSide(\@lhs);
      $M->setRighthandSide(\@rhs);
   }
   else {
      $M->setDescription($T);
   }

   return $M
}

# ----------------------------------------------------------------------

1
