#!/usr/bin/perl

package CBIL::Bio::GeneAssocParser::ParseDemo;

use lib "$ENV{GUS_HOME}/lib/perl";

use strict 'vars';

use CBIL::Bio::GeneAssocParser::Parser;


print STDERR "ParseDemo: Starting up \n";

my $parser = CBIL::Bio::GeneAssocParser::Parser->new("./");

$parser->loadAllFiles();
$parser->parseAllFiles();

#$parser->loadFile("gene_association.fb");
#$parser->parseFile("gene_association.fb");

1;
