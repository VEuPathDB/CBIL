
package CBIL::Cider::Part::Introduction;
@ISA = qw( CBIL::Cider::Part );

use strict;

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
	my $M = shift;
	my $A = shift;

	my $type = ref $A;

	if ($type eq 'HASH') {
		foreach my $att (qw( Body Title )) {
			my $method = "set$att";
			$M->$method($A->{$att});
		}
	}

	return $M
}

# ----------------------------------------------------------------------

sub setBody { $_[0]->{Body} = $_[1]; $_[0] }
sub getBody { $_[0]->{Body} }

sub setTitle { $_[0]->{Title} = $_[1]; $_[0] }
sub getTitle { $_[0]->{Title} }

# ----------------------------------------------------------------------
# 

sub html {
	my $M = shift;
	my $C = shift;

	# terse access to this
	my $h = $C->getHify;

	return join("\n",
							$h->e_TR({ viz => join("\n",
                                     $h->e_TD({ viz    => $M->getTitle() || '&nbsp;',
                                                class  => 'introTab', #$C->resource('Appearance.Titles.Class'),
                                                width  => $C->resource('Appearance.PageLayout.Columns.Left.Width'),
                                              }),
                                     $h->e_TD({ class  => 'introBody', #$C->resource('Appearance.Introduction.Class'),
                                                viz    => $M->getBody(),
                                                width  => $C->resource('Appearance.PageLayout.Columns.Right.Width'),
                                              }),
                                    ),
                       }),
							$h->e_TR({ viz => $h->e_TD({ viz     => $h->e_HR({}),
                                           colspan => 2
                                         }),
                       }),
             );
}

# ----------------------------------------------------------------------

1;


