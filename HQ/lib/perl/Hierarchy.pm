
package CBIL::HQ::Hierarchy;

# ======================================================================

=pod

=head1 Synopsis

This package helps access a tree of C<CBIL::HQ::Node>s.  The nodes
themselves form the tree, this class simply knows where the root is
and provides lookup by name.

=cut

# ======================================================================

use strict;

# ======================================================================

=pod

=head1 Class Methods

=cut

# ----------------------------------------------------------------------

=head2 C<initFromXmlFile>

Reads the XML from the C<$File>.  Makes sure that C<Node>
elements are arrays and that we do not use C<name> or other keys.

Dumps the loaded structure if in C<debug> mode.

Resursively converts from XML to objects.

=cut

sub NewFromXmlFile  {
   my $File = shift;
   my $RV;

	 # read the XML file.
	 # ..................................................

   my $_xml = XML::Simple::XMLin($File,
                                 forcearray => [ 'Node' ],
                                 keyattr    => [],
                                );

	 # recursively convert nodes to Nodes
	 # ..................................................

   my $recurse; $recurse = sub {
      my $_Node = shift;
      my $_RV;

      $_RV = CBIL::HQ::Node->new({ %$_Node });

      my @nodes  = map { $recurse->($_) } @{$_Node->{Node} || []};
      $_RV->setParts(\@nodes);

      if (scalar @nodes) {
         $_RV->setNodeCount(CBIL::Util::V::sum(map { $_->getNodeCount() } @nodes));
      }
      else {
         $_RV->setNodeCount(1);
      }

      return $_RV;
   };

	 my $root_node = $recurse->($_xml->{Root});

	 # make the new Hierarchy
	 # ..................................................

	 $RV = CBIL::HQ::Hierarchy->new({ Name => $_xml->{Name},
																		Root => $root_node
																	});

	 # return the new hierarchy
	 # ..................................................

	 return $RV;
}

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

	 # get the easy stuff
	 # ..................................................

	 $Self->setName                 ( $Args->{Name                } );
	 $Self->setRoot                 ( $Args->{Root                } );

	 # put all of the nodes in the dictionary
	 # ..................................................

   my %dictionary;

   my $addNode_func = sub {
      my $_Node = shift;
      $dictionary{$_Node->getName()} = $_Node;
   };

   $Args->{Root}->foreachNode($addNode_func);

   $Self->setDictionary(\%dictionary);

	 # ..................................................

   return $Self;
}

# ----------------------------------------------------------------------

sub getName                 { $_[0]->{'Name'                        } }
sub setName                 { $_[0]->{'Name'                        } = $_[1]; $_[0] }

sub getRoot                 { $_[0]->{'Root'                        } }
sub setRoot                 { $_[0]->{'Root'                        } = $_[1]; $_[0] }

sub getDictionary           { $_[0]->{Dictionary          } }
sub setDictionary           { $_[0]->{Dictionary          } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub lookup {
   my $Self = shift;
   my $Name = shift;

   my $RV = $Self->getDictionary()->{$Name};

   return $RV;
}

# ----------------------------------------------------------------------

1;



