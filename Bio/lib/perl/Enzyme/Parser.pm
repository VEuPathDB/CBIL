
package CBIL::Bio::Enzyme::Parser;

use strict 'vars';

use FileHandle;

use CBIL::Bio::Enzyme::Parser::Store;

use CBIL::Bio::Enzyme::Enzyme;
use CBIL::Bio::Enzyme::Class;
use CBIL::Bio::Enzyme::EcNumber;
use CBIL::Bio::Enzyme::Reaction;
use CBIL::Bio::Enzyme::DbRef;

use CBIL::Util::Disp;

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

   $M->setErrMsg    ($A->{ErrMsg}    || undef);
   $M->setInPath    ($A->{InPath}    || '.');
   $M->setFileCaches($A->{FileCaches} || {} );

   return $M
}

# ----------------------------------------------------------------------

#sub getQ { $_[0]->{Q} }
#sub setQ { $_[0]->{Q} = $_[1]; $_[0] }

sub getErrMsg     { $_[0]->{ErrMsg} }
sub setErrMsg     { $_[0]->{ErrMsg} = $_[1]; $_[0] }
sub clrErrMsg     { $_[0]->{ErrMsg} = undef; $_[0] }

sub getInPath     { $_[0]->{InPath} }
sub setInPath     { $_[0]->{InPath} = $_[1]; $_[0] }

sub getLoaded     { $_[0]->{Loaded} }
sub setLoaded     { $_[0]->{Loaded} = $_[1]; $_[0] }

sub getParsed     { $_[0]->{Parsed} }
sub setParsed     { $_[0]->{Parsed} = $_[1]; $_[0] }

sub getAssembled     { $_[0]->{Assembled} }
sub setAssembled     { $_[0]->{Assembled} = $_[1]; $_[0] }

sub getFileCaches { $_[0]->{FileCaches} }
sub setFileCaches { $_[0]->{FileCaches} = $_[1]; $_[0] }

sub getFileCache  { $_[0]->{FileCaches}->{$_[1]} }
sub setFileCache  { $_[0]->{FileCaches}->{$_[1]} = $_[2]; $_[0]}

# ----------------------------------------------------------------------

sub loadAllFiles {
   my $M = shift;

   $M->clrErrMsg;

   $M->setFileCache('enzymes',$M->loadFile('enzyme.dat'));
   $M->setFileCache('classes',$M->loadClasses('enzclass.txt'));

	 $M->setLoaded(1);
	 $M->setParsed(0);
	 $M->setAssembled(0);

   return $M
}

# ----------------------------------------------------------------------

sub loadFile {
  my $M = shift;
  my $F = shift;

  # prepare to read file
  # ........................................
  # get name,
  # get handle,
  # make sure handle's ok
  # save and adjust record separator

  my $f  = join('/', $M->getInPath, "$F");
  my $fh = FileHandle->new("<$f");

  unless ($fh) {
    $M->setErrMsg(join("\t",'Unable to open loadFile',$f,$!));
    print  STDERR $M->getErrMsg;
    return undef;
  }

  my $saved_input_record_separator = $/;
  $/ = "//\n";

  # read file
  # ........................................
  # read version information.
  # read entries.

  # file store
  my $store = CBIL::Bio::Enzyme::Parser::Store->new();

  # cheap hack alert!
  $store->setParseMethod('loadTableEnzymeEntry');

  $store->setVersion([split("\n",<$fh>)]);
  while ( <$fh> ) {
    $store->addRecord([split("\n",$_)]);
  }
  $fh->close;
  $/ = $saved_input_record_separator;

  # return value;
  $store
}

# ----------------------------------------------------------------------

