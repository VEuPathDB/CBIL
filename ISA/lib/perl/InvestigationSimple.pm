package CBIL::ISA::InvestigationSimple;
use base qw(CBIL::ISA::Investigation);

use strict;
use XML::Simple;

use Scalar::Util 'blessed';
use CBIL::ISA::OntologyTerm qw(@allOntologyTerms);
use File::Basename;
use CBIL::ISA::Functions qw(makeObjectFromHash makeOntologyTerm);

use CBIL::ISA::StudyAssayEntity::Characteristic;
use CBIL::ISA::StudyAssayEntity::ParameterValue;
use CBIL::ISA::StudyAssayEntity::ProtocolApplication;

use Data::Dumper;

sub setSimpleXml {$_[0]->{_simple_xml} = $_[1]}
sub getSimpleXml {$_[0]->{_simple_xml} }

sub setOntologyMapping {$_[0]->{_ontology_mapping} = $_[1]}
sub getOntologyMapping {$_[0]->{_ontology_mapping} }

sub setRegexMatch {$_[0]->{_regex_match} = $_[1]}
sub getRegexMatch {$_[0]->{_regex_match} }

sub setFunctions {$_[0]->{_functions} = $_[1]}
sub getFunctions {$_[0]->{_functions} }

sub new {
  my ($class, $investigationFile, $ontologyMappingFile, $ontologyMappingOverrideFile) = @_;

  @allOntologyTerms = ();

  my $investigationDirectory = dirname $investigationFile;

  my $investigationXml = XMLin($investigationFile, ForceArray => 1);
  my $ontologyMapping = XMLin($ontologyMappingFile, ForceArray => 1);

  my %ontologyMapping;
  foreach my $ot (@{$ontologyMapping->{ontologyTerm}}) {
    my $type = $ot->{type};
    foreach my $name (@{$ot->{name}}) {
      $ontologyMapping{lc($name)} = $ot;
    }
  }

  if($ontologyMappingOverrideFile) {
    my $ontologyMappingOverride = XMLin($ontologyMappingOverrideFile, ForceArray => 1);
    foreach my $ot (@{$ontologyMappingOverride->{ontologyTerm}}) {
      my $type = $ot->{type};
      foreach my $name (@{$ot->{name}}) {
        $ontologyMapping{lc($name)} = $ot;
      }
    }
  }

  my $self = $class->SUPER::new();
  $self->setInvestigationDirectory($investigationDirectory);

  $self->setOntologyMapping(\%ontologyMapping);
  $self->setSimpleXml($investigationXml);

  my $functions = CBIL::ISA::Functions->new({_ontology_mapping => \%ontologyMapping});
  $self->setFunctions($functions);

  return $self;
}


sub makeIdentifier {
  my ($self, $xml) = @_;

  my $rv;

  if($xml->{identifier}) {
    $rv = $xml->{identifier};
  }
  elsif(lc($xml->{identifierIsDirectoryName}) eq 'true') {
    my $investigationDirectory = $self->getInvestigationDirectory();
    $rv = basename $investigationDirectory;
  }
  else {
    die "Identifier must either be set in xml or set to directory basename";
  }

  if(my $regex = $xml->{identifierRegex}) {
    if($rv =~ qr/$regex/) {
      my $regexmatch = $1;
      $self->setRegexMatch($regexmatch);
    }
    else {
      die "Identifier $rv  did not match specified regex /$regex/";
    }
  }

  if(my $suffix = $xml->{identifierSuffix}) {
    $rv .= $suffix;
  }

  return $rv;
}

#@override
sub parseInvestigation {
  my ($self) = @_;

  my $xml = $self->getSimpleXml();

  my $identifier = $self->makeIdentifier($xml);

  $self->setIdentifier($identifier);
  my $investigationDirectory = $self->getInvestigationDirectory();

  foreach my $studyXml (@{$xml->{study}}) {
    my $metaDataFile = $studyXml->{fileName};
    my $metaDataFileFullPath = "$investigationDirectory/$metaDataFile";

    my $study = CBIL::ISA::Study->new({});

    $study->{_SIMPLE_XML} = $studyXml;

    $study->setFileName($metaDataFileFullPath);

    my %protocols;

    $studyXml->{identifier} = $identifier;

    my $studyIdentifier = $self->makeIdentifier($studyXml);
    $study->setIdentifier($studyIdentifier);    

    foreach my $edgeXml (@{$studyXml->{edge}}) {
      foreach my $protocolXml (@{$edgeXml->{protocol}}) {
        $protocols{lc($protocolXml)}++;
      }
    }
    foreach(@{$self->makeProtocols(\%protocols)}) {
      $study->addProtocol($_);
    }

    my $datasets = join(';', @{$studyXml->{dataset}});
    my $studyAssay = CBIL::ISA::StudyAssay->new({'_comment[dataset_names]' => $datasets});
    $study->addStudyAssay($studyAssay);

    $self->addStudy($study);
  }
}


