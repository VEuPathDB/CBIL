
package CBIL::Bio::DbFfWrapper::Transfac::History;

=pod

=head1 Purpose

=cut


use strict;

# ----------------------------------------------------------------------

sub new {
   my $Class = shift;
   my $Args = shift;

   my $self = bless {}, $Class;

   $self->init($Args);

   return $self
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

	 if (ref $Args) {
			$Self->setMonth                ( $Args->{Month               } );
			$Self->setDay                  ( $Args->{Day                 } );
			$Self->setYear                 ( $Args->{Year                } );
			$Self->setAction               ( $Args->{Action              } );
			$Self->setCurator              ( $Args->{Curator             } );
	 }

	 else {
			$Self->parse($Args);
	 }

   return $Self
}

# ----------------------------------------------------------------------

sub getMonth                { $_[0]->{'Month'                       } }
sub setMonth                { $_[0]->{'Month'                       } = $_[1]; $_[0] }

sub getDay                  { $_[0]->{'Day'                         } }
sub setDay                  { $_[0]->{'Day'                         } = $_[1]; $_[0] }

sub getYear                 { $_[0]->{'Year'                        } }
sub setYear                 { $_[0]->{'Year'                        } = $_[1]; $_[0] }

sub getAction               { $_[0]->{'Action'                      } }
sub setAction               { $_[0]->{'Action'                      } = $_[1]; $_[0] }

sub getCurator              { $_[0]->{'Curator'                     } }
sub setCurator              { $_[0]->{'Curator'                     } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub toString   {
   my $Self = shift;

   return sprintf('%s-%s-%s %s %s',
                  $Self->getYear, $Self->getMonth, $Self->getDay,
                  join(',', @{$Self->getAction()  || []}),
                  join(',', @{$Self->getCurator() || []})
                 )
}

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $T   = shift; # string ; text of a history line, excluding DT.

   my $Rv = $Self;

   if ($T =~ /(\d+)\.(\d+).(\d+) \((.+)\); (.+)\.?/) {
      $Self->setDay($1);
      $Self->setMonth($2);
      $Self->setYear($3);
      $Self->setAction([split(',',$4)]);
      $Self->setCurator([split(',',$5)]);
   }

	 # dateless history
	 elsif ($T =~ /\((.+)\); (.+)\./) {
			$Self->setAction([split(',',$1)]);
      $Self->setCurator([split(',',$2)]);
	 }

   else {
      print STDERR "unexpected History: '$T'\n";
      $Rv = undef;
   }

   return $Rv;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1

