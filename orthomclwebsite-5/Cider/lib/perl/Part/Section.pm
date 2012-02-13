
package CBIL::Cider::Part::Section;

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
	return qw( Title Body );
}

# ----------------------------------------------------------------------

sub setTitle { $_[0]->{Title} = $_[1]; $_[0] }
sub getTitle { $_[0]->{Title} }

sub setBody { $_[0]->{Body} = $_[1]; $_[0] }
sub getBody { $_[0]->{Body} }

# ----------------------------------------------------------------------

sub html {
	my $M = shift;
	my $C = shift; # CBIL::Cider

	my $h = $C->getHify;

	my $tag_html =
	$h->e_td({
						viz   => $M->getTitle(),
						class => 'tableTitle',
					 });

	my $content_html =
	$h->e_td({
						viz    => $M->getBody(),
						class  => 'tableBody',
						width  => $C->resource("Appearance.PageLayout.Columns.Right.Width"),
					 });

	return $h->e_table({ cellspacing => 0,
											 width       => '100%',
											 viz => join("\n",
																	 map { $h->e_tr({ viz => $_ }) } ($tag_html, $content_html)
                                   )
                     });
}

# ----------------------------------------------------------------------

1;


