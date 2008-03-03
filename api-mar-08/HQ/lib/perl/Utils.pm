package CBIL::HQ::Utils;

# ======================================================================

=pod

=head1 Synopsis

This package provides basic functions to facilitate HQ Analysis.

=cut

use strict;

use CBIL::HQ::Node;
use CBIL::HQ::Hierarchy;

# ======================================================================

=pod

=head2 nodeCountFromHqHierarchy

Returns the Total # of Leaves in the Hierachy.

=cut

# ---------------------------------------------------------------------
sub nodeCountFromHqHierarchy {
  my $hier = shift;

  return $hier->getRoot()->getNodeCount();
}


=pod

=head2 hMaxFromHqHierarchy

Calculates the Theoretical Maximum of H from an HqHierarchy.

=cut

# ---------------------------------------------------------------------
sub hMaxFromHqHierarchy {
  my $hier = shift;
  my $n = nodeCountFromHqHierarchy($hier);

  return log($n) / log(2);
}

=pod

=head2 qUbiqFromHqHierarchy

Calculates Q Ubiq from an HqHierarchy.

=cut

# ---------------------------------------------------------------------
sub qUbiqFromHqHierarchy {
  my $hier = shift;
  my $h_max = hMaxFromHqHierarchy($hier);

  return 2 * $h_max;
}

# ----------------------------------------------------------------------


1;
