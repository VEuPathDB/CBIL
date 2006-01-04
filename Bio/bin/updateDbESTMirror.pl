#! /usr/bin/perl
use lib "$ENV{GUS_HOME}/lib/perl";
use Getopt::Long;
use GUS::ObjRelP::DbiDatabase;
use GUS::Supported::GusConfig;

my ($verbose,$gusConfigFile,$dataFileDir);
&GetOptions("verbose!"=> \$verbose,
            "gusConfigFile=s" => \$gusConfigFile,
	    "dataFileDir=s" => \$dataFileDir );

$| = 1;

print STDERR "Establishing dbi login\n" if $verbose;

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
print  "updateDbESTMirror.pl: started at $date\n";

opendir(DDIR, $dataFileDir);
my @dataFiles = readdir(DDIR);

my $sth = $dbh->prepare("select count(*) from dbest.processedfile where name = ?");



closedir(DDIR);
print "Will load files:"; 
print (join "\n", @dataFiles);
print "\n";
# exit;

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
print "updateDbESTMirror.pl done\n";

################################################
# subroutines
################################################

sub delete {
  my $f = shift;
  my $t = shift;
  print "Deleting entries from file $dataFileDir/$f\n";
  open "F", "<$dataFileDir/$f" or die;
  while (<F>){
    chomp $_;
    my $s = "delete from $t where $ids{$t} = $_";
    $dbh->do($s) or die $dbh->errstr, $s, "\n";
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
      $dbh->do($del) or die $dbh->errstr . $del;
    }
    else {
      if($vals[1] == 0 ) {
	my $del = "delete from $t where $ids{$t} = $vals[0]";
	$dbh->do($del) or die $dbh->errstr . $del;
      }
    }
    my $sql = "insert into $t values (" . (join ",",@place_holders) . ")";

    $dbh->do($sql,undef,@vals) or die $dbh->errstr . 
      "$sql\nVALS=(" . (join(', ',(map {'\'' . $_ . '\''}  @vals))) . ")\nline= $_\n";
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



$dbh->disconnect();
1;
