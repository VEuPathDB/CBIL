
package CBIL::Bio::DbFfWrapper::Transfac::Feature;

use strict;

use vars qw($last_one);

# ----------------------------------------------------------------------

sub new {
   my $C = shift;
   my $A = shift;

   my $m = bless {}, $C;

   $m->init($A);

   $last_one = $m;

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

sub getStart { $_[0]->{Start} }
sub setStart { $_[0]->{Start} = $_[1]; $_[0] }

sub getStop { $_[0]->{Stop} }
sub setStop { $_[0]->{Stop} = $_[1]; $_[0] }

sub getDescription { $_[0]->{Description} }
sub setDescription { $_[0]->{Description} = $_[1]; $_[0] }

sub toString {
   my $M = shift;

   return sprintf("%6d\t%6d\t%s",
                  $M->getStart, $M->getStop, $M->getDescription
                 )
}

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of line

   # full line
   if ($T =~ m/\s+(\d+)\s+(\d+)\s+(.*)/) {
      $M->setStart($1);
      $M->setStop($2);
      $M->setDescription($3);
   }

   else {
      print STDERR "Unexpected Feature line: '$T'\n";
   }

   return $M

}

# ----------------------------------------------------------------------

1
