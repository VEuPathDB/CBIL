package CBIL::ObjectMapper::RuleSet::Rule;

# ------------------------------------------------------------------------
# RuleSet::Rule.pm
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;
use Tie::IxHash;

use CBIL::ObjectMapper::RuleSet::IOClass;

sub new {
	my ($slf,$node) = @_;
	$slf = {};
	bless $slf;
  $slf->{in} = Tie::IxHash->new();
  $slf->{out} = Tie::IxHash->new();
	if ($node) {
    $slf->instantiate($node);
  }
  return $slf;
}

sub instantiate {
  my ($slf, $node) = @_;
  $slf->setName($node->{name}) if $node->{name};
  foreach my $c (@{$node->{in}}){
    $slf->addInput(CBIL::ObjectMapper::RuleSet::IOClass->new($c));
  }
  foreach my $c (@{$node->{out}}){
    $slf->addOutput(CBIL::ObjectMapper::RuleSet::IOClass->new($c));
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

sub getInput {
	my ($slf,$name) = @_;
	return $slf->{in}->Values($slf->{in}->Indices($name));
}

sub getInputs {
	my ($slf) =@_;
	return $slf->{in}->Values();
}

sub setInputs {
	my ($slf,$io_classes) = @_;
  foreach my $c (@$io_classes) {
    $slf->addInput($c);
  }
}

sub addInput {
	my ($slf,$c) =@_;
	if (UNIVERSAL::isa($c, "CBIL::ObjectMapper::RuleSet::IOClass")){
		$slf->{in}->Push($c->getName() => $c);
	}
}

sub getOutput {
	my ($slf,$name) = @_;
	return $slf->{out}->Values($slf->{out}->Indices($name));
}

sub getOutputs {
	my ($slf) =@_;
	return $slf->{out}->Values();
}

sub setOutputs {
	my ($slf,$io_classes) =@_;
  foreach my $c (@$io_classes) {
    $slf->addOutput($c);
  }
}

sub setOutput {
	my ($slf,$idx, $io_class) =@_;
  if ( UNIVERSAL::isa($io_class, "CBIL::ObjectMapper::RuleSet::IOClass")) {
    $slf->{out}->Replace($idx,$io_class , $io_class->getName());
  }
}

sub addOutput {
	my ($slf,$c) =@_;
	if (UNIVERSAL::isa($c, "CBIL::ObjectMapper::RuleSet::IOClass")){
		$slf->{out}->Push($c->getName() => $c);
	}
}

sub toHash {
  my $slf = shift;
  my $ref = {} ;
  $ref->{name} = $slf->getName() if  $slf->getName() ;
  foreach my $o ($slf->getOutputs()) {
    push @{$ref->{out}}, $o->toHash();
  }
  foreach my $i ($slf->getInputs()) {
    push @{$ref->{in}}, $i->toHash();
  }
  return $ref;
}
1;

__END__

=pod 

=head1 CBIL::ObjectMapper::RuleSet::Rule

=head2 Summary

Represents single rule for transformation of a set of inputs to a set of (possibly related) outputs. 
Inputs and outputs are represented via C<CBIL::ObjectMapper::RuleSet::IOClass>. 

=head2 Usage

  my $slot = CBIL::ObjectMapper::RuleSet::Rule->new($hashref);

where $hashref contains the specifications for the input and output C<CBIL::ObjectMapper::RuleSet::IOClass>. 
The contructor for  C<CBIL::ObjectMapper::RuleSet::IOClass> is called within for both the inputs and outputs.

 
=head2 Notes

Please note that this class is really only meant to be used by classes within this package. I don't 
see any other useful applications for it.


=cut
