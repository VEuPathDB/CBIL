#!@perl@

# ----------------------------------------------------------
# extractHits.pl
#
# Extract a summary of high-scoring hits from a BLAST file.
# Demonstrates the use of the BLAST2 modules.
#
# Created: Wed Mar 22 13:15:56 EST 2000
#
# Jonathan Crabtree
# ----------------------------------------------------------

use strict vars;
use CBIL::Bio::BLAST2::BLAST2;

# ----------------------------------------------------------
# User input
# ----------------------------------------------------------

my $maxPVal = shift || 1;
my $blastFile = shift;
my $subjectRegex = shift || '^(\S+)\s*';

# ----------------------------------------------------------
# Main program
# ----------------------------------------------------------

$| = 1;

print STDERR "extractHits: processing $blastFile\n";

printf "%-30s", "subject";
printf "%-10s", "pval";
printf "%-15s", "strand";
printf "%-6s", "ids";
printf "%-6s", "len";
printf "%-5s", "pct";
printf "%-6s", "qlen";
printf "%-6s", "slen";
printf "%-6s", "qs";
printf "%-6s", "qe";
printf "%-6s", "ss";
printf "%-6s", "se";

print "\n---------------------------------------------------------------";
print "----------------------------------------\n";

my $blast = &CBIL::Bio::BLAST2::parseBLAST2output( $blastFile );
my $nSubjects = $blast->getNumSbjcts();
my $output = 0;

foreach my $s (0 .. ($nSubjects-1)) {
    my $sj = $blast->getSbjct($s);
    my $nHSPs = $sj->getNumHSPs();
    my ($sname) = ($sj->{'description'} =~ /$subjectRegex/);
    
    foreach my $h (0 .. $nHSPs-1) {
	my $hsp = $sj->getHSP($h);

	if ($$hsp{'pval'} <= $maxPVal) {
	    
	    $$hsp{'strand'} =~ s/\s+//g;

	    # Print a summary line to STDOUT
	    #
	    printf "%-30s", "$sname";
	    
	    printf "%-10s", $$hsp{'pval'};
	    printf "%-15s", $$hsp{'strand'};
	    printf "%-6s", $$hsp{'identities'};
	    printf "%-6s", $$hsp{'length'};
	    printf "%-5s", int(($$hsp{'identities'} / $$hsp{'length'}) * 100) . "%";
	    printf "%-6s", $blast->{'query_size'};
	    printf "%-6s", $sj->{'length'};
	    printf "%-6s", $$hsp{'q_start'};
	    printf "%-6s", $$hsp{'q_end'};
	    printf "%-6s", $$hsp{'s_start'};
	    printf "%-6s", $$hsp{'s_end'};
	    print "\n";
	    
	    $output = 1;
	}
    }
}
print "\n" if ($output);

