package CBIL::ISA::InvestigationSimple;
use base qw(CBIL::ISA::Investigation);

use strict;
use XML::Simple;

use Scalar::Util 'blessed';
use CBIL::ISA::OntologyTerm qw(@allOntologyTerms);
use ApiCommonData::Load::OntologyMapping;
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

sub setOntologySources {$_[0]->{_ontology_sources} = $_[1]}
sub getOntologySources {$_[0]->{_ontology_sources} }

sub setRegexMatch {$_[0]->{_regex_match} = $_[1]}
sub getRegexMatch {$_[0]->{_regex_match} }

sub setFunctions {$_[0]->{_functions} = $_[1]}
sub getFunctions {$_[0]->{_functions} }

sub setRowLimit {$_[0]->{_row_limit} = $_[1]}
sub getRowLimit {$_[0]->{_row_limit} }

sub setIsReporterMode {$_[0]->{_is_reporter_mode} = $_[1]}
sub getIsReporterMode {$_[0]->{_is_reporter_mode} }


sub setStudySpecialColumns {$_[0]->{_study_special_columns} = $_[1]}
sub getStudySpecialColumns {$_[0]->{_study_special_columns} }
sub addStudySpecialColumn {
  my ($self, $col) = @_;

  foreach(@{$self->{_study_special_columns}}) {
    return if($_ eq $col);
  }

  push @{$self->{_study_special_columns}}, $col;
}

sub new {
  my ($class, $investigationFile, $ontologyMappingFile, $ontologyMappingOverrideFile, $valueMappingFile, $debug, $isReporterMode, $dateObfuscationFile) = @_;

  @allOntologyTerms = ();

  my $investigationDirectory = dirname $investigationFile;

  my $investigationXml = XMLin($investigationFile, ForceArray => 1);
  my $ontologyMapping;
  if($ontologyMappingFile =~ /.owl$/i){
    my $om = ApiCommonData::Load::OntologyMapping->new($ontologyMappingFile);
    $ontologyMapping = $om->getOntologyMapping();
  }
  else{
    $ontologyMapping = XMLin($ontologyMappingFile, ForceArray => 1);
  }

  my %ontologyMapping;
  my %ontologySources;


  foreach my $os (@{$ontologyMapping->{ontologySource}}) {
    $ontologySources{lc($os)} = 1;
  }


  foreach my $ot (@{$ontologyMapping->{ontologyTerm}}) {
    my $sourceId = $ot->{source_id};
    $ontologyMapping{lc($sourceId)}->{$ot->{type}} = $ot;
    my @names;
    if(ref($ot->{name}) eq "ARRAY"){
      @names = @{$ot->{name}};
    }
    elsif(ref($ot->{name}) eq "HASH"){
      @names = map { $_->{content} } values %{$ot->{name}};
      $ot->{name} = \@names;
    }
    else {
      die "Cannot read names from ontologyTerm $sourceId in $ontologyMappingFile\n"
    }
    foreach my $name (@names) {
      $ontologyMapping{lc($name)}->{$ot->{type}} = $ot;
    }

  }

  if(-e $ontologyMappingOverrideFile) {
    my $ontologyMappingOverride = XMLin($ontologyMappingOverrideFile, ForceArray => 1);

    foreach my $os (@{$ontologyMappingOverride->{ontologySource}}) {
      $ontologySources{lc($os)} = 1;
    }

    foreach my $ot (@{$ontologyMappingOverride->{ontologyTerm}}) {
      my $sourceId = $ot->{source_id};
      $ontologyMapping{lc($sourceId)}->{$ot->{type}} = $ot;
      
      foreach my $name (@{$ot->{name}}) {
        $ontologyMapping{lc($name)}->{$ot->{type}} = $ot;
      }
    }
  }

  my $self = $class->SUPER::new();
  $self->setInvestigationDirectory($investigationDirectory);

  $self->setOntologyMapping(\%ontologyMapping);
  $self->setSimpleXml($investigationXml);

  $self->setDebug($debug);

  my $functions = CBIL::ISA::Functions->new({_ontology_mapping => \%ontologyMapping, _ontology_sources => \%ontologySources, _valueMappingFile => $valueMappingFile, _dateObfuscationFile => $dateObfuscationFile});
  $self->setFunctions($functions);

  $self->setStudySpecialColumns(['name', 'description', 'sourcemtoverride', 'samplemtoverride', 'parent']);
  $self->setRowLimit(500);

  $self->setOntologyAccessionsHash({});

  $self->setIsReporterMode($isReporterMode);

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
    $study->setHasMoreData(1);

    $study->setFileName($metaDataFileFullPath);

    my %protocols;

    $studyXml->{identifier} = $identifier;

    if(lc $studyXml->{disallowEdgeLookup} eq 'true') {
      $study->setDisallowEdgeLookup(1);
    }


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


    my $studyAssay;
    if($studyXml->{dataset}) {
      my $datasets = join(';', @{$studyXml->{dataset}});
      $studyAssay = CBIL::ISA::StudyAssay->new({'_comment[dataset_names]' => $datasets});
    }
    else {
      $studyAssay = CBIL::ISA::StudyAssay->new();
    }


    $study->addStudyAssay($studyAssay);

    $self->addStudy($study);
  }
}


