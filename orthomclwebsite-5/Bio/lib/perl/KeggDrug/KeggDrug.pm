package CBIL::Bio::KeggDrug::KeggDrug;

# Adhemar Neto, schistodb.net, 2008
# azneto@gmail.com
# modeled after CBIL::Bio::Enzyme::Enzyme

use strict;
use CBIL::Bio::KeggDrug::EcNumber;
use CBIL::Bio::KeggDrug::DbRef;

# ----------------------------------------------------------------------

sub new {
   my $C = shift;
   my $A = shift;

   my $m = bless {}, $C;

   $m->init($A);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $M = shift;
   my $A = shift;

   $M->parse($A);

   return $M
}

# ----------------------------------------------------------------------

sub getId                     { $_[0]->{Id} }
sub setId                     { $_[0]->{Id} = $_[1]; $_[0] }

# a string
sub getName                   { $_[0]->{Name} }
sub setName                   { $_[0]->{Name} = $_[1]; $_[0] }

# a string
sub getSynonyms               { $_[0]->{Synonyms} }
sub setSynonyms               { $_[0]->{Synonyms} = $_[1]; $_[0] }

# a string
sub getFormula                { $_[0]->{Formula} }
sub setFormula                { $_[0]->{Formula} = $_[1]; $_[0] }

# a string
sub getMass                   { $_[0]->{Mass} }
sub setMass                   { $_[0]->{Mass} = $_[1]; $_[0] }

# a string
sub getActivity               { $_[0]->{Activity} }
sub setActivity               { $_[0]->{Activity} = $_[1]; $_[0] }

# a string
sub getTarget                 { $_[0]->{Target} }
sub setTarget                 { $_[0]->{Target} = $_[1]; $_[0] }

# a ref to an array of DbRef objects
sub getTargetDbRef           { $_[0]->{TargetDbRef} }
sub setTargetDbRef           { $_[0]->{TargetDbRef} = $_[1]; $_[0] }
sub addTargetDbRef           { 
	                            my $check = 1;
	                            foreach my $obj (@{$_[0]->{TargetDbRef}}) {
	                            	$check = 0 if($obj->getDatabase eq $_[1]->getDatabase && $obj->getPrimaryId eq $_[1]->getPrimaryId);
	                            }
	                            push(@{$_[0]->{TargetDbRef}}, $_[1]) if($check);
	                            $_[0] 
                             }

# a string
sub getRemark                 { $_[0]->{Remark} }
sub setRemark                 { $_[0]->{Remark} = $_[1]; $_[0] }

# a ref to an array of strings
sub getPathway                { $_[0]->{Pathway} }
sub setPathway                { $_[0]->{Pathway} = $_[1]; $_[0] }
sub addPathway                { push(@{$_[0]->{Pathway}}, $_[1]); $_[0] }

# a ref to an array of DbRef objects
sub getDbRefs                 { $_[0]->{DbRefs} }
sub setDbRefs                 { $_[0]->{DbRefs} = $_[1]; $_[0] }
sub addDbRef                  { push(@{$_[0]->{DbRefs}},$_[1]); $_[0] }

# a string
sub getAtom                   { $_[0]->{Atom} }
sub setAtom                   { $_[0]->{Atom} = $_[1]; $_[0] }

# a string
sub getBond                   { $_[0]->{Bond} }
sub setBond                   { $_[0]->{Bond} = $_[1]; $_[0] }

# a string
sub getBracket                { $_[0]->{Bracket} }
sub setBracket                { $_[0]->{Bracket} = $_[1]; $_[0] }

