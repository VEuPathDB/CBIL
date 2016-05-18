package CBIL::TranscriptExpression::DataMunger::NoSampleConfigurationProfiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

# Use if you have a tab file and don't want to code the samples property in the configuration file
# The output file will equal the input file;  You must specify whether or not to calculate the percentiles

use strict;

use CBIL::TranscriptExpression::Error;

use Data::Dumper;

use File::Basename;

use File::Temp;


sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['makePercentiles',
                        'inputFile'
                       ];

  $args->{outputFile} = $args->{inputFile};

  my $output = $args->{outputFile};
  
  unless ($args->{isLogged}) {
    $args->{isLogged} = 0;
  }

  my $mainDirectory = $args->{mainDirectory};

  open(FILE, "$mainDirectory/$output") || die "Cannot open file $output for reading $!";
  my $header = <FILE>;
  chomp($header);
  my @samples = split('\t',$header);

  shift(@samples);
  close(FILE);

  my @uniq= ();
  my %seen = ( );
  foreach my $item (@samples) {
    push(@uniq, $item) unless $seen{$item}++;
  }
  unless (scalar @samples == scalar(@uniq)){
    die "sample names must be unique, average samples with the profiles step class before calling this step class";
  }
  $args->{samples} = \@samples;
  $args->{doNotLoad} = 1;


  my $self = $class->SUPER::new($args, $requiredParams);

  return $self;
}

sub munge {
  my ($self) = @_;
  
  $self->{mappingFile} = $self->getMappingFile();
  $self->SUPER::munge();

}

sub getMappingFile {
  my ($self) = @_;
  
  my $inputFile = $self->{inputFile};

  if($self->inputFileIsMappingFile()) {
    return $inputFile;
  }
  
  if (defined $self->{mappingFile}) {
    return $self->{mappingFile};
  }
  my $mappingFile = $self->makeSelfMappingFile();
  return $mappingFile;
  
}


sub makeSelfMappingFile {
  my ($self) = @_;
  my $inputFile = $self->{inputFile};
  my $mappingFileHandle = File::Temp->new();
  my $mappingFile = $mappingFileHandle->filename;
  print STDERR $mappingFile;
  open (INPUT, "<$inputFile") or die "unable to open input file $inputFile : $!";
  open (MAPPING, ">$mappingFile") or die "unable to open input file $inputFile : $!";
  my $isHeader = 1;
  while(<INPUT>) {
    unless ($isHeader) {
      my ($id) = split(/\t/,$_);
      print MAPPING "$id\t$id\n";
    }
    else {
      $isHeader = 0;
      next;
    }
  }
  close INPUT;
  close MAPPING;
  return $mappingFile;
}

1;
 
