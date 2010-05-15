
package CBIL::Cider::PageForm;
@ISA = qw( CBIL::Cider::Page );

use strict 'vars';

use CBIL::Cider::Page;

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

	$M->SUPER::init($A);

	my $type = ref $A;

	if ($type eq 'HASH') {
		foreach my $att (Action, Method) {
			my $method = "set$att";
			$M->$method($A->{$att});
		}
	}

	return $M;
}

# ----------------------------------------------------------------------

sub setAction { $_[0]->{Action} = $_[1]; $_[0] }
sub getAction { $_[0]->{Action} }

sub setMethod { $_[0]->{Method} = $_[1]; $_[0] }
sub getMethod { $_[0]->{Method} }


# ----------------------------------------------------------------------

sub html {
	my $M = shift;
	my $C = shift;

	my $h = $C->getHify;

	my $head_html = $M->getHeadPlate;
	$head_html = CBIL::Cider::Cider::expandMacro($head_html,'title',$M->getTitle);
	$head_html = CBIL::Cider::Cider::expandMacro($head_html,'meta',$M->getMeta);

	my $title_html = $M->getTitlePlate;
	$title_html = CBIL::Cider::Cider::expandMacro($title_html,'title',$M->getTitle);

	my $navbar_html = $M->getNavBar->html($C);

	my $body_html = $h->e_table
	({ viz         => join("\n",
												 map { $_->html($C)} @{$M->getBodyParts}
												),
		 width       => '100%',
		 cellspacing => $C->resource('Appearance.PageLayout.Tables.Cellspacing'),
	 });

	my $form_html = $h->e_form({ viz    => $body_html,
															 action => $M->getAction,
															 method => $M->getMethod,
														 });

	my $foot_html = $M->getFootPlate;

	return join("\n",
							$h->contentType,
							$C->expand_all(join("\n",
																	$head_html,
																	$title_html,
																	$navbar_html,
																	$form_html,
																	$foot_html
																 ))
						 );
}

# ----------------------------------------------------------------------

# ----------------------------------------------------------------------

1;


