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
=pod 

=head1 CBIL::ObjectMapper::RuleSet

=head2 SUMMARY

C<CBIL::ObjectMapper::RuleSet> represent a specification of declarative 
rules for transforming a set of inputs to a set of outputs. The specification is
serialized as XML (see DTD below for full specification) and the constructor takes 
either a string or filehandle or filelocation of the XML specification for a 
C<RuleSet>.

=head1 Methods

=head2 new([$cfg])

The constructor. Optionally takes in a configuration file handle, file location or XML string 
See the DTD specification below for the XML configuration file syntax. 

=cut

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


__END__

=pod 

=head2 USAGE

  my $ruleset = CBIL::ObjectMapper::RuleSet->new($config);

where $config is a file location/handle or XML string validated with the following DTD. 

=head2 DTD specification

      <?xml version="1.0"  encoding="ISO-8859-1" ?>
      <!ELEMENT ruleset (function?,rule*)>
      <!ATTLIST ruleset
             name CDATA #IMPLIED
            cfg CDATA #IMPLIED  
      >
      
      <!ELEMENT function (nvt*)>
      <!ATTLIST function 
            cfg CDATA #IMPLIED 
      >
      
      <!ELEMENT rule ((in*|out+),(out+|in*))>
      <!ATTLIST rule 
         name  CDATA #IMPLIED
      >
      
      <!ELEMENT in (slot*)>
      <!ATTLIST in
                name CDATA #IMPLIED 
                className CDATA #IMPLIED >
      
      <!ELEMENT out (slot*)>
      <!ATTLIST out
         name  CDATA #IMPLIED
         className CDATA #IMPLIED
      >
      
      <!ELEMENT slot (nvt)>
      <!ATTLIST slot
         name  CDATA #IMPLIED
         method CDATA #IMPLIED
      >
      
      <!ELEMENT nvt (nvt*)>
      <!ATTLIST nvt  
         name CDATA #IMPLIED 
         value CDATA #IMPLIED
         type  (scalar|func|data|rule|rulelist|string) 'scalar'
      >

=head2 Notes

This package was meant to be a simple  object translation specification and grew out of efforts to 
translate between gene expression object domains, specifically C<GUS::Model::RAD> and  C<Bio::MAGE>. 

While recursive calls to rules may be done, I found it simpler and easier to understand the mappings
if the more complex transformations happened within colling programs, rather than the C<RuleSet> 
specification itself. 


=head2 Release Notes

Created:  Mon Jun 16 12:13:44 EDT 2003
Author: Angel Pizarro

$Revision$ $Date$ $Author$


=cut