#@override
sub parseStudy {
  my ($self, $study) = @_;

  my $studyXml = $study->{_SIMPLE_XML};
  my $fileName = $study->getFileName();
  my $fileHandle = $study->getFileHandle();

  unless($fileHandle) {
    print STDERR "Processing study file $fileName\n";
    open($fileHandle,  $fileName) or die "Cannot open file $fileName for reading: $!";    
    $study->setFileHandle($fileHandle);

    my $header = <$fileHandle>;
    chomp $header;
    my @headers = split(/\t/, $header);
    $study->{_simple_study_headers} = \@headers;
    $study->{_simple_study_count} = 1;
  }

  $self->dealWithAllOntologies();
  @allOntologyTerms = ();
  $study->{_nodes} = [];
  $study->{_edges} = [];

  $self->addNodesAndEdgesToStudy($study, $fileHandle, $studyXml);


#  my %nodeType;
#  foreach(@{$study->getNodes()}) {
#    my $type = $_->getMaterialType()->getTerm();
#    $nodeType{$type}++;
#  }

#  print STDERR Dumper \%nodeType;
#  print STDERR "Edge Count:  " . scalar @{$study->getEdges()};
}


sub addNodesAndEdgesToStudy {
  my ($self, $study, $fileHandle, $studyXml) = @_;

  my $headers = $study->{_simple_study_headers};
  my $count = $study->{_simple_study_count};

  my $rowLimit = $self->getRowLimit();
  my $isReporterMode = $self->getIsReporterMode();

  my $rowCount = 0;
  my $reportedMissingColumns;
  while(my $line = <$fileHandle>) {
    chomp $line;



    my @a = split(/\t/, $line);

    my %valuesHash;

    for(my $i = 0; $i < scalar @$headers; $i++) {
      my $lcHeader = lc $headers->[$i];

      push @{$valuesHash{$lcHeader}}, $a[$i];
    }

    my $nodesHash = $self->makeNodes(\%valuesHash, $count, $studyXml, $study);

    my ($protocolAppHash, $nodeIOHash) = $self->makeEdges($studyXml, $study, $nodesHash);

    if($studyXml->{allNodesGetDeltas}){
      $self->allNodesGetDeltas($nodesHash, $nodeIOHash);
    }

    my $leftoverColumns = $self->addCharacteristicsToNodes($nodesHash, \%valuesHash, $nodeIOHash);

    my $missingColumns = $self->addProtocolParametersToEdges($protocolAppHash, \%valuesHash, $leftoverColumns, $nodeIOHash);

    if(not $reportedMissingColumns) {
      my %specialColumns = map {lc($_) => 1 } @{$self->getStudySpecialColumns()};
      my @missingColumns = sort grep {not $specialColumns{lc($_)}} @$missingColumns;
      if(@missingColumns){
        $self->handleError("Unmapped column headers:  ". join (", ", @missingColumns));
        $reportedMissingColumns++;
      }
    }
    $count++;
    $rowCount++;

    $study->{_simple_study_count} = $count;

    if($rowCount == $rowLimit) {
      print STDERR "Processed $count lines\n";

      if($isReporterMode) {
        $study->setHasMoreData(0);
        close $fileHandle;
      }


      return;
    }

  }

  $study->setHasMoreData(0);
  close $fileHandle;
}

