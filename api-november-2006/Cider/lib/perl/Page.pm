
package CBIL::Cider::Page;

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
	my $Self = shift;
	my $Args = shift;

  $Self->setMeta(' ');

  $Self->setHeadPlate            ( $Args->{HeadPlate           } );
  $Self->setTitlePlate           ( $Args->{TitlePlate          } );
  $Self->setFootPlate            ( $Args->{FootPlate           } );
  $Self->setMeta                 ( $Args->{Meta                } );
  $Self->setTitle                ( $Args->{Title               } );
  $Self->setNavBar               ( $Args->{NavBar              } );
  $Self->setNavBarMini           ( $Args->{NavBarMini          } );
  $Self->setBodyParts            ( $Args->{BodyParts           } );

	return $Self;
}

# ----------------------------------------------------------------------


sub setHeadPlate { $_[0]->{HeadPlate} = $_[1]; $_[0] }
sub getHeadPlate { $_[0]->{HeadPlate} }

sub setTitlePlate { $_[0]->{TitlePlate} = $_[1]; $_[0] }
sub getTitlePlate { $_[0]->{TitlePlate} }

sub setFootPlate { $_[0]->{FootPlate} = $_[1]; $_[0] }
sub getFootPlate { $_[0]->{FootPlate} }

sub setMeta { $_[0]->{Meta} = $_[1]; $_[0] }
sub getMeta { $_[0]->{Meta} }

sub setTitle { $_[0]->{Title} = $_[1]; $_[0] }
sub getTitle { $_[0]->{Title} }

sub setNavBar { $_[0]->{NavBar} = $_[1]; $_[0] }
sub getNavBar { $_[0]->{NavBar} }

sub setNavBarMini { $_[0]->{NavBarMini} = $_[1]; $_[0] }
sub getNavBarMini { $_[0]->{NavBarMini} }

sub setBodyParts { $_[0]->{BodyParts} = $_[1]; $_[0] }
sub getBodyParts { $_[0]->{BodyParts} }

# ----------------------------------------------------------------------

sub html {
	my $Self = shift;
	my $C = shift;

	my $h = $C->getHify;

	my $head_html = $Self->getHeadPlate;
	$head_html = CBIL::Cider::Cider::expandMacro($head_html,'title',$Self->getTitle);
	$head_html = CBIL::Cider::Cider::expandMacro($head_html,'meta', $Self->getMeta);

	my $title_html = $Self->getTitlePlate;
	$title_html = CBIL::Cider::Cider::expandMacro($title_html,'title',$Self->getTitle);

	my $navbar_html = $Self->getNavBar->html($C);
	my $navbar_mini_html = $Self->getNavBarMini ? $Self->getNavBarMini->html($C) : '';

	my $body_html = $h->e_table
	({ viz         => join("\n",
												 map { $_->html($C)} @{$Self->getBodyParts}
												),
		 width       => '100%',
		 cellspacing => $C->resource('Appearance.PageLayout.Tables.Cellspacing'),
	 });

	my $foot_html = $Self->getFootPlate;

	return join("\n",
							$h->contentType,
							$C->expand_all(join("\n",
																	$head_html,
																	$title_html,
																	$navbar_html,
																	$navbar_mini_html,
																	$body_html,
																	$foot_html
																 ))
						 );
}



# ----------------------------------------------------------------------

1;


