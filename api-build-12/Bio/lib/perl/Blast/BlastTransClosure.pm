#!/usr/local/bin/perl 

# take in files from dotsBlastMatrix

## note that this is specifically for dots updates as will go to dots
## and get the clusters to include in the closure....

# assumes a symmetrical matrix (AXA)
# if use for something like dots vs swissprot then need ot modify
# to keep the id that was used in the query as a key

# Brian Brunk 12/14/98
## modified 12/6/1999 to include the dots step...

package CBIL::Bio::Blast::BlastTransClosure;

use strict;

##constructor...
sub new {
  my($class,$organism,$length,$percent,$cF) = @_;
  my $self = {};
  bless $self,$class;

  ##if above not defined then give defaults 40 and 92 and no org
  defined $organism ? $self->{'org'} = $organism : $self->{'org'} = 0;
  defined $length ?  $self->{'lengthCutoff'} = $length : $self->{'lengthCutoff'} = 40;
  defined $percent ?  $self->{'percentCutoff'} = $percent : $self->{'percentCutoff'} = 92;
  defined $cF ? $self->{'chimFile'} = $cF : $self->{'chimFile'};

  $self->{'clusterID'} = 0; ##starting number for cluster_id

  print STDERR "DEBUGGING ON\n" if $self->{'debug'} == 1;
  print "Cutoff parameters:\n\tLength: $self->{'lengthCutoff'}\n\tPercent Identity: $self->{'percentCutoff'}\n\n" if $self->{'debug'} == 1;
  return $self;
}


##want to be ablee to substitue in a dots_id for all accessions that it contains 
##and then do the closure...


# %{$self->{'chimera'}};

##need to have two datastuctures
## 1.  %{$self->{'clusters'}}: key is cluster_id and values hash of included ids
## 2.  key is id and value is cluster to which assigned
## %{$self->{'clusters'}}; ##the clusters....
## %{$self->{'idAssign'}}; ##assignment of ids to clusters


##if have an array of chimeras can set them here rather than parsing the file
sub setChimeras{
  my ($self,@chims) = @_;
  foreach my $c (@chims){
    $self->{'chimera'}->{$c} = 1;
  }
}

sub parseMatrix{
  my($self,@files) = @_;

  ##parse chimera file if it is defined
  if(defined $self->{'chimFile'}){
    open(C,"$self->{'chimFile'}") || die "chimera file $self->{'chimFile'} not found\n";
    
##want to parse more fully to limit chimeras to >2 each side of brkpt...
    my $chim_id;
    while(<C>){
      if(/^\>(\S+)/){
        $chim_id = $1;
      }elsif(/Chimera\s\d+:\s1,.*numberLeft=(\d+),\snumRight=(\d+)/){
        $self->{'chimera'}->{$chim_id} = 1 if ($1 >= 2 && $2 >= 2);
      }
    }
    print STDERR "Chimeras: ",scalar(keys%{$self->{'chimera'}}),"\n";
    close C;
  }

  my $countErr = 0;
##  my $clusterID = 0;
  my %tmp;
  my $countLines = 0;
  foreach my $file (@files){
    open(F, "$file");
    while(<F>){
      if(/^\>(\S+):\s\(*(.*?)\)*$/){
        $countLines++;
        next if exists $self->{'chimera'}->{$1}; ##ignore this one
        print STDERR "Processing line $countLines\n" if $countLines % 1000 == 0;
#    $clusterID++;
        undef %tmp;
        $tmp{$1} = 1; ##asseumes that should always match self even if doesn't!
        foreach my $hit (split(', ',$2)){
          my($id,$pVal,$length,$percent) = split(':',$hit);
          $tmp{$id} = 1 if ($length >= $self->{'lengthCutoff'} && $percent >= $self->{'percentCutoff'});
        }
        $self->processNewSet(keys%tmp);
      }else{
        $countErr++;
#    print STDERR "Line in incorrect format: $_";
      }
    }
  }
  if($self->{'org'} != 0){
    $self->addClusterInfo();
  }
#print STDERR "$countErr lines are incorrect\n";
}

##now process the dots identifiers...now get the dots clusters and continue....
## unless $org == 0 (which means don't do the dots thing..

