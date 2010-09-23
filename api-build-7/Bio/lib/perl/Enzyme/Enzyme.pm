
package CBIL::Bio::Enzyme::Enzyme;

use strict;

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

   $M->parse($A) if ref $A eq 'ARRAY';

   return $M
}

# ----------------------------------------------------------------------

# an EcNumber string
sub getId                  { $_[0]->{Id} }
sub setId                  { $_[0]->{Id} = $_[1]; $_[0] }

# an EcNumber object
sub getNumber              { $_[0]->{Number} }
sub setNumber              { $_[0]->{Number} = $_[1]; $_[0] }

# the parent class
sub getParent              { $_[0]->{Parent} }
sub setParent              { $_[0]->{Parent} = $_[1]; $_[0] }

# a string
sub getDescription         { $_[0]->{Description} }
sub setDescription         { $_[0]->{Description} = $_[1]; $_[0] }

# a ref to an array of strings
sub getAlternateNames      { $_[0]->{AlternateNames} }
sub setAlternateNames      { $_[0]->{AlternateNames} = $_[1]; $_[0] }
sub addAlternateName       { push(@{$_[0]->{AlternateNames}}, $_[1]); $_[0] }

# a ref to an array of Reaction objects
sub getCatalyticActivities { $_[0]->{CatalyticActivities} }
sub setCatalyticActivities { $_[0]->{CatalyticActivities} = $_[1]; $_[0] }
sub addCatalyticActivity   { push(@{$_[0]->{CatalyticActivities}}, $_[1]); $_[0] }

# a ref to an array of refs to arrays of strings.
sub getCofactors           { $_[0]->{Cofactors} }
sub setCofactors           { $_[0]->{Cofactors} = $_[1]; $_[0] }
sub addCofactor            { push(@{$_[0]->{Cofactor}}, $_[1]); $_[0] }

# a ref to an array of strings.
sub getComments            { $_[0]->{Comments} }
sub setComments            { $_[0]->{Comments} = $_[1]; $_[0] }
sub addComment             { push(@{$_[0]->{Comments}},$_[1]); $_[0] }

# a ref to an array of DbRef objects
sub getDbRefs              { $_[0]->{DbRefs} }
sub setDbRefs              { $_[0]->{DbRefs} = $_[1]; $_[0] }
sub addDbRef               { push(@{$_[0]->{DbRefs}},$_[1]); $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $E = shift; # [string] : lines from file

   # temporary variables for multi-line parsing.
   my $an;
   my $cc;
   my $ca;

   my $actions =
   {
    ID => ['^\s*(\S+)$'             , sub { my $num = CBIL::Bio::Enzyme::EcNumber
                                            ->new($_[0]);
                                            $M->setNumber($num);
																						$M->setId($num->toString);
																					} ],
    DE => ['\s*(.+)\.$'             , sub { $M->setDescription($M->getDescription.$_[0]) },
           '\s*(.+)$'               , sub { $M->setDescription($_[0]) },
          ],
    AN => ['\s*(.+)\.$'             , sub { $an .= $_[0];
                                            $M->addAlternateName($an);
                                            undef $an; },
           '\s*(.+)$'               , sub { $an = $_[0]. ' '; },
          ],
    CA => ['^\s*(.+)\.$'            , sub { $ca .= $_[0];
                                            my $r = CBIL::Bio::Enzyme::Reaction->new($ca);
                                            $M->addCatalyticActivity($r);
                                            undef $ca; },
           '^\s*(.+)\s*$'           , sub { $ca = $_[0]. ' '; },
          ],
    CC => ['\s*(.+)\.$'             , sub { $cc .= $_[0];
                                            $cc =~ s/^\s*-\!- //;
                                            #$cc =~ s/\s+/ /g;
                                            $cc .= '.';
                                            $M->addComment($cc);
                                            undef $cc; },
           '\s*(.+)$'               , sub { $cc .= ' ' if $cc;
                                            $cc .= $_[0]. ' '; },
          ],
    CF => ['^\s*(.+).\s*$'          , sub { my @p = split(/\s*;\s*/, $_[0]);
                                            foreach (@p) {
                                               $M->addCofactor($_)
                                            } } ],
    PR => ['^\s*(PROSITE); (PD\S+);', sub { my $r = CBIL::Bio::Enzyme::DbRef
                                            ->new({ Database => $_[0],
                                                    PrimaryId => $_[1],
                                                  });
                                            $M->addDbRef($r); } ],
    DR => ['^\s*(.+)'                , sub { my @refs = split(/\s*;\s*/, $_[0]);
                                             foreach my $ref (@refs) {
                                                my @p = split(/\s*,\s*/, $ref);
                                                my $r = CBIL::Bio::Enzyme::DbRef
                                                ->new({ Database    => 'SWISSPROT',
                                                        PrimaryId   => $p[0],
                                                        SecondaryId => $p[1],
                                                      });
                                                $M->addDbRef($r);
                                             } }, ],
    DI => ['^(.+?)[.,]?$'            , sub { my @p = split(/\s*;\s+/,$_[0]);
                                             my $r = CBIL::Bio::Enzyme::DbRef
                                             ->new({ Database  => 'OMIM',
                                                     PrimaryId => $p[1],
                                                     SecondaryId => $p[0],
                                                   });
                                             $M->addDbRef($r); } ],
   };

 LINE_SCAN:
   for (my $i = 0; $i < @$E; $i++) {
      my $line = $E->[$i];
      my $code = substr($line,0,2);
      last if $code eq '//';

      my $act  = $actions->{$code};
      if (defined $act) {
         if ($act) {
            my $text = substr($line,4);
            my $matched;
            for (my $i=0; $i<@$act; $i+=2) {
               if ($text =~ /$act->[$i+0]/) {
                  $act->[$i+1]->($1,$2,$3,$4,$5,$6,$7,$8,$9);
                  $matched = 1;
                  last;
               }
            }
            unless ($matched) {
               printf STDERR "Poor format in %s: '%s'\n", ref $M, $line;
            }
         }
      }
      else {
         printf STDERR "Unexpected line in %s: '%s'\n", ref $M, $line;
      }
   }

   #Disp::Display($M);

   return $M
}

# ----------------------------------------------------------------------

1
