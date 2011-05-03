
package CBIL::Cider::Renderer::Basic;

# ----------------------------------------------------------------------

use strict;

# ----------------------------------------------------------------------

sub new {
	my $Class = shift;
	my $Args  = shift;

	my $self = bless {}, $Class; #$CBIL::Cider;

	$self->init($Args);

	return $self;
}

# ----------------------------------------------------------------------

sub init {
	my $Self = shift;
	my $Args = shift;

	$Self->setCider                ( $Args->{Cider               } );

	return $Self;
}

# ----------------------------------------------------------------------

sub getCider                { $_[0]->{'Cider'                       } }
sub setCider                { $_[0]->{'Cider'                       } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub render {
	my $Self = shift;
	my $Xml  = shift;

	
}

# ----------------------------------------------------------------------
=pod

=head2 SideBar

SideBars have a C<Style> that is used to set the appearance
configuration.  A sidebar is rendered as a C<TABLE>.

=cut

sub renderSideBar {
	my $Self    = shift;
	my $SideBar = shift;

	my $cider = $Self->getCider();
	my $hify  = $cider->getHify();

	my $prefix = "Appearance.SideBar.$SideBar->{Style}";

	my @rows;

	push(@rows,
			 $hify->e_tr({ viz => $hify->e_td({ viz   => $SideBar->{Title},
																					style => "@@$prefix.Title.Style@@",
																				}),
									 })
			) if defined $SideBar->{Title};

	# render any Contents
	my $method;

	push(@rows,
			 map {
				 $method = 'render'. 
				 $hify->e_tr({ viz => $hify->e_td({ viz => $Self->renderSummary($_),
																					}),
										 })
			 } @{$SideBar->{Contents}})
	if scalar @{$SideBar->{Summary}};

	my $RV = $hify->e_table({ viz   => join("\t",
																				@rows),
														style => "@@$prefix.Table.Style@@"
													});

	return $RV;
}


# ----------------------------------------------------------------------
=pod

=head2 Summary

Assumes summaries have a C<Title> and C<Content>.  These are rendered
as a C<TABLE> with the title and content in two rows.

Configued with: C<Summary.Title.Style>, C<Summary.Content.Style> and
C<Summary.TableStyle>.

=cut

sub renderSummary {
	my $Self    = shift;
	my $Summary = shift;

	my $cider = $Self->getCider();
	my $hify  = $cider->getHify();

	my $RV = $hify->e_table({ viz => join("\n",
																				$hify->e_tr({ viz => $hify->e_td({ viz   => $Summary->getTitle,
																																					 style => '@@Summary.Title.Style@@',
																																				 }),
																										}),
																				$hify->e_tr({ viz => $hify->e_td({ viz   => $Summary->{Content},
																																					 style => '@@Summary.Content.Style@@',
																																				 }),
																										}),
																			 ),
														style => '@@Summary.Table.Style@@'
													});
	return $RV;
}


1;


