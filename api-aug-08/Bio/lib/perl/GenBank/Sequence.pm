
package CBIL::Bio::GenBank::Sequence;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub setSequence { $_[0]->{SEQ} = $_[1]; $_[0] }

sub getSequence { $_[0]->{SEQ} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  my $seq;

  # scan rest of sequence
  while ( my $line = $IOS->getLine() ) {

    # sequence prefaced by index
    if ( $line =~ /^\s*\d+\s+(.+)/ ) {
      $seq .= $1;
    }

    # end of sequence
    else {
      $IOS->putLine($line);
      last;
    }
  }

  $seq =~ s/ //g;

  $M->setSequence($seq);

  $M;
}

1;

