
package CBIL::Bio::GenBank::Qualifier;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use CBIL::Bio::GenBank::BaseObject;

use strict 'vars';

sub setTag      { $_[0]->{TAG} = $_[1]; $_[0] }
sub setValue    { $_[0]->{VAL} = $_[1]; $_[0] }
sub setOrdinal  { $_[0]->{ORD} = $_[1]; $_[0] }

sub getTag      { $_[0]->{TAG} }
sub getValue    { $_[0]->{VAL} }
sub getOrdinal  { $_[0]->{ORD} }

# joining effects
# -1 : join with no space and remove all white space.
#  0 : join with a space.
#  c : join with c, what ever c is.

my $squash = {
              translation => -1,
             };

# These are the strict versions that didn't work reliably on some test
# data.  Altered to the new version which is more forgiving.  If this
# continues to be a problem...
#sub isFirstLine        { $_[0] =~ m/^ {21}\// }
#sub isContinuationLine { $_[0] =~ m/^ {21}[^\/]/ }

sub isFirstLine        { $_[0] =~ m/^ {20}\s*\// }
sub isContinuationLine { $_[0] =~ m/^ {20}\s*[^\/ ]/ }

sub parse {
  my $M   = shift;
  my $IOS = shift;

  my @value;

  # get line with tag
  my $line = $IOS->getLine();
  unless ( isFirstLine($line) ) {
    $IOS->putLine($line);
    $M->setValidity(0);
    return $M;
  }
  chomp $line;
  $line =~ s/^\s+\///;
  my ( $tag, $value ) = split( '=', $line );
  push( @value, $value );

  # get any additional lines
  while ( $line = $IOS->getLine() ) {

    # looks like a continuation
    if ( isContinuationLine($line) ) {
      chomp $line;
      $line =~ s/^\s+//;
      push( @value, $line );
    }

    # start of something new
    else {
      $IOS->putLine($line);
      last;
    }
  }

  # remove white space
  if ( $squash->{$tag} < 0 ) {
    $value = join( '', @value );
    $value =~ s/ //g;
  }

  # just join as is
  elsif ( $squash->{$tag} > 0 ) {
    $value = join( $squash->{$tag}, @value );
  }

  # join with space
  else {
    $value = join( ' ', @value );
  }

  # remove the quotes.
  $value =~ s/^"//;
  $value =~ s/"$//;

  # set.
  $M->setTag($tag);
  $M->setValue($value);

#   print join( "\t", 'qualifier',
#               $tag,
#               $value
#             ), "\n";

  # return value
  $M
}



1;

__END__


