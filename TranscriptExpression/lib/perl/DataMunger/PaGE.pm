package CBIL::TranscriptExpression::DataMunger::PaGE;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use CBIL::TranscriptExpression::Error;
use CBIL::TranscriptExpression::Utils;

use GUS::Community::FileTranslator;

use File::Basename;

my $MISSING_VALUE = 'NA';
my $USE_LOGGED_DATA = 1;

#-------------------------------------------------------------------------------

sub getInputFile            { $_[0]->{inputFile} }
sub getAnalysisName         { $_[0]->{analysisName} }

sub getConditions           { $_[0]->{conditions} }
sub getNumberOfChannels     { $_[0]->{numberOfChannels} }
sub getIsDataLogged         { $_[0]->{isDataLogged} }
sub getIsDataPaired         { $_[0]->{isDataPaired} }
sub getDesign               { $_[0]->{design} }
sub getMinPrescence         { $_[0]->{minPrescence} }
sub getLevelConfidence      { $_[0]->{levelConfidence} }
sub getStatistic            { $_[0]->{statistic} }

sub getBaseX                { $_[0]->{baseX} }


#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['baseLogDir',
                        'inputFile',
                        'outputFile',
                        'analysisName',
                        'conditions',
                        'numberOfChannels',
                        'levelConfidence',
                        'minPrescence',
                        'statistic',
                       ];

  my $self = $class->SUPER::new($args, $requiredParams);

  my $logDir = $args->{baseLogDir};

  unless(-d $logDir) {
    CBIL::TranscriptExpression::Error->new("baseLogDir dirrectory $logDir does not exist")->throw();
  }

  unless(defined($args->{isDataLogged})) {
    CBIL::TranscriptExpression::Error->new("Parameter [isDataLogged] is missing in the config file")->throw();
  }

  if($args->{design} eq 'D' && defined($args->{isDataPaired})) {
    CBIL::TranscriptExpression::Error->new("Parameter [isDataPaired] should not be specified with Dye swap design")->throw();
  }

  if($args->{design} ne 'D' && !defined($args->{isDataPaired})) {
    CBIL::TranscriptExpression::Error->new("Parameter [isDataPaired] is missing from the config file")->throw();
  }

  if($args->{numberOfChannels} == 2 && !($args->{design} eq 'R' || $args->{design} eq 'D') ) {
    CBIL::TranscriptExpression::Error->new("Parameter [design] must be given (R|D) when specifying 2 channel data.")->throw();
  }

  if($args->{isDataLogged} && !$args->{baseX}) {
    die "baseX arg not defined when isDataLogged set to true";
  }

  return $self;
}

sub munge {
  my ($self) = @_;

  chdir $self->getBaseLogDir;

  my ($pageInputFile, $pageGeneConfFile) = $self->makePageInput();

  $self->runPage($pageInputFile);

  my $baseX = $self->getBaseX();

  $self->translatePageOutput($baseX, $pageGeneConfFile);
}

sub translatePageOutput {
  my ($self, $baseX, $pageGeneConf) = @_;

  my $translator;

  if($self->getDesign() eq 'D') {
    $translator = "$ENV{GUS_HOME}/lib/xml/pageOneClassConfAndFC.xml";
  }
  else {
    $translator = "$ENV{GUS_HOME}/lib/xml/pageTwoClassConfAndFC.xml";
  }
  my $functionArgs = {baseX => $baseX};

  my $outputFile = $self->getOutputFile();
  my $logFile =  $pageGeneConf . ".log";

  my $fileTranslator = eval { 
    GUS::Community::FileTranslator->new($translator, $logFile);
  };

  if ($@) {
    die "The mapping configuration file '$translator' failed the validation. Please see the log file $logFile";
  };

  $fileTranslator->translate($functionArgs, $pageGeneConf, $outputFile);
}

sub runPage {
  my ($self, $pageIn) = @_;

  my $channels = $self->getNumberOfChannels();
  my $isLogged = $self->getIsDataLogged();
  my $isPaired = $self->getIsDataPaired();
  my $levelConfidence = $self->getLevelConfidence();
  my $minPrescence = $self->getMinPrescence();

  my $statistic = '--' . $self->getStatistic();

  my $design = "--design " . $self->getDesign() if($self->getDesign() && $channels == 2);

  my $isLoggedArg = $isLogged ? "--data_is_logged" : "--data_not_logged";
  my $isPairedArg = $isPaired ? "--paired" : "--unpaired";

  my $useLoggedData = $USE_LOGGED_DATA ? '--use_logged_data' : '--use_unlogged_data';

  my $executable = $self->getPathToExecutable() ? $self->getPathToExecutable() : 'PaGE_5.1.6_modifiedConfOutput.pl';

  
  my $pageCommand = "$executable --infile $pageIn --output_gene_confidence_list --output_text --num_channels $channels $isLoggedArg $isPairedArg --level_confidence $levelConfidence $useLoggedData $statistic --min_presence $minPrescence --missing_value $MISSING_VALUE $design";

  my $systemResult = system($pageCommand);

  unless($systemResult / 256 == 0) {
    die "Error while attempting to run PaGE:\n$pageCommand";
  }

}

sub makePageInput {
  my ($self) = @_;

  my $fn = $self->getInputFile();
  open(FILE, $fn) or die "Cannot open file $fn for reading: $!";

  my $header;
  chomp($header = <FILE>);

  my $headerIndexHash = CBIL::TranscriptExpression::Utils::headerIndexHashRef($header, qr/\t/);

  my $conditions = $self->groupListHashRef($self->getConditions());

  unless(scalar keys %$conditions <= 2) {
    die "Expecting 2 state comparison... expected 2 conditions";
  }

  my $logDir = $self->getBaseLogDir();

  my $analysisName = $self->getAnalysisName;
  $analysisName =~ s/\s/_/g;

  my $pageInputFile = $logDir . "/" . $analysisName;
  my $pageGeneConfFile = "PaGE-results-for-" . $analysisName . "-gene_conf_list.txt";

  open(OUT, "> $pageInputFile") or die "Cannot open file $pageInputFile for writing: $!";

  &printHeader($conditions, \*OUT);

  my @indexes;
  foreach my $c (keys %$conditions) {
    foreach my $r (@{$conditions->{$c}}) {
      my $index = $headerIndexHash->{$r};
      push @indexes, $index;
    }
  }


  while(<FILE>) {
    chomp;

    my @data = split(/\t/, $_);

    my @values = map {$data[$_]} @indexes;

    print OUT $data[0] . "\t" . join("\t", @values) . "\n";
  }

  close OUT;
  close FILE;

  return($pageInputFile, $pageGeneConfFile);
}


sub printHeader {
  my ($conditions, $outFh) = @_;


  my @a;
  my $c = 0;
  foreach(keys %$conditions) {

    my $r = 1;
    foreach(@{$conditions->{$_}}) {
      push @a, "c" . $c . "r" . $r;
      $r++;
    }
    $c++;
  }
  print  $outFh "id\t" . join("\t", @a) . "\n";  
}










1;