#@override
sub parseStudies {
  my ($self) = @_;

  foreach my $study (@{$self->getStudies()}) {

    my $studyXml = $study->{_SIMPLE_XML};
    my $fileName = $study->getFileName();

    $self->addNodesAndEdgesToStudy($study, $fileName, $studyXml);
  }

  # get from Investigation.pm
  $self->dealWithAllOntologies();
}




sub addNodesAndEdgesToStudy {
  my ($self, $study, $metaDataTabFile, $studyXml) = @_;

  open(FILE, $metaDataTabFile) or "Cannot open file $metaDataTabFile for reading: $!";

  my $header = <FILE>;
  chomp $header;
  my @headers = split(/\t/, $header);

  my @headersSlice = @headers[4..$#headers];

  my $count = 1;;
  while(my $line = <FILE>) {
    chomp $line;

    my @a = split(/\t/, $line);

    my $name = shift @a;
    my $description = shift @a;
    my $sourceMtOverride = shift @a;
    my $sampleMtOverride = shift @a;

    my $nodesHash = $self->makeNodes($name, $description, $sourceMtOverride, $sampleMtOverride, $count, $studyXml, $study);
    my $leftoverIndexes = $self->addCharacteristicsToNodes($nodesHash, \@a, \@headersSlice);

    my $protocolAppHash = $self->makeEdges($studyXml, $study, $nodesHash);
    my $missingIndexes = $self->addProtocolParametersToEdges($protocolAppHash, \@a, \@headersSlice, $leftoverIndexes);

    if(scalar @$missingIndexes > 0) {
      foreach my $i (@$missingIndexes) {
        print STDERR "Unmapped Column Header:  $headersSlice[$i]\n";
      }
      die "Please fix unmapped Columns!";
    }

    $count++;
  }

  close FILE;
}

sub addProtocolParametersToEdges {
  my ($self, $protocolAppHash, $values, $headers, $leftoverIndexes) = @_;

  &checkArrayRefLengths($values, $headers);

  my $ontologyMapping = $self->getOntologyMapping();

  my @rv;

  foreach my $i (@$leftoverIndexes) {
    my $value = $values->[$i];
    my $header = $headers->[$i];

    if($ontologyMapping->{lc($header)} && $ontologyMapping->{lc($header)}->{type} eq 'protocolParameter') {    
      my $qualifier = $ontologyMapping->{lc($header)}->{source_id};
      my $functions = $ontologyMapping->{lc($header)}->{function};
      my $parent = $ontologyMapping->{lc($header)}->{parent};

      my $protocolApp = $protocolAppHash->{$parent};

      my $pv = CBIL::ISA::StudyAssayEntity::ParameterValue->new({_value => $value});
      $pv->setQualifier($qualifier);

      my $functionsObj = $self->getFunctions();
      foreach my $function (@$functions) {
        eval {
          $functionsObj->$function($pv);
        };
        if ($@) {
          die "problem w/ function $function: $@";
        }
      }

      $protocolApp->addParameterValue($pv);
    }
    else {
      push @rv, $i;
    }
  }

  return \@rv;
}



sub makeEdges {
  my ($self, $studyXml, $study, $nodesHash) = @_;

  my %rv;

  foreach my $edge (@{$studyXml->{edge}}) {
    my $input = $edge->{input};
    my $output = $edge->{output};

    my $inputNode = $nodesHash->{$input};
    my $outputNode = $nodesHash->{$output};

    die "No node for input type $input" unless($inputNode);
    die "No node for output type $output" unless($outputNode);

    my @protocolApplications;
    foreach my $pn (@{$edge->{protocol}}) {
      my $pa = CBIL::ISA::StudyAssayEntity::ProtocolApplication->new({_value => $pn});
      $rv{$pn} = $pa;

      my $protocol = &findProtocolByName($pn, $study->getProtocols());

      $pa->setProtocol($protocol);
      push @protocolApplications, $pa;
    }
    $study->addEdge($inputNode, \@protocolApplications, $outputNode);
  }
  return \%rv;
}

sub findProtocolByName {
  my ($pn, $protocols) = @_;

  my $rv;
  foreach my $p (@$protocols) {
    if($p->getProtocolName() eq lc($pn)) {
      return $p;
    }
  }
  die "Could not find a protocol w/ name $pn";
}


sub addCharacteristicsToNodes {
  my ($self, $nodesHash, $values, $headers) = @_;

  my @rv;

  &checkArrayRefLengths($values, $headers);
  my $ontologyMapping = $self->getOntologyMapping();

  for(my $i = 0; $i < scalar @$headers; $i++) {
    my $header = $headers->[$i];
    my $value = $values->[$i];

    if($ontologyMapping->{lc($header)} && $ontologyMapping->{lc($header)}->{type} eq 'characteristicQualifier') {
      my $qualifier = $ontologyMapping->{lc($header)}->{source_id};
      my $functions = $ontologyMapping->{lc($header)}->{function};
      my $parent = $ontologyMapping->{lc($header)}->{parent};

      my $node = $nodesHash->{$parent};

      my $char = CBIL::ISA::StudyAssayEntity::Characteristic->new({_value => $value});
      $char->setQualifier($qualifier);

      my $functionsObj = $self->getFunctions();
      foreach my $function (@$functions) {
        eval {
          $functionsObj->$function($char);
        };
        if ($@) {
          die "Problem with function $function: $@";
        }
      }

      $node->addCharacteristic($char);
    }
    else {
      push @rv, $i;
    }
  }
  return \@rv;
}


sub checkArrayRefLengths {
  my ($a, $b) = @_;
  unless(scalar @$a == scalar @$b) {
    die "Inconsistent array lengths";
  }
}


sub makeNodes {
  my ($self, $prefix, $description, $sourceMtOverride, $sampleMtOverride, $count, $studyXml, $study) = @_;

  my $ontologyMapping = $self->getOntologyMapping();

  my %nodes;
  foreach my $isaType (keys %{$studyXml->{node}}) {
    my $class = "CBIL::ISA::StudyAssayEntity::$isaType";

    my $name = $prefix;

    if(my $suffix = $studyXml->{node}->{$isaType}->{suffix}) {
      $name .= " ($suffix)";
    }

    my $hash = { _value => $name };
    my $node = &makeObjectFromHash($class, $hash);

    my $materialType = $studyXml->{node}->{$isaType}->{type};
    $materialType = $sourceMtOverride if($sourceMtOverride && $isaType eq 'Source');
    $materialType = $sampleMtOverride if($sampleMtOverride && $isaType eq 'Sample');

    if($materialType) {
      my $mtClass = "CBIL::ISA::StudyAssayEntity::MaterialType";

      my $sourceId = $ontologyMapping->{lc($materialType)}->{source_id};
      unless($sourceId) {
        die "Could not find onotlogyTerm for material type $materialType";
      }

      my $mt = &makeOntologyTerm($sourceId, $materialType, $mtClass);      
      $node->setMaterialType($mt);
    }

    if($isaType eq 'Sample') {
      $node->setDescription($description);

      my $sampleIdentifier = $study->getIdentifier() . "-$count";;
      if(my $regexmatch = $self->getRegexMatch()) {
        my $sampleRegex = $studyXml->{sampleRegex};
        $sampleIdentifier =~ s/$regexmatch/$sampleRegex/;
        $node->setValue($sampleIdentifier);
      }
    }

    $nodes{$isaType} = $node;
    $study->addNode($node);
  }

  return \%nodes;
}

sub makeProtocols {
  my ($self, $protocols) = @_;

  my $ontologyMapping = $self->getOntologyMapping();
  my %protocolParams;

  my @rv;

  foreach my $termName (keys %$ontologyMapping) {


    my $type = $ontologyMapping->{$termName}->{type};
    my $parent = $ontologyMapping->{$termName}->{parent};

    my $sourceId = $ontologyMapping->{$termName}->{source_id};

    if($type eq 'protocolParameter' && $protocols->{$parent}) {
      my $pp = &makeOntologyTerm($sourceId, $termName, undef);
      push @{$protocolParams{$parent}}, $pp;
    }

    if($type eq 'protocol'  && $protocols->{$termName}) {
      my $pt = &makeOntologyTerm($sourceId, $termName, undef);

      my $protocol = CBIL::ISA::Protocol->new();
      $protocol->setProtocolType($pt);
      $protocol->setProtocolName($termName);
      push @rv, $protocol;
    }
  }

  # assign protocol params to protocols
  foreach my $pn (keys %protocolParams) {
    foreach my $rProtocol (@rv) {
      if($rProtocol->getProtocolName() eq $pn) {
        foreach(@{$protocolParams{$pn}}) {
          $rProtocol->addProtocolParameters($_);
        }
      }
    }
  }

  return \@rv;
}


#--------------------------------------------------------------------------------



1;
