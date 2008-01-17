
package CBIL::HQ::Analysis;

# ======================================================================

=pod

=head1 Synopsis

This package implements a means of measuring the tissue specificity of
a gene's expression pattern in a survey of tissues.

=cut

use strict;

use CBIL::HQ::Node;

use constant Flag_WarnAboutMissingTissues => 0;

# ======================================================================

=pod

=head1 Class Methods

=cut

# ----------------------------------------------------------------------

sub new {
	 my $Class = shift;
	 my $Args  = shift;

	 my $self = bless {}, $Class;

	 $self->init($Args);

	 return $self;
}

# ======================================================================

=pod

=head1 Instance Methods

=cut

# ----------------------------------------------------------------------

sub init {
	 my $Self = shift;
	 my $Args = shift;

	 $Self->setHierarchy            ( $Args->{Hierarchy           } );

	 $Self->setThreshold            ( $Args->{Threshold           } );
	 $Self->setReplacementValue     ( $Args->{ReplacementValue    } );
	 $Self->setPseudocounts         ( $Args->{Pseudocounts        } );

	 $Self->setObservations         ( $Args->{Observations        } );

	 return $Self;
}

# ----------------------------------------------------------------------

=pod

=head2 C<*etHierarchy>

=cut

sub getHierarchy            { $_[0]->{'Hierarchy'                   } }
sub setHierarchy            { $_[0]->{'Hierarchy'                   } = $_[1]; $_[0] }

=pod

=head2 C<*etThreshold>

This attribute contains a threshold that is applied to each
observation.  If the observation is less than this value, it is reset
to the C<ReplacementValue>.

=cut

sub getThreshold            { $_[0]->{'Threshold'                   } }
sub setThreshold            { $_[0]->{'Threshold'                   } = $_[1]; $_[0] }

=pod

=head2 C<*etReplacementValue>

This attribute contains the replacement value that is used when an
observation is less thatn the threshold value.

=cut

sub getReplacementValue     { $_[0]->{'ReplacementValue'            } }
sub setReplacementValue     { $_[0]->{'ReplacementValue'            } = $_[1]; $_[0] }

=pod

=head2 C<*etPseudocounts>

This attribute contains the number of pseudocounts that should be
added to each observation after thresholding has been applied.

=cut

sub getPseudocounts         { $_[0]->{'Pseudocounts'                } }
sub setPseudocounts         { $_[0]->{'Pseudocounts'                } = $_[1]; $_[0] }

=pod

=head2 C<*etObservations>

This attribute contains the observations for each tissue for a single
gene.  It should be a hash ref where the fieldnames are the tissues
and the values are the observations.

=cut

sub getObservations         { $_[0]->{'Observations'                } }
sub setObservations         { $_[0]->{'Observations'                } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

=pod

=head2 C<update>

This method updates the statistics in the C<Hierarchy> using the
current C<Observations>.

=cut

sub update {
	 my $Self = shift;

	 my $root_node = $Self->getHierarchy()->getRoot();

	 $root_node->reset();

	 $Self->_processObservations();

	 $root_node->mapRawToWeighted();
	 $root_node->mapWeightedToGlobalProb();
	 $root_node->mapGlobalProbToLocalProb();
	 $root_node->mapLocalProbToLocalBits();
	 $root_node->updateLocalEntropy();
	 $root_node->updateGlobalEntropy();

	 return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<_processObservations>

This B<private> method applies the thresholding and pseudocounts to
the current observations then setting the processed value into the
corresponding node in the hierarchy.

=cut

sub _processObservations {
	 my $Self = shift;

	 my $_obs = $Self->getObservations();

	 foreach (keys %$_obs) {
			my $value = $_obs->{$_};

			$value = $Self->getReplacementValue() if $value < $Self->getThreshold();

			$value += $Self->getPseudocounts();

			if (my $_node = $Self->getHierarchy()->lookup($_)) {
				 $_node->setRaw($value);
			}
			else {
				 Flag_WarnAboutMissingTissues && warn "unknown node label '$_'";
			}
	 }

	 # return self
	 return $Self;
}

# ======================================================================

1;

__END__








