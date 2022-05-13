package CBIL::ISA::Functions;
require Exporter;
@ISA = qw(Exporter);

@EXPORT_OK = qw(makeObjectFromHash makeOntologyTerm);
use strict;
use warnings;

use Scalar::Util qw/blessed looks_like_number/;
use Date::Manip qw(Date_Init ParseDate UnixDate DateCalc);

use CBIL::ISA::OntologyTerm;
use Date::Parse qw/strptime/;
use Carp;

use File::Basename;

use Data::Dumper;
use Digest::SHA;

use Switch;

sub getOntologyMapping {$_[0]->{_ontology_mapping} }
sub getOntologySources {$_[0]->{_ontology_sources} }
sub getValueMappingFile {$_[0]->{_valueMappingFile} }

sub getValueMapping {$_[0]->{_valueMapping} }
sub setValueMapping {$_[0]->{_valueMapping} = $_[1] }

sub getDateObfuscationFile {$_[0]->{_dateObfuscationFile} }

sub getDateObfuscationOutFh {$_[0]->{_dateObfuscationOutFh} }
sub setDateObfuscationOutFh {$_[0]->{_dateObfuscationOutFh} = $_[1] }

sub getDateObfuscation {$_[0]->{_dateObfuscation} }
sub setDateObfuscation {$_[0]->{_dateObfuscation} = $_[1] }

