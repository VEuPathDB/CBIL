package CBIL::ObjectMapper::RuleSetEngine;

# ------------------------------------------------------------------------
# RuleSetEngine.pm
#
# Created:  Mon Jun 16 12:13:44 EDT 2003
# Angel Pizarro
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;
use CBIL::ObjectMapper::RuleSet;

sub new { 
  my ($M,$rs,$dbg)   = @_;
  my $slf = {};
  bless $slf, $M;
  $slf->initialize($rs,$dbg);
  return $slf;
}

sub initialize {
  my ($slf,$rs,$dbg)   = @_;
  print "RS=$rs\n" if $dbg;
  if (UNIVERSAL::isa($rs, 'CBIL::ObjectMapper::RuleSet')){
    $slf->setRuleSet($rs);
  }else {
    $slf->setRuleSet(CBIL::ObjectMapper::RuleSet->new($rs,$dbg));
  }
  if ($slf->getRuleSet()->getFunction()) {
    $slf->setFunc($slf->getRuleSet()->getFunction());
  }
  $slf->setDebug($dbg);
  return $slf;
}

sub getRuleSet {
	my ($slf) = @_;
	return $slf->{ruleset};
}

sub setRuleSet {
	my ($slf,$rs) = @_;
  $slf->{ruleset} = $rs if $rs->isa('CBIL::ObjectMapper::RuleSet') ;
}

sub getRules {
	my ($slf) = @_;
  return $slf->getRuleSet->getRules();
}

sub getRule {
	my ($slf,$name) = @_;
  return $slf->getRuleSet->getRule($name);
}

sub makeObject {
  my ($slf,$path,$inputs) = @_;
  my ($rulename,$objname) = split /\./,$path;
  print STDERR "MAKE OBJECT $rulename.$objname (", (join ",", %$inputs), ")\n" if $slf->dbg;
#  $slf->setInputs($rulename,$inputs);
  #get the rule
  my $rule  = $slf->getRuleSet()->getRule($rulename);
  #get the target object
  my $out = $rule->getOutput($objname);
  my $obj;
  my $cn = $out->getClassName();
  $cn =~s/\:\:/\//g;
  $cn .= '.pm';
  eval {
    require "$cn";
    $obj = $out->getClassName()->new();
  };
  $slf->log('makeObject, eval 1', $@) if $@;
  foreach my $slot ($out->getSlots()){
    $slf->setSlot($rule,$slot,$obj,$inputs);
  }
  return $obj;
}

sub setSlot {
  my  ($slf,$rule,$slot,$obj,$inputs) = @_;
  my $nvt = $slot->getVal();
  my $val =  $slf->evalNVT($nvt,$inputs); 
  # what we will set the slot to.
  print "SLOT=(", $slot->getName(),") VAL=($val) rule=(", $rule->getName(), ") nvt=(", $nvt->getName(),":",$nvt->getType(),":", $nvt->getValue(), ")\n\n" if $slf->dbg;
  if ($val) {
    eval {
      my $method = $slot->getMethod();
      $obj->$method($val);
    };
    $slf->log('setSlot, eval 1', $@) if $@;
  }
  return $obj;
}
#---------------------------------------------
# EVALUATION FUNCTIONS
#---------------------------------------------

sub evalNVT {
  my ($slf,$nvt,$inputs) = @_;
  print STDERR "EVAL NVT=(", $nvt->getName(),":",$nvt->getType(),":", $nvt->getValue(), ")\n" if $slf->dbg;
  # rule | rulelist | func | data | scalar
  if ($nvt->getType() eq 'func') {
    return $slf->evalFunction($nvt->getValue(), $nvt->getVals(),$inputs);
  } elsif ($nvt->getType() eq 'data' ) {
    return $slf->evalData($nvt->getValue(),$inputs);
  } elsif ( $nvt->getType() eq 'string' ) {
    return $slf->evalString($nvt->getValue(),$inputs);
  } elsif ( $nvt->getType() eq 'rule' ) {
    return $slf->evalRule($nvt, $inputs);
  }
  #   elsif ( $nvt->getType() eq 'rulelist' ) {
  #     # special case of the above, where the first input is an array ref.
  #     # returns an array ref
  #     my @vals = @{$nvt->getVals()};
  #     my $firstObjArray = $slf->evalNVT((shift @vals),$inputs);
  #     my $result = [];
  #     foreach my $val (@$firstObjArray) {
  #       my $class = $slf->evalRule($nvt->getValue(),$val,$inputs);
  #       if ($class ) {
  #         $new_inputs->{$val->getName()} = $class;
  #         push @$result, $slf->makeObject($nvt->getValue(),$new_inputs);
  #       }
  #     }
  #     return $result;
  #   }
  #else the nvt is a scalar
  return  $nvt->getValue();
 }

