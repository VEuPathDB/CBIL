package CBIL::ObjectMapper::RuleSet::Slot;

# ------------------------------------------------------------------------
# RuleSet::Slot.pm
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;
use CBIL::ObjectMapper::RuleSet::NVT;

#use vars qw( );

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
	return $slf->{nvt};
}

sub setVal {
	my ($slf,$nvt) =@_;
	if (UNIVERSAL::isa($nvt, "CBIL::ObjectMapper::RuleSet::NVT")){
		$slf->{nvt} = $nvt;
	}
}

sub toHash {
  my $slf = shift;
  my $ref = {};
#  tie %$ref, 'Tie::IxHash';
  $ref->{name} = $slf->getName() if  $slf->getName() ;
  $ref->{method} = $slf->getMethod() if  $slf->getMethod() ;
  if ($slf->getVal()) {
    push @{$ref->{nvt}},  $slf->getVal()->toHash();
  }
  return $ref;
}

1;
