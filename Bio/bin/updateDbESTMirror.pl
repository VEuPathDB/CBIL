#! /usr/bin/perl
#
#	$Revision$
#
#	Added function to fetch latest insert/delete batches from NCBI ftp
#		--fetch=[x] where [x] is how many months ago, up to today, to fetch updates for
#	To be run under cron:
#		/eupath/data/dbest/updateDbESTMirror.pl --fetch=1 --gusConfigFile=/eupath/data/dbest/gus.config --dataFileDir=/eupath/data/dbest >> /eupath/data/dbest/log 2>&1
#
use strict;
use warnings;

use lib "$ENV{GUS_HOME}/lib/perl";
use Getopt::Long;
use GUS::ObjRelP::DbiDatabase;
use GUS::Supported::GusConfig;
use Net::FTP;
use Date::Calc qw/Today Add_Delta_YM/;
use Cwd qw/cwd abs_path/;

my ($verbose,$gusConfigFile,$dataFileDir,$fetch,$gunzip);
&GetOptions(
	"verbose!"=> \$verbose,
	"gusConfigFile=s" => \$gusConfigFile,
	"dataFileDir=s" => \$dataFileDir,
	"fetch=i" => \$fetch,
	"gunzip=s" => \$gunzip );

if($fetch){
	$gunzip ||= '/usr/bin/gunzip';
	$dataFileDir = fetchUpdates($fetch,$dataFileDir);
	printf STDERR ("Files downloaded to %s\n", $dataFileDir);
}

$| = 1;

printf STDERR ("Establishing dbi login\n") if $verbose;

my $gusconfig = GUS::Supported::GusConfig->new($gusConfigFile);

my $db = GUS::ObjRelP::DbiDatabase->new($gusconfig->getDbiDsn(),
					$gusconfig->getReadOnlyDatabaseLogin(),
					$gusconfig->getReadOnlyDatabasePassword(),
					$verbose,0,1,
					$gusconfig->getCoreSchemaName());

my $dbh = $db->getQueryHandle();


# -----------------------------------
# Configuration
# -----------------------------------

my %ids = ("dbest.est" => 'id_est',
	   "dbest.library" => 'id_lib',
	   "dbest.author" => 'id_pub',
	   "dbest.publication" => 'id_pub',
	   "dbest.maprec" => 'id_map',
	   "dbest.mapmethod" => 'id_method',
	   "dbest.sequence" => 'id_est',
	   "dbest.cmnt" => 'id_est',
	   "dbest.comment" => 'id_est',
	   "dbest.contact" => 'id_contact');

# -----------------------------------
# Input
# -----------------------------------

$dbh->do("ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'"); 


# -----------------------------------
# Main program
# -----------------------------------

$| = 1;

my $date = `date`; chomp($date);
printf STDERR ("updateDbESTMirror.pl: started at %s\n", $date);

opendir(DDIR, $dataFileDir);
my @dataFiles = readdir(DDIR);

my $sth = $dbh->prepare("select count(*) from dbest.processedfile where name = ?");



closedir(DDIR);
printf STDERR ("Loading data files: %s\n", join("\n", @dataFiles));

my ($h,@est, @seq, @comm, @pub, @maprec);

