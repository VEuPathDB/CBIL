
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

=head2 C<NewFromXmlFile>

Reads the XML from the C<$File>.  Makes sure that C<Node>
elements are arrays and that we do not use C<name> or other keys.

Dumps the loaded structure if in C<debug> mode.

Resursively converts from XML to objects.

=cut

sub NewFromXmlFile {
   my $File = shift;

   my $_xml = XML::Simple::XMLin($File,
                                 forcearray => [ 'Node' ],
                                 keyattr    => [],
                                );

   my $root = $_xml->{Root};
   my $name = $_xml->{Name};

   my $Rv = CBIL::HQ::Hierarchy->_makeHierarchy($root, $name);

   return $Rv;
}

# ----------------------------------------------------------------------


=head2 C<NewFromLeafNodes>

Will create a Hierarchy based on Node Name and number of Leaves UNDER each 
Node.  Takes in a sorted array whereby the index of the array is the 
ordinal number from the hierarchy (0 is the Root!).  Each element of the Array 
is a hash with the following keys:  Name, Extra, Leaf_Num

Ordinals are assigned.

=cut
sub NewFromLeafNodes {
  my $dat = shift;

  my $Root = CBIL::HQ::Node->new( {Extra => {}} );
  $Root->getExtra()->{Ordinal} = 0;

  if(scalar @$dat - 1 == $$dat[0]->{Leaf_Num}) {
    $Root->setNodeCount($$dat[0]->{Leaf_Num});
  }
  else {
    die "Error in Leaf Count for Root.\n";
  }

  my $prevLeaf = 1;

  for(my $i = scalar @$dat - 1; $i > 0; $i--) {
    my $leaf = $$dat[$i]->{Leaf_Num};

    my $Node = CBIL::HQ::Node->new( $$dat[$i] );

    $Node->getExtra->{Ordinal} = $i + 1;
    $Node->setNodeCount($leaf);

    # if the current Node is a Parent of something...
    my $n;
    while($leaf > $prevLeaf) {
      my $child = pop @{$Root->{Parts}};

      $n = $n + $child->getNodeCount();
      $prevLeaf = $n;

      push( @{$Node->{Parts}}, $child );
    }

    push( @{$Root->{Parts}}, $Node );

  }

  my $RV = CBIL::HQ::Hierarchy->new({ Name => 'Hierarchy',
				      Root => $Root
				      });
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

sub _makeHierarchy  {
  my $Self = shift;
  my $root = shift;
  my $name = shift;

  my $RV;

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

	 my $root_node = $recurse->($root);

	 # make the new Hierarchy
	 # ..................................................

	 $RV = CBIL::HQ::Hierarchy->new({ Name => $name,
					  Root => $root_node
					});

	 # return the new hierarchy
	 # ..................................................

	 return $RV;
}

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



