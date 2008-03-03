
package CBIL::Bio::GenBank::IoStream;

use strict 'vars';

sub new {
  my $C = shift;
  my $A = shift;

  my $m = bless {}, $C;

  $m->{FH} = $A->{fh};
  $m->{LB} = [];
  $m->{LN} = 0;

  $m;
}

sub getLineNumber { $_[0]->{LN} }

sub eof {
  my $M = shift;

  if ( scalar @{ $M->{LB} } > 0 ) {
    return 0;
  }
  else {
    my $fh = $M->{FH};
    return $fh->eof()
  }
}

sub getLine {
  my $M = shift;

  if ( scalar @{ $M->{LB} } > 0 ) {
    return pop( @{ $M->{LB} } );
  }
  else {
    my $fh = $M->{FH};
    my $line = <$fh>;
    $M->{LN}++;
    return $line;
  }
}

sub putLine {
  my $M = shift;
  my $L = shift;

  push( @{ $M->{LB} }, $L );
}


1;

__END__
