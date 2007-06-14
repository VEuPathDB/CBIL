
package CBIL::Bio::DbFfWrapper::Transfac::Parser;

use strict 'vars';

use FileHandle;

use CBIL::Bio::DbFfWrapper::Transfac::Reference;
use CBIL::Bio::DbFfWrapper::Transfac::RefLinks;
use CBIL::Bio::DbFfWrapper::Transfac::Parser::Store;
use CBIL::Bio::DbFfWrapper::Transfac::Matrix;
use CBIL::Bio::DbFfWrapper::Transfac::Factor;
use CBIL::Bio::DbFfWrapper::Transfac::Site;
use CBIL::Bio::DbFfWrapper::Transfac::Gene;
use CBIL::Bio::DbFfWrapper::Transfac::Class;
use CBIL::Bio::DbFfWrapper::Transfac::Cell;
use CBIL::Bio::DbFfWrapper::Transfac::Version;

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
   my $Self = shift;
   my $A = shift;

   $Self->setRefLinks  (CBIL::Bio::DbFfWrapper::Transfac::RefLinks->new);
   $Self->setErrMsg    ($A->{ErrMsg}    || undef);
   $Self->setInPath    ($A->{InPath}    || '.');
   $Self->setFiles     ($A->{Files}     || [( 'cell', 'class', 'gene', 'site', 'matrix', 'factor' )]);
   $Self->setFileCaches($A->{FileCaches} || {} );
   $Self->setCount     ($A->{Count               } || 1_000_000_000 );

   return $Self
}

# ----------------------------------------------------------------------

#sub getQ { $_[0]->{Q} }
#sub setQ { $_[0]->{Q} = $_[1]; $_[0] }

sub getErrMsg     { $_[0]->{ErrMsg} }
sub setErrMsg     { $_[0]->{ErrMsg} = $_[1]; $_[0] }
sub clrErrMsg     { $_[0]->{ErrMsg} = undef; $_[0] }

sub getInPath     { $_[0]->{InPath} }
sub setInPath     { $_[0]->{InPath} = $_[1]; $_[0] }

sub getVersion    { $_[0]->{Version} }
sub setVersion    { $_[0]->{Version} = $_[1]; $_[0] }

sub getFiles      { $_[0]->{Files} }
sub setFiles      { $_[0]->{Files} = $_[1]; $_[0] }

sub getFileCaches { $_[0]->{FileCaches} }
sub setFileCaches { $_[0]->{FileCaches} = $_[1]; $_[0] }

sub getFileCache  { $_[0]->{FileCaches}->{$_[1]} }
sub setFileCache  { $_[0]->{FileCaches}->{$_[1]} = $_[2]; $_[0]}

sub getRefCache   { $_[0]->{RefCache} }
sub setRefCache   { $_[0]->{RefCache} = $_[1]; $_[0]}
sub incRefCache   { $_[0]->{RefCache}->{$_[1]} = $_[2]; $_[0]};

sub getRefLinks   { $_[0]->{RefLinks} }
sub setRefLinks   { $_[0]->{RefLinks} = $_[1]; $_[0] }

