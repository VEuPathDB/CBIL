
package CBIL::HQ::Node;

# ======================================================================

=pod

=head1 Synopsis

This package implements a node in a hierarchy of tissues (or other
unordered conditions).

=cut

use strict;

use CBIL::Util::V;

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

	 $Self->setName                 ( $Args->{Name                } );
	 $Self->setParts                ( $Args->{Parts               } );
   $Self->setNodeCount            ( $Args->{NodeCount           } );
	 $Self->setExtra                ( $Args->{Extra               } );
	 $Self->setRaw                  ( $Args->{Raw                 } );
	 $Self->setWeighted             ( $Args->{Weighted            } );
	 $Self->setGlobalProb           ( $Args->{GlobalProb          } );
	 $Self->setGlobalBits           ( $Args->{GlobalBits          } );
	 $Self->setLocalBits            ( $Args->{LocalBits           } );
	 $Self->setLocalProb            ( $Args->{LocalProb           } );
	 $Self->setGlobalEntropy        ( $Args->{GlobalEntropy       } );
	 $Self->setLocalEntropy         ( $Args->{LocalEntropy        } );

	 return $Self;
}

# ----------------------------------------------------------------------

=pod

=head2 C<reset>

Resets all of the numeric values to zero.

=cut

sub reset {
   my $Self = shift;

   foreach (qw( LocalBits GlobalProb LocalProb GlobalEntropy LocalEntropy Weighted Raw )) {
      my $method = "set$_";
      $Self->$method(0);
   }

   foreach (@{$Self->getParts()}) { $_->reset() }

   return $Self;
}

# ----------------------------------------------------------------------

sub getName                 { $_[0]->{'Name'                        } }
sub setName                 { $_[0]->{'Name'                        } = $_[1]; $_[0] }

sub getParts                { $_[0]->{'Parts'                       } }
sub setParts                { $_[0]->{'Parts'                       } = $_[1]; $_[0] }

sub getNodeCount            { $_[0]->{NodeCount                     } }
sub setNodeCount            { $_[0]->{NodeCount                     } = $_[1]; $_[0] }

sub getExtra                { $_[0]->{'Extra'                       } }
sub setExtra                { $_[0]->{'Extra'                       } = $_[1]; $_[0] }

sub getRaw                  { $_[0]->{'Raw'                         } }
sub setRaw                  { $_[0]->{'Raw'                         } = $_[1]; $_[0] }

sub getWeighted             { $_[0]->{'Weighted'                    } }
sub setWeighted             { $_[0]->{'Weighted'                    } = $_[1]; $_[0] }

sub getGlobalProb           { $_[0]->{'GlobalProb'                  } }
sub setGlobalProb           { $_[0]->{'GlobalProb'                  } = $_[1]; $_[0] }

sub getGlobalBits           { $_[0]->{'GlobalBits'                  } }
sub setGlobalBits           { $_[0]->{'GlobalBits'                  } = $_[1]; $_[0] }

sub getLocalProb            { $_[0]->{'LocalProb'                   } }
sub setLocalProb            { $_[0]->{'LocalProb'                   } = $_[1]; $_[0] }

sub getLocalBits            { $_[0]->{'LocalBits'                   } }
sub setLocalBits            { $_[0]->{'LocalBits'                   } = $_[1]; $_[0] }

sub getGlobalEntropy        { $_[0]->{'GlobalEntropy'               } }
sub setGlobalEntropy        { $_[0]->{'GlobalEntropy'               } = $_[1]; $_[0] }

sub getLocalEntropy         { $_[0]->{'LocalEntropy'                } }
sub setLocalEntropy         { $_[0]->{'LocalEntropy'                } = $_[1]; $_[0] }

sub isLeaf {
  my $Self = shift;
  
  if (not defined $Self->{IsLeaf}) {
    $Self->{IsLeaf} = scalar @{$Self->getParts()} > 0 ? 0 : 1;
  }
  
  return $Self->{IsLeaf};
}

# ----------------------------------------------------------------------
=pod

=head1 C<foreachNode>

Applies a function to each node.

=cut

sub foreachNode {
   my $Self = shift;
   my $Func = shift;

   map { $_->foreachNode($Func) } @{$Self->getParts()};

   $Func->($Self);
}

# ----------------------------------------------------------------------
=pod

=head1 C<foreachLeafNode>

Applies a function to each leaf node.

=cut

sub foreachLeafNode {
  my $Self = shift;
  my $Func = shift;

  if ($Self->isLeaf()) {
    return $Func->($Self);
  }
  else {
    return map { $_->foreachLeafNode($Func) } @{$Self->getParts()};
  }
}

# ----------------------------------------------------------------------
=pod

=head1 C<foreachParentNode>

Applies a function to each internal node.  We do not do anything to leaves.
We apply to parts first, then to self.

=cut

sub foreachParentNode {
   my $Self = shift;
   my $Func = shift;

   if ($Self->isLeaf()) {
      ;
   }
   else {
      map { $_->foreachParentNode($Func) } @{$Self->getParts()};
      $Func->($Self);
   }
}

