#!/usr/local/bin/perl -w

package BLAST2;

# Module that parses (and creates an object that 
# stores the results of parsing) a BLAST2 output file.
# Uses SBJCT.pm and HSP.pm to represent the subjects
# and HSPs, respectively, in the BLAST output.
#
# Jonathan Crabtree 9/19/1998
#

use IO::File;
use CBIL::Bio::BLAST2::SBJCT;

# Generic function to print the contents of a hash ref.
#
sub printHash {
    my($href,			# Reference to the hash to be printed
       $truncate		# Number of characters after which to
				# truncate the display of a key's value.
       ) = @_;
    my $key;
    foreach $key (keys %$href) {
	print "$key = ";
	if (defined($truncate) && (length($$href{$key}) > $truncate)) {
	  print substr($$href{$key}, 0, $truncate), "\n";
        } else {
          print $$href{$key}, "\n";
        }
    }
}

# Remove extra whitespace from a string.  Trailing whitespace is
# removed and any string of blanks longer than 1 is replaced by
# a single blank (space).
#
sub removeXtraWS {
    my ($str) = @_;
    $str =~ s/\s*$//; $str =~ s/^\s*//; 
    $str =~ s/\s+/ /g;
    return $str;
}

# This is the primary method provided by this module.  It
# parses a BLAST output file and creates an object (hash)
# containing the parse results.
#
sub parseBLAST2output {
    my ($blast_cmd		# Command to run to generate some BLAST output.
	) = @_;

    my $blast_fh = new IO::File $blast_cmd;
    my %bo = ();

    if (not $blast_fh) {
	die("Unable to execute BLAST command $blast_cmd");
    }

    # Record BLAST executable name (BLASTN, TBLASTN, BLASTP, etc.)
    # and version number from the top of the file.
    #
    while (defined($line = <$blast_fh>)) {
	if ($line =~ /^(\S?BLAST\S)\s(\S+)\s/) { 
	    $bo{'program'} = $1; $bo{'version'} = $2; last; 
	}
    }

    # Read query description line, including the length of the
    # query sequence.
    #
  QUERY:
    while (defined($line = <$blast_fh>)) {
	if ($line =~ /^Query=(.*)$/) {
	    chomp($bo{'query'} = $1);

	    while (1) {
		if ($line =~ /\(([\d,]+) letters\)/) {
		    $bo{'query_size'} = $1;
		    $bo{'query_size'} =~ s/,//g;
		    last QUERY;
		}
		if ($line =~ /FATAL/) {
		    $blast_fh->close;
		    die "BLAST result file contained fatal errors.\n";
		}
		last if (!defined($line = <$blast_fh>));
		chomp($bo{'query'} .= $line);
	    }			       
	}			      
    }
    $bo{'query'} = &removeXtraWS($bo{'query'});

    # Get the database name and description
    #
    while (defined($line = <$blast_fh>)) {
	if ($line =~ /^Database:\s+(.*)$/) {
	    $bo{'db'} = $1;
	    last;
	}      
    }

    # Read the rest of the database name and its size
    #
    while (defined($line = <$blast_fh>)) {
	if ($line =~ /^\s+([\d,]+) sequences; ([\d,]+) total letters/) {
	    $bo{'db_seqs'} = $1; 
	    $bo{'db_letters'} = $2; 
	    $bo{'db_seqs'} =~ s/,//g;
	    $bo{'db_letters'} =~ s/,//g;
	    last;
	}
	chomp($bo{'db'} .= $line);
    }
    $bo{'db'} = &removeXtraWS($bo{'db'});

    # Skip histogram/subject list and find the first subject report
    #
    while (defined($line = <$blast_fh>)) {
	last if ($line =~ /^>/);
    }

    $bo{'n_subjects'} = 0;
    my @sbjct_list;

    $line = 'done' if not(defined($line));

    # Outer loop loops over subject reports
    #
  SUBJECTS:
    while ($line =~ /^>(.*)$/) {
	my ($sbjct_descr, $sbjct_length, $sbjct_n_hsps);
	$sbjct_descr = $1;

	#print STDERR "SUBJECT ", $sbjct_descr, "\n";

	while (defined($line = <$blast_fh>)) {
	    if ($line =~ /Length = ([\d,]+)/) {
		$sbjct_length = $1; 
		$sbjct_length =~ s/,//g;
		last;
	    }
	    chomp($sbjct_descr .= $line);
	}

	# Skip blank line.
	$line = <$blast_fh>;
	$line = <$blast_fh>;

	$sbjct_n_hsps = 0;
        my @hsp_list;
    
	# Inner loop reads HSPs
	#
      HSPS:
	while (1) {
	    ++$sbjct_n_hsps;
	    my ($score, $bits, $p, $np, $expect, $ids, $pos, $length, $strand,
                $query, $match, $sbjct, $q_start, $q_end, $s_start, $s_end);

	    while(1) {
		if ($line =~ /Strand HSPs:/) {
		    $line = <$blast_fh>; $line = <$blast_fh>; next;
		}
		last if ($line =~ /^\s*$/);
		$score = $1 if ($line =~ /Score = (\d+)\s/);
		$bits = $1 if ($line =~ /Score = \d+\s\((.+) bits\)/);
		if ($line =~ /P = ([\d\.\-\+e]+)/) {$p = $1; $np = 1;}
		$expect = $1 if ($line =~ /Expect = ([\d\.\-+e]+)/);
		if ($line =~ /Sum P\((\d+)\) = ([\d\.\-+e]+)/) {
		    $np = $1; $p = $2;
		}
		if ($line =~ /Identities = (\d+)\/(\d+)\s/) {
		    $ids = $1; $length = $2;
		}
		$pos = $1 if ($line =~ /Positives = (\d+)\/\d+\s/);
		$strand = $2 if ($line =~ /(Strand|Frame) = (\S+ \/ \S+|[\+\-]\d)/);

		last if (!defined($line = <$blast_fh>));
	    }			 

	    # Read set of Query/Match/Sbjct triplets making up the HSP,
	    # collapsing everything into three strings.  Also records
	    # the query and subject sequence coordinates.
	    #
	    my ($prefix, $seq_length);
	    $line = <$blast_fh>; # First Query line

	    while(1) {
		# Read Query/Match/Sbjct triplet

		last SUBJECTS if ($line =~ /^WARNING:/);

		if ($line =~ /^(Query:\s+(\d+) )(\S+) (\d+)$/) {   # Query
		    $q_start = $2 if (!defined($query));
		    $prefix = length($1); 
		    $seq_length = length($3);
		    $query .= $3; $q_end = $4;
		} else {
		    die "Error reading Query line: $line\n";
		}
	  
		chomp($line = <$blast_fh>);  # Match
		$match .= substr($line, $prefix, $prefix + $seq_length);
	  
		last if (!defined($line = <$blast_fh>));  # Sbjct

		if ($line =~ /^Sbjct:\s+(\d+) (\S+) (\d+)$/) {
		    $s_start = $1 if (!defined($sbjct));
		    $sbjct .= $2; $s_end = $3;
		} else {
		    die "Error reading Sbjct line: $line\n";
		}
  
		$line = <$blast_fh>;  # Blank line(s)
		while ($line =~ /^\s*$/) {
		    last if (!defined($line = <$blast_fh>));
		}
		last if ($line =~ /(Strand HSPs:|^ Score|^Parameters|>)/); # Another HSP
	    }

	    # Error check on the lengths of the parsed sequences.
	    #
	    if ((length($sbjct) != length($match)) ||
		(length($match) != length($query))) {
		print "\n";
		print "'", $sbjct, "'\n";
		print "'", $match, "'\n";
		    print "'", $query, "'\n";
		die ("Error reading HSP for $sbjct_descr - subject, match " .
		     "and query lines are not all the same length.");
	    }

	    $hsp = HSP::new($score, $bits, $expect, $p, $np, $ids, $pos, 
			    $strand, $length, $q_start, $q_end, $s_start,
			    $s_end, $query, $match, $sbjct, $prefix);

	    push(@hsp_list, $hsp);
	    last HSPS if ($line =~ /(^>|Parameters)/); # End of subject
	} # HSPS

	$subject = SBJCT::new($sbjct_descr, $sbjct_length, 
			      $sbjct_n_hsps, \@hsp_list);

	push(@sbjct_list, $subject);
        $bo{'n_subjects'}++;

	last SUBJECTS if ($line =~ /Parameters/); # End of subjects

    } # SUBJECTS

#    if (!defined(@sbjct_list)) {
#	print STDERR "BLAST2: No subject list defined for $blast_cmd\n";
#    }

    $bo{'subjects'} = \@sbjct_list;
    $blast_fh->close;
    bless($ref = \%bo);
    return $ref;
}

# Simple accessor methods
#
sub getNumSbjcts {
    my($this) = @_;
    return $$this{'n_subjects'};
}

sub getSbjct {
    my($this, $snum) = @_;
    return ${$$this{'subjects'}}[$snum];
}

sub toString {
    my($self, $format, $spans, $spanDelim) = @_;
    $format = 'blast' if (not(defined($format)));

    my $result = "";
    
    if ($format =~ /^blast$/i) {
	my $nSubjects = $self->getNumSbjcts();
	foreach my $s (0 .. ($nSubjects-1)) {
	    my $sj = $self->getSbjct($s);
	    $result .= $sj->toString($format, $spans, $spanDelim), "\n";
	}
	return $result;
    } elsif ($format =~ //i) {

	my ($queryId) = ($self->{'query'} =~ /^(.+)\([\d,]+ letters\)/);
	my $nSubjects = $self->getNumSbjcts();

	$result .= ">$queryId (" . $nSubjects . " subjects)\n";

	foreach my $s (0 .. ($nSubjects-1)) {
	    my $sj = $self->getSbjct($s);
	    $result .= $sj->toString($format, $spans, $spanDelim), "\n";
	}
	return $result;
    } else {
	return undef;
    }
}

1;

