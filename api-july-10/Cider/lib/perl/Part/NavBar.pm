
package CBIL::Cider::Part::NavBar;
@ISA = qw( CBIL::Cider::Part );

use strict 'vars';

# ----------------------------------------------------------------------

sub new {
	my $C = shift;
	my $A = shift;

	my $m = bless {}, $C;

	$m->init($A);

	return $m
}

# ----------------------------------------------------------------------

sub init {
	my $Self = shift;
	my $A = shift;

	my $type = ref $A;

	if ($type eq 'HASH') {
		# set defaults
		$Self->setLevel('Major');

		# modify with caller's args.
		foreach my $att (qw( Options Level Divider )) {
			my $method = "set$att";
			$Self->$method($A->{$att});
		}

		# connect to options
		foreach (@{$Self->getOptions}) {
			$_->setNavBar($Self);
		}
	}

	return $Self
}

# ----------------------------------------------------------------------

sub setOptions { $_[0]->{Options} = $_[1]; $_[0] }
sub getOptions { $_[0]->{Options} }

sub setLevel   { $_[0]->{Level} = $_[1]; $_[0] }
sub getLevel   { $_[0]->{Level} }

sub setDivider { $_[0]->{Divider} = $_[1] || '|'; $_[0] }
sub getDivider { $_[0]->{Divider} }

# -------------------------- Derived Accessors ---------------------------

sub getCssClass {
   my $Self = shift;

   my $Rv = 'NavBar'. $Self->getLevel();

   return $Rv;
}

# ----------------------------------------------------------------------
# The format is a table with a single row and cell containing all of
# the options

sub html {
	my $Self = shift;
	my $C = shift;

	# terse access to this
	my $h = $C->getHify;

	#Disp::Display($Self,'NavBar',STDERR);

	my $class   = $Self->getCssClass();
	my $divider = $Self->getDivider();

	return
	$h->e_table({ class => $class,
								viz   => $h->TR({ class => $class,
                                  viz   => $h->TD({ class => $class,
                                                    viz   => join($divider,
                                                                  map {
                                                                     $_->html($C)
                                                                  } @{$Self->getOptions()}
                                                                 ),
                                                  })
                                }),
							});
}

# ----------------------------------------------------------------------

1;


