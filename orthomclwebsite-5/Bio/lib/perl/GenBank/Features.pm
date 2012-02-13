
package CBIL::Bio::GenBank::Features;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use CBIL::Bio::GenBank::BaseObject;
use CBIL::Bio::GenBank::Feature;

use strict 'vars';

sub getAllFeatures  { $_[0]->{FEA} }
sub getFeatures     { $_[0]->{FBT}->{$_[1]} }
sub getSingleFeature { $_[0]->{FBT}->{$_[1]}->[0] }
sub getFeatureTypes { [ sort keys %{$_[0]->{FBT} } ] }

sub addFeature {
  $_[1]->setOrdinal( ++$_[0]->{NFE} );
  push( @{$_[0]->{FEA}}, $_[1] );
  push( @{$_[0]->{FBT}->{$_[1]->getType()}}, $_[1] );
	$_[0]->setValidity(0) unless $_[1]->getValidity;
  $_[0]
}

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('FEATURES',$IOS);

  $M->extractFeatures($IOS);
}

sub extractFeatures {
  my $M   = shift;
  my $IOS = shift;

  # scan through features
  while ( my $line = $IOS->getLine() ) {
    $IOS->putLine($line);
#   $M->reportError( $IOS, 'line', $line );

    # this is the end of features
    if ( $line !~ /^ {5}/ ) {
      last;
    }

    # this is another feature
    elsif ( $line =~ /^ {5}[a-zA-Z0-9-]/ ) {
      my $feature = CBIL::Bio::GenBank::Feature->new( { ios => $IOS } );
#     $M->reportError( $IOS,
#                      'addFeature',
#                      $feature->getType(),
#                      $feature->getLocString(),
#                      $feature->getOrdinal(),
#                    );
      $M->addFeature($feature);
    }

    # unexpected line
    else {
      $M->reportError( $IOS,
                       'FEATURES',
                       'unexpected line',
                       $line
                     );
    }
  }
}

1;

__END__
