#!/usr/bin/perl

=pod

=head1 Name

C<csp::command> - a command item in a C<csp::dialog>.

=head1 Description

=head1 Style_Config

relies on the following style configuration attributes.

C<CSP_SMALL_TOHELP_ICON}

=head1 Methods

=over 4

=cut

package CBIL::CSP::Command;

BEGIN {
  warn ">>> CBIL::CSP::Command\n";
}

@ISA = qw( CBIL::CSP::Item );

# ----------------------------------------------------------------------
=pod

=item new

creates a new command.

B<Arguments:>

=cut

sub new {
  my $class = shift;
  my $args = shift;
  
  #return undef unless $args->ensure('value');
  
  my $self = new CBIL::CSP::Item($args);
  
  bless $self, $class;

  undef $self->{items};
  
  return $self;
}

# ----------------------------------------------------------------------

=pod

=item makeModality

generates HTML string for form section.

Use a submit button to gather which will be the form anchor.

Includes the help link.

B<Arguments:>

none

=cut

sub makeModality {
  my $self = shift;
  
  # input modality
  my $btn = $self->submit(new CBIL::Util::A +{
				   name  => $self->{name},
				   value => $self->{text}
				  });

  return $btn;
}

# ----------------------------------------------------------------------

=pod

=item makeDisplay

generaters HTML for the entire form part.

=cut

sub makeDisplay {
  my $self = shift;

  my $rv
    = $self->tableData(new CBIL::Util::A +{
				viz => $self->makeModality(),
			       }
		      );

  return $rv;
}

# ----------------------------------------------------------------------

BEGIN {
  warn "<<< CBIL::CSP::Command\n";
}

1;