sub addProtocolParametersToEdges {
  my ($self, $protocolAppHash, $valuesHash, $leftoverColumns) = @_;

#  &checkArrayRefLengths($values, $headers);

  my $ontologyMapping = $self->getOntologyMapping();

  my @rv;

  foreach my $key (@$leftoverColumns) {
    my $header = $key;
    if($header =~ /Parameter Value\s*\[(.+)\]/i) {
      $header = $1;
    }

    my $omType = "protocolParameter";
    if($ontologyMapping->{lc($header)} && $ontologyMapping->{lc($header)}->{$omType}) {    
      my $qualifier = $ontologyMapping->{lc($header)}->{$omType}->{source_id};
      my $functionsRef = $ontologyMapping->{lc($header)}->{$omType}->{function};
      my $parent = $ontologyMapping->{lc($header)}->{$omType}->{parent};


#      my @functions = qw/formatSentenceCase/;

      my @functions;
      if($functionsRef) {
        push @functions, @$functionsRef;
      }
      else {
        push @functions, "valueIsMappedValue";
      }

      my $protocolApp = $protocolAppHash->{$parent};

      if(!$protocolApp) {
        $self->handleError("Protocol [$parent] not defined for paramValue [$header]");
      }
      else {

        my $values = $valuesHash->{$key};
        foreach my $value (@$values) {
          next unless($value || $value eq '0'); # put this here because I still wanna check the headers

          my $pv = CBIL::ISA::StudyAssayEntity::ParameterValue->new({_value => $value});
          $pv->setQualifier($qualifier);


          my $functionsObj = $self->getFunctions();
          foreach my $function (@functions) {
            eval {
              $functionsObj->$function($pv, $protocolApp, undef);
            };
            if ($@) {
              $self->handleError("problem w/ function $function: $@");
            }
          }
          $protocolApp->addParameterValue($pv);
        }
      }
    }
    else {
      push @rv, $key;
    }
  }

  return \@rv;
}




sub makeEdges {
  my ($self, $studyXml, $study, $nodesHash) = @_;

  my %rv;

  my %nodeIO;

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
    my $edge = $study->addEdge($inputNode, \@protocolApplications, $outputNode);

    my $outputNodeName = $outputNode->getValue();

    push @{$nodeIO{$outputNodeName}}, $inputNode;
  }
  return(\%rv, \%nodeIO);
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
  my ($self, $nodesHash, $valuesHash, $nodeIOHash) = @_;

  my @nodeNames = keys %$nodesHash;

  my @rv;