# ----------------------------------------------------------------------
=pod

=head2 C<applyPseudoCounts>

Looks at all leaf nodes and adds specified pseudocounts to the C<Raw>
counts in the leaves.

=cut

sub applyRawPseudoCounts {
  my $Self         = shift;
  my $PseudoCounts = shift;

  # adjust raw counts and return undef.
  my $apply_func = sub {
    my $_Self = shift;

    $_Self->setRaw($_Self->getRaw() + $PseudoCounts);

    return undef;
  };

  $Self->foreachLeafNode($apply_func);

  return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<applyRawMinimumCounts>

Looks at all leaf nodes and ensures that no counts are below specified
minimum.

=cut

sub applyRawMinimumCounts {
  my $Self          = shift;
  my $MinimumCounts = shift;

  # adjust raw counts and return undef.
  my $apply_func = sub {
    my $_Self = shift;

    $_Self->setRaw(CBIL::Util::V::max($_Self->getRaw(),$MinimumCounts));

    return undef;
  };

  $Self->foreachLeafNode($apply_func);

  return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<totalRaw>

Computes the total number of raw counts in all leaf nodes.

=cut

sub totalRaw {
  my $Self = shift;

  my $func = sub {
    my $_Self = shift;
    return $_Self->getRaw()
  };

  my $RV = CBIL::Util::V::sum($Self->foreachLeafNode($func));
  return $RV;
}

# ----------------------------------------------------------------------

sub mapRawToWeighted {
  my $Self = shift;
  my $Func = shift || sub { $_[0] };

  $Self->setWeighted($Func->($Self->getRaw()));

  map { $_->mapRawToWeighted($Func) } @{$Self->getParts()};

  return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<totalWeighted>

Computes the total number of weighed counts in all leaf nodes.

=cut

sub totalWeighted {
  my $Self = shift;

  my $func = sub {
    my $_Self = shift;
    return $_Self->getWeighted()
  };

  my $RV = CBIL::Util::V::sum($Self->foreachLeafNode($func));
  return $RV;
}

# ----------------------------------------------------------------------
=pod

=head2 C<mapWeightedToGlobalProb>

Divides each weighted value by provided constant to get probability.

First we update the probability in each leaf node as described above.  Next
we consider each parent and set its C<GlobalProb> to the sum of its C<Parts>
C<GlobalProb>.

=cut

sub mapWeightedToGlobalProb {
   my $Self  = shift;

   if (my $total = $Self->totalWeighted()) {

      # set probability
      my $leaf_func = sub { 
         my $_Self = shift;
         my $prob = $_Self->getWeighted() / $total;
         $_Self->setGlobalProb($prob);
         eval { $_Self->setGlobalBits(-log($prob)/log(2)) };
      };
      $Self->foreachLeafNode($leaf_func);

      # parent func; sum from kids
      my $parent_func = sub {
         my $_Self = shift;
         my $total = CBIL::Util::V::sum(map { $_->getGlobalProb() } @{$_Self->getParts});
         $_Self->setGlobalProb($total);
         eval { $_Self->setGlobalBits(-log($total)/log(2)) };
      };
      $Self->foreachParentNode($parent_func);
   }

   return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<mapGlobalProbToLocalProb>

Computes the local probability of node using its global prob and the
parents global probability.

=cut

sub mapGlobalProbToLocalProb {
   my $Self = shift;

   my $parent_func = sub {
      my $_Self = shift;

      my $globalProb = $_Self->getGlobalProb();
      if ($globalProb > 0.0) {
         foreach my $part (@{$_Self->getParts()}) {
            $part->setLocalProb( $part->getGlobalProb() / $globalProb );
         }
      }
   };
   $Self->foreachParentNode($parent_func);

   return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<mapLocalProbToLocalBits>

=cut

sub mapLocalProbToLocalBits {
   my $Self = shift;

   my $_func = sub {
      my $_Self = shift;
      eval {
         $_Self->setLocalBits(-log($_Self->getLocalProb())/log(2));
      };
   };

   $Self->foreachNode($_func);

   return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<updateLocalEntropy>

=cut

sub updateLocalEntropy {
   my $Self = shift;

   my $parent_func = sub {
      my $_Self = shift;

      my $entropy = CBIL::Util::V::sum(map {
         $_->getLocalProb() * $_->getLocalBits()
      } @{$_Self->getParts()});

      $_Self->setLocalEntropy($entropy);
   };

   $Self->foreachParentNode($parent_func);

   return $Self;
}

# ----------------------------------------------------------------------
=pod

=head2 C<updateGlobalEntropy>

=cut

sub updateGlobalEntropy {
   my $Self = shift;

   my $parent_func = sub {
      my $_Self = shift;

      my $entropy
      = $_Self->getLocalEntropy()
      + CBIL::Util::V::sum(map {
         $_->getLocalProb() * $_->getGlobalEntropy()
      } @{$_Self->getParts()});

      $_Self->setGlobalEntropy($entropy);
   };

   $Self->foreachParentNode($parent_func);

   return $Self;
}

# ======================================================================

1;

__END__

