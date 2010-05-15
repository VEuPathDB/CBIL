
package CBIL::Cider::Cider;

=pod

=head1 Purpose

C<CBIL::Cider::Cider> is the root object for a set of packages that
help generate a website with using page body parts, a navbar, and a
configurable look-and-feel.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================


use CBIL::Util::Hify;

use strict 'vars';

# ----------------------------------------------------------------------

sub new {
	my $C = shift;
	my $A = shift;

	my $m = bless {}, $C;

	$m->init($A);

	return $m;
}

# ----------------------------------------------------------------------

sub init {
	my $M = shift;
	my $A = shift;

	$M->setHify(CBIL::Util::Hify->new);

	foreach my $att (Macros) {
		my $method = "set$att";
		$M->$method($A->{$att}) if exists $A->{$att};
	}

	if (my $app_f  = $A->{ConfigXmlFile}) {
		$M->loadAppearanceConfigFile($app_f);
	}

	if (my $desc_f = $A->{DescriptionFile}) {
		$M->loadDescriptionFile($desc_f);
	}

	return $M
}

# ----------------------------------------------------------------------

sub setPrefix { $_[0]->{Prefix} = $_[1]; $_[0] }
sub getPrefix { $_[0]->{Prefix} }

# ----------------------------------------------------------------------

sub setHify { $_[0]->{Hify} = $_[1]; $_[0] }
sub getHify { $_[0]->{Hify} }

# ----------------------------------------------------------------------

sub setMacros { $_[0]->{Macros} = $_[1]; $_[0] }
sub getMacros { $_[0]->{Macros} }

sub addMacro {
	my $M = shift;
	my $N = shift;
	my $V = shift;

	$M->{Macros}->{$N} = $V;

	return $M;
}

sub getMacro {
	my $M = shift;
	my $N = shift;

	my $expansion = $M->{Macros}->{$N};
	if (not defined $expansion) {
		print STDERR join("\t", __PACKAGE__, 'no macro defined', $N), "\n";
	}
	return $expansion;
}

sub forgetMacro {
	my $M = shift;
	my $N = shift;

	erase $M->{Macros}->{$N};

	return $M;
}

# ----------------------------------------------------------------------

sub setAppearance { $_[0]->{Appearance} = $_[1]; $_[0] }
sub getAppearance { $_[0]->{Appearance} }
sub loadAppearanceConfigFile {
	my $M = shift;
	my $F = shift;

	use XML::Simple;

	my $xp = XML::Simple->new;
	my $ac_xml = $xp->XMLin($F);

	$M
	->setAppearance($ac_xml)
	->generateAppearanceConfigMacros()
	;

	return $M
}

sub generateAppearanceConfigMacros {
	my $M = shift;

	my @path = ();
	my $code;
	$code = sub {
		my $O = shift;

		my $type = ref $O;

		if ($type eq 'HASH') {
			foreach my $key (keys %$O) {
				push(@path, $key);
				$code->($O->{$key});
				pop(@path);
			}
		}

		elsif ($type eq 'ARRAY') {
			for (my $i = 0; $i < @$O; $i++) {
				push(@path, $i+1);
				$code->($O->[$i]);
				pop(@path);
			}
		}

		else {
			my $macro = join('.', @path);
			$M->addMacro($macro,$O);
			my $variable = join('_', @path);
			eval "$ $variable = \$O";
		}

		return;
	};

	$code->($M->getAppearance);

	return $M
}

sub resource {
	my $M = shift;
	my $R = shift;

	return $M->getMacro($R);
}

# ======================================================================

