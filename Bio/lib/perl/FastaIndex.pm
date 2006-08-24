
package CBIL::Bio::FastaIndex;

=pod

=head1 Name

C<FastaIndex> - a package which maintains and accesses an index into a
FASTA file of sequences.

=head1 Description

Uses a GDBM_File index into a FASTA format file of sequences.  Assumes
that the first word following the '>' is the accession number for the
sequence.

=head1 Methods

=over 4 

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict "vars";
use vars qw( @ISA @EXPORT);

@ISA = qw ( CBIL::Util::TO );
@EXPORT = qw ( new );

use English;
use Carp;
use FileHandle;
use Fcntl;
use GDBM_File;

use CBIL::Util::TO;
use CBIL::Util::A;

use Bio::Seq;

# ========================================================================
# ---------------------------- Public Methods ----------------------------
# ========================================================================

# --------------------------------- new ----------------------------------

=pod

=item new

Creates a new C<FastaIndex> object.  If an index is provided, then it is
opened.

B<Arguments>

C<seq_file> (req)
sequence filename, i.e. 'db.seq'.

C<index_file> (opt) 
index filename.  If not provided defaults to C<seq_file>

C<open>     (opt)
should the index file be opened for readonly access.

B<Returns>

FastaIndex object if successful.

undef      otherwise.

=cut

sub new {
   my $class = shift;
   my $Args  = shift;

   confess if (!$Args);
   return undef unless $Args->ensure('seq_file');

   my $Self = CBIL::Util::TO::e;

   bless $Self, $class;
  
   $Self->copy($Args, 'seq_file', 'index_file');
   $Self->{index_file} = $Self->{seq_file} unless $Self->{index_file};

   if ($Args->check('open')) {
      $Self->open();
   } else {
      $Self->{index_open} = 0;
      $Self->{seq_open} = 0;
   }
  
   return $Self;
}

# --------------------------------- open ---------------------------------

=pod

=item open

Opens readonly access to existing index and sequence file.

B<Arguments>

C<index_file> (opt)

B<Returns>

1 if able to open file.

=cut

sub open {
   my $Self = shift;
   my $Args = shift;

   # check for required values
   return undef unless $Self->ensure('seq_file');

   # set optional values.
   $Self->safeCopy($Args, 'index_file') if defined $Args;
  
   # do the work
   my %index;
  
   if (tie(%index, 'GDBM_File', "$Self->{index_file}.db", O_READONLY, 0)) {
      $Self->{index} = \ %index;
      $Self->{index_open} = 1;

      $Self->{seq_fh} = new FileHandle "<$Self->{seq_file}";

      if (defined $Self->{seq_fh}) {
         $Self->{seq_open} = 1;
         return 1;
      } else {
         carp(sprintf("%s: could not open %s for reading because %s.\n",
                      "FastaIndex::open",
                      $Self->{seq_file},
                      $ERRNO));
         untie $Self->{index};
         return undef;
      }
   } else {
      undef $Self->{index};
      $Self->{index_open} = 0;
      carp(sprintf("%s: Unable to open '%s' because, %s.\n",
                   "FastaIndex::open",
                   $Self->{index_file},
                   $ERRNO
                  )
          );
      return undef;
   }
}

# -------------------------------- close ---------------------------------

=pod

=item close

Closes the connection between the object and the index and sequence files.

=cut

sub close {
   my $Self = shift;

   return undef unless $Self->ensure('index', 'seq_fh');

   $Self->{seq_fh}->close();
   undef $Self->{seq_fh};
   $Self->{seq_open} = 0;

   untie $Self->{index};
   undef $Self->{index};
   $Self->{index_open} = 0;  

   return 1;
}

# ----------------------------- getSequence ------------------------------

=pod

=item getSequence

Returns the sequence for an EST given its accession number.

B<Arguments>

C<accno> (req) accesion number of the EST.

C<strip> (opt) if set to true will strip out newlines.

C<lc>    (opt) if set then sequence is returned in lowercase.

C<uc>    (opt) if set then sequence is returned in uppercase.

uc takes precedence over lc.

B<Returns>

a C<CBIL::Util::TO> object with the attributes, C<hdr> and C<seq> containing the
obvious things if all goes well.

=cut

sub getBioSeq {
   my $Self = shift;
   my $Args = ref $_[0] ? shift : {@_};

   my $_a = $Self->getSequence($Args);

   return Bio::Seq->new( -display_id => $Args->{accno},
                         -desc       => $_a->{hdr},
                         -seq        => $_a->{seq},
                       )
}

sub getSequence {
   my $Self = shift;
   my $Args = ref $_[0] ? shift : {@_};

   my $Rv;

   if (not $Self->{seq_open}) {
      carp (sprintf("%s: sequence file is not open.\n",
                    "FastaIndex::getSequence")
           );
   } elsif (not $Self->{index}) {
      carp (sprintf("%s: index file is not open.\n",
                    "FastaIndex::getSequence")
           );
   } elsif (not defined $Args->{'accno'}) {
      carp (sprintf("%s: no accession number provided.\n",
                    "FastaIndex::getSequence")
           );
   } else {
      my $ndx = $Self->{index}->{$Args->{accno}};
      if (defined $ndx) {

         my $seq_fh = $Self->{seq_fh};

         if (seek($seq_fh, $ndx, 0)) {

            # get header.
            my $header = <$seq_fh>; chomp $header;

            # get sequence.
            my $seq;
            while (not $seq_fh->eof()) {
               my $chunk = <$seq_fh>;
               last if $chunk =~ /^>/;
               chomp $chunk if $Args->{strip};
               $seq .= $chunk;
            }

            # set case as required.
            # ..............................

            if ( $Args->{ uc } ) {
               $seq =~ uc($seq);
            } elsif ( $Args->{ lc } ) {
               $seq =~ lc($seq);
            }

            # return assembled object;
            # ..............................

            $Rv = CBIL::Util::A->new({ hdr => $header, seq => $seq });
         }

         # error handling
         else {
            carp (sprintf("%s: could not seek to %s for %s.\n",
                          "FastaIndex::getSequence",
                          $ndx,
                          $Args->{accno})
                 );
         }
      }

      # error handling
      else {
         carp (sprintf("%s: no index entry for %s.\n",
                       "FastaIndex::getSequence",
                       $Args->{accno})
              );
      }
   }

   return $Rv;
}


