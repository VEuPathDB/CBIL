package CBIL::TranscriptExpression::DataMunger::ProfileFromSeparateFiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

use strict;

use File::Temp qw/ tempfile /;

use CBIL::TranscriptExpression::Error;

# Each File contains 2 columns tab delim (U_ID \t VALUE)
# Each value in the analysis config can specify a display name
#   which will be used in the header of the output file ( "Display Name|file")
sub getHasHeader     {$_[0]->{hasHeader}}
sub setHasHeader     {$_[0]->{hasHeader} = $_[1]}

sub new {
  my ($class, $args) = @_;

  $args->{inputFile} = '.';

  my $self = $class->SUPER::new($args);

  if(defined $args->{hasHeader}) {
    $self->setHeader($args->{hasHeader});
  }

  return $self;
}

sub munge {
  my ($self) = @_;

  $self->readDataHash();
  my $inputFile = $self->writeDataHash();

  $self->setInputFile($inputFile);

  $self->SUPER::munge();

  unlink($inputFile);
}

sub readDataHash {
  my ($self) = @_;

  my $files = $self->getSamples();

  my $hasHeader = $self->getHasHeader();

  my @headers;
  foreach my $file (@$files) {
    my @ar = split(/\|/, $file);

    my $fn = pop @ar;

    push @headers, $fn;

    open(FILE, $fn) or CBIL::TranscriptExpression::Error->new("Cannot open File $fn for reading: $!")->throw();

    if($hasHeader) {
      <FILE>;
    }

    while(my $line = <FILE>) {
      chomp $line;
      my ($uId, $value) = split(/\t/, $line);

      if($self->{dataHash}->{$uId}->{$fn}) {
        CBIL::TranscriptExpression::Error->new("ID $uId is not unique for $fn")->throw();
      }

      $self->{dataHash}->{$uId}->{$fn} = $value;
    }
    close FILE;
  }

  $self->{headers} = \@headers;
}

sub writeDataHash {
  my ($self) =  @_;

  my $dataHash = $self->{dataHash};
  my $headers = $self->{headers};

  my ($fh, $file) = tempfile();

  print $fh "U_ID\t" . join("\t", @$headers) . "\n";

  foreach my $uid (keys %$dataHash) {
    my @values = map {$dataHash->{$uid}->{$_} || 'NA'} @$headers;
    print $fh "$uid\t" . join("\t", @values) . "\n";
  }
  return $file;
}

1;

