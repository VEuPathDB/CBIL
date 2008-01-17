
package CBIL::Bio::DbFfWrapper::Transfac::ObservedCounts;

use strict;

# ----------------------------------------------------------------------

sub new {
   my $Class = shift;
   my $Args  = shift;

   my $m = bless {}, $Class;

   $m->init($Args);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

	 if (ref $Args) {
			$Self->setLabels               ( $Args->{Labels              } );
			$Self->setObservations         ( $Args->{Observations        } );
	 }

	 else {
			$Self->parse($Args);
	 }

   return $Self
}

# ----------------------------------------------------------------------

sub getLabels       { $_[0]->{Labels} }
sub setLabels       { $_[0]->{Labels} = $_[1]; $_[0] }
sub getLabelCount   { scalar @{$_[0]->{Labels} || []} }

sub getObservations { $_[0]->{Observations} }
sub setObservations { $_[0]->{Observations} = $_[1]; $_[0] }

sub getObservation  { $_[0]->{Observations}->[$_[1]] }
sub setObservation  { $_[0]->{Observations}->[$_[1]] = $_[2]; $_[0] }

sub getNumberOfColumns { scalar grep {$_} @{$_[0]->{Observations}} };

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $T = shift; # string ; text of line

   # title line
   if ($T =~ /^P0/) {
      my @parts = split(/\s+/,$T);
      shift @parts;
      $Self->setLabels(\@parts);
   }

   # observation line
   elsif ($T =~ /^\d+/) {
      my @parts = split(/\s+/,$T);
      my $ordinal = shift @parts;
      my @obs;
      for (my $i=0; $i<$Self->getLabelCount; $i++) { $obs[$i]=$parts[$i] }
      $Self->setObservation($ordinal,\@obs);
   }

   # unexpected
   else {
      print STDERR "Unexpected ObservedCounts: '$T'\n";
   }
   return $Self

}

# ----------------------------------------------------------------------

1
