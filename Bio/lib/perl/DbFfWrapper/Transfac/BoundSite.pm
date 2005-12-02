
package CBIL::Bio::DbFfWrapper::Transfac::BoundSite;

use strict;

# ----------------------------------------------------------------------

sub new {
   my $C = shift;
   my $Args = shift;

   my $m = bless {}, $C;

   $m->init($Args);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->parse($Args) unless ref $Args;

   return $Self
}

# ----------------------------------------------------------------------

sub getSequence { $_[0]->{Sequence} }
sub setSequence { $_[0]->{Sequence} = $_[1]; $_[0] }

sub getSite { $_[0]->{Site} }
sub setSite { $_[0]->{Site} = $_[1]; $_[0] }

sub getStart { $_[0]->{Start} }
sub setStart { $_[0]->{Start} = $_[1]; $_[0] }

sub getLength { $_[0]->{Length} }
sub setLength { $_[0]->{Length} = $_[1]; $_[0] }

sub getGaps { $_[0]->{Gaps} }
sub setGaps { $_[0]->{Gaps} = $_[1]; $_[0] }

sub getOrientation { $_[0]->{Orientation} }
sub setOrientation { $_[0]->{Orientation} = $_[1]; $_[0] }

sub getQuality { $_[0]->{Quality} }
sub setQuality { $_[0]->{Quality} = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $T = shift; # string ; text of line

   # from Matrix (v4.0 (e.g.))
   if ($T =~ m/^(R\d{5}); Start:\s+(-?\d+); Length:\s+(\d+); Gaps: (.+); Orientation: (.)/) {
     my $gaps = $4 eq '-' ? [] : [split(/,/,$4)];
     $Self->setSite($1);
     $Self->setStart($2);
     $Self->setLength($3);
     $Self->setGaps($gaps);
     $Self->setOrientation($5);
   }

   # from Matrix (v7.3)
   elsif ($T =~ /(.*); (R\d+); (-?\d+); (\d+); *(.*); (.)/) {
      $Self->setSequence($1);
      $Self->setSite($2);
      $Self->setStart($3);
      $Self->setLength($4);
      $Self->setGaps([split(/,/, $5)]);
      $Self->setOrientation($6);
   }

   # from Matrix (v7.3) : alternate form that points to COMPEL?
   elsif ($T =~ /(.*); (C\d+), +(s\d+); (-?\d+); (\d+); *(.*); (.)/) {
      $Self->setSequence($1);
      $Self->setSite({ Compel => $2, CompelSite => $3 });
      $Self->setStart($4);
      $Self->setLength($5);
      $Self->setGaps([split(/,/, $6)]);
      $Self->setOrientation($7);
   }

   # from Factor
   elsif ($T =~ /^(R\d{5});.+Quality: (\d)/) {
      $Self->setSite($1);
      $Self->setQuality($2);
   }

   else {
      print STDERR "Unexpected BoundSite line: '$T'\n";
   }

return $Self

}

# ----------------------------------------------------------------------

1
