#/usr/bin/perl

=pod

hash of tag => {
  o  => option
	h  => hint
	d  => default
	e  => error checking
  l  => value can be a list
  ld => list delimiter
  t  => type
  r  => required
}

=cut

package CBIL::Util::EasyCsp;

use strict 'vars';

require Getopt::Long;

use CBIL::Util::A;

# ======================================================================
# --------------------------- TYPE NAMES -------------------------------
# ======================================================================

$CBIL::Util::EasyCsp::String  = 'string';
$CBIL::Util::EasyCsp::Float   = 'float';
$CBIL::Util::EasyCsp::Int     = 'int';
$CBIL::Util::EasyCsp::Boolean = 'boolean';

# ----------------------------------------------------------------------


sub DoItAll {
	my $Desc   = shift;
	my $Usage  = shift;

  $Desc = { map {($_->{o} => $_)} @$Desc } if ref $Desc eq 'ARRAY';

	my $cla = GetOptions( $Desc );

	my $rv = $cla->{ usage } || ! ErrorCheck( $Desc, $cla );

	print STDERR UsageString( $Desc, $Usage ) if $rv;

	return $rv ? undef : $cla;
}

sub GetOptions {
	my $D = shift;  # a descriptor

	# arguments from command line.
	my $cla = CBIL::Util::A::e;

	# assemble an options descriptor
	my %cld;

	# standards
	my $so = &StandardOptions;
	foreach ( keys %{ $so } ) {
		#$cld{ $so->{ $_ }->{ o } } = \$cla->{ $_ };
		$cld{ _optionTag( $so->{ $_ } ) } = \$cla->{ $_ };
	}

	foreach ( keys %{ $D } ) {
		#$cld{ $D->{ $_ }->{ o } } = \$cla->{ $_ };
		$cld{ _optionTag( $D->{ $_ } ) } = \$cla->{ $_ };
	}

	#CBIL::Util::Disp::Display( \%cld );

	# process the arguments
	my $ok = Getopt::Long::GetOptions( %cld );

	$cla = { usage => 1 } if ! $ok;

	return $cla;
}

=pod
=head1 StandardOptions
=cut

sub StandardOptions {

	return {
		verbose => { o => 'verbose', t => 'boolean', h => 'generate lots of output' },
		veryVerbose => { o => 'veryVerbose', t => 'boolean', h => 'generate reams of output' },
		debug   => { o => 'debug',   t => 'boolean', h => 'turn on debugging output' },
    usage   => { o => 'help',    t => 'boolean', h => 'get usage' }
	};

}

=pod
=head1 UsageString



=cut

sub _ftag {
	my $tag = shift;
	my $leader = defined $tag ? '--' : '  ';
	sprintf( "  %s%-24.24s", $leader, $tag );
}

sub _optionTag {
	my $Opt = shift;

	if ( defined $Opt->{ t } ) {
		my $tag = $Opt->{ o };
		$tag =~ s/=.$//;
		$tag =~ s/!//;

		if ( $Opt->{ l } ) {
			return "$tag=s";
		}
		elsif ( $Opt->{ t } =~ /^s(t(r(i(n(g)?)?)?)?)?$/i ) {
			return "$tag=s";
		}
		elsif ( $Opt->{ t } =~ /^f(l(o(a(t)?)?)?)?$/i ) {
			return "$tag=f";
		}
		elsif ( $Opt->{ t } =~ /^i(n(t)?)?$/i ) {
			return "$tag=i";
		}
		elsif ( $Opt->{ t } =~ /^b(o(o(l(e(a(n)?)?)?)?)?)?$/i ) {
			return "$tag!";
		}
		else {
			return "$tag=s";
		}
	}
	else {
		return $Opt->{ o }
	}
}

# ----------------------------------------------------------------------
# generate usage string for a single option.

sub single_usage {
	my $O = shift; 

	my @RV;

	return '' unless defined $O->{o};

	push(@RV, join("\t", _ftag(_optionTag($O))));
	push(@RV,   "\thint:     $O->{h}");
	push(@RV,   "\ttype:     $O->{t}") if defined $O->{t};
	if ($O->{l} ) {
		my $delim =defined $O->{ld} ? "$O->{ld}" : ',';
		push(@RV, "\tlist:     delimit values with a '$delim'" );
	}
	if (defined $O->{e}) {
		my $s_legal = join(', ', @{$O->{e}});
		push(@RV, "\tpatterns: $s_legal" );
	}
	push(@RV,   "\tdefault:  $O->{d}") if defined $O->{d};
	push(@RV,   "\tREQUIRED!")        if $O->{r};

	join("\n",@RV). "\n"
}

# ----------------------------------------------------------------------
# generate whole usage message.