sub evalRule {
  my ($slf,$nvt,$inputs) = @_;
  print STDERR "RULE=" , $nvt->getValue(), "\n" if $slf->dbg;
  print STDERR " Inputs:\n" if $slf->dbg;
  my $new_inputs;
  # must create the new input set.
  foreach my $val ( @{$nvt->getVals()}) {
    my $class = $slf->evalNVT($val,$inputs);
    if ($class ) {
      $new_inputs->{$val->getName()} = $class ;
    }else {
      $slf->log("evalRule($nvt, $inputs)", 
                ("Did not make expected class=" . $val->getName()));
      return undef;
    }
    print STDERR "  I=($val) = (", $val->getName(), ":",
      $val->getType(), ":", $val->getValue(), 
        ") $new_inputs->{$val->getName()}\n" if $slf->dbg;
  }
  return $slf->makeObject($nvt->getValue(),$new_inputs);
}

sub evalData {
  my ($slf,$path,$inputs) = @_;
  my ($cname,$method) = split /\./,$path;
  #  print "INPUT = $in; rname=$rname; cname=$cname; method=$method\n";
  if ($method && $inputs->{$cname}) { 
    my $val;
    eval {
      $val = $inputs->{$cname}->$method;
    };
    $slf->log("evalData[ $path ], eval 1", $@) if $@;
    $val ? return $val : return undef;
  }
  return $inputs->{$cname};
}

sub evalString {
  my ($slf,$inputname,$inputs) = @_;
  print "INPUT = $inputname\n" if $slf->dbg;
  return $inputs->{$inputname};
}

sub evalFunction {
  my ($slf,$fname,$args,$inputs) = @_;
  print STDERR "DO FUNC + ($fname) -> (", (join ",", @$args), ")\n" if $slf->dbg;
  my @ARGS;
  if (UNIVERSAL::isa($args,'ARRAY') ) {
    for (my $i = 0; $i <  @$args; $i++) {
      print STDERR "  $fname ARG# $i=($args->[$i])\n" if $slf->dbg;
      if (UNIVERSAL::isa( $args->[$i] , 'CBIL::ObjectMapper::RuleSet::NVT')) {
        print STDERR "      nvt_val=(",  $args->[$i]->getValue(), ")\n " if $slf->dbg;
        $ARGS[$i] = $slf->evalNVT($args->[$i],$inputs);
      }
      print STDERR "  $fname ARG #$i VAL=($ARGS[$i])\n" if $slf->dbg;
    }
  }elsif (UNIVERSAL::isa( $args , 'CBIL::ObjectMapper::RuleSet::NVT')) {
    push @ARGS,  $slf->evalNVT($args,$inputs);
  }else {
    push @ARGS,$args;
  }
  my $result;
  eval {
    $result = $slf->getFunc()->$fname(\@ARGS);
  };
  $slf->log("evalFunction[ $fname, $args, $inputs ], eval 1", $@) if $@;
  $result ? return $result : return undef;
}

#---------------------------------------------
# FUNCTION INSTANCE
#---------------------------------------------
sub setFunc {
  my ($slf,$func) = @_; 
  my $funcModule;
  if (UNIVERSAL::isa($func,'CBIL::ObjectMapper::RuleSet::Function')) {
    $funcModule = $func->getCfg();
  } else {
    $funcModule = $func;
  }
  #perl-ify
  $funcModule  =~ s/\./::/g;
  my $c = $funcModule;
  $c  =~ s/\:\:/\//g;
  $c  = "$ENV{GUS_HOME}/lib/perl/$c.pm";
  eval {
    require($c);
    $slf->{__FUNC} = $funcModule->new();
  };
  $slf->log("setFunc(module=$funcModule, path=$c)", $@) if $@;
}

sub getFunc {
  my ($slf) = @_;
  return $slf->{__FUNC};
}

#---------------------------------------------
# UTILITY FUNCTIONS
#---------------------------------------------
sub setDebug { 
  my ($slf,$dbg) = @_; 
  $slf->{__DEBUG} = $dbg;
}

sub dbg { 
  my ($slf) = @_; 
  return $slf->{__DEBUG};
}

sub log {
  my ($slf, $qualifier ,$err) = @_;
  print STDERR join "\t", ("ERR:" . localtime), "RuleSetEngine.$qualifier" , $err;
  print STDERR"\n";
}
1;
__END__

# sub do {
#   eval {
#     require("$inst") ;
#   };
#   $slf->log("setInstance($inst)", $@) ; #if ($@);
#   # perlize 
#   $inst =~ s/\//::/g; 
#   $inst =~ s/\.pm$//g; 
#   $slf->{__INSTANCE} = $inst->new();
#   print STDERR "FUNCTIONS INSTANCE =$inst\n";
#   
#   if ($slf->can('')){ print "YEEHAA, we got some functions\n"; }
#   my ($slf,$func,$args)  = @_;
#   my $val ;
#   eval {
#     $val = $slf->getInstance()->$func( $args );
#   };
#   $slf->log("do($func,$args)",$@ ) if $@;
#   return $val;
# }
# sub log {
#   my ($slf, $qualifier ,$err) = @_;
#   print STDERR join "\t", ( "ERR:RuleSet::Function $qualifier: ". localtime , $err);
#   print STDERR"\n";
# }
