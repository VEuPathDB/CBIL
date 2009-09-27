#!/usr/bin/perl
=head1 Name

C<TO> - basic object class.

=head1 Description

C<TO> is a basic object in the ooTESS system.  Every other object should be 
a sub-class of an C<TO> either directly or indirectly.

=head1 Methods

=over 4

=cut

package CBIL::Util::TO;

#BEGIN {
#  warn ">>> TO\n";
#}

use Carp;
use Exporter;

@ISA = qw( Exporter );
@EXPORT 
  = qw ( new attributes typeCheck check oneOf ensure toString dump copy );

# ----------------------------------------------------------------------
=pod
=item AUTOLOAD

Supports Get* and Set* methods for attributes.  Name of attribute must
begin with a letter to indicate that it is public.  Others, will be
passed on.

=cut

sub AUTOLOAD {
  my $self = shift;
  
  my $type = ref $self;
  return undef unless $type;
  
  my $name = $AUTOLOAD;
  
  $name =~ s/.*://;

  # a get method
  if ($name =~ /^Get([a-zA-Z].+)$/) {
    my $att = $1;

    return $self->{$att};
  }

  # set method
  elsif ($name =~ /^Set([a-zA-Z].+)$/) {
    my $att = $1;

    return $self->{$att} = shift;
  }

  else {
    croak "Unknown method '$name' for class '$type'.\n";
  }
}

# ----------------------------------------------------------------------

use strict vars;

# ----------------------------------------------------------------------

=item e

creates an empty C<TO> object.  Hopes are that C<TO:e> is prettier than
C<new CBIL::Util::A +{}>.

Arguments:

none.

=cut

sub e {
  my $self = {};
  
  return bless $self, "TO";
}

# ----------------------------------------------------------------------

=item new

creates a new C<TO> object.  Takes a hash ref with the initial attributes.

=cut

sub new {
  my $class = shift;
  my $args  = shift;
  
  #warn sprintf("about to bless a '%s' to be a '%s'.\n", ref $args, $class);

  my $self = bless {}, $class;
  
  $self->copy($args, keys %$args);

  #my $self = $args ? $args : { };
  
  return $self;
}

# ----------------------------------------------------------------------

=item attributes

returns all the attributes of an C<TO> as an ARRAY ref.

=cut

sub attributes {
  my $self = shift;
  
  return [ keys %{$self} ];
}

# ----------------------------------------------------------------------

=item typeCheck

checks to see whether listed attributes type check.

Arguments:

A list of attribute/type pairs.  The types are either a single value or a 
ARRAY ref when the type is polymorphic.

All attributes are not required to be present.

Type strings may be regular expressions.

=cut

sub typeCheck {
  my $self = shift;
  my $args = shift;
  
  my $rv;
  
  foreach ($args->attributes()) {
    my $actType = $self->{$_};
    my $lglTypes = $args->{$_};
    
    # a list of types
    if (ref $lglTypes eq 'ARRAY') {
      my $lglType;
      my $type; foreach $type (@ $lglTypes) {
        $rv = 1 if $actType =~ $type;
      }
      
      if (not $rv) {
        my $types = join(',', @ $lglTypes);
        carp("actual type '$actType' does not match one of $types.\n");
      }
    }
    
    # a scalar.
    elsif (not ref $lglTypes) {
      if ($actType =~ $lglTypes) {
     }
     else {
       $rv = 1;
     }
    }
    
    # not legal mechanism of specifing types
    else {
      carp(sprintf("TO::typeCheck: %s\'s ref '%s' is a bad argument.\n",
      $_,
      ref $lglTypes));
    }
  }
  
  return $rv;
}

# ----------------------------------------------------------------------

=item check

looks to see if all required attribute are in the objects.  Does 
not complain if they are not.  C<check> can be used to check for optional 
attributes and take action accordingly.

Arguments:

A list of attribute names.

=cut

sub check {
  my $self = shift;
   
  my $b_rv = 1;
    
  foreach (@_) {
    if (not defined $self->{$_}) {
      $b_rv = 0;
    }
  }
    
  return $b_rv;
}

# ----------------------------------------------------------------------

=item oneOf

looks to see if at least one attribute is present in the objects.  
Does not complain if they are not.

Arguments:

A list of attribute names.

=cut

sub oneOf {
  my $self = shift;
   
  my $b_rv = 0;
    
  foreach (@_) {
    if (defined $self->{$_}) {
      $b_rv = 1;
    }
  }
    
  return $b_rv;
}
# ----------------------------------------------------------------------

=item ensure

is like C<check> except that it carps if attributes are not 
present.  Use C<ensure> to do 'type checking'.

=cut

sub ensure {
  my $self = shift;
    
  my $b_rv = 1;
    
  foreach (@_) {
    if (not defined $self->{$_}) {
      $b_rv = 0;
      confess "TO::ensure: $_ is not defined.\n";
    }
  }
    
  return $b_rv;
}

# ----------------------------------------------------------------------

=item toString

converts an C<TO> to a string which it returns.

=cut

sub toString {
  my $self = shift;
  my $args = shift;
    
  my $format = "%s%-32.32s\t%s\n";
    
  my $rv = sprintf($format, $args->{INTRO}, 'class', ref $self);
    
  foreach (sort @{$self->attributes()}) {
    $rv .= sprintf($format, $args->{INTRO}, $_, $self->{$_});
  }
  
  return $rv;
}

# ----------------------------------------------------------------------

=item dump

is like C<toString> except that it writes to a file.

Arguments:

  opt FH output filehandle; uses STDOUT if FH is not supplied.

=cut

sub dump {
  my $self = shift;
  my $args = shift;
    
  $args = TO::e unless $args;
  
  my $fh = $args->{FH} ? $args->{FH} : STDOUT;
 
  $args->{INTRO} = "" unless $args->check('INTRO');
    
  print $fh $self->toString($args);
}

# ----------------------------------------------------------------------

=item copy

copies requested attributes from one C<TO> to another.

=cut

sub copy {
  my $self  = shift;
  my $other = shift;
  
  foreach (@_) {
    $self->{$_} = $other->{$_};
  }
}

# ----------------------------------------------------------------------

=item safeCopy

copies requested attributes from one C<TO> to another as long as they
are defined in other.

=cut

sub safeCopy {
  my $self  = shift;
  my $other = shift;
  
  foreach (@_) {
    $self->{$_} = $other->{$_} if defined $other->{$_};
  }
}

# ----------------------------------------------------------------------
=pod
=item cast

=cut

sub cast {
  my $self = shift;
  my $class = shift;

  # save current class;
  push(@{$self->{__TO_CAST_STACK__}}, ref $self);

  bless $self, $class;
}

=pod
=item tsac

undo last cast

=cut

sub tsac {
  my $self = shift;

  my $class = pop @{$self->{__TO_CAST_STACK__}} or ref $self;

  bless $self, $class;
}

# ----------------------------------------------------------------------

=back

=cut

# ----------------------------------------------------------------------

#END {
#  warn "<<< TO\n";
#}

1;

