#!/usr/bin/perl

package CBIL::Util::Disp;

my $displayed;

sub Display {
	my $V = shift;
	my $P = shift || '';
	my $S = shift || STDOUT;
	my $D = shift || 100;

	init();
	display( $V, $P, $S, $D );
}

sub init { $displayed = undef }

sub display {
  my $O = shift;
  my $I = shift;
  my $H = shift;
	my $D = shift;

	# too deep
	return unless $D > 0;
	
	# already displayed
	if ( defined $displayed->{ $O } ) {
		print $H $I, "/". $O. "/". "\n";
	}
		
  # plain scalar.
  elsif ( not ref $O ) {
    print $H $I, $O, "\n";
  }
  
  # scalar, dereference for now.
  elsif ( ref $O eq 'SCALAR' ) {
    print $H $I, ${ $O}, "\n";
  }
  
  # reference to something
  elsif ( ref $O eq 'REF' ) {
    display( ${ $O }, $I. 'REF ', $H, $D - 1 );
		$displayed->{ $O } = 1;
  }
  
  # code? we don't do code!
  elsif ( ref $O eq 'CODE' ) {
    print $H $I, 'CODE', "\n";
  }
  
  # glob, don't do them either
  elsif ( ref $O eq 'GLOB' ) {
    print $H $I, 'GLOB', "\n";
  }
  
  # list
  elsif ( ref $O eq 'ARRAY' ) {
    my $elt; 
    my $b_allSimple = 1;
    my $i_length = 0;
    foreach $elt ( @{ $O }) {
      if ( ref $elt ) {
        $b_allSimple = 0;
        last;
      }
      $i_length += length( $elt );
    }
    
    print $H $I, "[ <", scalar @{ $O }, ">";
    
    if ( $b_allSimple && $i_length < 80 ) {
      print $H " ", join( ', ', @{ $O } ), " ]\n";
    }
    
    else {
      print $H "\n";
      
      my $i = ' ' x (length( $I ) + 2); 
      foreach $elt ( @{ $O }) {
        display( $elt, $i, $H, $D - 1 );
      }
      
      print $H $i, "]\n";
    }
  }
  
  # an object
  #elsif ( ref $O eq 'A' ) {
  else {

		$displayed->{ $O } = 1;

		my $key; 
    my $b_allSimple = 1;
    my $i_length = 0;
    my $i_width  = 0;
    foreach $key ( keys %{ $O }) {
      if ( ref $O->{ $key } ) {
        $b_allSimple = 0;
      }
      $i_length += length( $O->{ $key } );
      $i_width = length( $key ) if $i_width < length( $key );
    }
    
    print $H $I, "{ <", $O, "> ";
    
    if ( $b_allSimple && $i_length < 80 ) {
      print $H 
      ' ',
      join( ', ', map { sprintf "%s = '%s'", $_, $O->{$_} } sort keys %{ $O } ),
      " }\n";
    }
    else {
      print $H "\n";
      my $i = ' ' x (length( $I ) + 2); 
      foreach $key ( sort keys %{ $O }) {
        my $atti = sprintf( "$i%-${i_width}.${i_width}s = ", $key );
        display( $O->{ $key }, $atti, $H, $D - 1 );
      }
      print $H $i, "}\n";
    }
  }
}

1;


