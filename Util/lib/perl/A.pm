#!/usr/bin/perl
=pod
=head1 Name

C<A> - basic object class.

=head1 Description

C<A> is a basic object in the ooTESS system.  Every other object should be 
a sub-class of an C<A> either directly or indirectly.

=head1 Methods

=over 4

=cut

package CBIL::Util::A;

#BEGIN {
#  warn ">>> A\n";
#}

use Carp;
use Exporter;

@ISA = qw( Exporter );
@EXPORT 
  = qw ( new attributes typeCheck check oneOf ensure toString dump copy );

# ----------------------------------------------------------------------

use strict "vars";

# ----------------------------------------------------------------------
=pod
=item e

creates an empty C<A> object.  Hopes are that C<A:e> is prettier than
C<new CBIL::Util::A +{}>.

Arguments:

none.

=cut

sub e {
  return bless {}, CBIL::Util::A;
}

# ----------------------------------------------------------------------
=pod
=item new

creates a new C<A> object.  Takes a hash ref with the initial attributes.

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
=pod
=item attributes

returns all the attributes of an C<A> as an ARRAY ref.

=cut

sub attributes {
  my $self = shift;
  
  return [ keys %{$self} ];
}

# ----------------------------------------------------------------------
=pod
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
      carp(sprintf("A::typeCheck: %s\'s ref '%s' is a bad argument.\n",
      $_,
      ref $lglTypes));
    }
  }
  
  return $rv;
}

# ----------------------------------------------------------------------
=pod
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
=pod
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
=pod
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
      confess "A::ensure: $_ is not defined.\n";
    }
  }
    
  return $b_rv;
}

# ----------------------------------------------------------------------
=pod
=item toString

converts an C<A> to a string which it returns.

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
=pod
=item dump

is like C<toString> except that it writes to a file.

Arguments:

  opt FH output filehandle; uses STDOUT if FH is not supplied.

=cut

sub dump {
  my $self = shift;
  my $args = shift;
    
  $args = A::e() unless $args;
  
  my $fh = $args->{FH} ? $args->{FH} : STDOUT;
 
  $args->{INTRO} = "" unless $args->check('INTRO');
    
  print $fh $self->toString($args);
}

# ----------------------------------------------------------------------
=pod
=item copy

copies requested attributes from one C<A> to another.

=cut

sub copy {
  my $self  = shift;
  my $other = shift;
  
  foreach (@_) {
    $self->{$_} = $other->{$_};
  }
}

=pod
=item safeSet
=cut

sub safeSet {
  my $Me = shift;
  my $A  = shift;

  my $n_set
    = 0;
    
  foreach (keys % $A) {
    if (not defined $Me->{$_}) {
      $Me->{$_} = $A->{$_};
      $n_set++;
    }
  }

  return $n_set;
}

# ----------------------------------------------------------------------
=pod
=item safeCopy

copies requested attributes from one C<A> to another as long as they
are defined in other.

=item crypticSafeCopy

is similar to C<safeCopy> but prepends an underscore to hide attribute
names.

=cut

sub safeCopy {
  my $self  = shift;
  my $other = shift;
  
  foreach (@_) {
    $self->{$_} = $other->{$_} if defined $other->{$_};
  }
}

sub crypticSafeCopy { crypticCopy( @_ ) }

sub crypticCopy { 
	my $self  = shift;
	my $other = shift;

	foreach ( @_ ) {
		$self->{ "_$_" } = $other->{ $_ } if defined $other->{ $_ };
	}
}

=pod
=item defGet 

returns the value of an attribute if it is defined otherwise returns
the default value.

=cut

sub defGet {
  my $M = shift;
  my $A = shift;
  my $D = shift;

  return defined $M->{$A} ? $M->{$A} : $D;
}

# ----------------------------------------------------------------------
=pod
=item cast

=cut

sub cast {
  my $self = shift;
  my $class = shift;

  # save current class;
  push(@{$self->{__A_CAST_STACK__}}, ref $self);

  bless $self, $class;
}

=pod
=item tsac

undo last cast

=cut

sub tsac {
  my $self = shift;

  my $class;
  if (scalar @{$self->{__A_CAST_STACK__}} > 0) {
    $class = @{$self->{__A_CAST_STACK__}};
  } else {
    $class = ref $self;
  }

  bless $self, $class;
}

# ----------------------------------------------------------------------
=pod
=back

=cut

# ----------------------------------------------------------------------

#END {
#  warn "<<< A\n";
#}

1;

