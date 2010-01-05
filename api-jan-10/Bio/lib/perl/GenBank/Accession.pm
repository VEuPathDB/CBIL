
package CBIL::Bio::GenBank::Accession;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub setAccession { $_[0]->{ACC} = $_[1]; $_[0] } 
sub setSecondaryAccession { $_[0]->{ACC2} = $_[1]; $_[0] } 

sub getAccession { $_[0]->{ACC} } 
sub getSecondaryAccession { $_[0]->{ACC2} } 

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;
  
	my $a = $M->parseAsText( 'ACCESSION', $IOS );
	my @acc = split /\s+/, $a->[0];
	
	$M->setAccession($acc[0]);
	if ($acc[1]) { 
		$M->setSecondaryAccession($acc[1]);
	}
	
  $M;
}

1;

