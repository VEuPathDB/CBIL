
package CBIL::Cider::Part::NavBar::Option;
@ISA = qw( CBIL::Cider::Part );

use strict 'vars';

# ----------------------------------------------------------------------

sub new {
   my $Class = shift;
   my $Args  = ref $_[0] ? shift : {@_};

   my $Self = bless {}, $Class;

   $Self->init($Args);

   return $Self
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->setText                 ( $Args->{Text                } );
   $Self->setHref                 ( $Args->{Href                } );
   $Self->setTarget               ( $Args->{Target              } );
   $Self->setNavBar               ( $Args->{NavBar              } );

   return $Self
}

# ----------------------------------------------------------------------

sub getText                 { $_[0]->{'Text'              } }
sub setText                 { $_[0]->{'Text'              } = $_[1]; $_[0] }

sub getHref                 { $_[0]->{'Href'              } }
sub setHref                 { $_[0]->{'Href'              } = $_[1]; $_[0] }

sub getTarget               { $_[0]->{'Target'            } }
sub setTarget               { $_[0]->{'Target'            } = $_[1]; $_[0] }

sub getNavBar               { $_[0]->{'NavBar'            } }
sub setNavBar               { $_[0]->{'NavBar'            } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub html {
	my $Self = shift;
	my $C = shift;

	# terse access to this
	my $h = $C->getHify;

	my $class = $Self->getNavBar()->getCssClass();
	my $rez   = $Self->getNavBar()->getLevel() eq 'Major' ? 'NavBar' : 'NavBarMini';

	my $rv;

	# make a link if we have an href
	if (defined $Self->getHref()) {
		$rv = $h->A({ viz   => $Self->getText(),
                  class => $class,
                  #										class => $C->resource("Appearance.$rez.A.Class"),
                  href  => $Self->getHref,
                  $Self->getTarget ? ( target => $Self->getTarget ) : (),
                });
	}

	# otherise just make some text
	else {
     $rv = $Self->getText();
     #$rv = $h->e_font({ viz   => $Self->getText,
     #                   class => $C->resource("Appearance.$rez.Class"),
     #                   class => $rez,
     #                 });
	}

	return $rv;
}

# ----------------------------------------------------------------------

1;


