#!/usr/bin/perl

=pod
=head1 Name

C<FastaIndex> - a package which maintains and accesses an index into a
FASTA file of sequences.

=head1 Description

Uses a NDBM_File index into a FASTA format file of sequences.  Assumes
that the first word following the '>' is the accession number for the
sequence.

=head1 Methods

=over 4 

=cut

package CBIL::Bio::FastaIndex;

@ISA = qw ( TO );
@EXPORT = qw ( new );

use strict "vars";

use English;
use Carp;
use FileHandle;
use Fcntl;
use NDBM_File;

use CBIL::Util::TO;

# ----------------------------------------------------------------------
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
  my $args  = shift;

  return undef unless $args->ensure('seq_file');

  my $self = TO::e;

  bless $self, $class;
  
  $self->copy($args, 'seq_file', 'index_file');
  $self->{index_file} = $self->{seq_file} unless $self->{index_file};

  if ($args->check('open')) {
    $self->open();
  }
  else {
    $self->{index_open} = 0;
    $self->{seq_open} = 0;
  }
  
  return $self;
}

# ----------------------------------------------------------------------
=pod
=item open

Opens readonly access to existing index and sequence file.

B<Arguments>

C<index_file> (opt)

B<Returns>

1 if able to open file.

=cut

sub open {
  my $self = shift;
  my $args = shift;

  # check for required values
  return undef unless $self->ensure('seq_file');

  # set optional values.
  $self->safeCopy($args, 'index_file') if defined $args;
  
  # do the work
  my %index;
  
  if (tie(%index, NDBM_File, $self->{index_file}, O_READONLY, 0)) {
    $self->{index} = \ %index;
    $self->{index_open} = 1;

    $self->{seq_fh} = new FileHandle "<$self->{seq_file}";

    if (defined $self->{seq_fh}) {
      $self->{seq_open} = 1;
      return 1;
    }
    else {
      carp(sprintf("%s: could not open %s for reading because %s.\n",
		   "FastaIndex::open",
		   $self->{seq_file},
		   $ERRNO));
      untie $self->{index};
      return undef;
    }
  }
  else {
    undef $self->{index};
    $self->{index_open} = 0;
    carp(sprintf("%s: Unable to open '%s' because, %s.\n",
		 "FastaIndex::open",
		 $self->{index_file},
		 $ERRNO
		)
	);
    return undef;
  }
}

# ----------------------------------------------------------------------
=pod
=item close

Closes the connection between the object and the index and sequence files.

=cut

sub close {
  my $self = shift;

  return undef unless $self->ensure('index', 'seq_fh');

  $self->{seq_fh}->close();
  undef $self->{seq_fh};
  $self->{seq_open} = 0;

  untie $self->{index};
  undef $self->{index};
  $self->{index_open} = 0;  

  return 1;
}

# ----------------------------------------------------------------------
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

a C<TO> object with the attributes, C<hdr> and C<seq> containing the
obvious things if all goes well.

=cut

sub getSequence {
  my $self = shift;
  my $args = shift;

  if (not $self->{seq_open}) {
    carp (sprintf("%s: sequence file is not open.\n",
		 "FastaIndex::getSequence")
	  );
    return undef;
  }

  elsif (not $self->{index}) {
    carp (sprintf("%s: index file is not open.\n",
		 "FastaIndex::getSequence")
	  );
    return undef;
  }

  elsif (not $args->ensure('accno')) {
    carp (sprintf("%s: no accession number provided.\n",
		 "FastaIndex::getSequence")
	  );
    return undef;
  }

  else {
    my $ndx = $self->{index}->{$args->{accno}};
    if (defined $ndx) {
      if (seek($self->{seq_fh}, $ndx, 0)) {
	
	# get header.
	my $header = $self->{seq_fh}->getline();
	chomp $header;

	# get sequence.
	my $seq;
	READ_SEQ:
	while (not $self->{seq_fh}->eof()) {
	  my $chunk = $self->{seq_fh}->getline();;
	  chomp $chunk if $args->{strip};
	  last READ_SEQ if $chunk =~ /^>/;
	  $seq .= $chunk;
	}

	# set case as required.
	# ..............................

	if ( $args->{ uc } ) {
	    $seq =~ tr/a-z/A-Z/;
	}
	
	elsif ( $args->{ lc } ) {
	    $seq =~ tr/A-Z/a-z/;
	}
	

	# return assembled object;
	# ..............................

	return new CBIL::Util::A +{ hdr => $header, seq => $seq };

      }
      else {
	carp (sprintf("%s: could not seek to %s for %s.\n",
		     "FastaIndex::getSequence",
		     $ndx,
		     $args->{accno})
	     );
	return undef;
      }
    }
    else {
#      carp (sprintf("%s: no index entry for %s.\n",
#		   "FastaIndex::getSequence",
#		   $args->{accno})
#	   );
      return undef;
    }
  }
}

# ----------------------------------------------------------------------
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
  my $self = shift;
  my $args = shift;

  # check for required stuff
  return undef unless $self->ensure('seq_file')
    and $args->ensure('get_key');

  # set optional stuff
  $self->safeCopy($args, 'index_file');

  # get access to the index and sequence file.

  my %index;

  system "/bin/rm -f $self->{seq_file}.pag";
  system "/bin/rm -f $self->{seq_file}.dir";
  system "/bin/rm -f $self->{seq_file}.db";

  system "touch $self->{seq_file}.pag";
  system "touch $self->{seq_file}.dir";
  system "touch $self->{seq_file}.db";

  if (tie(%index, NDBM_File, $self->{index_file}, O_RDWR | O_CREAT, 0644)) {
    $self->{index} = \ %index;
    $self->{index_open} = 1;

    # open the sequence file
    $self->{seq_fh} = new FileHandle "<$self->{seq_file}";
    if (defined $self->{seq_fh}) {
      $self->{seq_open} = 1;
    }
    else {			# could not open sequence file.
      carp(sprintf("%s: could not open %s for reading because %s.\n",
		  "FastaIndex::createIndex",
		   $self->{seq_file},
		   $ERRNO));
      untie $self->{index};
      return undef;
    }
  }

  else {			# could not open index.
    undef $self->{index};
    $self->{index_open} = 0;
    carp(sprintf("%s: Unable to tie index '%s' because, %s.\n",
		 "FastaIndex::createIndex",
		 $self->{index_file},
		 $ERRNO
		)
	);
    return undef;
  }
  
  # create the index.
  my $ndx;

  #print "EOF " . $self->{seq_fh}->eof() . "\n";

  while (not $self->{seq_fh}->eof()) {
    $ndx = tell $self->{seq_fh};
    my $line = $self->{seq_fh}->getline();
    #print ">>> $line";
    if ($line =~ /^>/) {
      my $key;
      if ($key = &{$args->{get_key}}($line)) {
	$self->{index}->{$key} = $ndx;
	print "$key, $ndx\n" if $args->{echo};
      }
    }
  }

  $self->close();
}

=pod
=item getCount

Returns the number of sequences in the file.  File must be indexed first.

=cut

sub getCount {
  my $self = shift;
  return scalar(keys %{$self->{index}});
}

# ----------------------------------------------------------------------
=pod
=item gk_firstWord

returns the first word following the '>' from a defline.

=cut

sub gk_firstWord {
  $_[0] =~ /^>\s*(\S+)/;
  return $1;
}

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

