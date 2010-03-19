
package CBIL::Bio::KeggDrug::EcNumber;

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

sub getList    { $_[0]->{EcNumber} }
sub setList    { $_[0]->{EcNumber} = $_[1]; $_[0] }

sub getNumber  { $_[0]->{EcNumber}->[$_[1]] }
sub setNumber  { $_[0]->{EcNumber}->[$_[1]] = $_[2]; $_[0]}

sub getDepth   { scalar @{$_[0]->{EcNumber}} }

sub toString   { return join('.', map {$_[0]->{EcNumber}->[$_] || '-'} (0..3)) }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of line

	 my @parts;
	 if ($T =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/) {
		 @parts = ($1,$2,$3,$4);
	 }
	 elsif ($T =~ /^(\d+)\.(\d+)\.(\d+)\.-$/) {
		 @parts = ($1,$2,$3);
	 }
	 elsif ($T =~ /^(\d+)\.(\d+)\.-\.-$/) {
		 @parts = ($1,$2);
	 }
	 elsif ($T =~ /^(\d+)\.-\.-\.-$/) {
		 @parts = ($1);
	 }
	 elsif ($T =~ /^-\.-\.-\.-$/) {
		 @parts = ();
	 }
	 else {
		 print STDERR "Unexpected EcNumber format: '$T'\n";
		 return $M;
	 }
   $M->setList(\@parts);

   return $M
}

# ----------------------------------------------------------------------

1
