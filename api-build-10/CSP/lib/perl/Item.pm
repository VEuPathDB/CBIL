#/usr/bin/perl

=pod
=head1 Name

C<csp::item> - basic dialog element item.

=head1 Description

Inherits from C<csp::html> so that any item can be used to create HTML 
easily.

=head1 Attributes

which helps answer questions about style.

C<name> which is used to refer to the item.

C<text> bit of text which every item can use to display itself.

C<depth> depth in hierarchy.  Generally used to guide indentation.  
Defaults to 0 when an item is created, then is adjusted when it is added to 
a topic.

C<help> bit of help text.

C<seealso> list of other items of interest.

=cut

package CBIL::CSP::Item;

BEGIN {
  warn ">>> CBIL::CSP::Item\n";
}

@ISA = qw ( CBIL::CSP::Tohtml );
@EXPORT = qw ( new );

use strict "vars";

use CBIL::CSP::Tohtml;

# ======================================================================
=pod
=head1 Methods

=head2 Create and Utility Methods

=over 4

=cut

# ----------------------------------------------------------------------

=pod
=item new

creates a new item.

Arguments:

req C<style_config>

req C<name>

req C<text>

req C<help>

opt C<seealso>

=cut

sub new {
  my $class = shift;
  my $args = shift;
  
  return undef unless $args->ensure('style_config', 'name', 'text', 'help');
  
  my $self = new CBIL::CSP::Tohtml $args;
  
  bless $self, $class;
  
  $self->copy($args, 'style_config', 'name', 'text', 'help', 'seealso');
  
  return $self;
}

# ======================================================================
=pod
=back

=head2 HTML-Generating Methods

=over 4

=cut

# ----------------------------------------------------------------------

=pod
=item makeDisplay

create the input (form) part of the item.

=cut

sub makeDisplay {
  my $self = shift;
  my $args = shift;

  #print STDERR "CBIL::CSP::Item::makeDisplay: $self->{text}\n";

  return $self->tableData(new CBIL::Util::A +{viz => $self->{text}});
}

# ----------------------------------------------------------------------
=pod
=item helpTarget

creates the anchor tag HTML for the help section.

Arguments:

C<viz> the stuff that is visible in the help link.

=cut

sub helpTarget {
  my $self = shift;
  my $args = shift;
  
  return undef unless $self->ensure('tag', 'viz');
  
  return $self->anchor(new o +{
	name => "$self->{tag}.help",
	viz  => $args->{viz} 
  });
}

# ----------------------------------------------------------------------

=item helpLink

creates the reference tag HTML for a link to the help section of an object.

Arguments:

C<viz> the stuff that is visible in the help link.

=cut

sub helpLink {
  my $self = shift;
  my $args = shift;
  
  return undef unless $self->ensure('tag', 'viz');
  
  return $self->link(new o +{
	href => "$self->{tag}.help",
	viz  => $args->{viz} 
  });
}

# ----------------------------------------------------------------------
=pod
=item formTarget

creates the anchor tag HTML for the form section.

Arguments:

C<viz> the stuff that is visible in the form link.

=cut

sub formTarget {
  my $self = shift;
  my $args = shift;
  
  return undef unless $self->ensure('tag', 'viz');
  
  return $self->anchor(new o +{
			       name => "$self->{tag}.form",
			       viz  => $args->{viz} 
			      });
}

# ----------------------------------------------------------------------
=pod
=item formLink

creates the reference tag HTML for a link to the form section of an object.

Arguments:

C<viz> the stuff that is visible in the form link.

=cut

sub helpLink {
  my $self = shift;
  my $args = shift;
  
  return undef unless $self->ensure('tag', 'viz');
  
  return $self->link(new o +{
	href => "$self->{tag}.form",
	viz  => $args->{viz} 
  });
}

# ----------------------------------------------------------------------
=pod
=item seeAlso

adds 'See Also's HTML for the help section.

=cut

sub seeAlso {
  my $self = shift;
  
  my $rv = "<b>See Also:</b> ";
  
  # add each item.  Have to decide if these are items or tags.
  foreach (@ {$self->{seealso}}) {
    $rv .= $_->helpLink(new o +{ viz => $self->{tag}} );
  }
  
  return $rv;
}

# ======================================================================

sub gifToHelp {
  my $self = shift;
  my $args = shift;
  
  return undef unless 
  $args->ensure('style_config') and
  $args->{style_config}->ensure('CSP_TOHELP_GIF');
  
  return $self->toHelp(new SO +{
	viz => $self->{style_config}->{CSP_TOHELP_GIF}
  });
}

# ----------------------------------------------------------------------
=pod
=back

=cut

BEGIN {
  warn "<<< CBIL::CSP::Item\n";
}


1;
