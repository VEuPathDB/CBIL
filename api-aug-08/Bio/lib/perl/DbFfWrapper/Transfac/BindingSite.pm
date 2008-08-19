
package CBIL::Bio::DbFfWrapper::Transfac::BindingSite;

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

sub getSite   { $_[0]->{Site} }
sub setSite   { $_[0]->{Site} = $_[1]; $_[0] }

sub getStart  { $_[0]->{Start} }
sub setStart  { $_[0]->{Start} = $_[1]; $_[0] }

sub getStop   { $_[0]->{Stop} }
sub setStop   { $_[0]->{Stop} = $_[1]; $_[0] }

sub getStrand               { $_[0]->{'Strand'                      } }
sub setStrand               { $_[0]->{'Strand'                      } = $_[1]; $_[0] }

sub getSequence             { $_[0]->{'Sequence'                    } }
sub setSequence             { $_[0]->{'Sequence'                    } = $_[1]; $_[0] }

sub getLength {$_[0]->getStop - $_[0]->getStart + 1}

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of line

   # from Matrix
   if ($T =~ /(-?\d+)\s+(-?\d+)\s+(R\d{5})/) {
     $M->setStart($1);
     $M->setStop($2);
     $M->setSite($3);
   }

   elsif ($T =~ /(empty)\s+(empty)\s+(R\d{5})/) {
     $M->setSite($3);
   }

	 elsif ($T =~ /(.+?);\s+(R\d+); (\d+); (\d+); (\d*); (.)\./) {
			$M->setSequence($1);
			$M->setSite    ($2);
			$M->setStrand  ($6);
	 }

   else {
      print STDERR "Unexpected BindingSite line: '$T'\n";
   }

return $M

}

# ----------------------------------------------------------------------

1
