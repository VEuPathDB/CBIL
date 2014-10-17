package CBIL::TranscriptExpression::DataMunger::GenericProfiles;
use base qw(CBIL::TranscriptExpression::DataMunger::Profiles);

use strict;

use CBIL::TranscriptExpression::Error;

use Data::Dumper;

use File::Temp qw/ tempfile /;

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


  my $self = $class->SUPER::new($args, $requiredParams);

  return $self;
}





1;
 
