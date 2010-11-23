package CBIL::ObjectMapper::RuleSet::NVT;


# ------------------------------------------------------------------------
# RuleSet::NVT.pm
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;

sub new {
	my ($slf,$node) = @_;
	$slf = {};
	bless $slf;
  $slf->setType('scalar');
  $slf->{nvt} = [];
	if ($node) {
    $slf->instantiate($node);
  }
  return $slf;
}

sub instantiate {
  my ($slf, $node) = @_;
  $slf->setName($node->{name}) if ($node->{name});
  $slf->setType($node->{type}) if $node->{type};
  $slf->setValue($node->{value}) if $node->{value};
  
  foreach my $nvt (@{$node->{nvt}}){
    $slf->addVal(CBIL::ObjectMapper::RuleSet::NVT->new($nvt));
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

sub getType {
	my $slf = shift;
	return $slf->{type};
}

sub setType {
	my ($slf,$t) =@_;
  # rule | rulelist | func | data | scalar | string
	$slf->{type} = $t if ($t =~/rule|rulelist|func|data|scalar|string/);
}

sub getValue {
	my ($slf,$name) = @_;
	return $slf->{value};
}

sub setValue {
	my ($slf,$v) =@_;
	$slf->{value} = $v;
}

sub getVal {
	my ($slf,$idx) =@_;
	return $slf->{nvt}->[$idx];
}

sub getVals {
	my ($slf) =@_;
	return $slf->{nvt};
}

sub setVals {
	my ($slf,$vals) = @_;
  $slf->{nvt} = [];
  foreach my $v (@$vals) {
    $slf->addVal($v);
  }
}

sub addVal {
  my ($slf,$v) =@_;
  if ($v->isa( "CBIL::ObjectMapper::RuleSet::NVT")){
    push @{$slf->{nvt}}, $v ;
  }
}


sub toHash {
  my $slf = shift;
  my $ref = {};
  $ref->{name} = $slf->getName() if $slf->getName() ;
  $ref->{value} = $slf->getValue() if $slf->getValue() ;
  $ref->{type} = $slf->getType() if $slf->getType() ;
  if ($slf->getVals()) {
    foreach my $v (@{$slf->getVals()}) {
      push @{$ref->{nvt}}, $v->toHash();
    }
  }
  return $ref;
}

1;

__END__

=pod 

=head1 CBIL::ObjectMapper::RuleSet::NVT

=head2 Summary

A fairly flexible container for (name, type, value) tuples used throughout the 
C<CBIL::ObjectMapper::RuleSet> package.

=head2 Notes

Please note that this class is really only meant to be used by classes within this package. I don't 
see any other useful applications for it.

=cut
