package CBIL::ISA::Reader;
use Text::CSV;
use strict;
use warnings;


sub getFh {$_[0]->{_fh}}
sub setFh {$_[0]->{_fh} = $_[1]}
sub setDelimiter { $_[0]->{_delimiter} = $_[1] }
sub getDelimiter { $_[0]->{_delimiter} }
sub setLineParser { $_[0]->{_line_parser} = $_[1] }
sub getLineParser { $_[0]->{_line_parser} }

sub initReader {
  my ($self, $delimiter) = @_;
  $self->setDelimiter($delimiter);
  my $csv = Text::CSV->new({
    binary => 1,
    sep_char => $delimiter,
    quote_char => '"'
  }) or die "Cannot use CSV: " . Text::CSV->error_diag ();
  $self->setLineParser($csv);
}

sub readNextLine {
  my ($self) = @_;
  my $fh = $self->getFh();
  my $csv = $self->getLineParser();
  my $fields = $csv->getline($fh);
  return $fields;
}

sub splitLine {
  my ($self, $line) = @_;
  my $csv = $self->getLineParser();
  my @columns;
  if($csv->parse($line)) {
    @columns = $csv->fields();
  }
  else {
    my $error= "" . $csv->error_diag;
    die "Could not parse line: $error";
  }
  return wantarray ? @columns : \@columns;
}

1;
