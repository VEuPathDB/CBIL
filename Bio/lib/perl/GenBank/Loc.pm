####################################################################
#
#    This file was generated using Parse::Yapp version 1.03.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package CBIL::Bio::GenBank::Loc;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.03',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'NUM' => 1,
			'LIT' => 6,
			"<" => 7,
			">" => 8,
			'ID' => 10,
			"(" => 4,
			'OP' => 14
		},
		GOTOS => {
			'location' => 5,
			'endpoint' => 2,
			'operator' => 9,
			'midpoint' => 3,
			'range' => 12,
			'literal' => 11,
			'loc' => 13
		}
	},
	{#State 1
		ACTIONS => {
			'MIDP' => 15
		},
		DEFAULT => -12
	},
	{#State 2
		ACTIONS => {
			'RANGE' => 16
		},
		DEFAULT => -6
	},
	{#State 3
		DEFAULT => -5
	},
	{#State 4
		ACTIONS => {
			'NUM' => 17,
			"<" => 7,
			">" => 8,
			"(" => 4,
			'OP' => 14
		},
		GOTOS => {
			'endpoint' => 18,
			'singlechoose' => 19,
			'operator' => 20
		}
	},
	{#State 5
		ACTIONS => {
			'' => 21
		}
	},
	{#State 6
		DEFAULT => -8
	},
	{#State 7
		ACTIONS => {
			'NUM' => 22
		}
	},
	{#State 8
		ACTIONS => {
			'NUM' => 23
		}
	},
	{#State 9
		ACTIONS => {
			'RANGE' => -16
		},
		DEFAULT => -7
	},
	{#State 10
		ACTIONS => {
			":" => 24
		}
	},
	{#State 11
		DEFAULT => -3
	},
	{#State 12
		DEFAULT => -4
	},
	{#State 13
		DEFAULT => -1
	},
	{#State 14
		ACTIONS => {
			"(" => 25
		}
	},
	{#State 15
		ACTIONS => {
			'NUM' => 26
		}
	},
	{#State 16
		ACTIONS => {
			'NUM' => 17,
			"<" => 7,
			">" => 8,
			"(" => 4,
			'OP' => 14
		},
		GOTOS => {
			'endpoint' => 27,
			'operator' => 20
		}
	},
	{#State 17
		DEFAULT => -12
	},
	{#State 18
		ACTIONS => {
			'SINGLE' => 28
		}
	},
	{#State 19
		ACTIONS => {
			")" => 29
		}
	},
	{#State 20
		DEFAULT => -16
	},
	{#State 21
		DEFAULT => -0
	},
	{#State 22
		DEFAULT => -14
	},
	{#State 23
		DEFAULT => -13
	},
	{#State 24
		ACTIONS => {
			'NUM' => 1,
			'LIT' => 6,
			"<" => 7,
			">" => 8,
			"(" => 4,
			'OP' => 14
		},
		GOTOS => {
			'endpoint' => 2,
			'operator' => 9,
			'midpoint' => 3,
			'literal' => 11,
			'range' => 12,
			'loc' => 30
		}
	},
	{#State 25
		ACTIONS => {
			'NUM' => 1,
			'LIT' => 6,
			"<" => 7,
			">" => 8,
			'ID' => 10,
			"(" => 4,
			'OP' => 14
		},
		GOTOS => {
			'endpoint' => 2,
			'listoflocs' => 31,
			'midpoint' => 3,
			'location' => 32,
			'operator' => 9,
			'range' => 12,
			'literal' => 11,
			'loc' => 13
		}
	},
	{#State 26
		DEFAULT => -17
	},
	{#State 27
		DEFAULT => -11
	},
	{#State 28
		ACTIONS => {
			'NUM' => 17,
			"<" => 7,
			">" => 8,
			"(" => 4,
			'OP' => 14
		},
		GOTOS => {
			'endpoint' => 33,
			'operator' => 20
		}
	},
	{#State 29
		DEFAULT => -15
	},
	{#State 30
		DEFAULT => -2
	},
	{#State 31
		ACTIONS => {
			")" => 34
		}
	},
	{#State 32
		ACTIONS => {
			"," => 36
		},
		DEFAULT => -20,
		GOTOS => {
			'morelocs' => 35
		}
	},
	{#State 33
		DEFAULT => -9
	},
	{#State 34
		DEFAULT => -10
	},
	{#State 35
		DEFAULT => -18
	},
	{#State 36
		ACTIONS => {
			'NUM' => 1,
			'LIT' => 6,
			"<" => 7,
			">" => 8,
			'ID' => 10,
			"(" => 4,
			'OP' => 14
		},
		GOTOS => {
			'location' => 37,
			'endpoint' => 2,
			'operator' => 9,
			'midpoint' => 3,
			'literal' => 11,
			'range' => 12,
			'loc' => 13
		}
	},
	{#State 37
		ACTIONS => {
			"," => 36
		},
		DEFAULT => -20,
		GOTOS => {
			'morelocs' => 38
		}
	},
	{#State 38
		DEFAULT => -19
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'location', 1, undef
	],
	[#Rule 2
		 'location', 3,
sub
#line 4 "Loc.yp"
{ [ 'xref', $_[1], $_[3] ] }
	],
	[#Rule 3
		 'loc', 1, undef
	],
	[#Rule 4
		 'loc', 1, undef
	],
	[#Rule 5
		 'loc', 1, undef
	],
	[#Rule 6
		 'loc', 1, undef
	],
	[#Rule 7
		 'loc', 1, undef
	],
	[#Rule 8
		 'literal', 1,
sub
#line 8 "Loc.yp"
{ [ 'literal', $_[1] ] }
	],
	[#Rule 9
		 'singlechoose', 3,
sub
#line 12 "Loc.yp"
{ [ 'single', $_[1], $_[3] ] }
	],
	[#Rule 10
		 'operator', 4,
sub
#line 14 "Loc.yp"
{ [ $_[1], @{$_[3]} ] }
	],
	[#Rule 11
		 'range', 3,
sub
#line 16 "Loc.yp"
{ [ 'span', $_[1], $_[3] ] }
	],
	[#Rule 12
		 'endpoint', 1,
sub
#line 18 "Loc.yp"
{ [ 'exact', $_[1] ] }
	],
	[#Rule 13
		 'endpoint', 2,
sub
#line 19 "Loc.yp"
{ [ 'above', $_[2] ] }
	],
	[#Rule 14
		 'endpoint', 2,
sub
#line 20 "Loc.yp"
{ [ 'below', $_[2] ] }
	],
	[#Rule 15
		 'endpoint', 3,
sub
#line 21 "Loc.yp"
{ [ $_[2] ] }
	],
	[#Rule 16
		 'endpoint', 1, undef
	],
	[#Rule 17
		 'midpoint', 3,
sub
#line 25 "Loc.yp"
{ [ 'midpoint', $_[1], $_[3] ] }
	],
	[#Rule 18
		 'listoflocs', 2,
sub
#line 27 "Loc.yp"
{ [ $_[1], @{$_[2]} ] }
	],
	[#Rule 19
		 'morelocs', 3,
sub
#line 29 "Loc.yp"
{ [ $_[2], @{$_[3]} ] }
	],
	[#Rule 20
		 'morelocs', 0,
sub
#line 30 "Loc.yp"
{ [] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 32 "Loc.yp"


#package CBIL::Bio::GenBank::Loc;
#use vars qw ( @ISA );
use strict;

#@ISA= qw ( Parse::Yapp::Driver );
#use Parse::Yapp::Driver;

# ----------------------------------------------------------------------

my $ActiveString;
my $InitialString;
my $IsValid;

sub _Error {
  my $P = shift;

	$IsValid = 0;
  print join( "\t", 'ERR', 'syntax in CBIL::Bio::GenBank::Loc', $InitialString, $P->YYData ), "\n";
  exists $P->YYData->{ERRMSG}
  and do {
    print $P->YYData->{ERRMSG};
    delete $P->YYData->{ERRMSG};
    return;
  };
  CBIL::Util::Disp::Display($P);
}

sub _Lexer {
  my $P = shift;

	#print "_Lexer\n";

  my $yyd = $P->YYData;

  # scan for significant text
  while ( ! $yyd->{INPUT} ) {
    $yyd->{INPUT} = $ActiveString or return ('',undef);
    undef $ActiveString;
    $yyd->{INPUT} =~ s/^[ \t]+//;
    $yyd->{INPUT} =~ s/[ \n]$//;
    last if length $yyd->{INPUT} > 0;
    delete $yyd->{INPUT};
  }

  my @rv;
  #print join( "\t", 'LYP', $yyd->{INPUT} ), "\n";

  for ( $yyd->{INPUT} ) {
    s/^\s+//;

    # positive integers
    if ( s/^(\d+)// ) {
      @rv = ('NUM',$1);        last;
    }

    # operators
    elsif(
          s/^(complement)// ||
          s/^(join)// ||
          s/^(oneof)// ||
          s/^(one-of)// ||
          s/^(order)// ||
          s/^(group)// ||
          s/^(replace)// ||
          0
         ) {
      @rv = ( 'OP', $1);       last;
    }

    # literal
    elsif ( s/^"([^"]*)"// ) {
      @rv = ( 'LIT', $1);      last;
    }

    # id
    elsif ( s/^([a-zA-Z]+\d+)(?:\.(\d+))?// ) {
      @rv = ( 'ID', [ $1, $2 ] );  last;
    }

		# range
		elsif ( s/^\.\.// ) {
			@rv = ( 'RANGE' ); last;
		}

		# single choose
		elsif ( s/^\.// ) {
			@rv = ( 'SINGLE' ); last;
		}

		# mid point
		elsif ( s/^\^// ) {
			@rv = ( 'MIDP' ); last;
		}

    # single char
    elsif ( s/^(.)// ) {
      @rv = ( $1,$1 );
    }
  }

  #print join( "\t", 'LYP', @rv ), "\n";

  @rv
}

sub Run {
  my $M = shift;
  $ActiveString = shift;
  $InitialString = $ActiveString;

	$IsValid = 1;
  print join( "\t", 'RUN', $InitialString ), "\n";
  my $rv = $M->YYParse( yylex   => \&_Lexer,
                        yyerror => \&_Error
                      );

#  CBIL::Util::Disp::Display( $rv );

  $rv
}

sub IsValid {
	my $M = shift;

	# RETURN
	$IsValid
}

1;
