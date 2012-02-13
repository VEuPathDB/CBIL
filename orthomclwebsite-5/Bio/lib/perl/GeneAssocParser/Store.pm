package CBIL::Bio::GeneAssocParser::Store;

use strict;

sub new{
    my ($class) = @_;
    
    my $self = {};
    bless ($self, $class);
    
    return $self;
}



sub addRecord{

    #print
    my ($self, $record) = @_;
    push(@{$self->{Records}}, $record);
    
}

sub addParsedEntry{
    my ($self, $entry) = @_;
    
    my $entryKey = $entry->getDBObjectId . $entry->getDBObjectSymbol() . $entry->getGOId . $entry->getEvidence;
    #my $tempId = $entry->getDBObjectId;
    #my $tempGo = $entry->getGOId;
    #my $tempSymbol = $entry->get
    #my $tempEvidence = $entry->getEvidence;
 
    #unless ($entryKey) { print STDERR "Store.AddParsedEntry: could not make key for entry: $tempId $tempGo $tempEvidence";}
    #unless ($entry) {print STDERR "Store.addParsedEntry:  could not make ENTRY for this key: $tempId $tempGo $tempEvidence";}
    $self->{Entries}->{$entryKey} = $entry;
}

sub getParsedEntries{
    my ($self) = @_;
    return $self->{Entries};
}

sub getRecords{
     my ($self) = @_;
    return $self->{Records}
}

1;