sub getCount      { $_[0]->{'Count'                       } }
sub setCount      { $_[0]->{'Count'                       } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub getCellCache   { $_[0]->{FileCache}->{cell  } }
sub getClassCache  { $_[0]->{FileCache}->{class } }
sub getGeneCache   { $_[0]->{FileCache}->{gene  } }
sub getSiteCache   { $_[0]->{FileCache}->{site  } }
sub getMatrixCache { $_[0]->{FileCache}->{matrix} }
sub getFactorCache { $_[0]->{FileCache}->{factor} }

# ----------------------------------------------------------------------

sub loadAllFiles {
   my $Self = shift;

   $Self->clrErrMsg;

   # load all of the files we know about
   foreach my $file (@{$Self->getFiles}) {
      $Self->setFileCache($file,$Self->loadFile($file));
      last if $Self->getErrMsg;
   }

   return $Self
}

# ----------------------------------------------------------------------

sub loadFile {
  my $Self = shift;
  my $F = shift;

  # prepare to read file
  # ........................................
  # get name,
  # get handle,
  # make sure handle's ok
  # save and adjust record separator

  my $f  = join('/', $Self->getInPath, "$F.dat");
  my $fh = FileHandle->new("<$f");

  unless ( $fh ) {
    $Self->setErrMsg(join("\t",'Unable to open loadFile',$f,$!));
    return undef;
  }

  my $saved_input_record_separator = $/;
  $/ = "//\n";

  # read file
  # ........................................
  # read version information.
  # read entries.

  # file store
  my $store = CBIL::Bio::DbFfWrapper::Transfac::Parser::Store->new();

  my $record_n  = 0;
  my $version_c = <$fh>;
  my $version_o = CBIL::Bio::DbFfWrapper::Transfac::Version->new($version_c);
  $store->setVersion($version_o);
  while ( <$fh> ) {
     $record_n++;
     $store->addRecord([split("\n",$_)]);
     last if $record_n >= $Self->getCount();
  }
  $fh->close;
  $/ = $saved_input_record_separator;

  $Self->setVersion($version_o) unless $Self->getVersion;

  # return value;
  $store
}

# ----------------------------------------------------------------------
# Extract references and put them into the database.
#
# We will maintain a cache which is MEDLINE to ref_id.  Thus we can create
# ----------------------------------------------------------------------

sub extractRefsFromAllFiles {
  my $Self = shift;

  # extract references from each file.
  # ..............................

  $Self->setRefCache({});

  # process each file
  foreach (@{$Self->getFiles}) {
    $Self->extractRefsFromFile($_);
  }

  return $Self
}

sub extractRefsFromFile {
  my $Self = shift;  # Me
  my $F = shift;  # string : file

  my $cache = $Self->getFileCache($F);
  foreach my $record (@{$cache->getRecords}) {
    $Self->extractRefsFromRecord($record);
  }

  return $Self
}

sub extractRefsFromRecord {
  my $Self = shift;  # Me
  my $R = shift;  # Entry

  my $lines_n = scalar @$R;
  my $ac;

  for (my $line_i = 0; $line_i<$lines_n; ) {

    # track accession number for this entry
     if ($R->[$line_i] =~ /^AC\s+([A-Z]?\d+)$/) {
        $ac = $1;
        $line_i++;
     }

     # look for start of a reference
     elsif ($R->[$line_i] =~ /^RN/) {
        #print "$line_i\t$R->[$line_i]\n";
        my $ref = CBIL::Bio::DbFfWrapper::Transfac::Reference->new;
        $ref->parse($R,\$line_i);
        $ref->makeId;
        $Self->incRefCache($ref->getId,$ref);
        $Self->getRefLinks->addLink($ac,$ref);
        #Disp::Display($Self->getRefLinks);
     }

     else {
        $line_i++;
     }
  }

  return $Self;
}

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------

sub parseAllFiles {
  my $Self = shift;

  foreach my $file (@{$Self->getFiles}) {

     progress( '=' x 70 );
     progress( 'entering', $file );
     progress( '=' x 70 );

     my $load_method = sprintf( 'loadTable%sEntry', ucfirst $file );
     my $good_n = 0;
     my $bad_n  = 0;

     my $store = $Self->getFileCache($file);
     foreach my $record (@{$store->getRecords}) {
        if (my $entry = $Self->$load_method($record)) {
           $good_n++;
           $store->setEntry($entry);
        }
        else {
           $bad_n++;
        }
     } # eo entry scan
  } # eo file scan

  # return value
  undef
}

sub loadTableCellEntry {
  my $Self = shift;
  my $E = shift;

  return CBIL::Bio::DbFfWrapper::Transfac::Cell->new($E)
}

sub loadTableClassEntry {
  my $Self = shift;
  my $E = shift;

  return CBIL::Bio::DbFfWrapper::Transfac::Class->new($E);
}

sub loadTableGeneEntry {
  my $Self = shift;
  my $E = shift;

  return CBIL::Bio::DbFfWrapper::Transfac::Gene->new($E);
}

sub loadTableSiteEntry {
  my $Self = shift;
  my $E = shift;

  return CBIL::Bio::DbFfWrapper::Transfac::Site->new($E);
}

sub loadTableFactorEntry {
  my $Self = shift;
  my $E = shift;

  return CBIL::Bio::DbFfWrapper::Transfac::Factor->new($E);
}

sub loadTableMatrixEntry {
  my $Self = shift;
  my $E = shift;

  return CBIL::Bio::DbFfWrapper::Transfac::Matrix->new($E);
}

# ----------------------------------------------------------------------
# Handle DbRefs
# ----------------------------------------------------------------------


sub addPendingDbRefs {
  my $Self = shift;
  my $E = shift;

  # the DbRefs are already made, we need to make the following links:
  # TransfacEntryImp <- TransfacDbRef -> DbRef

  foreach my $db_ref ( @{ $Self->{Pending}->{DbRefs} } ) {
    my $tf_db_ref = TransfacDbRef->new({});
    $tf_db_ref->setParent($E);
    $tf_db_ref->setParent($db_ref);
  }

	delete $Self->{Pending}->{DbRefs};
}

# ----------------------------------------------------------------------
# Handling Sequences
# ----------------------------------------------------------------------

sub addPendingSequence {
  my $Self = shift;
  my $S = shift;

  my $seq = $Self->cleanDnaSequence( $S );

  push( @{ $Self->{Pending}->{Sequences} },
        TransfacSiteSequence->new( { sequence => $seq,
                                   } )
      );
}

sub cleanDnaSequence {
  my $Self = shift;
  my $S = shift;

  # remove trailing .
  $S =~ s/\.$//;

  # and this wacky thing that just won't go away!
  $S =~ s/\[1:30\]/nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn/;

  # return value
  $S
}

sub addPendingSequences {
  my $Self = shift;
  my $E = shift;

  foreach my $seq ( @{ $Self->{Pending}->{Sequences} } ) {
    my $seq_gus = TransfacSiteSequence->new( {
                                              sequence => $seq,
                                             } );
    $E->addChild( $seq_gus );
  }

  delete $Self->{Pending}->{Sequences};
}

# ----------------------------------------------------------------------
# Sizes
# ----------------------------------------------------------------------

sub addPendingSize {
  my $Self = shift;
  my $S = shift;

  push( @{ $Self->{Pending}->{Sizes} },
        TransfacFactorSize->new( $S ) );
}

# ----------------------------------------------------------------------
# Handling methods
# ----------------------------------------------------------------------

sub load_method_cache {
  my $Self = shift;

  my $sql = 'select tf_method_id, name from TransfacMethod';
  #my $sql = 'select tf_method_id from TransfacMethod';
  my $sth = $Self->{dbq}->prepareAndExecute($sql);
  while ( my ( $id, $name ) = $sth->fetchrow_array() ) {
    $Self->{Cache}->{Method}->{$name} = $id;
    #my $method = TransfacMethod->new( { tf_method_id => $id } );
    #$method->retrieveFromDB();
    #$Self->{Cache}->{Method}->{ $method->getName() } = $method;
  }
  $sth->finish();

  #Disp::Display( $Self->{Cache}->{Method} );

  #foreach ( values %{ $Self->{Cache}->{Method} } ) {
  # Disp::Display( $_->{attributes}, ref $_, STDOUT );
  #}
}

sub addPendingMethod {
  my $Self = shift;
  my $C = shift;

  # create a 'controlled' method if we haven't a matching one already.
  unless ( $Self->{Cache}->{Method}->{$C} ) {
    my $method = TransfacMethod->new( { name => $C } );
    $method->submit() if $Self->{Ctx}->{cla}->{LE};
    $Self->{Cache}->{Method}->{$C} = $method->getId();
    #$Self->{Cache}->{Method}->{$C} = $method;
    GusApplication::Log( 'METHOD', $C );
  }

  my $method_link =
  TransfacSiteMethod->new( { tf_method_id => $Self->{Cache}->{Method}->{$C}
                           } );
  push( @{ $Self->{Pending}->{Methods} }, $method_link );

# my $method      = $Self->{Cache}->{Method}->{$C};
# if ( $method ) {
#   $method_link->setParent( $method );
#   push( @{ $Self->{Pending}->{Methods} }, $method_link );
# }
# else {
#   GusApplication::Log( 'METHOD', 'missing', $C );
# }

  $Self
}

# ----------------------------------------------------------------------
# Handling factor features
# ----------------------------------------------------------------------

sub addPendingFeature {
  my $Self = shift;
  my $F = shift;

  # new line.
  if ( $F =~ /\s+(\d+)\s+(\d+)\s+(.+)$/ ) {
    my $feature = { ordinal => $Self->ordinal( 'Features' ),
                    first   => $1,
                    last    => $2,
                    description => $3
                  };
    push( @{ $Self->{Pending}->{Features} },
          TransfacFactorFeature->new( $feature )
        );
  }

  # continuation
  elsif ( $F =~ /\s+(.+)$/ ) {
    my $old_feat = pop @{ $Self->{Pending}->{Features} };
    $old_feat->setDescription( $old_feat->getDescription. ' '. $1 );
    push( @{ $Self->{Pending}->{Features} }, $old_feat );
  }
}

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------

sub addPendingName {
  my $Self = shift;
  my $S = shift;

  push( @{ $Self->{Pending}->{Names} },
        TransfacFactorName->new( $S )
      );
}

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------

sub addPendingHomolog {
  my $Self = shift;
  my $S = shift;

  my $ord = $Self->ordinal( 'Homologs' );
  push( @{ $Self->{Pending}->{Homologs} },
        TransfacFactorHomolog->new( { ordinal => $ord,
                                      name    => $S
                                    } )
      );
}

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------

sub addPendingSpecificity {
  my $Self = shift;
  my $S = shift;

  push( @{ $Self->{Pending}->{Specificities} },
        TransfacFactorSpecificity->new( $S )
      );
}

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------

sub addPendingFuncFeat {
  my $Self = shift;
  my $S = shift;


  my $ord = $Self->ordinal( 'FuncFeats' );
  push( @{ $Self->{Pending}->{FuncFeats} },
        TransfacFactorFuncFeat->new( { ordinal     => $ord,
                                       description => $S,
                                     } )
      );
}

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------

sub addPendingStructFeature {
  my $Self = shift;
  my $S = shift;

  my $ord = $Self->ordinal( 'StructFeatures' );
  push( @{ $Self->{Pending}->{StructFeatures} },
        TransfacFactorStructFeature->new( { ordinal     => $ord,
                                            description => $S
                                          } )
      );
}

# ----------------------------------------------------------------------
# Handling intra-TRANSFAC links
#
# These are collected while the files are scanned, and store for
# processing once all entries have been loaded.
#
# Here are the linking tables:
#   TransfacCellSite
#   TransfacFactorClass
#   TransfacFactorMatrix
#   TransfacFactorSite
#   TransfacGeneSite
#   TransfacMatrixSite
#
# We store pending links and extra information with table names in
# alphabetical order.
# ----------------------------------------------------------------------

sub addPendingLink {
  my $Self  = shift;
  my $T1 = shift;
  my $A1 = shift;
  my $T2 = shift;
  my $A2 = shift;
  my $H  = shift;

  if ( $T1 le $T2 ) {
    push( @{ $Self->{Links} }, [ $T1, $A1, $T2, $A2, $H ] );
  }
  else {
    push( @{ $Self->{Links} }, [ $T2, $A2, $T1, $A1, $H ] );
  }
}

sub loadPendingLinks {
  my $Self = shift;

  foreach my $link ( @{ $Self->{Links} } ) {

		$link->[0] = ucfirst $link->[0];
		$link->[2] = ucfirst $link->[2];

    if ( $link->[0] eq 'Cell'   && $link->[2] eq 'Site' ||
         $link->[0] eq 'Factor' && $link->[2] eq 'Class' ||
         $link->[0] eq 'Factor' && $link->[2] eq 'Matrix' ||
         $link->[0] eq 'Factor' && $link->[2] eq 'Site' ||
         $link->[0] eq 'Gene'   && $link->[2] eq 'Site' ||
         $link->[0] eq 'Matrix' && $link->[2] eq 'Site'
       ) {

      my $link_class = join( '', 'Transfac', $link->[0], $link->[2] );
      my $a_class = lc $link->[0];
      my $b_class = lc $link->[2];
      my $iref = $link_class->new
      ({ "tf_${a_class}_id" => $Self->{Cache}->{Entry}->{$a_class}->{$link->[1]},
         "tf_${b_class}_id" => $Self->{Cache}->{Entry}->{$b_class}->{$link->[3]},
         %{ $link->[4] }
       });
      $iref->submit() if $Self->{Ctx}->{cla}->{LE};
    }

    # unexpected internal reference
    else {
      GusApplication::Log( 'IREF', @{ $link } );
      next;
    }

  }
}

# ----------------------------------------------------------------------
# TAXON HANDLING
#
# We'll load up a cache in the shape of a tree where we skip null terms.
# ----------------------------------------------------------------------

sub load_taxon_cache {
  my $Self = shift;

  GusApplication::Log( 'PRG', 'load_taxon_cache' );

  $Self->{Cache}->{Taxa} = {};

  my $sql = 'select * from Taxon';
  my $sth = $Self->{dbq}->prepare( $sql );
  $sth->execute();
  while ( my @row = $sth->fetchrow_array() ) {

    # cache by species scientific name
    $Self->{Cache}->{Species}->{ lc $row[2] } = $row[0];

    # cache by species common name
    $Self->{Cache}->{Common}->{ lc $row[3] } = [ split( /\s+/, $row[2] ) ]
    unless $Self->{Cache}->{Common}->{ lc $row[3] };

#   GusApplication::Log( 'ROW', @row );

#   my @row = map { $row->{ $_ } } qw( domain kingdom phylum division class tax_order family genus species );

    # remove nulls to get simple path
    my @terms;
    for ( my $i = 4; $i < 12; $i++ ) {
      if ( defined $row[$i] ) {
        push( @terms, lc $row[$i] )
      }
    }
#   GusApplication::Log( 'TERM', @terms );

    # create path in cach
    my $addr = $Self->{Cache}->{Taxa};
  BUILD_PATH:

    # work down to find last already-existing node
    for ( my $i = 0; $i <= $#terms; $i++ ) {

      # empty? create value to go here
      if ( ! defined $addr->{ $terms[$i] } ) {
        my $value = $row[0];
        for ( my $j = $#terms; $j > $i; $j-- ) {
          #Disp::Display( $value );
          $value = { $terms[$j] => $value }
        }
        #Disp::Display( $value );

        # put it in and bail out
        $addr->{ $terms[$i] } = $value;
        last BUILD_PATH;
      }

      # got it? keep going.
      else {
        $addr = $addr->{ $terms[$i] }
      }
    }
  }
  $sth->finish();

  #Disp::Display( $Self->{Cache}->{Taxa} );
}

my $cache = {
             'hamster'              => [ 'Cricetus', 'cricetus' ],
             'clawed frog'          => [ 'Xenopus', 'laevis' ],
             'sea urchin'           => [ 'Stongylocentrotus', 'purpuratus' ],
             'EBV'                  => [ 'Epstein-Barr', 'virus' ],

             # cell short-hands
             'human'                => [ 'Homo',       'sapiens' ],
             'mouse'                => [ 'Mus',        'musculus' ],
             'rat'                  => [ 'Rattus',     'rattus' ],
             'cat'                  => [ 'Felis',      'catus' ],
             'hamster'              => [ 'Cricetus',   'cricetus' ],
             'Xenopus'              => [ 'Xenopus',    'laevis' ],
             'chicken'              => [ 'Gallus',     'gallus' ],
             'chick'                => [ 'Gallus',     'gallus' ],
             'pig'                  => [ 'Sus',        'scrofa' ],
             'Drosophila'           => [ 'Drosophila', 'melanogaster' ],
             'rat/mouse'            => [ 'Mus',        'musculus' ],
             'mouse/rat'            => [ 'Mus',        'musculus' ],
             'gibbon ape'           => [ 'Hylobates',  'lar' ],
             'bovine'               => [ 'Bos',        'taurus' ],
             'African Green Monkey' => [ 'Cercopithecus', 'aethiops' ],
            };

sub parseSpecies {
   my $Self = shift;
   my $L = shift;

   # elmininate parenthesis and contents
   $L =~ s/\(.+\)//g;

   # leading and trailing spaces
   $L =~ s/\s+$//;
   $L =~ s/^\s+//;

   # misspellings
   $L =~ s/Medigo/Medicago/g;
   $L =~ s/Lycopsersicon/Lycopersicon/g;
   $L =~ s/L\.//;

   my @parts = split( /\s*,\s*/, $L );
   my @words = split( /\s+/, $L );
   my @sc_words = split( /\s+/, $parts[1] );

   GusApplication::Log( 'pSPEC', 'L', $L, join( '-', map { "'$_'" } @parts ) );

   my $common = $Self->{Cache}->{Common}->{ $L };

   # cache of common short-hands
   if ( defined $cache->{ $parts[0] } ) {
     GusApplication::Log( 'pSPEC', 'cache', $parts[0], @{ $cache->{ $parts[0] } } );
     return $cache->{ $parts[0] }
   }

   # common names
   elsif ( defined $common ) {
     GusApplication::Log( 'pSPEC', 'common', @{ $common } );
     return $common;
   }

   # canonical form
   elsif ( $parts[1] =~ /([A-Z][a-z\-]+)\s+([a-z\-]+)\s*$/ ) {
     GusApplication::Log( 'pSPEC', 'canon', $1, $2 );
     return [ $1, $2 ];
   }

   # two word - might be scientific names
   elsif ( scalar @words == 2 ) {
     GusApplication::Log( 'pSPEC', 'words', @words );
     return \@words;
   }

   # scientific names might be a virus name
   elsif ( scalar @sc_words >= 2 && $L =~ /virus/ ) {
     GusApplication::Log( 'pSPEC', 'virus', @sc_words );
     return \@sc_words;
   }

   # dunno, just give the cleaned-up words
   else {
     GusApplication::Log( 'SPECIES', 'huh', $L );
     return \@words;
   }
}

sub lookup_taxon {
  my $Self = shift;
  my $C = shift;
  my $S = shift;

  # try by classification
  my $n = $Self->{Cache}->{Taxa};
  my @act = ();
  foreach ( @{ $C }, @{ $S } ) {
    my $nn = $n->{ lc $_ };
    if ( defined $nn ) {
      push( @act, 'match' );
      $n = $nn;
      last unless ref $n;
    }
    else {
      push( @act, 'miss' );
    }
  } # classification and species scan

  # try by species if no success.
  my $species_guess = 'na';
  if ( $n !~ /^\d+$/ ) {

    $species_guess =
    $Self->{Cache}->{Species}->{ join( ' ', map { lc $_ } @{ $S } ) };

    $n = $species_guess;
  }

  if ( $n !~ /^\d+$/ ) {
    $n = 0;
  }

  GusApplication::Log( 'TAXA', $n, @{ $C }, '-', @{ $S } );
  GusApplication::Log( 'TACT', $n, $species_guess, @act );

  # return value
  return $n
}

# ----------------------------------------------------------------------
# UTILITIES
# ----------------------------------------------------------------------

# outputs standard progress messages.

sub progress {

  my $time = localtime;
  $time =~ s/ /_/g;
  print join( "\t", 'PRG', $time, @_ ), "\n";
}

# joins list refs with spaces, then reduces multiple spaces with
# single space.

sub flattenLists {
  my $E = shift;

  foreach ( @_ ) {
    $E->{ $_ } = join( ' ', @{ $E->{ $_ } } );
    $E->{ $_ } =~ s/\s+/ /g;
  }
}

1;

# ======================================================================

__END__

$| = 1;

use Disp;

my $p = CBIL::Bio::DbFfWrapper::Transfac::Parser->new({ InPath => shift @ARGV,
                              	})	;
$p->loadAllFiles;	
$p->extractRefsFromAllFiles;
$p->parseAllFiles;

#Disp::Display($p->getRefLinks);
#Disp::Display($p->getRefCache);

__END__

=pod
=head1 Description
B<Template> - a template plug-in for C<ga> (GUS application) package.

=head1 Purpose
B<Template> is a minimal 'plug-in' GUS application.

=cut