sub loadClasses {
   my $M = shift;
   my $F = shift;

   my $fh = FileHandle->new($M->getInPath.'/'.$F);
   unless ($fh) {
      $M->setErrMsg(join("\t", 'Unable to open class file', $F, $!));
      print STDERR $M->getErrMsg."\n";
      return undef;
   }
	 my @lines = <$fh>;
	 $fh->close;

   my $store = CBIL::Bio::Enzyme::Parser::Store
   ->new({ ParseMethod => 'loadTableEnzclassEntry'});

   my @version;
	 for (my $i = 0; $i < @lines; $i++) {
      chomp $lines[$i];

      # an EC class
      if ($lines[$i] =~ /^\d+\./) {
				my @rows = ($lines[$i]);
				if ($lines[$i] !~ /\.\s*$/) {
					$i++;
					push(@rows,$lines[$i]);
				}
				$store->addRecord(\@rows);
      }
      else {
         push(@version,$lines[$i]);
      }
   }

   $store->setVersion(\@version);

   return $store
}

# ----------------------------------------------------------------------

sub parseAllFiles {
  my $M = shift;

	$M->loadAllFiles unless $M->getLoaded;

  foreach my $file (sort keys %{$M->getFileCaches}) {
     my $good_n = 0;
     my $bad_n  = 0;
     my $store = $M->getFileCache($file);
     my $load_method = $store->getParseMethod;
     if ($load_method) {
        foreach my $record (@{$store->getRecords}) {
           if (my $entry = $M->$load_method($record)) {
              $good_n++;
              $store->setEntry($entry);
           }
           else {
              $bad_n++;
           }
        } # eo entry scan
     }
     else {
        $M->setErrMsg("no load method for $file");
        print STDERR $M->getErrMsg."\n";
     }
  } # eo file scan

	$M->setParsed(1);
	$M->setAssembled(0);

  # return value
  undef
}

sub loadTableEnzymeEntry {
  my $M = shift;
  my $E = shift;

  return CBIL::Bio::Enzyme::Enzyme->new($E)
}

sub loadTableEnzclassEntry {
  my $M = shift;
  my $E = shift;

  return CBIL::Bio::Enzyme::Class->new($E)
}

# ----------------------------------------------------------------------

sub assemble {
	my $M = shift;

	$M->parseAllFiles unless $M->getParsed;

	# link in classes
	my $class_entries = $M->getFileCache('classes')->getEntries;
	foreach my $class (values %$class_entries) {
		$M->linkClass($class);
	}
	#CBIL::Util::Disp::Display($class_entries->{'6.5.1.-'}, 'class 6.5.1.-' );

	# link in enzymes
	my $enzyme_entries = $M->getFileCache('enzymes')->getEntries;
	foreach my $enzyme (values %$enzyme_entries) {
		$M->linkClass($enzyme);
	}

	#CBIL::Util::Disp::Display($enzyme_entries->{'6.5.1.3'}, 'enzyme 6.5.1.3');

	$M->setAssembled(1);
}

sub linkClass {
	my $M = shift;
	my $C = shift;

	# no parent for top of the heap
	if ($C->getNumber->getDepth < 1) {
		;
	}

	# add it in.
	else {
		my $parent_path = $C->getId;
		if ($parent_path =~ /n\d+$/) {
			$parent_path =~ s/n\d+$/-/;
		}
        elsif ($parent_path =~ /\d+$/) {
            $parent_path =~ s/\d+$/-/;
        }
		else {
			$parent_path =~ s/\d+\.-/-.-/;
		}
		my $parent_class = $M->getFileCache('classes')->getEntries->{$parent_path};
		if (defined $parent_class) {
			$C->setParent($parent_class);
		}
		else {
			print join("\t", ref $M, 'WARN',
								 'no parent found; making a fake parent', $C->getId,
								), "\n";
			my $fake_parent = CBIL::Bio::Enzyme::Class
			->new({ Id          => $parent_path,
							Number      => CBIL::Bio::Enzyme::EcNumber->new($parent_path),
							Description => 'MISSING: INFERRED FROM CHILD',
						});
			$M->getFileCache('classes')->getEntries->{$parent_path} = $fake_parent;
			$M->linkClass($fake_parent);
			$C->setParent($fake_parent);
		}
	}
}


1;

# ======================================================================

__END__

$| = 1;

use Disp;
my $p = CBIL::Bio::Enzyme::Parser
->new({ InPath => shift @ARGV,
      });
$p->loadAllFiles;
$p->parseAllFiles;