# get the files and order them by table, date , operation and order 
foreach my $f(@dataFiles) {
  $sth->execute($f);
  my $num = $sth->fetchrow_array();
  $sth->finish();
  if ($num >= 1) {
    printf STDERR ("%s loaded into dbEST during a previous run - skipping.\n", $f);
    next;
  }

  if ($f =~ /insert|delete/) {
    $f =~ /(\w+)\.(\w+)\.(\d+)(.*)/;
    my $t = $1; my $op = $2; my $date = $3; my $rest = $4;
    if ($t =~ /comment/) { $t =~ s/comment/cmnt/; }
    $t = "dbest." . $t;
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
printf STDERR ("updateDbESTMirror.pl done\n");

$dbh->disconnect();

################################################
# subroutines
################################################

sub delete {
  my $f = shift;
  my $t = shift;
  print STDERR "Deleting entries from file $dataFileDir/$f\n";
  open "F", "<$dataFileDir/$f" or die;
  while (<F>){
    chomp $_;
    my $s = "delete from $t where $ids{$t} = $_";
    $dbh->do($s) or die "Couldn't delete rows with $s\n    using file $f\n" . $dbh->errstr . "\n";
  }
  my $insert = "insert into dbest.processedfile name Values ('$f')";
  $dbh->do("$insert") or die "Couldn't insert with $insert" . $dbh->errstr . "\n";
  $dbh->commit();
  close(F);
}

sub insert {
  my $f = shift;
  my $t = shift;

  # It is OK to do a straight insert since the previous delete file
  # should have deleted any rows being updated...

  print STDERR "Inserting entries from $dataFileDir/$f...";
  my $start = time;
  open(F,"<$dataFileDir/$f");
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

    if (!($t =~ /dbest.cmnt|dbest.sequence/)) {
      my $del = "delete from $t where $ids{$t} = $vals[0]";
      $dbh->do($del) or die "Couldn't delete with $del" . $dbh->errstr . "\n";
    }
    else {
      if($vals[1] == 0 ) {
	my $del = "delete from $t where $ids{$t} = $vals[0]";
	$dbh->do($del) or die "Couldn't delete with $del" . $dbh->errstr . "\n";
      }
    }
    my $sql = "insert into $t values (" . (join ",",@place_holders) . ")";

    $dbh->do($sql,undef,@vals) or die $dbh->errstr ,$sql, . 
      "$sql\nVALS=(" . (join(', ',(map {'\'' . $_ . '\''}  @vals))) . ")\nline= $_\n";
  }
  my $insert = "insert into dbest.processedfile name Values ('$f')";
  $dbh->do("$insert") or die "Couldn't insert using $insert" . $dbh->errstr . "\n";
  $dbh->commit();
  close(F);
  my $end = time;
  my $secs = $end - $start;
  my $mins = int(($secs / 60.0) + 0.5);
  print STDERR "done in ", ($end - $start), " second(s) ($mins minutes)\n";
}

sub fixdate{
  my ($t,$l) = @_;
  if ($t =~ /^dbest.est/) {
    my @a = split /\t/, $_;
    $a[4] = &fixdatefmt($a[4]);
    $a[32] = &fixdatefmt($a[32]);
    unless ($a[37] =~ /^$|NULL/) {$a[37] = &fixdatefmt($a[37]);}
    unless ($a[38] =~ /^$|NULL/) {$a[38] = &fixdatefmt($a[38]);}

    $l = join "\t", @a;
  } elsif ($t =~ /^dbest.maprec/) { 
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

sub fetchUpdates {
	my ($monthsAgo,$downloadRoot) = @_;
	$monthsAgo ||= 1;
	my @monthsToFetch;
	my @today = Today();
	do{ 
		push(@monthsToFetch, sprintf("%04d%02d",Add_Delta_YM(@today, 0, -$monthsAgo)));
	}while(1 + $monthsAgo--);
	my $downloadDir = abs_path(sprintf("%s/download_%04d%02d%02d", $downloadRoot || ".", @today));
	unless(-d $downloadDir){
		mkdir($downloadDir) or die "Cannot create directory $downloadDir:$!\n";
	}
	chdir($downloadDir);
	my $host = 'ftp.ncbi.nih.gov';
	my $path = '/repository/dbEST/bcp';
	my $ftp = Net::FTP->new($host) or die "Cannot connect to $host:$!\n";
	$ftp->login('anonymous', '');
	$ftp->binary();
	$ftp->cwd($path) or die "At FTP host, cannot cd to $path:$!\n";
	my @list;
	foreach my $month (@monthsToFetch){
	 	push(@list, grep { /(insert|delete)\.$month\d\d\.bcp\.\d+\.gz/ } $ftp->ls());
	}
	$ftp->get($_) for @list;
	$ftp->quit();
	opendir(DH, $downloadDir) or die "$!\n";
	my @allfiles = grep { /\.gz$/ } readdir(DH);
	system("$gunzip -f $_") for @allfiles;
	return $downloadDir;
}



1;
