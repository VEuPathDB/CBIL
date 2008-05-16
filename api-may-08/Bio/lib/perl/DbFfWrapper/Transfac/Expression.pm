

package CBIL::Bio::DbFfWrapper::Transfac::Expression;

use strict;

# ----------------------------------------------------------------------

sub new {
   my $Class = shift;
   my $Args  = shift;

   my $self = bless {}, $Class;

   $self->init($Args);

   return $self
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

	 if (ref $Args) {
			$Self->setOrgan                ( $Args->{Organ               } );
			$Self->setCellName             ( $Args->{CellName            } );
			$Self->setSystem               ( $Args->{System              } );
			$Self->setDevelopmentalStage   ( $Args->{DevelopmentalStage  } );
			$Self->setRelativeLevel        ( $Args->{RelativeLevel       } );
			$Self->setDetectionMethod      ( $Args->{DetectionMethod     } );
			$Self->setMolecule             ( $Args->{Molecule            } );
			$Self->setReference            ( $Args->{Reference           } );
			$Self->setText                 ( $Args->{Text                } );
	 }

	 else {
			$Self->parse($Args);
	 }

   return $Self
}

# ----------------------------------------------------------------------

sub getOrgan                { $_[0]->{'Organ'                       } }
sub setOrgan                { $_[0]->{'Organ'                       } = $_[1]; $_[0] }

sub getCellName             { $_[0]->{'CellName'                    } }
sub setCellName             { $_[0]->{'CellName'                    } = $_[1]; $_[0] }

sub getSystem               { $_[0]->{'System'                      } }
sub setSystem               { $_[0]->{'System'                      } = $_[1]; $_[0] }

sub getDevelopmentalStage   { $_[0]->{'DevelopmentalStage'          } }
sub setDevelopmentalStage   { $_[0]->{'DevelopmentalStage'          } = $_[1]; $_[0] }

sub getRelativeLevel        { $_[0]->{'RelativeLevel'               } }
sub setRelativeLevel        { $_[0]->{'RelativeLevel'               } = $_[1]; $_[0] }

sub getDetectionMethod      { $_[0]->{'DetectionMethod'             } }
sub setDetectionMethod      { $_[0]->{'DetectionMethod'             } = $_[1]; $_[0] }

sub getMolecule             { $_[0]->{'Molecule'                    } }
sub setMolecule             { $_[0]->{'Molecule'                    } = $_[1]; $_[0] }

sub getReference            { $_[0]->{'Reference'                   } }
sub setReference            { $_[0]->{'Reference'                   } = $_[1]; $_[0] }

sub getText                 { $_[0]->{'Text'                        } }
sub setText                 { $_[0]->{'Text'                        } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $T = shift; # string ; text of line

   # trim trailing period
   $T =~ s/\.$//;

	 if (my @parts = $T =~ /(.*),\s*(.*),\s*(.*),\s*(.*);\s*(.*);\s*(.*);\s*(.*);\s*(.*)/) {
			$Self->setOrgan                ($parts[0]);
			$Self->setCellName             ($parts[1]);
			$Self->setSystem               ($parts[2]);
			$Self->setDevelopmentalStage   ($parts[3]);
			$Self->setRelativeLevel        ($parts[4]);
			$Self->setDetectionMethod      ($parts[5]);
			$Self->setMolecule             ($parts[6]);
			$Self->setReference            ($parts[7]);

			$Self->setText($T);
	 }

   # short form in v10.2
	 elsif (my @parts = $T =~ /(.*), \s*(.*), \s*(.*), \s*(.*); \s*([^;]+);?/x) {
			$Self->setOrgan                ($parts[0]);
			$Self->setCellName             ($parts[1]);
			$Self->setSystem               ($parts[2]);
			$Self->setDevelopmentalStage   ($parts[3]);
			$Self->setRelativeLevel        ($parts[4]);
			$Self->setDetectionMethod      ($parts[5]);
			$Self->setMolecule             ($parts[6]);
			$Self->setReference            ($parts[7]);

			$Self->setText($T);
	 }
	 else {
			print STDERR join("\t", ref $Self, 'BadFormat', $T), "\n";
	 }

   return $Self

}

# ----------------------------------------------------------------------

1
