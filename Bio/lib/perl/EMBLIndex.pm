#!/usr/bin/perl

=pod
=head1 Name

C<EMBLIndex> - a package that maintains and accesses an index 
into an EBML-style database file.  Modeled very closely after
FastaIndex.pm.

=head1 Description

Uses an GDBM_File to index an EMBL database.  Assumes that the
EMBL database entries are delimited by a single-line delimiter
and also that the EMBL entries have a unique primary key.

=head1 Methods

=over 4

=cut

package CBIL::Bio::EMBLIndex;

@ISA = qw ( TO );
@EXPORT = qw ( new );

use strict vars;

use Carp;
use Fcntl;      # File access constants.
use FileHandle;
use GDBM_File;

=pod
=item new

Create a new C<EMBLIndex> object.

B<Arguments>

C<embl_file> (req)
EMBL database filename.

C<index_file> (opt)
GDBM index filename.  If not provided defaults to C<embl_file>.

C<is_entry_delim> (req)
Reference to a subroutine that accepts a line of the EMBL flat
file and returns true iff that line delimits the end of a 
database entry.

C<get_prim_key> (req)
Reference to a subroutine that accepts a line of the EMBL flat
file and returns the current entry's primary key if it appears
on that line.  Returns undef otherwise.

C<open> (opt)
Whether to open the index file for readonly access.

B<Returns>

An EMBLIndex object if successful, otherwise undef.

=cut

sub new {
    my ($class, $args) = @_;

    return undef unless ($args->ensure('embl_file') && 
			 $args->ensure('is_entry_delim') &&
			 $args->ensure('get_prim_key'));

    my $self = TO::e;
    bless $self, $class;

    $self->copy($args, 'embl_file', 'index_file', 'is_entry_delim', 'get_prim_key');
    $self->{index_file} = $self->{embl_file} unless $self->{index_file};

    $self->open() if ($args->check('open'));
    return $self;
}

=pod
=item open

Open an existing EMBL and index file for readonly access.

B<Arguments>

C<index_file> (opt)

B<Returns>

1 if the file(s) could be opened, undef otherwise.

=cut

sub open {
    my($self, $args) = @_;
    $self->safeCopy($args, 'index_file') if defined $args;

    my %index;
    if (tie(%index, GDBM_File, $self->{index_file}, O_READONLY, 0)) {
	$self->{index} = \%index;
	$self->{embl_fh} = new FileHandle "<$self->{embl_file}";

	if (defined $self->{embl_fh}) {
	    return 1;
	} else {
	    carp(sprintf("%s: could not open %s for reading because %s.\n",
			 "EMBLIndex::open", $self->{embl_file}, $!));
	    untie $self->{index};
	    undef $self->{index};
	    return undef;
	}
    }

    # tie of index file failed
    #
    else {
	untie $self->{index};
	undef $self->{index};
	carp(sprintf("%s: Unable to open index '%s' because, %s.\n",
		     "EMBLIndex::createIndex", $self->{index_file}, $!));
	return undef;
    }
}

=pod
=item close

Close any open index or database files.

=cut

sub close {
    my $self = shift;

    if ($self->check(embl_fh)) {
	$self->{embl_fh}->close();
	undef $self->{embl_fh};
    }

    if ($self->check('index')) {
	untie $self->{'index'};
	undef $self->{'index'};
    }

    return 1;
}

=pod
=item createIndex

Create an index for the EMBL database file.

B<Arguments>

C<get_prim_key> (opt)
Reference to a subroutine that accepts a line of the EMBL flat
file and returns the current entry's primary key if it appears
on that line.  Returns undef otherwise.

C<echo> (opt)
Whether to echo items as they are indexed.

B<Results>

1 if successful, undef otherwise.

=cut

