package CBIL::Bio::GeneAssocParser::Assoc;

use FileHandle;
#use strict;

sub new{
    my ($class, $entry) = @_;

    my $self = {};

    bless ($self, $class);

    $self->parse($entry);
    return $self;
}



sub parse{
    my ($self, $entry) = @_;
    my @columns = split(/\t/, $entry);
   
    
    
    my $rowLength = @columns;
    if ($rowLength > 13){ 
	$self->setDB($columns[0]);
	$self->setDBObjectId($columns[1]);
	$self->setDBObjectSymbol($columns[2]);
	$self->setIsNot($columns[3]);
	$self->setGOId($columns[4]);
	$self->setDBReference($columns[5]);
	$self->setEvidence($columns[6]);
	$self->setWith($columns[7]);
	$self->setAspect($columns[8]);
	$self->setDBObjectName($columns[9]);
	$self->setDBObjectSynonym($columns[10]);
	$self->setDBObjectType($columns[11]);
	$self->setTaxon($columns[12]);
	$self->setDate($columns[13]);
	
    }
    else{
	print STDERR "Error in Assoc::Parse(): file has only $rowLength fields; the file is not of the expected format";
	return undef;
	
    }
}

sub showMyInfo{
    my ($self) = @_;
    my $tempObjId = $self->getDBObjectId();
    my $tempObjSym = $self->getDBObjectSymbol();
    my $tempNot = $self->getIsNot();
    my $tempRef =  $self->getDBReference();
    my $tempAspect = $self->getAspect();
    my $tempName = $self->getDBObjectName();
    my $tempSyn = $self->getDBObjectSynonym();
    my $tempType = $self->getDBObjectType();
    my $tempTaxon = $self->getTaxon();
    my $tempEvidence = $self->getEvidence();
    my $tempWith = $self->getWith();
    my $tempDB = $self->getDB();
    my $tempGOId = $self->getGOId();
    my $tempDate = $self->getDate();

        
    open(RESULT, ">>./testResult") || die "file couldn't be opened ";
    #print STDERR "$tempDB\t$tempObjId\t$tempObjSym\t$tempNot\t$tempRef\t$tempEvidence\t$tempWith\t$tempAspect\t$tempName\t$tempSyn\t$tempType\t$tempTaxon\t $tempGOId\t$tempDate\n";
    
    
    print RESULT "$tempDB\t$tempObjId\t$tempObjSym\t$tempNot\t$tempGOId\t$tempRef\t$tempEvidence\t$tempWith\t$tempAspect\t$tempName\t$tempSyn\t$tempType\t$tempTaxon\t$tempDate\n";
    



}

sub setDB{
    my ($self, $value) = @_;
    $self->{DB} = $value;
}

sub setDBObjectId{
    my ($self, $value) = @_;
    $self->{DBObjectId} = $value;
}

sub setDBObjectSymbol{
    my ($self, $value) = @_;
    $self->{DBObjectSymbol} = $value;
}

sub setIsNot{
    my ($self, $value) = @_;
    $self->{IsNot} = $value;
}

sub setGOId{
    my ($self, $value) = @_;
    $self->{GOId} = $value;
}

sub setDBReference{
    my ($self, $value) = @_;
    $self->{DBReference} = $value;
}
sub setEvidence{
    my ($self, $value) = @_;
    $self->{Evidence} = $value;
}
sub setWith{
    my ($self, $value) = @_;
    $self->{With} = $value;
}

sub setAspect{
    my ($self, $value) = @_;
    $self->{Aspect} = $value;
}

sub setDBObjectName{
    my ($self, $value) = @_;
    $self->{DBObjectName} = $value;
}

sub setDBObjectSynonym{
    my ($self, $value) = @_;
    $self->{DBObjectSynonym} = $value;
}

sub setDBObjectType{
    my ($self, $value) = @_;
    $self->{DBObjectType} = $value;
}

sub setTaxon{
    my ($self, $value) = @_;
    $self->{Taxon} = $value;
}

sub setDate{
    my ($self, $value) = @_;
    $self->{Date} = $value;
}

sub getDB{
    my ($self) = @_;
    return $self->{DB};
}

sub getDBObjectId{
    my ($self) = @_;
    return $self->{DBObjectId};
}

sub getDBObjectSymbol{
    my ($self) = @_;
    return $self->{DBObjectSymbol};
}

sub getIsNot{
    my ($self) = @_;
    return $self->{IsNot};
}

sub getGOId{
    my ($self) = @_;
    return $self->{GOId};
}

sub getDBReference{
    my ($self) = @_;
    return $self->{DBReference};
}

sub getEvidence{
    my ($self) = @_;
    return $self->{Evidence};
}

sub getWith{
    my ($self) = @_;
    return $self->{With};
}



sub getAspect{
    my ($self) = @_;
    return $self->{Aspect};
}

sub getDBObjectName{
    my ($self) = @_;
    return $self->{DBObjectName};
}

sub getDBObjectSynonym{
    my ($self) = @_;
    return $self->{DBObjectSynonym};
}

sub getDBObjectType{
    my ($self) = @_;
    return $self->{DBObjectType};
}

sub getTaxon{
    my ($self) = @_;
    return $self->{Taxon};
}

sub getDate{
    my ($self) = @_;
    return $self->{Date};
}



1;
