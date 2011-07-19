#!/usr/bin/perl

=pod

=head1 Name

C<Stencil> - an object to create structured input items.

=head1 Description

A Stencil allow the caller to intermingle text and input objects.  The
stencil has a template which is HTML text containing special tags
which are replaced by the input modalities for the objects inthe
stencil.

Match %pattern% in %attribute% if checked %selected%.

=head1 Methods

=over 4

=cut

package CBIL::CSP::Stencil;

BEGIN {
  warn ">>> CBIL::CSP::Stencil\n";
}

@ISA = qw ( CBIL::CSP::Topic );

use strict "vars";

use CBIL::CSP::Topic;

# ----------------------------------------------------------------------
=pod
=item makeModality

adds HTML for display of topic and items under it.

=cut

sub makeModality {
  my $self = shift;
  my $args = shift;

  # use text attribute as the template
  my $myMode = $self->{text};

  # collect the input modalities for the contained objects
  my $item; foreach $item (@ {$self->{items}}) {
    my $mode 
      = $item->makeModality();

    my $pat
      = ":" . $item->{name} . ":";

    $myMode =~ s/$pat/$mode/g;
  }
  
  return $myMode;
}

# ----------------------------------------------------------------------
=pod
=item makeDisplay

=cut

sub makeDisplay {
  my $self = shift;
  my $args = shift;

  my $mode = $self->makeModality();

  return $self->tableData(new TO 
			  +{viz => $mode
			   });
}
