package CBIL::ObjectMapper::RuleSet::IOClass;

# ------------------------------------------------------------------------
# RuleSet::IOClass.pm
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;
use Tie::IxHash;

use CBIL::ObjectMapper::RuleSet::Slot;

#use vars qw( );

sub new {
	my ($slf,$node) = @_;
	$slf = {};
	bless $slf;
  $slf->{slot} = Tie::IxHash->new();

	if ($node) {
    $slf->instantiate($node);
  }
  return $slf;
}

sub instantiate {
  my ($slf, $node) = @_;
  $slf->setName($node->{name}) if $node->{name};
  $slf->setClassName($node->{className}) if $node->{className};
  foreach my $s (@{$node->{slot}}){
    $slf->addSlot(CBIL::ObjectMapper::RuleSet::Slot->new($s));
  }
}

sub getName {
	my $slf = shift;
	return $slf->{name};
}

sub setName {
	my ($slf,$name) =@_;
	$slf->{name} = $name;
}

sub getClassName {
	my $slf = shift;
	return $slf->{className};
}

sub setClassName {
  my ($slf,$cname) =@_;
  # convert className to perl equivalent
  $cname =~ s/\./::/g;
  $slf->{className} = $cname;
}

sub getSlot {
  my ($slf,$name) = @_;
  return $slf->{slot}->Values($slf->{slot}->Indices($name));
}

sub getSlots {
	my ($slf) =@_;
	return $slf->{slot}->Values();
}

sub setSlots {
	my ($slf,$slots) = @_;
  $slf->{slot} = Tie::IxHash->new();
  foreach my $s (@$slots) {
    $slf->addSlot($s);
  }
}

sub addSlot {
	my ($slf,$s) =@_;
	if ($s->isa ("CBIL::ObjectMapper::RuleSet::Slot")){
		$slf->{slot}->Push($s->getName() => $s);
	}
}

sub toHash {
  my $slf = shift;
  my $ref = {};
  $ref->{name} = $slf->getName() if $slf->getName() ;
  if ($slf->getClassName() ) {
    $ref->{className} = $slf->getClassName();
    # return non-perlish classname
    $ref->{className} =~ s/\:\:/\./g;
  }
  foreach my $s ($slf->getSlots()) {
    push @{$ref->{slot}}, $s->toHash();
  }
  return $ref;
}

1;

__END__

=pod 

=head1 CBIL::ObjectMapper::RuleSet::IOClass

=head2 Summary

A representation of a Perl object serving as an input or output to a 
C<CBIL::ObjectMapper::RuleSet::Rule>. The attributes and assocations of the object are
represented by contained C<CBIL::ObjectMapper::RuleSet::Slot> and the constructor passes 
the specifications for C<RuleSet::Slot> to its constructor.

=head2 Usage

  my $ioclass = CBIL::ObjectMapper::RuleSet::IOClass->new($hashref);

where $hashref contains the specifcation for the IOClass and the specifications for all
contained C<RuleSet::Slot>.

  $hashref = {name => "name to refer to class by",
              className => "fully qualified Perl object name",
              slot => [CBIL::ObjectMapper::RuleSet::Slot]
              };

                
=head2 Notes

Please note that this class is really only meant to be used by classes within this package. I don't 
see any other useful applications for it.

=cut
