
package CBIL::Bio::GenBank::Feature;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use CBIL::Bio::GenBank::BaseObject;
use CBIL::Bio::GenBank::Qualifier;
use CBIL::Bio::GenBank::Loc;

use strict 'vars';

sub isFirstLine        { $_[0] =~ /^ {5}[a-zA-Z0-9]/ }
sub isContinuationLine { $_[0] =~ /^ {21}[^\/]/ }

sub setType       { $_[0]->{TYP} = $_[1]; $_[0] }
sub setLocString  { $_[0]->{LOC} = $_[1]; $_[0] }
sub setOrdinal    { $_[0]->{ORD} = $_[1]; $_[0] }
sub setLocParse   { $_[0]->{LCP} = $_[1]; $_[0] }

sub getType       { $_[0]->{TYP} }
sub getLocString  { $_[0]->{LOC} }
sub getOrdinal    { $_[0]->{ORD} }
sub getLocParse   { $_[0]->{LCP} }
sub getAllQualifiers { $_[0]->{QUA} }
sub getQualifiers { $_[0]->{QBT}->{$_[1]} }
sub getSingleQualifier { $_[0]->{QBT}->{$_[1]}->[0] }
sub getQualifierTags { [ keys %{ $_[0]->{QBT} } ] }

sub addQualifier {
  $_[1]->setOrdinal( ++$_[0]->{NQU} );
  push( @{$_[0]->{QUA}}, $_[1] );
  push( @{$_[0]->{QBT}->{$_[1]->getTag()}}, $_[1] );
	$_[0]->setValiidty(0) unless $_[1]->getValidity;
  $_[0]
}

my $parser;
sub parse {
  my $M   = shift;
  my $IOS = shift;

  my $line = $IOS->getLine();
  $line =~ s/^\s+//; chomp $line;
  my ( $type, $location ) = split( /\s+/, $line, 2 );
  for ( $line = $IOS->getLine();
        isContinuationLine($line);
        $line = $IOS->getLine() ) {
    $line =~ s/^\s+//; chomp $line;
    $location .= $line;
  }
  $IOS->putLine($line);

  $M->setType($type);
  $M->setLocString($location);
  $parser = CBIL::Bio::GenBank::Loc->new() unless $parser;
  $M->setLocParse( $parser->Run($location) );
	$M->setValidity( $parser->IsValid() );

# #$line = $IOS->getLine();
# while ( CBIL::Bio::GenBank::Feature::isContinuationLine($line) ) {
#   $line =~ s/^\s+//; chomp $line;
#   $M->setLocString($M->getLocString(). $line );
#   $line = $IOS->getLine();
# }
# $IOS->putLine($line);

  while (1) {
    my $qualifier = CBIL::Bio::GenBank::Qualifier->new( { ios => $IOS } );
    last unless $qualifier->getValidity();
#   $M->reportError( $IOS,
#                    'addQualifier',
#                    $qualifier->getTag(),
#                    $qualifier->getValue(),
#                  );
    $M->addQualifier($qualifier);
  }

  # return value
  $M
}

1;

__END__



