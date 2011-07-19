package CBIL::Bio::GenBank::ArrayStream;

use strict;

# a wrapper around an array to make it look like a stream (emulating IoStream)

sub new {
  my ($class, $linesArray) = @_;

  my $self = {};
  bless($self, $class);

  $self->{lines} = $linesArray;
  $self->{lineNum} = 0;

  return $self;
}

sub getLineNumber {
  my ($self) = @_;

  return $self->{lineNum};
}

sub getLine {
  my ($self) = @_;

  return $self->{lines}->[$self->{lineNum}++];
}

sub putLine {
  my ($self) = @_;

  $self->{lineNum}--;
}


1;

__END__
