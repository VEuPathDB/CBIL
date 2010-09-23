
package CBIL::Bio::GenBank::BaseCount;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub setCounts { $_[0]->{CNT}->{$_[1]} = $_[2]; $_[0] }

sub getCounts { $_[0]->{CNT}->{$_[1]} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('BASE COUNT', $IOS);

  $_ = $M->getString();
  s/^\s+//g;
  my @obs = split /\s+([a-z]+)\s*/;
  for ( my $i = 0; $i < scalar @obs; $i += 2 ) {
    $M->setCounts($obs[$i+1],$obs[$i]);
  }


  $M;
}

1;