sub new {
  my ($class, $args) = @_;

  my $self = bless $args, $class;

  my $valueMappingFile = $self->getValueMappingFile();

  my $valueMapping = {};
  if($valueMappingFile) {
    open(FILE, $valueMappingFile) or die "Cannot open file $valueMappingFile for reading: $!";

    while(my $line = <FILE>) {
      chomp $line;
      my @row = map { s/^\s*|\s*$//g; defined($_) ? $_ : ''} split(/\t/, $line);
      my ($qualName, $qualSourceId, $in, $out, $categoricalOrder, $termId) = @row;
      if($termId){ $termId =~ s/[\{\}]//g }
      # term ID is the ontology term source ID (IRI) for the value, referenced in GUS by Study.Characteristic.ONTOLOGY_TERM_ID
      # not to be confused with Qualifier_ID or Unit_ID
      #
      my $lcIn = lc($in) if(defined($in)); # value hash key, matching is not case-sensitive
      if( $lcIn =~ /^:::function:/ ){ ## bypass case-insensitivity for embedded functions
        $lcIn = $in;
      }


      # I think case for source_ids matters so these need to match exactly
      $valueMapping->{$qualSourceId}->{$lcIn} = $out;

      if($qualName) {
        my $lcQualName = lc $qualName;
        $valueMapping->{$lcQualName}->{$lcIn} = $out;
      }
      if($termId){ $valueMapping->{_TERMS_}->{$qualSourceId}->{$lcIn}=$termId }
      # This maps a term to the ORIGINAL value (not mapped value)
    }
    close FILE;
  }
  $self->setValueMapping($valueMapping);

  my $dateObfuscationFile = $self->getDateObfuscationFile();
  my $dateObfuscation = {};
  if($dateObfuscationFile) {
    open(FILE, $dateObfuscationFile) or die "Cannot open file $dateObfuscationFile for reading: $!";

    while(<FILE>) {
      chomp;
      my ($recordTypeSourceId, $recordPrimaryKey, $delta) = split(/\t/, $_);
      #die("$dateObfuscationFile has a bad format: [$recordTypeSourceId] [$recordPrimaryKey] [$delta]\n") unless($recordTypeSourceId && $recordPrimaryKey && $delta);
      $dateObfuscation->{$recordTypeSourceId}->{$recordPrimaryKey} = $delta;
    }
    close FILE;

    # Important to append here
    open(my $dateObfuscationOutFile, ">>$dateObfuscationFile") or die "Cannot open file $dateObfuscationFile for writing: $!";
    $self->setDateObfuscationOutFh($dateObfuscationOutFile);
  }
  $self->setDateObfuscation($dateObfuscation);

  return $self;
}


sub enforceYesNoUndefForBoolean {
  my ($self, $obj) = @_;
  my $value = $obj->getValue();
  return undef unless defined($value);
  if($value =~ /^\d+$/){ $value = int($value); } # remove leading zeros if $value is integer;
  my %allowedValues = (
    "1" => "Yes",
    "yes" => "Yes",
    "true" => "Yes",
    "y" => "Yes",
    "0" => "No",
    "no" => "No",
    "n" => "No",
    "false" => "No",
    "" => "",
  );
  my $cv = $allowedValues{lc($value)};
  if(defined($cv)) {
    return $obj->setValue($cv);
  }
  else  {
    return $obj->setValue(undef);
  }
}

sub enforceYesNoForBoolean {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();

  return undef unless defined($value);# && $value ne "";
  if($value =~ /^\d+$/){ $value = int($value); } # remove leading zeros if $value is integer;

  my %allowedValues = (
    "1" => "Yes",
    "yes" => "Yes",
    "true" => "Yes",
    "y" => "Yes",
    "0" => "No",
    "no" => "No",
    "n" => "No",
    "false" => "No",
    "" => "",
  );

  my $cv = $allowedValues{lc($value)};

  if(defined($cv)) {
    return $obj->setValue($cv);
  }

  die "Could not map value [$value] to Yes or No\n" .  Dumper($obj);
}


sub cacheDelta {
  my ($self, $sourceId, $primaryKey, $deltaString) = @_;

  # print to cache file
  my $dateObfuscationOutFh = $self->getDateObfuscationOutFh();
  my $dateObfuscation = $self->getDateObfuscation();

  print $dateObfuscationOutFh "$sourceId\t$primaryKey\t$deltaString\n";
  $dateObfuscation->{$sourceId}->{$primaryKey} = $deltaString;
}


sub calculateDelta {
  my ($self) = @_;
  my $params = $self->getFunctionParams();
  my $plusOrMinusDays = $params->{plusOrMinusDays} || 7; # TODO: parameterize this
  my $direction = int (rand(2)) ? 1 : -1;
  my $magnitude = 1 + int(rand($plusOrMinusDays));
  my $days = $direction * $magnitude; 
  my $deltaString = "0:0:0:$days:0:0:0";
  return $deltaString;
}


sub internalDateWithObfuscation {
  my ($self, $obj, $parentObj, $parentInputObjs, $dateFormat) = @_;

  my $value = $obj->getValue();
  $value && $value =~ s/^\s*(.*)\s$/$1/;
  return unless $value;

  # deal with "Mon Year" values by setting the day to the first day of the month
  if(defined($value) && ($value =~ /^\w{3}\s*\d{2}(\d{2})?$/)) {
    $value = "1 " . $value;
  }

  Date_Init($dateFormat); 

  my $formattedDate;
  
  my $params = $self->getFunctionParams();
 
  my $dateValue = ParseDate($value);
  if($params->{minDate}){
    my $minDate = ParseDate($params->{minDate});
    my @delta = split(/:/, DateCalc($minDate,$dateValue));
    if( $delta[4] <= 0 ){ # abort, make no change to value and do not create a date delta
      return;
    }
  }
  if($params->{maxDate}){
    my $maxDate = ParseDate($params->{maxDate});
    my @delta = split(/:/, DateCalc($maxDate,$dateValue));
    if( $delta[4] >= 0 ){ # abort, make no change to value and do not create a date delta
      return;
    }
  }
 
  if($self->getDateObfuscationFile()) {
    my $dateObfuscation = $self->getDateObfuscation();

    my $delta;

    if($parentObj->isNode()) {
      my $nodeId = $parentObj->getValue();

      my $materialType = $parentObj->getMaterialType();
      my $materialTypeSourceId = $materialType->getTermAccessionNumber();
      $delta = $dateObfuscation->{$materialTypeSourceId}->{$nodeId};

      unless($delta) {

        # if I have inputs and one of my inputs has a delta, cache that and use for self
        if(scalar @$parentInputObjs > 0) {
          foreach my $input(@$parentInputObjs) {
            my $inputNodeId = $input->getValue();

            my $inputMaterialType = $input->getMaterialType();
            my $inputMaterialTypeSourceId = $inputMaterialType->getTermAccessionNumber();

            if($delta && $delta ne $dateObfuscation->{$inputMaterialTypeSourceId}->{$inputNodeId}) {
              die "2 deltas found for parents of $nodeId" if($dateObfuscation->{$inputMaterialTypeSourceId}->{$inputNodeId});
            }

            $delta = $dateObfuscation->{$inputMaterialTypeSourceId}->{$inputNodeId};
            $self->cacheDelta($materialTypeSourceId, $nodeId, $delta) if($delta);
            last;
          }
          # I had a parent, but it didn't have a delta
          unless($delta) {
          #  die "No delta available for $nodeId";
          #  TODO set a property for a fallback callback
         	  $delta = $self->calculateDelta();
         	  $self->cacheDelta($materialTypeSourceId, $nodeId, $delta);
          }
        }

        # else, calculate new delta and cache for self
        unless($delta) {
          $delta = $self->calculateDelta();
          $self->cacheDelta($materialTypeSourceId, $nodeId, $delta);
        }
      }
    }
    else {
      # TODO: deal with protocol params
      die "Only Characteristic Values currently allow date obfuscation";
    }

    my $date = DateCalc($value, $delta); 
    $formattedDate = UnixDate($date, "%Y-%m-%d");
  }
  else {
    die "No dateObfuscationFile was not provided";
  }

  $obj->setValue($formattedDate);

  unless($value){
    return $value;
  }
  unless(defined($formattedDate)) {
    die "Date Format not supported for [$value]=[$formattedDate], OR bad date obfuscation file\n" . $obj->getAlternativeQualifier . "\n" . Dumper($obj);
  }

  return $formattedDate;
}


sub setDeltaForNode {
  my ($self, $nodeObj, $parentInputObjs) = @_;
  unless($self->getDateObfuscationFile()) {
    die "No dateObfuscationFile was not provided";
  }
  my $dateObfuscation = $self->getDateObfuscation();
  my $delta;
  my $nodeId = $nodeObj->getValue();

  my $materialType = $nodeObj->getMaterialType();
  my $materialTypeSourceId = $materialType->getTermAccessionNumber();
  $delta = $dateObfuscation->{$materialTypeSourceId}->{$nodeId};
  return 1 if $delta;
  if(scalar @$parentInputObjs) {
  # if I have inputs and one of my inputs has a delta, cache that and use for self
    foreach my $input(@$parentInputObjs) {
      my $inputNodeId = $input->getValue();

      my $inputMaterialType = $input->getMaterialType();
      my $inputMaterialTypeSourceId = $inputMaterialType->getTermAccessionNumber();

      if($delta && $delta ne $dateObfuscation->{$inputMaterialTypeSourceId}->{$inputNodeId}) {
        die "2 deltas found for parents of $nodeId" if($dateObfuscation->{$inputMaterialTypeSourceId}->{$inputNodeId});
      }

      $delta = $dateObfuscation->{$inputMaterialTypeSourceId}->{$inputNodeId};
      last;
    }
  }
  $delta ||= $self->calculateDelta();
  $self->cacheDelta($materialTypeSourceId, $nodeId, $delta);
  return 1;
}


sub formatEuroDate {
  my ($self, $obj, $parentObj) = @_;

  my $value = $obj->getValue();
  return unless $value;

  # deal with "Mon Year" values by setting the day to the first day of the month
  if($value =~ /^\w{3}\s*\d{2}(\d{2})?$/) {
    $value = "1 " . $value;
  }

  Date_Init("DateFormat=non-US"); 

  my $formattedDate = UnixDate(ParseDate($value), "%Y-%m-%d");

  $obj->setValue($formattedDate);

  unless($formattedDate) {
    die "Date Format not supported for [$value]\n";
  }

  return $formattedDate;
}



sub formatHouseholdId {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();

  if ($value=~/^HH\d+$/i) {
    $value = uc($value);
    $obj->setValue($value);
  }
  else {
    $obj->setValue("HH$value");
  }
  return $obj;
}

sub valueIsMappedValue {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();
  my $qualName = $obj->getAlternativeQualifier();
  # Handle automatically generated variables, having suffix like "!!1", "!!2"
  # These are generated when an entity has multiple values from the same column
  # They should be treated the same here as the original column (alternative qual)
  $qualName =~ s/\!\!.*$//;
  #
  my $qualSourceId = $obj->getQualifier();

  my $valueMapping = $self->getValueMapping();

  ## 
  ## First look for a rule matching this particular column
  ## (the codebook for this file and/or column may be special)
  ## This is found in column 1 of valueMap.txt
  my $qualifierValues = $valueMapping->{$qualName};
  ## get the mapping for the IRI
  ## This is found in column 2 of valueMap.txt
  $qualifierValues //= {};
  my $vmBySourceId = $valueMapping->{$qualSourceId};
  while( my ($rawval, $mapval) = each %$vmBySourceId){
    next if( $qualifierValues->{lc($rawval)} ); # give bias to previous rows, no override
    $qualifierValues->{lc($rawval)} = $mapval;
  }
  ## _TERMS_ are the ontology IRIs for specific values
  ## Currently this serves no purpose but may be relevant at some time in the future
  ## If there is an IRI for the value, it is added to this file during preprocessing
  my $terms = $valueMapping->{_TERMS_}->{$qualSourceId};

  unless(defined($value) && ($value ne "")){ return }

  ## $qualifierValues = { hashref of value=>mapped value/term }
  if($qualifierValues) { ## there is some row for this variable
    my $lcValue = lc($value); ## matching is not case-sensitive
    ## Skip rows where 
## <CLEAN-UP qualifierValues->{:::undef:::} tried to use this to insert a value, didn't work
    # unless(defined($value) || defined($qualifierValues->{':::undef:::'})){ return; }
    # unless(defined($value)){ return; }
    # unless(defined($lcValue)){ $lcValue = ':::undef:::';}
## CLEAN-UP>
    my $newValue = $qualifierValues->{$lcValue};
    unless(defined($newValue) && length($newValue)){
      foreach my $regex ( grep { /^\{\{.*\}\}$/ } keys %$qualifierValues){
        my ($test) = ($regex =~ /^\{\{(.*)\}\}$/);
        $test = qr/$test/;
        if($lcValue =~ $test){
          $newValue = $qualifierValues->{$regex};
          last;
        }
        else {
          #printf STDERR ("NO MATCH $lcValue =~ $test\n");
        }
      }
    }
    if(defined($newValue)){
      if(uc($newValue) eq ':::UNDEF:::'){
        $obj->setValue(undef);
      }
      elsif($newValue || $newValue eq '0') {
        $obj->setValue($newValue);
      }
    }
    ## After matching value and applying mapping
    ## Check whether there are functions in valueMap.txt
    ## Functions are normally added in ontologyMapping.xml
    ## but it may be convenient to add them in valueMap.txt
    my @mappedFunctions = map { /^:::function:(.*)$/; $1 } grep { /^:::function:/ } keys %$qualifierValues;
    foreach my $func (@mappedFunctions){
      if($self->can($func)){
        ## Get param(s) from mapped value column
        ## Leave it up to the function to parse it
        my $param = $qualifierValues->{$func};
        $self->$func($obj,$param);
      }
      else{
printf STDERR "$func is not defined\n";
      }
    }
    
    if(keys %{$terms} && defined($terms->{$lcValue})){
      my $termSourceId = $terms->{$lcValue};
      $obj->setTermAccessionNumber($termSourceId);
      my ($termSource) = $termSourceId =~ /^(\w+)_|:/;
      $obj->setTermSourceRef($termSource);
    }
  }
}

sub excludeColumn {
  my ($self, $obj) = @_;
  return $obj->setValue(undef);
}

sub mappedValueRequired {
  my ($self, $obj) = @_;
  my $oldval = $obj->getValue();
  $self->valueIsMappedValue($obj);
  my $newval = $obj->getValue();
  if($oldval eq $newval){
    my $qualSourceId = $obj->getQualifier();
    my $qualName = $obj->getAlternativeQualifier();
    print STDERR ("VALUE_MAP_ERROR\t$qualSourceId|$qualName\t{{$oldval}}\n");
  }
}



sub valueIsMappedValueAltQualifier {
  my ($self, $obj) = @_;

  my $value = lc $obj->getValue();
  my $altQualifier = $obj->getAlternativeQualifier();

  my $valueMapping = $self->getValueMapping();

  my $qualifierValues = $valueMapping->{$altQualifier};


  if($qualifierValues) {
    my $lcValue = lc($value);

    my $newValue = $qualifierValues->{$lcValue};
    $newValue = undef unless(defined($newValue));

    if(exists $qualifierValues->{$value}) {
      $obj->setValue($newValue);
    }
  }
}



sub valueIsOntologyTerm {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();

  my $omType = blessed($obj) eq 'CBIL::ISA::StudyAssayEntity::Characteristic' ? 'characteristicValue' : 'protocolParameterValue';

  $value = basename $value; # strip prefix if IRI
  my ($valuePrefix) = $value =~ /^(\w+)_|:/;

  my $om = $self->getOntologyMapping();
  my $os = $self->getOntologySources();

  if(defined $valuePrefix and $os->{lc($valuePrefix)}) {
    $obj->setTermAccessionNumber($value);
    $obj->setTermSourceRef($valuePrefix);
  }
  elsif(my $hash = $om->{lc($value)}->{$omType}) {
    my $sourceId = $hash->{source_id};
    my ($termSource) = $sourceId =~ /^(\w+)_|:/;

    $obj->setTermAccessionNumber($sourceId);
    $obj->setTermSourceRef($termSource);
  }
  else {
    die "Could not determine Accession Number for: [$value]";
  }
}




sub splitLatitudeLongitudeUnitFromValue {
  my ($self, $obj) = @_;

  my $om = $self->getOntologyMapping();
  my $valueOrig = $obj->getValue();

  my ($value, $unitString, $nsew) = $valueOrig =~ /(\S+)(\s([NnSsEeWw])?\s?degrees$)/;

  if($value and not $unitString) {
    die "Tried, and then could not separate into value and unit string: $valueOrig";
  }

  $unitString = "degrees";
  if($nsew) {
    $value = $value * -1;
  }

  $obj->setValue($value);

  my $class = "CBIL::ISA::StudyAssayEntity::Unit";

  my $unitSourceId = $om->{lc($unitString)}->{unit}->{source_id};
  if (defined $value) {
    unless($unitSourceId) {
      die "Could not find ontologyTerm for Unit:  $unitString";
    }

    my $unit = &makeOntologyTerm($unitSourceId, $unitString, $class);

    $obj->setUnit($unit);
  }
  else {
    $obj->setUnit(undef);
  }
}


sub splitUnitFromValue {
  my ($self, $obj) = @_;

  my $om = $self->getOntologyMapping();
  my $valueOrig = $obj->getValue();

  my ($value, $unitString) = split(/\s+/, $valueOrig);
  if($value and not $unitString) {
    die "Tried, and then could not separate into value and unit string: $valueOrig";
  }
  $obj->setValue($value);
  
  my $class = "CBIL::ISA::StudyAssayEntity::Unit";

  my $unitSourceId = $om->{lc($unitString)}->{unit}->{source_id};
  if (defined $value) {
    unless($unitSourceId) {
      die "Could not find ontologyTerm for Unit:  $unitString";
    }

    my $unit = &makeOntologyTerm($unitSourceId, $unitString, $class);

    $obj->setUnit($unit);
  }
  else {
    $obj->setUnit(undef);
  }
}


sub setUnitToYear {
  my ($self, $obj) = @_;

  my $YEAR_SOURCE_ID = "UO_0000036";

  my $unit = $obj->getUnit();
  my $unitSourceId = $unit->getTermAccessionNumber();
  return if $unitSourceId eq $YEAR_SOURCE_ID;

  my $conversionFactor;
  if ($unitSourceId eq "UO_0000035") {     # month
    $conversionFactor = 12;
  } elsif ($unitSourceId eq "UO_0000034") { # week
    $conversionFactor = 52;
  } elsif ($unitSourceId eq "UO_0000033") {  # day
    $conversionFactor = 365.25;
  } else {
    die "unknown unitSourceId \"$unitSourceId\"";
  }

  my $value = $obj->getValue();
  $obj->setValue($value / $conversionFactor);
  $unit->setTermAccessionNumber("$YEAR_SOURCE_ID");
  $unit->setTerm("year");
}


sub formatDate {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();
  return unless $value;

  Date_Init("DateFormat=US"); 

  my $formattedDate = UnixDate(ParseDate($value), "%Y-%m-%d");

  $obj->setValue($formattedDate);

  unless($formattedDate) {
    die "Date Format not supported for $value\n";
  }

  return $formattedDate;
}

sub killNA {
  my ($self, $obj) = @_;
  my $value = $obj->getValue();
  return unless $value;
  if($value =~ /^na$/i){ $obj->setValue(undef); return }
}
  


sub formatDateWithObfuscation {
  my ($self, $obj, $parentObj, $parentInputObjs) = @_;

  $self->internalDateWithObfuscation($obj, $parentObj, $parentInputObjs, "DateFormat=US");
}

sub formatEuroDateWithObfuscation {
  my ($self, $obj, $parentObj, $parentInputObjs) = @_;

  $self->internalDateWithObfuscation($obj, $parentObj, $parentInputObjs, "DateFormat=non-US");
}

sub formatDateWithObfuscationMin1900 {
  my ($self, $obj, $parentObj, $parentInputObjs) = @_;
  $self->{_functionParams}->{internalDateWithObfuscation}->{minDate}='1900-01-01';
  $self->internalDateWithObfuscation($obj, $parentObj, $parentInputObjs, "DateFormat=US");
}

sub resolveDateFormats {
  my ($self, $obj, $parentObj, $parentInputObjs) = @_;
  my $value = $obj->getValue();
  return unless $value;
  $value =~ s/^USER_ERROR_//;
  my $finalDate;
# USER_ERROR_22sep13:00:00:00|22/sep/13|9/22/2013|2013-09-22|22sep2013
  my %monthnum;
  @monthnum{qw/jan feb mar apr may jun jul aug sep oct nov dec/} = 1 .. 12;
  foreach my $dval ( split(/\|/, $value)){
    my ($day,$mon,$yr);
    switch($dval){
      case /^na$/ { $dval = undef }
      case /^\d{1,2}\W?[a-z]{3}\W?\d{2,4}(\W\d\d:\d\d:\d\d)?$/ {
        ($day,$mon,$yr) = ($dval =~ m/^(\d{1,2})\W?([a-z]{3})\W?(\d{2,4})(\W\d\d:\d\d:\d\d)?$/);
        if($yr < 1000){
          if($yr > 20){ $yr += 1900 }
          else { $yr += 2000 }
        }
        $mon=$monthnum{$mon};
      }
      case /^\d{1,2}\W?\d{1,2}\W?\d{2,4}$/ {
        ($mon,$day,$yr) = ($dval =~ m/^(\d{1,2})\W?(\d{1,2})\W?(\d{2,4})$/);
        if($yr < 1000){
          if($yr > 20){ $yr += 1900 }
          else { $yr += 2000 }
        }
      }
      case /^\d{4}\W?\d{2}\W?\d{2}$/ {
        ($yr,$mon,$day) = ($dval =~ m/^(\d{4})\W?(\d{2})\W?(\d{2})$/);
      }
      else { die "date format not supported in $dval" }
    }
    next unless($dval);
    #printf STDERR "$dval = day $day, mon $mon, yr $yr\n";
    my $date = sprintf("%02d-%02d-%04d", $mon, $day, $yr);
    $finalDate ||= $date;
    if($finalDate ne $date){
      warn "Cannot resolve date $date != $finalDate in $value\n" . Dumper $obj;
      return;
    }
  }
  $obj->setValue($finalDate);
  return $finalDate;
}

sub fixDateMissingDayMonth {
  my ($self, $obj, $parentObj, $parentInputObjs) = @_;
  my $value = $obj->getValue();
  return unless $value;
  $value =~ s/^na$//;
  $value =~ s/^0{1,2}(\W)0{1,3}(\W\d{2,4})$/02${1}07$2/; 
  $value =~ s/^0{1,2}(\W(\d{1,2}|[a-z]{3})\W\d{2,4})$/15$1/; 
  $obj->setValue($value);
  return $value;
}

sub formatTime {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();
  return unless($value);
  if($value =~ /^0:(\d\d\w\w)$/){ 
    $value =~ s/^0:(\d\d\w\w)$/12:$1/;
    Date_Init("DateFormat=US"); 
    my $formattedTime = UnixDate(ParseDate($value), "%H%M");
    $obj->setValue($formattedTime);
    unless($formattedTime) {
      die "(formatTime) Format not supported for $value\n" . Dumper $obj;
    }
    return $formattedTime;
  }
  elsif($value =~ /^\d{4}$/){
   #my $newvalue =~ s/^(\d\d)(\d\d)/\1:\2$/;
    my $hour = $value / 100;
    my $min = $value % 100;
    my $formattedTime = sprintf("%02d:%02d", $hour, $min);
    $obj->setValue($formattedTime);
    unless($formattedTime) {
      die "(formatTime) Format not supported for $value\n" . Dumper $obj;
    }
    return $formattedTime;
  }
  else {
    Date_Init("DateFormat=US"); 
    my $formattedTime = UnixDate(ParseDate($value), "%H:%M");
    $obj->setValue($formattedTime);
    unless($formattedTime) {
      die "(formatTime) Format not supported for $value\n" . Dumper $obj;
    }
    return $formattedTime;
  }
}

sub formatTimeHHMMtoDecimal {
  my ($self, $obj) = @_;
  my $value = $obj->getValue();
  return unless defined $value;
  if(looks_like_number($value) && (int($value) < 1200)){
    my $time = sprintf('%.03f',$value / 60);
    $obj->setValue($time);
    return $time;
  }
  unless($value =~ /^(\d{1,2})[\W:]?(\d\d)(:\d\d)?[\W_]?(am|pm)?$/i){
    die "Time format does not match: [$value] in " . Dumper $obj;
  }
  my($hr,$min,$sec,$half) = ($value =~ m/^(\d{1,2})[\W:]?(\d\d)(:\d\d)?[\W_]?(am|pm)?$/i);
  $min = $min / 60;
  if(defined($half) && ($half eq 'pm') && ($hr < 12)){
    $hr = ($hr + 12) % 24;
  }
  my $time = sprintf('%.03f',$hr + $min);
  $obj->setValue($time);
  return $time;
}

sub formatStataInteger2Date {
  ## Stata saves dates as days since January 1, 1960
  my ($self, $obj) = @_;
  my $value = $obj->getValue();
  return unless($value);
  return unless(looks_like_number($value));
  Date_Init("DateFormat=non-US"); 
  my $date = UnixDate(DateCalc("1960-01-01", "0:0:0:$value:0:0:0"), "%Y-%m-%d");
  $obj->setValue($date);
  return $date;
}

sub formatUnixInteger2Date {
  ## Stata saves dates as days since January 1, 1960
  my ($self, $obj) = @_;
  my $value = $obj->getValue();
  return unless($value);
  return unless(looks_like_number($value));
  Date_Init("DateFormat=non-US"); 
  my $scalarTime = localtime($value);
  my $date = UnixDate($scalarTime, "%Y-%m-%d");
  $obj->setValue($date);
  return $date;
}

sub makeOntologyTerm {
  my ($sourceId, $termName, $class) = @_;

  $class //= "CBIL::ISA::OntologyTerm";
  my ($termSource) = $sourceId ? $sourceId =~ /^(\w+)_|:/: ();
  unless (defined $termSource){
     $termSource = "";
     carp "makeOntologyTerm sourceId=$sourceId termName=$termName class=$class can not determine \$termSource as sourceId doesn't match " . '/^(\w+)_|:/';
  }

  my $hash = {term_source_ref => $termSource,
              term_accession_number => $sourceId,
              term => $termName
  };
  
  
  return &makeObjectFromHash($class, $hash);
  
}

sub formatUppercase {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return $obj->setValue(uc($val)) if(defined($val));
}

sub trimWhitespace {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined $val && length $val;
  $val =~ s/^\s+|\s+$//g;
  return $obj->setValue($val) if(defined($val));
}
sub formatSentenceCase {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  if(defined($val)){
    return $obj->setValue(ucfirst(lc($val)));
  }
  return;
}

sub formatTitleCase {
  my ($self, $obj) = @_;
  my $_v = $obj->getValue();
  return unless defined $_v;
  my $val = join(" ", map { ucfirst } split(/\s/, lc($obj->getValue())));
  return $obj->setValue($val);
}

sub formatNumeric {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
    return unless defined($val);
  if($val =~ /^na$/i){
    return $obj->setValue(undef);
  }
}
sub formatInteger {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  if(looks_like_number($val)){
    return $obj->setValue(sprintf("%d",$val + 0.5));
  }
}

sub convertDaysToMonths {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  if(looks_like_number($val)){
    # days per month = 365.25 / 12 = 30.43
    my $months = int(($val / 30.43) + 0.5);
    return $obj->setValue(sprintf("%d",$months));
  }
}

sub formatNumericFiltered {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  unless(looks_like_number($val)){
    return $obj->setValue(undef);
  }
}

sub formatDateAsInteger {
# use for merging unequal dates from different variables; not for production
# use after formatting date as YYYY-MM-DD
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val) && length($val);
  $val =~ s/-//g;
  return $obj->setValue($val);
}

sub formatClinicalFtoC {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return unless $val > 65;
  return $obj->setValue((($val - 32) * 5) / 9);
}

sub formatFtoC {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return $obj->setValue((($val - 32) * 5) / 9);
}

sub formatFloat1 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return $obj->setValue(sprintf('%.1f', $val));
}
sub formatFloat2 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return $obj->setValue(sprintf('%.2f', $val));
}
sub formatFloat3 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return $obj->setValue(sprintf('%.3f', $val));
}
sub formatFloat4 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return $obj->setValue(sprintf('%.4f', $val));
}
sub scaleDivideBy1000 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return $obj->setValue($val / 1000);
}
sub formatQuotation {
  my ($self, $obj) = @_;
  return $obj->setValue(sprintf("\"%s\"",$obj->getValue()));
}

