#!/usr/bin/perl

package CBIL::Bio::GeneOntologyParser::ParseDemo;

use strict 'vars';
use lib "$ENV{GUS_HOME}/lib/perl";

use CBIL::Bio::GeneOntologyParser::Parser;

print STDERR "ParseDemo: Starting up \n";

my $parser = CBIL::Bio::GeneOntologyParser::Parser->new(".");

print STDERR "ParseDemo: loading file\n";

#$parser->loadFile("function.ontology");
$parser->loadAllFiles();
print STDERR "ParseDemo: done loading file\n";
#my $store = $parser->parseFile("function.ontology");
$parser->parseAllFiles();
my $files = $parser->getFileCaches();
foreach my $file (keys %$files){
    
    my $store = $files->{$file};
#$parser->getFileCache("function.ontology");

    my $entries = $store->getEntries();
    foreach my $entryId(keys %$entries){
	my $entry = $entries->{$entryId};
	$entry->printMyInfo();
    }
}
1;
