#! /usr/bin/perl
use DBI;
use strict;
# -----------------------------------
# Configuration
# -----------------------------------

my %ids = (est => 'id_est',
	   library => 'id_lib',
	   author => 'id_pub',
	   publication => 'id_pub',
	   maprec => 'id_map',
	   mapmethod => 'id_method',
	   sequence => 'id_est',
	   cmnt => 'id_est',
	   comment => 'id_est',
	   contact => 'id_contact');

# -----------------------------------
# Input
# -----------------------------------

my $USER = shift || die "First argument must be user name\n";
$USER =~ /^(\w+)\@\w+$/;
my $DBI_USER = $1;
my $PASSWORD = shift || die "Second argument must be password\n";



my $dataFileDir = shift || die "Third argument must specify directory containing the data files.\nFile names must begin with the appropriate table file names followed by a '.' \n\t ex: est.yada.2001011999.bcp.stuff -(applies to)-> est table \n";

my $DBI_DSN = shift || die "Fourth argument must specify the DBI_DSN string, e.g dbi:Oracle:cbilbld";

my $dblink = shift || die "Fifth argument must be the db link to dbest, e.g. pinneylink";

print "Read in params: USER=$USER PW=$PASSWORD DBI_USER=$DBI_USER DATA_DIR=$dataFileDir DBI_DSN=$DBI_DSN\n";

# DBI handle
my $dbh = DBI->connect($DBI_DSN,$DBI_USER,$PASSWORD) or die DBI::errstr();

$dbh->do("ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'"); 

$dbh->{AutoCommit} = 0;
# -----------------------------------
# Main program
# -----------------------------------

$| = 1;

my $date = `date`; chomp($date);
print  "updateAll.pl: started at $date\n";

opendir(DDIR, $dataFileDir);
my @dataFiles = readdir(DDIR);

my $sth = $dbh->prepare("select count(*) from dbest.processedfile where name = ?");



closedir(DDIR);
print "Will load files:"; 
print (join "\n", @dataFiles);
print "\n";
# exit;
my $count = 0;
my ($h,@est, @seq, @comm, @pub, @maprec);

# get the files and order them by table, date , operation and order 
foreach my $f(@dataFiles) {
        $sth->execute($f);
        my $num = $sth->fetchrow_array();
        $sth->finish();
        if ($num >= 1) {
	  print "$f loaded into dbEST during a previous run - skipping.\n";
	  next;
	}

	if ($f =~ /insert|delete/) {
		$f =~ /(\w+)\.(\w+)\.(\d+)(.*)/;
		my $t = $1; my $op = $2; my $date = $3; my $rest = $4;
		if ($t =~ /comment/) { $t =~ s/comment/cmnt/; }
		$t = $t ."@$dblink";
		if ($op =~ /insert/) { 
	    push @{$h->{$t}->{$date}->{insert}}, $f;
		}else {
	    push @{$h->{$t}->{$date}->{delete}}, $f;
		}
	}
}

# for each table, grab a date, then do the deletes, first and then the inserts
foreach my $t (keys %$h) {
	foreach my $date (sort keys %{$h->{$t}}) {
		foreach my $f (@{$h->{$t}->{$date}->{delete}}){
	    &delete($f,$t);
		}
		foreach my $f (@{$h->{$t}->{$date}->{insert}}){
	    &insert($f, $t);
		}
	}
}
print "updateAll.pl done\n";

################################################
# subroutines
################################################

sub delete {
	my $f = shift;
	my $t = shift;
	print "Deleting entries from file $dataFileDir/$f\n";
	open "F", "<$dataFileDir/$f" or die;
	my $count = 0;
	while (<F>){
	    chomp $_;
	    my $s = "delete from $t where $ids{$t} = $_";
	    $dbh->do($s) or die $dbh->errstr, $s, "\n";
	    $count++;
	    if ($count % 100 == 0) { 
		$dbh->commit();
	    }
	}
        my $insert = "insert into dbest.processedfile name Values ('$f')";
	$dbh->do("$insert");
	$dbh->commit();
	close(F);
}