sub _SCRAP_ERRORS {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless $val;
  if($val =~ /^USER_ERROR/){
    my @values = split(/\|/, $val);
    return $obj->setValue($values[1]);
  }
}

sub parseDmsCoordinate {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  my ($decVal,$min,$sec) = ( $val =~ m/([+-]?\d+\.?\d*)/g );
  my ($card) = ($val =~ /([NSEWnsew])/);
  if($min){ $decVal += $min/60; }
  if($sec){ $decVal += $sec/3600; }
  if(defined($card) && $card =~ /[SWsw]/) { $decVal = -$decVal; }
  return $obj->setValue($decVal);
}

sub digestSHAHex16 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  return $obj->setValue(substr(Digest::SHA::sha1_hex($val),0,16));
}

sub encryptSuffix1 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  my ($prefix,$suffix1,@suffixN) = split(/_/, $val);
  $suffix1 = substr(Digest::SHA::sha1_hex($suffix1),0,16);
  my $newId = join("_", $prefix, $suffix1, @suffixN); 
  return $obj->setValue($newId);
}

sub encryptSuffix2 {
  my ($self, $obj) = @_;
  my $val = $obj->getValue();
  return unless defined($val);
  my @id = split(/_/, $val);
  $id[2] = substr(Digest::SHA::sha1_hex($id[2]),0,16);
  my $newId = join("_", @id); 
  return $obj->setValue($newId);
}

