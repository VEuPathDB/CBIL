package CBIL::ObjectMapper::RuleSet::Function;

# ------------------------------------------------------------------------
# RuleSet::Function.pm
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;
use Exporter;
use Tie::IxHash;

use CBIL::ObjectMapper::RuleSet::NVT;

use vars qw / @ISA @EXPORT @EXPORT_OK /;

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
  $slf->setCfg($node->{cfg}) if $node->{cfg};
  $slf->{nvt} = {};
  foreach my $f ( @{$node->{nvt}} ){
    $slf->addFunc(CBIL::ObjectMapper::RuleSet::NVT->new($f));
  }
}

sub getCfg {
	my $slf = shift;
	return $slf->{cfg};
}

sub setCfg {
	my ($slf,$cfg) =@_;
	$slf->{cfg} = $cfg;
}

sub getFunc {
	my ($slf,$name) =@_;
	return $slf->{nvt}->{$name};
}

sub getFuncs {
	my ($slf) =@_;
	return values %{$slf->{nvt}};
}

sub setFuncs {
	my ($slf,$funcs) = @_;
  foreach my $f (@$funcs) {
    $slf->addFunc($f);
  }
}

sub addFunc {
	my ($slf,$v) =@_;
	if (UNIVERSAL::isa($v, "RuleSet::NVT")){
    $slf->{nvt}->{$v->getName()} =  $v ;
  }
}

sub toHash {
  my $slf = shift;
  my $ref = {};
  $ref->{cfg} = $slf->getCfg() if $slf->getCfg();
  foreach my $f ($slf->getFuncs()) {
    push @{$ref->{nvt}}, $f->toHash();
  }
  return $ref;
}

1;

