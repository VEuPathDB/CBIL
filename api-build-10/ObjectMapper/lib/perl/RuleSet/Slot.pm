package CBIL::ObjectMapper::RuleSet::Slot;

# ------------------------------------------------------------------------
# RuleSet::Slot.pm
#
# Represents an attribute or assocation for the parent C<CBIL::ObjectMapper::RuleSet::IOClass>. 
#
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;
use CBIL::ObjectMapper::RuleSet::NVT;

sub new {
	my ($slf,$node) = @_;
	$slf = {};
	bless $slf;
	if ($node) {
    $slf->instantiate($node);
  }
  return $slf;
}

sub instantiate {
  my ($slf, $node) = @_;
  $slf->setName($node->{name}) if $node->{name};
  $slf->setMethod($node->{method}) if $node->{method};
  foreach my $nvt  (@{$node->{nvt}}){
    $slf->setVal(CBIL::ObjectMapper::RuleSet::NVT->new($nvt));
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

sub getMethod {
	my $slf = shift;
	return $slf->{method};
}

sub setMethod {
	my ($slf,$method) =@_;
	$slf->{method} = $method;
}

sub getVal {
	my ($slf) = @_;
	return $slf->{val};
}

sub setVal {
	my ($slf,$nvt) =@_;
	if (UNIVERSAL::isa($nvt, "CBIL::ObjectMapper::RuleSet::NVT")){
		$slf->{val} = $nvt;
	}
}

sub toHash {
  my $slf = shift;
  my $ref = {};
  $ref->{name} = $slf->getName() if  $slf->getName() ;
  $ref->{method} = $slf->getMethod() if  $slf->getMethod() ;
  if ($slf->getVal()) {
    push @{$ref->{nvt}},  $slf->getVal()->toHash();
  }
  return $ref;
}

1;
 
__END__

=pod 

=head1 CBIL::ObjectMapper::RuleSet::Slot

=head2 Summary

Represents an attribute or assocation for the parent C<CBIL::ObjectMapper::RuleSet::IOClass>. 

=head2 Usage

  my $hashref = {name => "slot name",
                 method => "access_subroutine_name", # note that this must be a valid subroutine name for the
                                                     # containing class represented by the IOClass.
                 val => CBIL::ObjectMapper::RuleSet::NVT
                 };
                 

  my $slot = CBIL::ObjectMapper::RuleSet::Slot->new($hashref);


or

  my $slot = CBIL::ObjectMapper::RuleSet::Slot->new();
  $s->setName( "slot name" );
  $s->setMethod( "valid_subroutine_access_method_name" );
  $s->setVal( CBIL::ObjectMapper::RuleSet::NVT );

 
=head2 Notes

Please note that this class is really only meant to be used by classes within this package. I don't 
see any other useful applications for it.


=cut
