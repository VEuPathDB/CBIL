
package CBIL::Bio::GeneOntologyParser::Term;

use strict;

# ----------------------------------------------------------------------

sub new {
   my $class = shift;
   my $args = shift;

   my $self = bless {}, $class;

   $self->init($args);

   return $self
}

# ----------------------------------------------------------------------

sub init {
   my $self = shift;
   my $args = shift;

   $self->parse($args) if not ref $args;

   return $self
}

# ----------------------------------------------------------------------
# Assumes that a term will put itself on the path, then call
# getParentId.  In this scenario, adjPath puts the term in the path at
# the appropriate depth and trims the rest of the path.  getParentId
# then returns the next-to-last item in the path.

$CBIL::Bio::GeneOntologyParser::Term::Path;

sub getPath          { $CBIL::Bio::GeneOntologyParser::Term::Path }
sub setPath          { $CBIL::Bio::GeneOntologyParser::Term::Path = $_[0] || [] }

sub adjPath          {
    my $depth = shift; # int : depth
    my $id = shift; # string : term id (GO:\d{6})
    
    $CBIL::Bio::GeneOntologyParser::Term::Path->[$depth] = $id;
    splice(@$CBIL::Bio::GeneOntologyParser::Term::Path,$depth+1);
}

sub getParentId {
    my $p = $CBIL::Bio::GeneOntologyParser::Term::Path;
    if (@$p > 1) {
	return $p->[$#$p - 1];
   }
    else {
	return undef;
    }
}
# ----------------------------------------------------------------------



sub parse {
    my $self = shift;
    my $entry = shift; # string : line from file
    
    # separate leading space from rest of text.
    my ($leading_space, $text) = $entry =~ /^(\s*)(.*)$/;
    
    # figure depth
    my $depth = length($leading_space);
    
    my $delim_rx = '\s*(\$|%|<)\s*';
    my @parts           = split($delim_rx, $text);

    shift @parts;
    my $term_relation   = shift @parts;
    my $term            = shift @parts;
    my @other_relations = @parts;
    
    # parse new term
    my @term_parts   = split(/\s*;\s*/, $term);
    my $term_name    = shift @term_parts;
    my ($term_gonos) = grep {/GO:\d+/}    @term_parts;
    my @term_gonos   = split(/\s*,\s*/, $term_gonos);
    my $term_gono    = shift @term_gonos;
    my @term_ecnos   = grep {/^EC:.+$/}      @term_parts;
    my @term_tcnos   = grep {/^TC:.+$/}      @term_parts;
    my @term_synos   = grep {/^synonym:.*$/} @term_parts;
    
    $term_name =~ s/\\//g;
    map { s/\\//g } @term_synos;
    map { s/synonym:// } @term_synos;
    
    # adjust the path so we can get a good parent id.
    adjPath($depth,$term_gono);
    
    $self->setRoot(0);

    $self->setRelationToParent($term_relation);
    if ($term_relation eq '<') {
	$self->addContainer($self->getParentId());
    }
    elsif ($term_relation eq '%') {
	$self->addClass($self->getParentId());
    }
    elsif ($term_relation eq "\$") {
	print STDERR "setting root to true for $term_gono\n";
	$self->setRoot(1);
    }
    
    $self->setId($term_gono);
    $self->setName($term_name);
    $self->setAlternateIds(\@term_gonos) if @term_gonos;
    $self->setDbRefs([ @term_ecnos, @term_tcnos ] ) if @term_ecnos || @term_tcnos;
    $self->setSynonyms(\@term_synos) if @term_synos;

    # add relationships
    for (my $i = 0; $i < @other_relations; $i += 2) {
	my $code = $other_relations[$i];
	my $text = $other_relations[$i+1];
	my @or_parts = split(/\s*;\s*/, $text);
	if (scalar @or_parts != 2) {
	
	    print join("\t", 'unexpected other relations', $text), "\n";
	    print "$entry\n";
	}
	elsif ($code eq '<') {
	    $self->addContainer($or_parts[1]);
	}
	elsif ($code eq '%') {
	    $self->addClass($or_parts[1]);
	}
	else {
         print join("\t", 'unknown relation code', $code), "\n";
         print "$entry\n";
     }
    }
    
    #Disp::Display(getPath);
    
    #Disp::Display($self);
    
    return $self
    }

# ----------------------------------------------------------------------

sub printMyInfo{

    my ($self) = @_;
    my $synonyms = $self->getSynonyms();
    my $classes = $self->getClasses();
    my $containers = $self->getContainers();
    my $dbRefs = $self->getDbRefs();
    my $alternateIds = $self->getAlternateIds();

    open (LOG, ">>./goLog");
    print LOG "info for id " . $self->getId() . "\n";
    print LOG "name is " . $self->getName() . ", am I root? " . $self->getRoot() . " relation is " . $self->getRelationToParent() . "\n";
    print LOG "branch root is " . $self->getBranchRoot() . "\n";
   
    print LOG "Alternate id's: ";
    if ($alternateIds){
	for (my $i= 0; $i < scalar(@$alternateIds); $i++){
	    print LOG $alternateIds->[$i] . ", ";}    
    } print LOG "\n";
    
    print LOG "I am a subclass of parents: ";
    if ($classes){
	for (my $i= 0; $i<scalar(@$classes); $i++){
	    print LOG $classes->[$i] . ", ";}   
    } print LOG "\n";
    
    print LOG "I am part of containers: ";
    if ($containers){
	for (my $i= 0; $i<scalar(@$containers); $i++){
	    print LOG $containers->[$i] . ", ";} 
    } print LOG "\n";

    print LOG "my synonyms: ";
    if ($synonyms){
	for (my $i= 0; $i<scalar(@$synonyms); $i++){
	    print LOG $synonyms->[$i] . "** ";} 
    } print LOG "\n";
    print LOG "my dbRefs: ";
    if ($dbRefs){
	for (my $i= 0; $i<scalar(@$dbRefs); $i++){
	    print LOG $dbRefs->[$i] . ", ";} 
    } print LOG "\n";
	
}

sub setId{
    my ($self, $id) = @_;
    $self->{Id} = $id;
}

sub setName{
    my ($self, $name) = @_;
    $self->{Name} = $name;
}

sub setRoot{
    my ($self, $root) = @_;
    $self->{Root} = $root;
}

sub setBranchRoot{
    my ($self, $branchRoot) = @_;
    $self->{BranchRoot} = $branchRoot;
}

sub setAlternateIds{
    my ($self, $alternateIds) = @_;
    $self->{AlternateIds} = $alternateIds;
}

sub setSynonyms{
    my ($self, $synonyms) = @_;
    $self->{Synonyms} = $synonyms;
}

sub setDbRefs{
    my ($self, $dbRefs) = @_;
    $self->{DbRefs} = $dbRefs;
}

sub setContainers{
    my ($self, $containers) = @_;
    $self->{Containers} = $containers;
}

sub setClasses{
    my ($self, $classes) = @_;
    $self->{Classes} = $classes;
}

sub setRelationToParent{
    my ($self, $relation) = @_;
    $self->{RelationToParent} = $relation;
}

sub getId{
    my ($self) = @_;
    return $self->{Id};
}

sub getName{
    my ($self) = @_;
    return $self->{Name};
}

sub getRoot{
    my ($self) = @_;
    return $self->{Root};
}

sub getBranchRoot{
    my ($self) = @_;
    return $self->{BranchRoot};
}

sub getAlternateIds{
    my ($self) = @_;
    return $self->{AlternateIds};
}

sub getSynonyms{
    my ($self) = @_;
    return $self->{Synonyms};
}

sub getDbRefs{
    my ($self) = @_;
    return $self->{DbRefs};
}

sub getContainers{
    my ($self) = @_;
    return $self->{Containers};
}

sub getClasses{
    my ($self) = @_;
    return $self->{Classes};
}

sub getRelationToParent{
    my ($self) = @_;
    return $self->{RelationToParent};
}

sub addSynonym{
    my ($self, $synonym) = @_;
    push(@{$self->{Synonyms}}, $synonym);
}

sub addDbRef{
    my ($self, $dbRef) = @_;
    push(@{$self->{DbRefs}}, $dbRef);
}

sub addClass{
    my ($self, $class) = @_;
    push(@{$self->{Classes}}, $class);
}

sub addContainer{
    my ($self, $container) = @_;
    push(@{$self->{Containers}}, $container);
}

1
