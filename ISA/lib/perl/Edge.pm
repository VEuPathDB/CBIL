package CBIL::ISA::Edge;

use strict;

sub new {
  my $class = shift;
  return bless {}, $class;
}

sub addInput { push @{$_[0]->{_inputs}}, $_[1] }
sub getInputs { $_[0]->{_inputs} }

sub addOutput { push @{$_[0]->{_outputs}}, $_[1] }
sub getOutputs { $_[0]->{_outputs} }

sub setPerformer { $_[0]->{_performer} = $_[1] }
sub getPerformer { $_[0]->{_performer} }

sub setDate { $_[0]->{_date} = $_[1] }
sub getDate { $_[0]->{_date} }

sub set { $_[0]->{_} = $_[1] }
sub get { $_[0]->{_} }


1;

Edge
 Processes
   protocol_name

   ProtocolParamValues
     parameter_name
     Term Accession Number
     Term Source

     Unit