# a string
sub getComment                { $_[0]->{Comment} }
sub setComment                { $_[0]->{Comment} = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $E = shift; # [string] : lines from file



   my $actions =
   {
    ENTRY               => sub {
                                 my($entry_id,$entry_type) = split(' ',shift);
                                 $M->setId($entry_id) 
                               },
    NAME                => sub {
                                 my @names = split(/\n/,shift);
                                 my $name = shift(@names);
                                 $name =~ s/;$//g;
                                 my $synonyms;
                                 $synonyms .= $_." " for(@names);
                                 $M->setName($name);
                                 $M->setSynonyms($synonyms) 
                               },
    FORMULA             => sub {
                                 my $formula = shift;
                                 $M->setFormula($formula)
                               },
    MASS                => sub {
                                 my $mass = shift;
                                 $M->setMass($mass)
                               },
    ACTIVITY            => sub {
                                 my $activity = shift;
                                 $activity =~ s/\n/ /g;
                                 $M->setActivity($activity)
                               },
    TARGET              => sub {
                                 my $target = shift;
                                 $target =~ s/\n/ /g;
                                 $M->setTarget($target);
                                 
                                 my @targets = split(" ",$target);
                                 
                                 foreach (@targets) {

                                 	if($_ =~ /PATH:(\w{3}\d{3,5})/) {
                                 		my $r = CBIL::Bio::KeggDrug::DbRef->new({ Database  => "PATH",
                                                                                  PrimaryId => $1});
                                        $M->addTargetDbRef($r);
                                 	}
                                 	                                 	
                                 	elsif($_ =~ /(\d+\.\d+\.\d+\.\d+)/) {
                                 		my $num = CBIL::Bio::KeggDrug::EcNumber->new($1);
                                 		my $r = CBIL::Bio::KeggDrug::DbRef->new({ Database  => "EC",
                                                                                  PrimaryId => $num->toString});
                                        $M->addTargetDbRef($r);
                                 	}
                                 	
                                 	elsif($_ =~ /([Kk][Oo]?\d{3,})/) {
                                 		my $r = CBIL::Bio::KeggDrug::DbRef->new({ Database  => "KO",
                                                                                  PrimaryId => $1});
                                        $M->addTargetDbRef($r);
                                 	}
                                 	
                                 	elsif($_ =~ /(\w{3}[:]?\d{3,5})/) {
                                 		my $r = CBIL::Bio::KeggDrug::DbRef->new({ Database  => "Genes",
                                                                                  PrimaryId => $1});
                                        $M->addTargetDbRef($r);
                                 	}

 
                                 }
                               },
    REMARK              => sub {
                                 my $remark = shift;
                                 $remark =~ s/\n/ /g;
                                 $M->setRemark($remark)
                               },
    PATHWAY             => sub {
                                 my $pathway = shift;
                                 my @pathways = split("\n",$pathway);
                                 foreach (@pathways) {
                                 	$M->addPathway($1) if($_ =~ /PATH: (\S+)/) ;
                                 }
                               },
    DBLINKS             => sub {
    	                         my @dblinks = split("\n",shift);
    	                         for(@dblinks) {
    	                         	if($_ =~ m/(\S+): (\S+)/g) {
    	                         		my ($db, $id) =  ($1, $2);
    	                         		my $r = CBIL::Bio::KeggDrug::DbRef->new({ Database  => $db,
                                                                                  PrimaryId => $id});
                                        $M->addDbRef($r); 
    	                         	}
    	                         }
                               },
    ATOM                => sub {
                                 my $atom = shift;
                                 $M->setAtom($atom)
                               },
    BOND                => sub {
                                 my $bond = shift;
                                 $M->setBond($bond)
                               },
    BRACKET             => sub {
                                 my $bracket = shift;
                                 $M->setBracket($bracket)
                               },
    COMMENT             => sub {
                                 my $comment = shift;
                                 $comment =~ s/\n/ /g;
                                 $M->setComment($comment)
                               },
    PRODUCTS            => sub {
                               my @products = split("\n",shift);
                               for(@products) {
                                  if($_ =~ m/(.+) \(([^\)]+)\) ([^-\s]+-[^-\s]+-[^-\s]+-[^-\s]+-[^\s]+$)/g) {
                                      my ($prod, $db, $id) =  ($1, $2, $3);
                                      my $r = CBIL::Bio::KeggDrug::DbRef->new({ Database  => $db,
                                                                                PrimaryId => $id,
                                                                                SecondaryId => $prod });
                                      $M->addDbRef($r); 
    	                         	}
    	                         }
                               },
    SOURCE             => sub {
                               },
    COMPONENT          => sub {
                               },
   };




         my @chunks = split /\n(?=\S)/, $E;

         foreach my $chunk (@chunks){
              $chunk =~ /^(\S+)/;
              my $key = $1;
              next if !$key;
              last if ($key && ($key eq '///'));

              $chunk =~ s/^$key\s+//g;  ### gets rid of the field name
              $chunk =~ s/\n\s+/\n/g;  ### gets rid of the initial spaces, if there's any
              
              my $act = $actions->{$key};
              if(defined($act)) {
                   $act->($chunk);
              } else {
                   printf STDERR "Unexpected line in %s: '%s'\n", ref $M, $chunk;
              }
         }


   return $M
}

# ----------------------------------------------------------------------

1