# ----------------------------- createIndex ------------------------------

=pod

=item createIndex

Creates an index for the object\'s sequence file.

B<Arguments>

C<get_key> (req)
reference to a subroutine which will extract the key from the 
defline.

C<echo>      (opt)
indicates whether indexed items are echoed as they are indexed.

C<index_file> (opt)
another chance to change the index filename.

B<Results>

1 if successful.

B<Examples>

Here\'s one example of an invocation using an anonymous get_key
subroutine and no echoing.  The get_key subroutine extracts the first
gbnnnn word from the defline.

$o_fastaIndex->createIndex(new CBIL::Util::A +{ echo => 0,
                                                get_key => sub { 
                                                   $_[0] =~ /(gb\d+)/; 
                                                   $1; 
                                                }
                                              })

=cut

sub createIndex {
   my $Self = shift;
   my $Args = shift;

   # check for required stuff
   return undef unless $Self->ensure('seq_file')
   and $Args->ensure('get_key');

   # set optional stuff
   $Self->safeCopy($Args, 'index_file');

   # get access to the index and sequence file.

   my %index;

   system "/bin/rm -f $Self->{seq_file}.pag";
   system "/bin/rm -f $Self->{seq_file}.dir";
   system "/bin/rm -f $Self->{seq_file}.db";

   system "touch $Self->{seq_file}.pag";
   system "touch $Self->{seq_file}.dir";

   if (tie(%index, 'GDBM_File', "$Self->{index_file}.db", O_RDWR | O_CREAT, 0644)) {
      $Self->{index} = \ %index;
      $Self->{index_open} = 1;

      # open the sequence file
      $Self->{seq_fh} = new FileHandle "<$Self->{seq_file}";
      if (defined $Self->{seq_fh}) {
         $Self->{seq_open} = 1;
      } else {                  # could not open sequence file.
         carp(sprintf("%s: could not open %s for reading because %s.\n",
                      "FastaIndex::createIndex",
                      $Self->{seq_file},
                      $ERRNO));
         untie $Self->{index};
         return undef;
      }
   } else {                     # could not open index.
      undef $Self->{index};
      $Self->{index_open} = 0;
      carp(sprintf("%s: Unable to tie index '%s' because, %s.\n",
                   "FastaIndex::createIndex",
                   $Self->{index_file},
                   $ERRNO
                  )
          );
      return undef;
   }
  
   # create the index.
   my $ndx;

   #print "EOF " . $Self->{seq_fh}->eof() . "\n";

   while (not $Self->{seq_fh}->eof()) {
      $ndx = tell $Self->{seq_fh};
      my $line = $Self->{seq_fh}->getline();
      #print ">>> $line";
      if ($line =~ /^>/) {
         my $key;
         if ($key = &{$Args->{get_key}}($line)) {
            $Self->{index}->{$key} = $ndx;
            print "$key, $ndx\n" if $Args->{echo};
         }
      }
   }

   $Self->close();
}

# ------------------------------- getCount -------------------------------

=pod

=item getCount

Returns the number of sequences in the file.  File must be indexed first.

=cut

sub getCount {
   my $Self = shift;
   return scalar(keys %{$Self->{index}});
}

# ----------------------------- gk_firstWord -----------------------------

=pod

=item gk_firstWord

returns the first word following the '>' from a defline.

=cut

sub gk_firstWord {
   $_[0] =~ /^>\s*(\S+)/;
   return $1;
}

# --------------------------- gk_alphaNumeric ----------------------------

=pod

=item gk_alphaNumeric

returns words of the form [a-zA-Z]+[0-9]+.

=cut

sub gk_alphaNumeric {
   $_[0] =~ /([a-zA-Z]+[0-9]+)/;
   return $1;
}

# ----------------------------------------------------------------------

=pod

=back

=cut

sub _randomString {
   my $Rv = join('',
                 map { chr(ord('a') + rand(26)) } (1 .. 1000)
                );
   return $Rv;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;

# ----------------------------------------------------------------------

=pod
=head1 Usage

Here is some sample code that creates and queries a database.

use CBIL::Util::TO;
use CBIL::Bio::FastaIndex;

my $o_FastaIndex = new FastaIndex(new CBIL::Util::A +{ seq_file => "test.seq" });

# create the index using a simple index selection subroutine.
$o_FastaIndex->createIndex( 
                           new CBIL::Util::A +{ echo => 0,
                                                get_key => \&gk_firstWord
                                              });

# open and query the file.
$o_FastaIndex->open();

while (1) {
   print ": ";
   my $accno = <STDIN>;
   chomp $accno;
   my $est = $o_FastaIndex->getSequence(new CBIL::Util::A +{ accno => $accno });
   $est->dump() if $est;
}

$o_FastaIndex->close();

=cut

