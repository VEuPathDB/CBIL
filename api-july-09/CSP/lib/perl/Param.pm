#!/usr/bin/perl

=head1 Name

C<param> - a C<csp::item> which can be used to gather information.

=head1 Description

=head1 Attributes

C<optional>

C<type>

C<default>

C<ranges>

=head1 Style_Config

C<CSP_DEFAULT_FIELD_WIDTH> default width of fields.

=head1 Backward Compatibility of Tags

Here are the conversions from the non-oo CSP tags to current tags.

C<Name> -> C<name> which is inherited from C<item>.

C<Prompt> -> C<text> which is inherited from C<item>.

C<Optional> -> C<optional>

C<Defaults> -> C<defaults>

C<Range> -> C<range>

C<Length> -> C<length>

C<Type> -> C<type>

=head1 Methods

=over 4

=cut

package CBIL::CSP::Param;

BEGIN {
  warn "loading CBIL::CSP::Param package.\n";
}

@ISA = qw( CBIL::CSP::Item );

use strict vars;
use CBIL::CSP::Item;

# ----------------------------------------------------------------------

=item new

creates a new object.

Arguments:

=cut

sub new {
  my $class = shift;
  my $args  = shift;
  
  return undef unless $args->ensure('type');
  
  # try to create an item.
  my $self = new csp::item($args);
  
  return undef unless $self;
  
  # type check what we have
  $self->typeCheck( new SO +{
	type => '\w+_TypeDriver',
  });
  
  # add param stuff.
  $self->copy($args, 'type', 'optional', 'default', 'range', 'length');
  
  return $self;
}

# ----------------------------------------------------------------------

=item makeModality

return some HTML which is the input modality for the parameter.

For now we use a text field and assume this is a scalar.

=cut

sub makeModality {
  my $self = shift;
  my $args = shift;
  
  return undef unless $self->ensure('tag');
  
  # width; try several sources before using fixed parameter.
  my $width = $self->{width} 
  or length($self->{default}) 
  or $self->{style_config}->{CSP_DEFAULT_FIELD_WIDTH}
  or 10;
  
  return $self->textField(new SO +{
	name  => $self->{name},
	value => $self->{default},
	width => $width,
	
  });
  
}

# ----------------------------------------------------------------------

=item makeStencil

returns a template for placing the input in a nice context.

=cut

sub makeStencil {
  my $self = shift;
  
  return undef unless $self->ensure('text');
  
  my $units = $self->{units} ? "[$self->{units}]" : "";
  my $stencil = $self->{text} . "_PUT_IT_HERE_" . $units;
}
