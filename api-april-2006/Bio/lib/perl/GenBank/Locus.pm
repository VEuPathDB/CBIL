
package CBIL::Bio::GenBank::Locus;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub setId       { $_[0]->{ID}  = $_[1]; $_[0] }
sub setLength   { $_[0]->{LEN} = $_[1]; $_[0] }
sub setType     { $_[0]->{TYP} = $_[1]; $_[0] }
sub setDivision { $_[0]->{DIV} = $_[1]; $_[0] }
sub setDate     { $_[0]->{DAT} = $_[1]; $_[0] }

sub getId       { $_[0]->{ID}  }
sub getLength   { $_[0]->{LEN} }
sub getType     { $_[0]->{TYP} }
sub getDivision { $_[0]->{DIV} }
sub getDate     { $_[0]->{DAT} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  my $line = $IOS->getLine();

	my @A = split /\s+/, $line;
  my ( $LOCUS, $id, $length, $bp, $type, $circular, $div, $date );
	if (@A > 7) {
		( $LOCUS, $id, $length, $bp, $type, $circular, $div, $date ) = @A;
	} elsif (@A == 7) {
		( $LOCUS, $id, $length, $bp, $type, $div, $date ) = @A;
	}	else {
		( $LOCUS, $id, $length, $bp, $div, $date ) = @A;
	}
  # needs only the line ## Bad parse for RefSeq follows
	#  = ( $line =~ /LOCUS\s+(\S+)\s+(\d+) bp\s+(\S+)\s+(\S+)\s+(\S+)/ );

  $M->setId(       $id );
  $M->setLength(   $length );
  $M->setType(     $type );
  $M->setDivision( $div );
  $M->setDate(     $date );

  $M;
}

1;

