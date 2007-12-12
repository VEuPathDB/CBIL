
package CBIL::Bio::DbFfWrapper::Transfac::DbRef;

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

   if (ref $Args) {
      $Self->setDatabase             ( $Args->{Database            } );
      $Self->setPrimaryId            ( $Args->{PrimaryId           } );
      $Self->setSecondaryId          ( $Args->{SecondaryId         } );
      $Self->setStart                ( $Args->{Start               } );
      $Self->setStop                 ( $Args->{Stop                } );
   }
   else {
      $Self->parse($Args);
   }

   return $Self
}

# ----------------------------------------------------------------------

sub getDatabase             { $_[0]->{'Database'                    } }
sub setDatabase             { $_[0]->{'Database'                    } = $_[1]; $_[0] }

sub getPrimaryId            { $_[0]->{'PrimaryId'                   } }
sub setPrimaryId            { $_[0]->{'PrimaryId'                   } = $_[1]; $_[0] }

sub getSecondaryId          { $_[0]->{'SecondaryId'                 } }
sub setSecondaryId          { $_[0]->{'SecondaryId'                 } = $_[1]; $_[0] }

sub getStart                { $_[0]->{'Start'                       } }
sub setStart                { $_[0]->{'Start'                       } = $_[1]; $_[0] }

sub getStop                 { $_[0]->{'Stop'                        } }
sub setStop                 { $_[0]->{'Stop'                        } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $T = shift; # string ; text of line

   # trim trailing period
   $T =~ s/\.$//;

   # MEDLINE from RX lines.
   if ($T =~ /^(MEDLINE); (\d+)/) {
      $Self->setDatabase($1);
      $Self->setPrimaryId($2);
   }

   # TITLE LINE
   elsif ($T =~ /^(.+?): (\S+); (\S+)/) {
      $Self->setDatabase($1);
      $Self->setPrimaryId($2);
      my $sid = $3; $sid =~ s/\.$//;
      if ($sid =~ /(\S+)\((-?\d+):(-?\d+)\)/) {
         $Self->setSecondaryId($1);
         $Self->setStart($2);
         $Self->setStop($3);
      }
      else {
         $Self->setSecondaryId($sid);
      }
   }

   # no secondary ids
   elsif ($T =~ /^(.+?):\s*(\S+)/) {
      $Self->setDatabase($1);
      $Self->setPrimaryId($2);
   }

	 # complicated ones for RSNP
	 elsif ($T =~ /^(RSNP):\s*(\S+);/) {
			$Self->setDatabase($1);
			$Self->setPrimaryId($2);
	 }

   # unexpected
   else {
      print STDERR "Unexpected DbRef: '$T'\n";
   }
   return $Self

}

# ----------------------------------------------------------------------

1