sub UsageString {
	my $D = shift;
	my $T = shift;

	my $s_rv;


	$s_rv .= $T. "\n";
	$s_rv .= "Usage:\n";

	my @all_options = sort { lc $a->{o} cmp lc $b->{o} } ((values %{&StandardOptions}),
																												(values %$D),
																											 );
	$s_rv .= join("\n",
								map {single_usage($_)} @all_options
							 ). "\n";

#	my $so =  &StandardOptions;
#	foreach ( sort keys %{ $so } ) {
#		$s rv .= single_usage($so->{$_});
#		$s_rv .= join( "\t",
#									 #'',
#									 _ftag( _optionTag( $so->{ $_ }) ), 
#									 "$so->{ $_ }->{ h }",
#								 ). "\n";
#		$s_rv .= join( "\t",
#									 _ftag( undef ),
#									 "   type:    $so->{ $_ }->{ t }",
#								 ). "\n"
#								 if defined $so->{ $_ }->{ t };
#		$s_rv .= join( "\t", 
#									 _ftag( undef ),
#									 "   default: $so->{ $_ }->{ d }" 
#								 ). "\n"
#								 if defined $so->{ $_ }->{ d };
#		$s_rv .= join( "\t",
#									 _ftag( undef ),
#									 "   REQUIRED!",
#								 ). "\n"
#								 if defined $so->{ $_ }->{ r };
#		$s_rv .= "\n";
#
#	}
#
#  foreach ( sort keys %{ $D } ) {
#		$s_rv .= join( "\t",
#									 #'',
#									 _ftag( _optionTag( $D->{ $_ } ) ),
#									 "$D->{ $_ }->{ h }",
#								 ). "\n";
#		$s_rv .= join( "\t",
#									 _ftag( undef ),
#									 "   type:    $D->{ $_ }->{ t }",
#								 ). "\n"
#								 if defined $D->{ $_ }->{ t };
#		$s_rv .= join( "\t", 
#									 #'',
#									 _ftag( undef ),
#									 "   REQUIRED!",
#								 ). "\n"
#								 if defined $D->{ $_ }->{ r };
#		$s_rv .= join( "\t", 
#									 #'',
#									 _ftag( undef ),
#									 "   default: $D->{ $_ }->{ d }"
#								 ). "\n"
#								 if defined $D->{ $_ }->{ d };
#		if ( $D->{ $_ }->{ l } ) {
#			my $delim = defined $D->{ $_ }->{ ld } ? "'$D->{ $_ }->{ ld }'" : "','";
#			$s_rv .= join( "\t", 
#										 #'', 
#										 _ftag( undef ),
#										 "  list delimited by a '$delim'\n" )
#		}
#		if ( defined $D->{ $_ }->{ e } ) {
#			my $s_legal = join( ', ', @{ $D->{ $_ }->{ e } } );
#			$s_rv .= join( "\t", 
#										 #'', 
#										 _ftag( undef ),
#										 "   legal values: $s_legal" ). "\n";
#		}
#		$s_rv .= "\n";
#
#	}
#
	return $s_rv;
}

sub ErrorCheck {
	my $D = shift;
	my $V = shift;

	my $b_allOk = 1;

	my $tag; foreach $tag ( sort keys %{ $D } ) {

		# set default values
		if ( ! defined $V->{ $tag } && exists $D->{ $tag }->{ d } ) {
			$V->{ $tag } = $D->{ $tag }->{ d };
		}

		# check for required values
		if ($D->{$tag}->{r}) {
			if (not defined $V->{$tag}) {
				print STDERR "No value supplied for required option $tag.\n";
				$b_allOk = 0;
			}
		}

		# split lists on comma
		if ( $D->{ $tag }->{ l } ) {
			my $ld = $D->{ tag }->{ ld } || ',';
			$V->{$tag} = [ split( $ld, $V->{ $tag } ) ];
		}

		# enforce pattern matching requirements if required or defined
		if (ref $D->{$tag}->{e} eq 'ARRAY' &&
				(defined $V->{$tag} || $D->{$tag}->{r})
			 ) {

			# values to consider
			my @values = ref $V->{$tag} ? @{$V->{$tag}} : ($V->{$tag});

			# values that did not match an RX.
			my @bad_values;

		ALL_CHECK:
			foreach my $value (@values) {
				my $b_ok = 0;

			IDV_CHECK:
				foreach my $pat_rx (@{$D->{$tag}->{e}}) {
					if ($V->{ $tag } =~ $pat_rx) {
						$b_ok = 1;
						last;
					}
				}

				unless ($b_ok) {
					push(@bad_values, $value);
				}
			}

			if (@bad_values) {
				print STDERR join("\t",
													'BADVAL(S)',
													"--$D->{$tag}->{o}",
													join(', ', map {"'$_'"} @bad_values),
												 ), "\n";
				$b_allOk = 0;
			}
		}
	}

	return $b_allOk;
}

# ......................................................................

1;

__END__


my $ecd = { map {($_->{o},$_)}
						( { h => 'sequence logo',
								t => 'string',
								r => 1,
								e => [ 'a+c+g+t+' ],
								o => 'Logo'
							},
						)
					};

my $cla = DoItAll( $ecd, 'Test of CBIL::Util::EasyCsp.pm' );

require CBIL::Util::Disp;
CBIL::Util::Disp::Display( $cla );


