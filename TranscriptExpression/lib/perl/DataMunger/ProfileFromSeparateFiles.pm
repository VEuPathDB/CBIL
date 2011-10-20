package CBIL::TranscriptExpression::DataMunger::MergeSeparateFiles;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use CBIL::TranscriptExpression::Error;

# Each File contains 2 columns tab delim (U_ID \t VALUE)
# Each value in the analysis config can specify a display name
#   which will be used in the header of the output file ( "Display Name|file")
sub getFiles         {$_[0]->{files}}

sub getHasHeader     {$_[0]->{hasHeader}}
sub setHasHeader     {$_[0]->{hasHeader} = $_[1]}

sub new {
  my ($class, $args) = @_;
  my $requiredParams = ['files',
                        'outputFile'
                       ];

  my $self = $class->SUPER::new($args, $requiredParams);

  if(defined $args->{hasHeader}) {
    $self->setHeader($args->{hasHeader});
  }

  return $self;
}

sub munge {
  my ($self) = @_;

  $self->readDataHash();
  $self->writeDataHash();
}

sub readDataHash {
  my ($self) = @_;

  my $files = $self->getFiles();

  my $hasHeader = $self->getHasHeader();

  my @headers;
  foreach my $file (@$files) {
    my @ar = split(/\|/, $file);

    my $fn = pop @ar;
    my $display = pop @ar;

    $display = defined $display ? $display : $fn;

    push @headers, $display;

    open(FILE, $fn) or CBIL::TranscriptExpression::Error->new("Cannot open File $fn for reading: $!")->throw();

    if($hasHeader) {
      <FILE>;
    }

    while(my $line = <FILE>) {
      chomp $line;
      my ($uId, $value) = split(/\t/, $line);

      if($self->{dataHash}->{$uId}->{$display}) {
        CBIL::TranscriptExpression::Error->new("ID $uId is not unique for $display")->throw();
      }

      $self->{dataHash}->{$uId}->{$display} = $value;
    }
    close FILE;
  }

  $self->{headers} = \@headers;
}

sub writeDataHash {
  my ($self) =  @_;

  my $dataHash = $self->{dataHash};
  my $headers = $self->{headers};

  my $outputFile = $self->getOutputFile();

  open(OUT, "> $outputFile") or CBIL::TranscriptExpression::Error->new("Cannot open File $outputFile for writing: $!")->throw();

  print OUT "U_ID\t" . join("\t", @$headers) . "\n";

  foreach my $uid (keys %$dataHash) {
    my @values = map {$dataHash->{$uid}->{$_} || 'NA'} @$headers;
    print OUT "$uid\t" . join("\t", @values) . "\n";
  }

  close OUT;
}

1;