sub insert {
	my $f = shift;
	my $t = shift;

	# It is OK to do a straight insert since the previous delete file
	# should have deleted any rows being updated...

	print "Inserting entries from $dataFileDir/$f...";
	my $start = time;
	open(F,"<$dataFileDir/$f");
	my $count = 0;
	while (<F>) {
		chomp($_);
		my $NULL = "\tNULL\t"; 
		my $NULL_end = "\tNULL";
		while ($_ =~ /\t\t/) {
		    $_=~ s/\t\t/$NULL/g;
		}
		$_=~ s/\t$/$NULL_end/;
		$_ = &fixdate($t,$_);

		my @place_holders = split( /\t/,$_);
		my @vals;
		for (my $i = 0; $i < (scalar @place_holders); $i++){
		    if (!($place_holders[$i] =~ /^NULL$/)) {
			push @vals, $place_holders[$i];
		    }
		}
		@place_holders = map {if ($_ =~ /^NULL$/) { $_} else {"\?"}} @place_holders;
		
		if (!($t =~ /cmnt|sequence/)) {
			my $del = "delete from $t where $ids{$t} = $vals[0]";
			$dbh->do($del) or die $dbh->errstr . $del;
		}else {
			if($vals[1] == 0 ) {
				my $del = "delete from $t where $ids{$t} = $vals[0]";
				$dbh->do($del) or die $dbh->errstr . $del;
			}
		}
		my $sql = "insert into $t values (" . (join ",",@place_holders) . ")";

		$dbh->do($sql,undef,@vals) or die $dbh->errstr . 
		  "$sql\nVALS=(" . (join(', ',(map {'\'' . $_ . '\''}  @vals))) . ")\nline= $_\n";
		
		$count++;
		if ($count % 100 == 0) { 
			$dbh->commit();
		}
		
	}
        my $insert = "insert into dbest.processedfile name Values ('$f')";
	$dbh->do("$insert");
	$dbh->commit();
	close(F);
	my $end = time;
	my $secs = $end - $start;
	my $mins = int(($secs / 60.0) + 0.5);
	print "done in ", ($end - $start), " second(s) ($mins minutes)\n";
}

sub fixdate{
	my ($t,$l) = @_;
	if ($t =~ /^est/) {
	    my @a = split /\t/, $_;
	    $a[4] = &fixdatefmt($a[4]);
	    $a[32] = &fixdatefmt($a[32]);
	    unless ($a[37] =~ /^$|NULL/) {$a[37] = &fixdatefmt($a[37]);}
	    unless ($a[38] =~ /^$|NULL/) {$a[38] = &fixdatefmt($a[38]);}
	      
	    $l = join "\t", @a;
	} elsif ($t =~ /^maprec/) { 
		my @a = split /\t/, $_;
		$a[5] = &fixdatefmt($a[5]);
		$l =  join "\t", @a;
	} 
	return $l;
}

sub fixdatefmt {
    my $d = shift;
    # May 26 1992  8:32AM -> yyyy-mm-dd
    my @A = split /\s+/, $d;
    my $m = &getNumMonth($A[0]);
    #my $m = uc $A[0]; 
    $A[2] =~ s/^1900$/2000/;
    #$A[2] =~ s/^\d\d//;
    if (length $A[1] == 1 ) {$A[1] = "0" . $A[1];}
    return "$A[2]-$m-$A[1] 00:00:00";
    #return "$A[1]-$m-$A[2]";
}

sub getNumMonth { 
	my $m = shift;
	$m = uc $m;
  my %month = ("JAN" => '01',
               "FEB" => '02',
               "MAR" => '03',
               "APR" => '04',
               "MAY" => '05',
               "JUN" => '06',
               "JUL" => '07',
               "AUG" => '08',
               "SEP" =>'09',
               "OCT" => '10',
               "NOV" => '11',
               "DEC" => '12'
							 );

	return  $month{$m};
}



$dbh->disconnect();
1;
