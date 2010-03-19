#!@perl@

# --------------------------------------------------------
# loadAll.pl
#
# Invoke the Oracle SQL*Loader on a set of control and data files.
# Used to perform initial import of BCP files into
# an Oracle database.  The user must specify an Oracle
# login and password and the directories that contains the
# SQL*Loader .ctl files and corresponding data files.
#
# Jonathan Crabtree
# $Revision$ $Date$ $Author$
# --------------------------------------------------------

use strict;

# -----------------------------------
# Configuration
# -----------------------------------

my $SQL_LOADER = "sqlldr";

# Direct mode is faster.  Faster is gooder.
# Also allow an unlimited number of errors (bad rows.)
#
my $LOADER_ARGS = "DIRECT=FALSE ERRORS=9999999 ";

# -----------------------------------
# Input
# -----------------------------------

my $USER = shift || "First argument must be user name";
my $PASSWORD = shift || "Second argument must be password";

# Directory containing the SQL*Loader control files
# to use.  Control files must end in '.ctl'
#
my $controlFileDir = shift || die "Third argument must specify directory containing .ctl files";

my $dataFileDir = shift || die "Fourth argument must specify directory containing the data files.\nFile names must begin with the appropriate control file names followed by a '.' \n\t ex: est.ctl -(applies to)-> est.yada.2001011999.bcp.stuff\n";

# -----------------------------------
# Main program
# -----------------------------------

$| = 1;

my $date = `date`; chomp($date);
print "loadAll.pl: started at $date\n";

opendir(CDIR, $controlFileDir);
my @controlFiles = grep(/\.ctl$/, readdir(CDIR));

closedir(CDIR);

opendir(DDIR, $dataFileDir);
my @dataFiles = readdir(DDIR);

my $count = 0;

foreach my $cfile (@controlFiles) {
	## Get the data files that this control file will insert
	$cfile =~ /(^\w+)\./;
	my $table = $1;
	foreach my $dfile (@dataFiles) {
		if ($dfile =~ /^$table\./) {
			my $loadCmd = "$SQL_LOADER USERID=$USER/$PASSWORD CONTROL=$controlFileDir/$cfile DATA=$dataFileDir/$dfile BAD=$dataFileDir/$dfile.bad LOG=$dataFileDir/$dfile.log $LOADER_ARGS > /dev/null";
			
			print "Loading $cfile::$dfile...";
			print "$loadCmd\n";;
			my $start = time;
			system($loadCmd);
			my $end = time;
			
			my $secs = $end - $start;
			my $mins = int(($secs / 60.0) + 0.5);
		
			print "done in ", ($end - $start), " second(s) ($mins minutes)\n";
			
			++$count;
		}
	}
}

my $date = `date`; chomp($date);
print "loadAll.pl: finished at $date\n";
