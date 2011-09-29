
package CBIL::Bio::Enzyme::Class;

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

	 if (ref $A eq 'ARRAY') {
		 $M->parse($A);
	 }
	 elsif (ref $A eq 'HASH') {
		 $M->setId($A->{Id});
		 $M->setNumber($A->{Number});
		 $M->setParent($A->{Parent});
		 $M->setDescription($A->{Description});
	 }

   return $M
}

# ----------------------------------------------------------------------

# an EcNumber string
sub getId                  { $_[0]->{Id} }
sub setId                  { $_[0]->{Id} = $_[1]; $_[0] }

# an EcNumber object
sub getNumber              { $_[0]->{Number} }
sub setNumber              { $_[0]->{Number} = $_[1]; $_[0] }

# a string
sub getDescription         { $_[0]->{Description} }
sub setDescription         { $_[0]->{Description} = $_[1]; $_[0] }

# the parent class
sub getParent              { $_[0]->{Parent} }
sub setParent              { $_[0]->{Parent} = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $E = shift; # [string] : lines from file

 LINE_SCAN:
   for (my $i = 0; $i < @$E; $i++) {
      my $line = $E->[$i];
      if ($line =~ /^(.\...\...\.-)\s+(.+)$/) {
         my $class       = $1;
         my $designation = $2;

				 # remove white space
         $class =~ s/\s//g;

				 # add next line to designation if there is no trailing period.
				 if ($designation !~ /\.\s*$/) {
					 $i++;
					 chomp $E->[$i];
					 my ($s) = $E->[$i] =~ /^\s*(\s.+)$/;
					 $designation .= $s;
				 }

				 my $num = CBIL::Bio::Enzyme::EcNumber->new($class);
				 $M->setId($num->toString);
         $M->setNumber($num);
         $M->setDescription($designation);

      }
   }

   #Disp::Display($M);

   return $M
}

# ----------------------------------------------------------------------

1
