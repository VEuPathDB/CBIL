package CBIL::TranscriptExpression::DataMunger::ProfileFromSeparateFiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

use strict;

use File::Temp qw/ tempfile /;

use CBIL::TranscriptExpression::Error;

# The Default is that Each File contains 2 columns tab delim (U_ID \t VALUE)
# Each value in the analysis config can specify a display name for the output && optinally a specific column to cut out
#  ( "Selected Column|Output Column Name|file")

sub getHasHeader     {$_[0]->{hasHeader}}
sub setHasHeader     {$_[0]->{hasHeader} = $_[1]}

sub setSamples       {$_[0]->{samples} = $_[1]}


sub new {
  my ($class, $args) = @_;

  $args->{inputFile} = '.';

  my $self = $class->SUPER::new($args);

  if(defined $args->{hasHeader}) {
    $self->setHasHeader($args->{hasHeader});
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
  my $fileSuffix = $self->getFileSuffix();

  my $hasHeader = $self->getHasHeader();

  my @headers; # these are the output headers
  foreach my $file (@$files) {
    my ($fn, $display, $selectedColumn);

    my @options = split(/\|/, $file);

    # if only one value in $file.. it must be the file name
    if(scalar @options == 1) {
      $fn = $options[0];
      $display = $fn;
    } 
    elsif(scalar @options == 2) {
      $display = $options[0];
      $fn = $options[1];
    } 
    elsif(scalar @options == 3) {
      $selectedColumn = $options[0];
      $display = $options[1];
      $fn = $options[2];
    }

    $fn = $fn . $fileSuffix if($fileSuffix);

    push @headers, $display;

    open(FILE, $fn) or CBIL::TranscriptExpression::Error->new("Cannot open File $fn for reading: $!")->throw();

    if($selectedColumn && !$hasHeader) {
      CBIL::TranscriptExpression::Error->new("Trying to select a specific column $selectedColumn from file $fn but hasHeader flag was set to false")->throw();
    }

    my $inputHeader;
    my @inputHeaders;
    if($hasHeader) {
      $inputHeader = <FILE>;
      chomp $inputHeader;
      @inputHeaders = split(/\t/, $inputHeader);
    }

    while(my $line = <FILE>) {
      next if ($line =~ /^\W*$/);
      chomp $line;
      my ($uId, @rest) = split(/\t/, $line);

      my $value;
      if(!$selectedColumn && scalar @rest == 1) {
        $value = $rest[0];
      }
      else {
        my( $index ) = grep { $inputHeaders[$_] eq $selectedColumn } 0..$#inputHeaders;

      unless(defined $index) {
        CBIL::TranscriptExpression::Error->new("Ooops!  I tried to select $selectedColumn from an array of headers  @inputHeaders but didn't find it.")->throw();
      }

        # subtract 1 because the uid was popped off this array already
        $value = $rest[$index - 1];
      }

      if($self->{dataHash}->{$uId}->{$display}) {
        CBIL::TranscriptExpression::Error->new("ID $uId is not unique for $display")->throw();
      }

      $self->{dataHash}->{$uId}->{$display} = $value;
    }
    close FILE;
  }

  $self->setSamples(\@headers);
}

sub writeDataHash {
  my ($self) =  @_;

  my $dataHash = $self->{dataHash};
  my $headers = $self->getSamples();

  my ($fh, $file) = tempfile();

  print $fh "U_ID\t" . join("\t", @$headers) . "\n";

  foreach my $uid (sort keys %$dataHash) {
    my @values = map {defined($dataHash->{$uid}->{$_}) ? $dataHash->{$uid}->{$_} : 'NA'} @$headers;
    print $fh "$uid\t" . join("\t", @values) . "\n";
  }
  return $file;
}

1;