sub loadDescriptionFile {
	my $M = shift;
	my $F = shift;

	my $input = CBIL::Cider::Input->new($F);

	print "SCANNING\n";

	# mapping from regexp matcher to code to call.
	my @dispatch =
	(

	 # comment do nothing
	 { rex => '^\s*#',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

		 },
	 },

	 # blank line; skip it
	 { rex => '^\s*$',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

			 $I->incIndex;

		 },
	 },

	 # macro definition load it and add to collection
	 { rex => '^MACRO',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

			 $I->getLine->{line} =~ /^MACRO\s+(\S+)\s+(.+)/;
			 $S->addMacro($1,$2);
			 $I->incIndex;
		 },
	 },

	 { rex => '^RELEASE',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

			 $I->getLine->{line} =~ /RELEASE\s+(.+)/;
			 $S->setRelease($1);

			 $I->incIndex;
		 },
	 },

	 # end of section
	 { rex => '^\/\/',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

			 $I->incIndex;
		 },
	 },

	 # load page defaults
	 { rex => '^DEFAULTS',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

			 $S->loadDefaults($I);
		 },
	 },

	 # class
	 { rex => '^CBIL::Cider::.+',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

			 $I->getLine->{line} =~ /^(CBIL::Cider::.+)/;
			 my $class = $1;
			 eval "require $class";
			 my $obj = eval "new $class";
			 $obj->initFromInput($I);
			 $S->addObject($obj);
		 }
	 },

	 # unrecognized
   { rex => '.?',
		 sub => sub {
			 my $S = shift;
			 my $I = shift;

			 my $line = $I->getLine;

			 print STDERR join("\t",
												 'ERR',
												 'unrecognized tag',
												 $line->{count},
												 $line->{file},
												 $line->{line}
												), "\n";
			 exit 0;
		 },
	 },
	);

 Lines:
	while (my $line = $input->getLine) {
		#Disp::Display($line);

	Handlers:
		foreach my $handler (@dispatch) {
			if ($line->{line} =~ /$handler->{rex}/) {
				$handler->{sub}->($M,$input);
				last Handlers;
			}
		}
	}

	# define built-in macros;
	my $now_t = localtime;
	$M->addMacro('update', $now_t);

	# define configuration macros
	# TBD

	# process text
	$M->expandMacros();

	#Disp::Display($M);

	#exit 0;
}

# ======================================================================

sub setRelease { $_[0]->{Release} = $_[1]; $_[0] }
sub getRelease { $_[0]->{Release} }

sub setDefaults { $_[0]->{Defaults} = $_[1]; $_[0] }
sub getDefaults { $_[0]->{Defaults} }
sub loadDefaults {
	my $M = shift;
	my $I = shift;

	$I->incIndex;
	my $defaults = CBIL::Cider::Reader::read(CBIL::Cider::Page->getLegalAttributes, $I);
	$M->setDefaults($defaults);

	return $M;
}

# ----------------------------------------------------------------------
# expand macros in all object attributes that appear to be scalars.

sub expandMacros {
	my $M = shift;

	my @obj = ();

	# defaults
	push(@obj, $M->getDefaults);

	# objects
	push(@obj, values %{$M->getObjects || {}});

	# expand every macro in every (scalar) attribute of every queued object.
	foreach my $obj (@obj) {
		foreach my $att (keys %$obj) {
			next if ref $obj->{$att};
			$obj->{$att} = $M->expand_all($obj->{$att});
		}
	}
}

sub expand_all {
	my $M = shift;
	my $T = shift;

	my $rv = $T;

	my $macros = $M->getMacros();
	#Disp::Display($macros,undef,STDERR);
	foreach my $mac (keys %$macros) {
		$rv = expandMacro($rv, $mac, $macros->{$mac});
	}

	$rv
}

sub expandMacro {
	my $T = shift;
	my $N = shift;
	my $M = shift;

	#print STDERR join("\t", $N, $M ), "\n";

	$T =~ s/\^\^\^$N\^\^\^/$M/g;

	$T
}

# strips HTML
sub __sh {
	my $T = shift;

	$T =~ s/<.+?>//g;
	$T =~ s/&.+?;//g;

	$T
}


# ======================================================================

sub getObjects {
	my $M = shift;
	my $T = shift;

	$T = ref $T if ref $T;

	return $M->{Objects}->{T};
}

sub addObject {
	my $M = shift;
	my $O = shift;

	my $type = ref $O;

	push(@{$M->{Objects}->{$type}},$O);

	return $M
}

# ======================================================================


1;
