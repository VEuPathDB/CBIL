package CBIL::ObjectMapper::RuleSet;

# ------------------------------------------------------------------------
# RuleSet.pm
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;
use XML::Simple;
use Tie::IxHash;

use CBIL::ObjectMapper::RuleSet::Rule;
use CBIL::ObjectMapper::RuleSet::Function;

use vars qw( @ISA @EXPORT @EXPORT_OK @xmloptions);

@xmloptions = ('keyattr' =>  [],
               'forcearray'=> 1,
               forcecontent => 1,
               'rootname' => 'ruleset',
               'xmldecl' => "<?xml version='1.0'  encoding='ISO-8859-1' standalone='no' ?>\n<!DOCTYPE ruleset SYSTEM 'ruleset.dtd' >",
               suppressempty => 1
               );

sub new {
	my ($M,$cfg,$dbg) = @_;
	my $slf = {};
	bless $slf,$M;
  $slf->_setParser(XML::Simple->new(@xmloptions));
  $slf->{rule} = Tie::IxHash->new();
  $slf->{__DEBUG} = $dbg;
	if ($cfg) {
    eval {
      $slf->initialize($slf->_getParser()->XMLin($cfg),$dbg);
    };
    print STDERR "FAILED RuleSet.INIT($cfg): $@\n" if $@;
    }
	return $slf;
}

sub initialize {
  my ($slf, $node,$dbg) = @_;
  $slf->setName($node->{name}) if $node->{name};
  $slf->setCfg($node->{cfg}) if $node->{cfg};
  $slf->setFunction(CBIL::ObjectMapper::RuleSet::Function->new($node->{function}->[0])) if ($node->{function}->[0]);
  foreach my $R (@{$node->{rule}}){
    $slf->addRule(CBIL::ObjectMapper::RuleSet::Rule->new($R));
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

sub getRule {
	my ($slf,$name) = @_;
  #  print STDERR "RULE ($name)=",$slf->{rule}->{$name}, ";\n" ;
	return $slf->{rule}->Values($slf->{rule}->Indices($name));
}

sub getRules {
	my ($slf) =@_;
	return $slf->{rule}->Values();
}

sub addRule {
	my ($slf,$r) =@_;
	if (UNIVERSAL::isa($r, "CBIL::ObjectMapper::RuleSet::Rule")){
		$slf->{rule}->Push($r->getName() => $r);
	}
}

sub getFunction {
	my ($slf) = @_;
	return $slf->{function};
}

sub setFunction {
	my ($slf,$func) =@_;
	if (UNIVERSAL::isa($func, "CBIL::ObjectMapper::RuleSet::Function")) {
		$slf->{function} = $func;
	}
}

sub setCfg {
	my ($slf,$cfg) = @_;
	$slf->{cfg} = $cfg;
}

sub getCfg {
	my ($slf) = @_;
	return $slf->{cfg};
}


sub getNameOfClass {
	return 'RuleSet';
}

sub toXml {
  my $slf = shift;
  return $slf->_getParser()->XMLout($slf->toHash());
}

sub toHash {
  my $slf = shift;
  my $ref = {};
  #tie %$ref, 'Tie::IxHash';
  $ref->{name} = $slf->getName() if $slf->getName() ;
  $ref->{cfg} = $slf->getCfg() if $slf->getCfg() ;
  if ($slf->getFunction()) {
    $ref->{function} = $slf->getFunction->toHash();
  }
  foreach my $r ($slf->getRules()) {
    push @{$ref->{rule}}, $r->toHash();
  }
  return $ref;
}

#################
# Private methods
#################
sub _getParser {
  my $slf = shift;
  return $slf->{__PARSER};
}

sub _setParser {
  my ($slf,$p)= @_;
  $slf->{__PARSER}= $p;
}

1;

