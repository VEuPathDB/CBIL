
package CBIL::Bio::GenBank::Version;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub setAccession { $_[0]->{ACC} = $_[1]; $_[0] } 
sub setSeqVersion  { $_[0]->{SVN} = $_[1]; $_[0] }
sub setGiNumber { $_[0]->{GID} = $_[1]; $_[0] }

sub getAccession { $_[0]->{ACC} } 
sub getSeqVersion  { $_[0]->{SVN} }
sub getGiNumber { $_[0]->{GID} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  my $ids = $M->parseAsText('VERSION', $IOS);
	
	my ($acc,$gi) = split /\s+/, $ids->[0];
	$M->setAccession( $acc ) ;
	$acc =~ s/^\w+\.(\d+)/$1/;
	$M->setSeqVersion( $acc );
	$gi =~ s/.+GI\:(.+)/$1/;
	$M->setGiNumber( $gi );

  $M;
}

1;

