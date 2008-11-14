
package CBIL::Cider::Part::Tab;

use strict;

# ----------------------------------------------------------------------

sub new  {
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

	if (my $type = ref $A) {

		# init from hash
		if ($type eq 'HASH') {
			foreach ($M->getLegalAttributes) {
				$M->{$_} = $A->{$_};
			}
		}

		# from Input
		elsif ($A->isa('CBIL::Cider::Input')) {
			$M->initFromInput($A);
		}

	}

	return $M
}

# ----------------------------------------------------------------------

sub initFromInput {
	my $M = shift;
	my $I = shift;

	$I->incIndex;

	my @atts = map { uc $_ } $M->getLegalAttributes;
	$M->init(CBIL::Cider::Reader::read(\@atts,$I));

	return $M
}

# ----------------------------------------------------------------------

sub getLegalAttributes {
	return qw( Level Tag Body );
}

# ----------------------------------------------------------------------

sub setLevel { $_[0]->{Level} = $_[1]; $_[0] }
sub getLevel { $_[0]->{Level} }

sub setTag { $_[0]->{Tag} = $_[1]; $_[0] }
sub getTag { $_[0]->{Tag} }

sub setBody { $_[0]->{Body} = $_[1]; $_[0] }
sub getBody { $_[0]->{Body} }

# ----------------------------------------------------------------------

sub html {
	my $M = shift;
	my $C = shift; # CBIL::Cider

	my $h = $C->getHify;

	my $class = 'tab'. $M->getLevel;

	my $tag_html =
	$h->e_TD({ viz    => $M->getTag,
						 width  => $C->resource("Appearance.PageLayout.Columns.Left.Width"),
						 class  => 'tab'. $M->getLevel(). 'Label',
					 });

	my $content_html =
	$h->e_TD({ viz    => $M->getBody,
						 width  => $C->resource("Appearance.PageLayout.Columns.Right.Width"),
						 align  => 'left',
						 valign => 'top',
						 class  => 'tab'. $M->getLevel(). 'Body',
					 });

	return $h->e_TR({ viz => join("\n", $tag_html, $content_html),
									});
}

# ----------------------------------------------------------------------

1;


