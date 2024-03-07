package CBIL::ISA::InvestigationFileReader;
use base qw(CBIL::ISA::Reader);

use strict;
use utf8;

use CBIL::Util::V;
use Data::Dumper;
use Encode;

sub setInvestigationFile { $_[0]->{_investigation_file} = $_[1] }
sub getInvestigationFile { $_[0]->{_investigation_file} }

sub setDelimiter { $_[0]->{_delimiter} = $_[1] }
sub getDelimiter { $_[0]->{_delimiter} }

sub setColumnCounts { $_[0]->{_column_counts} = $_[1] }
sub getColumnCounts { $_[0]->{_column_counts} }

sub setInvestigationHash { $_[0]->{_investigation_hash} = $_[1] }
sub getInvestigationHash { $_[0]->{_investigation_hash} }



my @CONTEXTS = ("ONTOLOGY SOURCE REFERENCE", 
                "INVESTIGATION",
                "INVESTIGATION PUBLICATIONS",
                "INVESTIGATION CONTACTS",
                "STUDY",
                "STUDY DESIGN DESCRIPTORS",
                "STUDY PUBLICATIONS",
                "STUDY FACTORS",
                "STUDY ASSAYS",
                "STUDY PROTOCOLS",
                "STUDY CONTACTS",
    );

sub new {
  my ($class, $investigationFile, $delimiter) = @_;
  my $self = bless {}, $class;
  $self->setDelimiter($delimiter);
  $self->setInvestigationFile($investigationFile);
  $self->initReader($delimiter);
  return $self;
}

sub read {
  my ($self) = @_;

  my $investigationFile = $self->getInvestigationFile();
  my $delimiter = $self->getDelimiter();

  my $iHash = {};
  my $columnCounts = {};
  my ($fh);

  open($fh, "<", $investigationFile) or die "Cannot open file $investigationFile for Reading: $!";
  $self->setFh($fh);

  my ($lineContext, $studyIdentifier);

  my $studiesKey = "_studies";

  my $line = 0;
  while(my $fields = $self->readNextLine()) {
    $fields = encode("UTF-8", $fields);
    
    # split and remove leading and trailing quotes
    #my @a = map { s/^"(.*)"$/$1/; $_; } $self->splitLine($line);
    my @a = @$fields;

    $studyIdentifier = $a[1] if(uc $a[0] eq 'STUDY IDENTIFIER');
    if(&isContextSwitch($a[0])) {
      $lineContext = uc $a[0];
      next;
    }

    # next if($a[0] eq 'STUDY PUBLICATIONS');
    # next if($a[0] eq 'STUDY DESIGN DESCRIPTORS');
    # next if($a[0] eq 'STUDY CONTACTS');

    my $header = shift @a;

    # making keys for a hash out of the headers;  will also be used in objects
    $header =~ s/^investigation //i;
    $header =~ s/^study //i;
    $header = "_" . lc $header;
    $header =~ s/ /_/g;



    if($lineContext =~ /^study/i) {
      push @{$iHash->{$studiesKey}->{$studyIdentifier}->{$lineContext}->{$header}}, @a;
      push @{$columnCounts->{$studiesKey}->{$studyIdentifier}->{$lineContext}}, scalar @a;
    }
    else {
      push @{$iHash->{$lineContext}->{$header}}, @a;
      push @{$columnCounts->{$lineContext}}, scalar @a;
    }
    $line++;
    #printf STDERR ("done reading %d\n", $line);
    #last if eof($fh);
  }

  close $fh;
  my $maxColumnCounts = {};

  foreach my $col (keys %$columnCounts) {
    if(ref($columnCounts->{$col}) eq 'ARRAY') {
      my $max = CBIL::Util::V::max(@{$columnCounts->{$col}});
      $maxColumnCounts->{$col} = $max;
    }
  }
 
  foreach my $studyId (keys %{$columnCounts->{$studiesKey}}) {
    foreach my $lineContext (keys %{$columnCounts->{$studiesKey}->{$studyId}}) {
      my $max = CBIL::Util::V::max(@{$columnCounts->{$studiesKey}->{$studyId}->{$lineContext}});
      $maxColumnCounts->{$studiesKey}->{$studyId}->{$lineContext} = $max;
    }
  }

  $self->setInvestigationHash($iHash);
  $self->setColumnCounts($maxColumnCounts);
}

#--------------------------------------------------------------------------------
# Helper methods start
#--------------------------------------------------------------------------------

sub isContextSwitch {
  my $new = shift;

  foreach(@CONTEXTS) {
    if($_ eq uc $new) {
      return 1;
    }
  }
  return 0;
}

1;