sub idObfuscateDate1 {
  my ($self, $node, $type) = @_;
  return $self->idObfuscateDateN($node,$type,1);
}

sub idObfuscateDate2 {
  my ($self, $node, $type) = @_;
  return $self->idObfuscateDateN($node,$type,2);
}
sub idObfuscateDate3 {
  my ($self, $node, $type) = @_;
  return $self->idObfuscateDateN($node,$type,3);
}

sub idObfuscateDateN {
  my ($self, $node, $type, $offset) = @_;
  my $materialTypeSourceId = $self->getOntologyMapping()->{$type}->{'materialType'}->{'source_id'};
  my $nodeId = $node->getValue();
  die unless defined($nodeId);
  my $local = {};
  my @id = split(/_/, $nodeId);
  unless(length($id[$offset])){return}
  $local->{dateOrig} = $id[$offset];
  ## Support only date format YYYY-
  return unless($local->{dateOrig} =~ /^\d{4}[\W]\d{2}[\W]\d{2}$/);
  if(lc($local->{dateOrig}) eq "na"){
    $nodeId =~ s/_na/_nax/i; # make it different
    return $node->setValue($nodeId);
  }
  ## OK I spent about 4 hours debugging this shit
  ## apparently a leading 0 in "09-07-2009" will cause ParseDate to read it as 2009-07-20
  my $dateOrig = $local->{dateOrig}; # save this for regex replace
  $local->{dateOrig} =~ s/^0//;
  $local->{formattedDate} = "NOT SET";
  my $dateObfuscation = $self->getDateObfuscation();
  my $delta = $dateObfuscation->{$materialTypeSourceId}->{$nodeId};
  if($delta) {
    # Date_Init("DateFormat=US");
    $local->{unixDate} = ParseDate($local->{dateOrig});
    unless($local->{unixDate}){
      Date_Init("DateFormat=US");
      $local->{unixDate} = ParseDate($local->{dateOrig});
    }
    unless($local->{unixDate}){
      warn "Cannot parse date: " . $local->{dateOrig};
      return;
    }
    $local->{preDate} = UnixDate($local->{unixDate}, "%Y-%m-%d");
    $local->{date} = DateCalc($local->{unixDate}, $delta);
    $local->{formattedDate} = UnixDate($local->{date}, "%Y-%m-%d");
  }
  else {
    die "MISSINGDELTA:$type:$materialTypeSourceId:$nodeId";
  }
  my $newId = $nodeId; 
  die "No date in $nodeId\n" . Dumper $local unless $local->{dateOrig} && $local->{formattedDate}; 
  $newId =~ s/$dateOrig/$local->{formattedDate}/;
  return $node->setValue($newId);
}

sub getFunctionParams {
  my($self) = @_;
  return {} unless $self->{_functionParams};
  my (undef,undef,undef,$subName) = caller(1);
  $subName =~ s/^.*:://;
  return $self->{_functionParams}->{$subName};
}

sub makeObjectFromHash {
  my ($class, $hash) = @_;

  eval "require $class";
  my $obj = eval {
    $class->new($hash);
  };
  if ($@) {
    die "Unable to create class $class: $@";
  }

  return $obj;
}

1;