sub addClusterInfo{
  my ($self,%dm) = @_; ##pass in cluster info as hash of arrays##dots matrix....with prim_tran_id as keys..
#  if(!defined %dm){
#    print STDERR "Processing organism_id $self->{'org'} dots ids to add to components\n";
#    
#    my $dbh = &assemblyLogin('dots');
#
#    my $query = "select r.primary_transcript_id,'DT.'+convert(varchar,r.rna_id)
# from rna_sequence rs,rna r
# where rs.organism_id = $self->{'org'}
# and r.rna_id = rs.rna_id";
#    
#    &sqlexec($dbh,$query);
#    
#    while(my($pt_id,$r2_id) = $dbh->dbnextrow()){
#      push(@{$dm{$pt_id}},$r2_id);
#    }
#
#    ##only do ones that have > 1 sequence
##    foreach my $id (keys%dm){
##      delete $dm{$id} if scalar(@{$dm{$id}}) < 2;
#    }
#    print STDERR "$self->{'org'} has ",scalar(keys%dm)," pt_ids with > 1 rna_id\n" if $self->{'debug'} == 1;
#  
##close the database handles..
#    $dbh->dbclose();
#  }
    
  foreach my $id (keys%dm){
    $self->processNewSet(@{$dm{$id}});  
  }
  
}


##print out the results 

sub toString{
  my $self = shift;
  my $res;
  undef $self->{summary};
  foreach my $id (keys%{$self->{'clusters'}}){
    next if scalar(keys%{$self->{'clusters'}->{$id}}) == 0;

    $res .= "Cluster_$id \(". scalar(keys%{$self->{'clusters'}->{$id}}). " sequences\): \(". join(', ', keys%{$self->{'clusters'}->{$id}}). "\)\n";
    my $num = scalar(keys%{$self->{'clusters'}->{$id}});
    $self->{summary}->{$num}++;
  }
  
  return $res;
}

##returns array of arrays of ids in clusters
sub getClusterArray{
  my $self = shift;
  my @res;
  undef $self->{summary};
  foreach my $id (keys%{$self->{'clusters'}}){
    next if scalar(keys%{$self->{'clusters'}->{$id}}) == 0;

    push(@res, [keys%{$self->{'clusters'}->{$id}}]);
    my $num = scalar(keys%{$self->{'clusters'}->{$id}});
    $self->{summary}->{$num}++;
  }
  
  return @res;
}

sub getSummary{
  my $self = shift;
  my $sum = "";
  if(!exists $self->{summary}){
    $self->getResults();
  }
  $sum .= "Summary of distribution\n";
  foreach my $num (sort{$b <=> $a}keys%{$self->{summary}}){
    $sum .= "  $num: $self->{summary}->{$num}\n";
  }
  return $sum;
}

sub processNewSet {
  my($self,@ids) = @_;
  print STDERR "Ids that meet criteria: \(", join(', ', @ids), "\)\n" if $self->{'debug'} == 1;
  ##first check to see if any of the ids match existing clusters
  my %list;
  foreach my $id (@ids){
    next if exists $self->{'chimera'}->{$id};  ##chimera
    if(exists $self->{'idAssign'}->{$id}){
#      push(@list,$self->{'idAssign'}->{$id});
      $list{$self->{'idAssign'}->{$id}} = 1;
    }
  }
  $self->processSet(\@ids,keys%list);
}

sub processSet {
  my($self,$ids,@clusList) = @_;

  ##if @clusList = 0 then new cluster, if 1 then add to that cluster, if
  ## > 1 then make new cluster and bring in all the other ids

  my @oldids;
  my @sorted;

  if(scalar(@clusList) == 0){
    $self->{'clusterID'}++;
    $self->assignIDs($self->{'clusterID'},@{$ids});
  }elsif(scalar(@clusList) == 1){  ##use old clusterID and assign new to old
    $self->assignIDs($clusList[0],@{$ids});
  }else{
    @sorted = sort{scalar(keys%{$self->{'clusters'}->{$b}}) <=> scalar(keys%{$self->{'clusters'}->{$a}})} @clusList;
    for (my $i=1;$i<scalar(@sorted);$i++){
      push(@oldids,keys%{$self->{'clusters'}->{$sorted[$i]}});
      undef %{$self->{'clusters'}->{$sorted[$i]}};  ##releases from memory as will not be used again
    }
    $self->assignIDs($sorted[0],@{$ids},@oldids);
  }
}

sub assignIDs{
  my($self,$clusterID,@ids) = @_;
  foreach my $id (@ids){
    next if exists $self->{'chimera'}->{$id};  ##chimera
    $self->{'idAssign'}->{$id} = $clusterID;
    $self->{'clusters'}->{$clusterID}->{$id} = 1;
  }
}

1;