#  &checkArrayRefLengths($values, $headers);
  my $ontologyMapping = $self->getOntologyMapping();

  while (my ($key, $values) = each %$valuesHash) {

    my $header = $key;
    if($header =~ /Characteristics\s*\[(.+)\]/i) {
      $header = $1;
    }

    my $omType = "characteristicQualifier";
    if($ontologyMapping->{lc($header)} && $ontologyMapping->{lc($header)}->{$omType}) {

      my $qualifier = $ontologyMapping->{lc($header)}->{$omType}->{source_id};
      my $functionsRef = $ontologyMapping->{lc($header)}->{$omType}->{function};

#      my @functions = qw/formatSentenceCase/;
      my @functions;
      if($functionsRef) {
        push @functions, @$functionsRef;

      }
      else {
        push @functions, "valueIsMappedValue";
      }
      my $forceDateDelta = grep { /Obfuscation/i } @functions;

      my $parent = $ontologyMapping->{lc($header)}->{$omType}->{parent};
      my $node = $nodesHash->{$parent};

      my $nodeName = $node->getValue();

      my @inputNodes;
      if($nodeIOHash->{$nodeName}) {
        @inputNodes = @{$nodeIOHash->{$nodeName}};
      }

      foreach my $value(@$values) {
        next unless($value || $value eq '0' || $forceDateDelta); # put this here because I still wanna check the headers
        my $char = CBIL::ISA::StudyAssayEntity::Characteristic->new({_value => $value});
        $char->setQualifier($qualifier);
        $char->setAlternativeQualifier(lc($header));

        my $functionsObj = $self->getFunctions();
        foreach my $function (@functions) {
          eval {
            $functionsObj->$function($char, $node, \@inputNodes);
          };
          if ($@) {
            $self->handleError("problem w/ function $function: $@");
          }
        }

        $node->addCharacteristic($char) if(defined $char->getValue() && $char->getValue() ne "");

      }
    }
    else {
      push @rv, $key;
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
  my ($self, $valuesHash, $count, $studyXml, $study) = @_;

  my $ontologyMapping = $self->getOntologyMapping();

  my %nodes;

  my %inputNames;
  foreach my $edge ( @{$studyXml->{edge}} ){
    $inputNames{ $edge->{input} } = 1;
  }

  foreach my $nodeName (keys %{$studyXml->{node}}) {
    my $isaType = defined($studyXml->{node}->{$nodeName}->{isaObject}) ? $studyXml->{node}->{$nodeName}->{isaObject} : $nodeName;
    my $class = "CBIL::ISA::StudyAssayEntity::$isaType";

    my $idColumn = lc($studyXml->{node}->{$nodeName}->{idColumn}) || "name";
    my $name;
    if($idColumn =~ /:::/){
      my @cols = split(/:::/, $idColumn);
      my @keys = map { $valuesHash->{$_}->[0] } @cols;
      $name = join("_", @keys);
    }
    else { 
      $name = $valuesHash->{$idColumn}->[0];
    }
    $self->addStudySpecialColumn($idColumn); # housekeeping

    my $description = $valuesHash->{description}->[0];
    my $sourceMtOverride = $valuesHash->{sourcemtoverride}->[0];
    my $sampleMtOverride = $valuesHash->{samplemtoverride}->[0];

    if(my $suffix = $studyXml->{node}->{$nodeName}->{suffix}) {

      if(lc $studyXml->{node}->{$nodeName}->{useExactSuffix} eq 'true') {
        $name .= $suffix;
      }
      else {
        $name .= " ($suffix)";
      }
    }

    my $hash = { _value => $name };
    my $node = &makeObjectFromHash($class, $hash);
    my $idObfuscationFunction = $studyXml->{node}->{$nodeName}->{idObfuscationFunction};
    my $oldNodeId = $node->getValue();
    if($idObfuscationFunction){
      my $functionsObj = $self->getFunctions();
      eval {
        $functionsObj->$idObfuscationFunction($node,$studyXml->{node}->{$nodeName}->{type});
      };
      if ($@) {
        $self->handleError("problem w/ function $idObfuscationFunction: $@");
      }
      else{
        my $nodeId = $node->getValue();
        $self->{idMap}->{$nodeId} = $oldNodeId;
        # printf STDERR ("OBFUSCATED\t%s\t%s\n", $nodeId, $oldNodeId);
      }
    }
    my $nodeId = $node->getValue();
    if($idObfuscationFunction && !defined($inputNames{$nodeName}) ){
      ## only check if id obfuscation is used and
      ## if this is is not an edge INPUT (PARENT); check only OUTPUTs or nodes without any edges
      if($nodeId eq $oldNodeId){
        #warn "Node ID not obfuscated: $oldNodeId = $nodeId";
      }
      if(defined($self->{seenNodes}->{$nodeId})){
        die "Duplicate node ID for $nodeName $oldNodeId: $nodeId = " . $self->{seenNodes}->{$nodeId};
      }
      $self->{seenNodes}->{$nodeId} = $oldNodeId;
    }
    my $materialType = $studyXml->{node}->{$nodeName}->{type};
    $materialType = $sourceMtOverride if($sourceMtOverride && $isaType eq 'Source');
    $materialType = $sampleMtOverride if($sampleMtOverride && $isaType eq 'Sample');

    if($materialType) {
      my $mtClass = "CBIL::ISA::StudyAssayEntity::MaterialType";


      my $sourceId = $ontologyMapping->{lc($materialType)}->{materialType}->{source_id};
      unless($sourceId) {
        $self->handleError("Could not find ontologyTerm for material type [$materialType]");
      }

      my $mt = &makeOntologyTerm($sourceId, $materialType, $mtClass);      
      $node->setMaterialType($mt);
    }

    if($isaType eq 'Sample' && $studyXml->{sampleRegex}) {
      $node->setDescription($description);

      my $sampleIdentifier = $study->getIdentifier() . "-$count";;
      if(my $regexmatch = $self->getRegexMatch()) {
        my $sampleRegex = $studyXml->{sampleRegex};
        $sampleIdentifier =~ s/$regexmatch/$sampleRegex/;
        $node->setValue($sampleIdentifier);
      }
    }

    $nodes{$nodeName} = $node;
    $study->addNode($node);
  }

  return \%nodes;
}

sub makeProtocols {
  my ($self, $protocols) = @_;

  my $ontologyMapping = $self->getOntologyMapping();
  my %protocolParams;

  my %seenPPs;

  my @rv;

  my $omType = "protocol";
  foreach my $protocolName (keys %$protocols) {
    my $sourceId = $ontologyMapping->{lc($protocolName)}->{$omType}->{source_id};

    my $pt = &makeOntologyTerm($sourceId, $protocolName, undef);

    my $protocol = CBIL::ISA::Protocol->new();
    $protocol->setProtocolType($pt);
    $protocol->setProtocolName($protocolName);
    push @rv, $protocol;
  }

  $omType = "protocolParameter";

  foreach my $termName (keys %$ontologyMapping) {
    if($ontologyMapping->{$termName}->{$omType}) {
      my $parent = lc($ontologyMapping->{$termName}->{$omType}->{parent});
      my $sourceId = $ontologyMapping->{$termName}->{$omType}->{source_id};

      next unless($protocols->{$parent});

      unless($seenPPs{$parent}{$sourceId}) {
        my $pp = &makeOntologyTerm($sourceId, $sourceId, undef);
        push(@{$protocolParams{$parent}}, $pp) ;
      }
      $seenPPs{$parent}{$sourceId} = 1;
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

sub allNodesGetDeltas {
  my ($self, $nodesHash, $nodeIOHash) = @_;
  my $functionsObj = $self->getFunctions();
  foreach my $node (values %$nodesHash){
    my $nodeName=$node->getValue();
    $functionsObj->setDeltaForNode($node,$nodeIOHash->{$nodeName} || []);
  }
}

sub writeObfuscatedIdFile {
  my ($self,$file) = @_;
  $file ||= $self->getInvestigationDirectory() . "/idObfuscation.txt";
  open(FH, ">$file") or die "Cannot write $file: $!";
    printf FH ("ObfuscatedID\tOriginalID\n");
  while(my ($obfuscatedId,$originalId) = each(%{$self->{idMap}})){
    printf FH ("%s\t%s\n", $originalId, $obfuscatedId);
  }
  close(FH);
}

#--------------------------------------------------------------------------------



1;
