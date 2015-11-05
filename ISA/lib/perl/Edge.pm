package CBIL::ISA::Edge;

use strict;

use Data::Dumper;

sub new {
  my ($class, $inputs, $protocolApplications, $outputs, $fileName) = @_;

  $inputs = [] unless($inputs);
  $outputs = [] unless($outputs);
  $protocolApplications = [] unless($protocolApplications);  


  unless(ref($inputs) eq 'ARRAY') {
    $inputs = [$inputs];
  }

  unless(ref($outputs) eq 'ARRAY') {
    $outputs = [$outputs];
  }

  unless(ref($protocolApplications) eq 'ARRAY') {
    $protocolApplications = [$protocolApplications];
  }

  return bless {"_inputs" => $inputs,
                "_outputs" => $outputs,
                "_protocol_applications" => $protocolApplications,
                "_file_name" => $fileName,
  }, $class;
}


# Only add new inputs
sub addInput { 
  my ($self, $node) = @_;

  foreach(@{$self->getInputs()}) {
    return $_ if($node->equals($_));
  }
  
  push @{$self->{_inputs}}, $node;
  return $node;
}
sub getInputs { $_[0]->{_inputs} }

# Only add new outputs
sub addOutput { 
  my ($self, $node) = @_;

  foreach(@{$self->getOutputs()}) {
    return $_ if($node->equals($_));
  }
  
  push @{$self->{_outputs}}, $node;
  return $node;
}
sub getOutputs { $_[0]->{_outputs} }

sub setProtocolApplications { $_[0]->{_protocol_applications} = $_[1] }
sub getProtocolApplications { $_[0]->{_protocol_applications} }


# If ProtocolApplications are the same && some input OR output Matches
sub equals {
  my ($self, $obj) = @_;

  my $pas = $self->getProtocolApplications();
  my $objPas = $obj->getProtocolApplications();

  # Next check if the protocol applications are the same

  return 0 unless(scalar @$pas == scalar @$objPas);
  my %protocolValueCounts;

  foreach (@$pas, @$objPas) {
    my $value = $_->getValue();
    $protocolValueCounts{$value}++;

    foreach my $pv(@{$_->getParameterValues()}) {
      my $key = $value . "|" . $pv->getQualifier() . "|" . $pv->getTerm();
      $protocolValueCounts{$key}++;
    }
  }

  foreach(keys %protocolValueCounts) {
    return 0 unless($protocolValueCounts{$_} == 2);
  }

  # Any input node matches OR any output node matches

  my $inputs = $self->getInputs();
  my $objInputs = $obj->getInputs();

  my $outputs = $self->getOutputs();
  my $objOutputs = $obj->getOutputs();

  foreach my $i (@$inputs) {
    foreach my $oi (@$objInputs) {
      return 1 if($i->getValue() eq $oi->getValue() && $i->getEntityName() eq $oi->getEntityName());
    }
  }

  foreach my $o (@$outputs) {
    foreach my $oo (@$objOutputs) {
      return 1 if($o->getValue() eq $oo->getValue() && $o->getEntityName() eq $oo->getEntityName());
    }
  }

  return 0;
}


1;

