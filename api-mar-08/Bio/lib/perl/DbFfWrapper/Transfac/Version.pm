
package CBIL::Bio::DbFfWrapper::Transfac::Version;

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

sub getMonth { $_[0]->{Month} }
sub setMonth { $_[0]->{Month} = $_[1]; $_[0] }

sub getDay   { $_[0]->{Day} }
sub setDay   { $_[0]->{Day} = $_[1]; $_[0] }

sub getYear  { $_[0]->{Year} }
sub setYear  { $_[0]->{Year} = $_[1]; $_[0] }

sub getMajor { $_[0]->{Major} }
sub setMajor { $_[0]->{Major} = $_[1]; $_[0] }

sub getMinor { $_[0]->{Minor} }
sub setMinor { $_[0]->{Minor} = $_[1]; $_[0] }

sub getAudience { $_[0]->{Audience} }
sub setAudience { $_[0]->{Audience} = $_[1]; $_[0] }

sub getVersionString {
   my $M = shift;

   return sprintf('v%s.%s-%s',
                  $M->getMajor, $M->getMinor, $M->getAudience
                  )
}

sub getDateString {
   my $M = shift;

   return sprintf('%s-%s-%s',$M->getYear,$M->getMonth,$M->getDay)
}

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $T = shift; # string ; text of a version line, excluding VV.

   if ($T =~ /Rel.+ (\d+)\.(\d+) - (\S+) - (\d+)-(\d+)-(\d+)/) {
      $M->setMajor($1);
      $M->setMinor($2);
      $M->setAudience($3);
      $M->setDay($4);
      $M->setMonth($5);
      $M->setYear($6);
   }

   else {
      print STDERR "unexpected Version: '$T'\n";
   }
}

# ----------------------------------------------------------------------

1