sub createIndex {
    my($self, $args) = shift;

    my $idSub = (defined($args) && $args->{get_prim_key}) || $self->{get_prim_key};
    my $echo = defined($args) && $args->{echo};
    
    if (tie my %index, GDBM_File, $self->{index_file}, O_RDWR|O_CREAT|O_TRUNC, 0644) {
	$self->{index} = \%index;

	# Open EMBL file
	#
	if (!defined($self->{embl_fh} = new FileHandle "<$self->{embl_file}")) {
	    carp(sprintf("%s: unable to read from %s because %s.\n",
			 "EMBLIndex::createIndex", $self->{embl_file}, $!));
	    untie $self->{index};
	    $self->{index} = undef;
	    return undef;
	}
    }

    # tie of index file failed
    #
    else {
	untie $self->{index};
	undef $self->{index};
	carp(sprintf("%s: Unable to open index '%s' because, %s.\n",
		     "EMBLIndex::createIndex", $self->{index_file}, $!));
	return undef;
    }

    my $posn;
    my $markPosn = 1;

    my $tKey;
    my $key;
    my $firstLine;

    # scan the EMBL database, creating the index as we go
    #
    while (not $self->{embl_fh}->eof()) {
	if ($markPosn) {
	    $posn = tell $self->{embl_fh};
	    $markPosn = 0;
	}

	my $line = $self->{embl_fh}->getline();

	$firstLine = $line if (not defined($firstLine));

	if (defined($tKey = &{$idSub}($line))) {
	    $key = $tKey;
	} elsif (&{$self->{is_entry_delim}}($line)) {

	    # Time to write the position of the entry and move on.
	    # Make sure we have a unique key for it.
	    #
	    if (!defined($key)) {
		carp(sprintf("%s: Unable to read primary key for the entry with the first line:\n%s\n",
			     "EMBLIndex::createIndex", $firstLine));
		return undef;
	    }

	    # Check uniqueness
	    #
	    if (defined($self->{index}->{$key})) {
		carp(sprintf("%s: Primary key %s is not unique.\n",
			     "EMBLIndex::createIndex", $key));
		return undef;
	    }

	    # Store index of the beginning of the entry.
            #
	    $self->{index}->{$key} = $posn;
	    print "$key -> $posn\n" if ($args->{echo});

	    $markPosn = 1;
	    $firstLine = undef;
	    $key = undef;

	}
    }
    return 1;
}

=pod
=item getEntry

Return an entry from the EMBL database given its primary key value.

B<Arguments>

C<key> (req) Primary key of the desired entry.

C<silent_notfound> (opt) If true does not carp if the entry is not found.

B<Returns>

A C<TO> object with the attributes C<key> and C<entry> 
or undef should things go awry (including the case where
the desired entry is not in the database.)

=cut

sub getEntry {
    my ($self, $args) = @_;

    if (not $self->{index}) {
	carp (sprintf("%s: index file is not open.\n",
		      "EMBLIndex::getEntry"));
	return undef;
    } elsif (not $self->{embl_fh}) {
	carp (sprintf("%s: EMBL database file is not open.\n",
		      "EMBLIndex::getEntry"));
	return undef;
    } elsif (!defined($args) || !($args->check(key))) {
	carp (sprintf("%s: No key specified.\n", "EMBLIndex::getEntry"));
	return undef;
    } else {

	# All OK, look up the desired entry.
	#
	my $ndx = $self->{index}->{$args->{key}};

	if (defined($ndx)) {
	    my $entry;

	    if (seek($self->{embl_fh}, $ndx, 0)) {
		while (not $self->{embl_fh}->eof()) {
		    my $line = $self->{embl_fh}->getline();
		    last if (&{$self->{is_entry_delim}}($line));
		    $entry .= $line;
		}
		return new CBIL::Util::A +{key => $args->{key}, entry => $entry };
	    } 
	    # seek failed
	    #
	    else {
		carp (sprintf("%s: could not seek to %s for %s.\n",
			      "EMBLIndex::getEntry", $ndx, $args->{key}));
		return undef;
	    }
	}

	# No such entry
	#
	else {
	    if (not $args->{silent_notfound}) {
		carp (sprintf("%s: could not seek to %s for %s.\n",
			      "EMBLIndex::getEntry", $ndx, $args->{key}));
	    }
	    return undef;
	}
	
    }
}
