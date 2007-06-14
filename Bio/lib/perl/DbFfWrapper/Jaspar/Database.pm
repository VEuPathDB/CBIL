
package CBIL::Bio::DbFfWrapper::Jaspar::Database;

=pod

=head1 Purpose

Parses a JASPAR download instance into an internal format suitable for
further processing.

=head1 Details

JASPAR contains two directories; SITES and MatrixDir.

MatrixDir contains files of the form MAddd.pfm which are contain the
freqency counts in rows by letter and the file matrix_list.txt which
contains information about each factor for each matrix.

SITES contains files of the form MAdddd.sites which contain the site
string information for each PWM and a version of the PWM.  Not every
PWM has a sites file so these are secondary.

This is a fairly simple structure so we just pile all of the
subpackages in this file.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;
use vars qw( @ISA );

use CBIL::Util::Files;

# ========================================================================
# ------------------------------- Methods --------------------------------
# ========================================================================

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;
   my $Args  = ref $_[0] ? shift : {@_};

   my $Self = bless {}, $Class;

   $Self->init($Args);

   return $Self;
}

# --------------------------------- init ---------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->setMatrices             ( $Args->{Matrices            } );
   $Self->setFactors              ( $Args->{Factors             } );
   $Self->setSites                ( $Args->{Sites               } );

   return $Self;
}

# ------------------------------ accessors -------------------------------

sub getMatrices             { $_[0]->{'Matrices'          } }
sub setMatrices             { $_[0]->{'Matrices'          } = $_[1]; $_[0] }

sub getFactors              { $_[0]->{'Factors'           } }
sub setFactors              { $_[0]->{'Factors'           } = $_[1]; $_[0] }

sub getSites                { $_[0]->{'Sites'             } }
sub setSites                { $_[0]->{'Sites'             } = $_[1]; $_[0] }

# --------------------------- loadFromDownload ---------------------------

=pod

=head1 Loading Data from Files

=cut

sub loadFromDownload {
   my $Self = shift;
   my $Path = shift;

   $Self->setMatrices({});      # ::Matrix by accession
   $Self->setFactors ({});      # ::Factor by accession
   $Self->setSites   ({});      # [ ::Site ] by accession

   $Self->_loadFactorsAndPwms($Path);
   $Self->_loadSites($Path);

   return $Self;
}

# ------------------------- _loadFactorsAndPwms --------------------------

=pod

=head1 Loading Factors and PWMs



=cut

sub _loadFactorsAndPwms {
   my $Self = shift;
   my $Path = shift;

   my $base_p = "$Path/MatrixDir";

   my @places;
   if (-e "$base_p/JASPAR_CORE") {
      @places = ( 'JASPAR_CORE', 'JASPAR_FAM' );
   }

   else {
      @places = '';
   }

   foreach my $place (@places) {

      my $_f   = "$Path/MatrixDir/$place/matrix_list.txt";
      my $_fh  = CBIL::Util::Files::SmartOpenForRead($_f);

      my @_factors;

      while (<$_fh>) {
         chomp;
         my $_factor = CBIL::Bio::DbFfWrapper::Jaspar::Factor->new()->initFromString($_);
         push(@_factors, $_factor);
         $Self->getFactors()->{$_factor->getAccession()} = $_factor;
      }
      $_fh->close();

      foreach my $_factor (@_factors) {
         my $_pwm = CBIL::Bio::DbFfWrapper::Jaspar::Matrix
         ->new( Accession => $_factor->getAccession())
         ->initFromFile($Path. "/MatrixDir/$place/". $_factor->getAccession(). '.pfm');

         $Self->getMatrices()->{$_pwm->getAccession()} = $_pwm;
      }
   }

   return $Self;
}

# ------------------------------ _loadSites ------------------------------

sub _loadSites {
   my $Self = shift;
   my $Path = shift;

   my @_factors = values %{$Self->getFactors()};
   foreach my $_factor (@_factors) {
      my $acc = $_factor->getAccession();
      my $_f = "$Path/SITES/$acc.sites";
      if (-e $_f) {
         my $_fh = CBIL::Util::Files::SmartOpenForRead($_f);
         while (my $def = <$_fh>) {
            last unless $def =~ /^>/;
            my $site = <$_fh>;
            my $_site = CBIL::Bio::DbFfWrapper::Jaspar::Site->new
            ( Accession => $_factor->getAccession(),
            )->initFromStrings($def, $site);
            push(@{$Self->getSites()->{$_site->getMatrixAccession()}}, $_site);
         }
         $_fh->close();
      }
   }

   return $Self;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;

# ########################################################################
# ---------------- CBIL::Bio::DbFfWrapper::Jaspar::Factor ----------------
# ########################################################################

package CBIL::Bio::DbFfWrapper::Jaspar::Factor;

=pod

=head1 Purpose

Internal representation of a JASPAR factor.

=cut

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;
   my $Args  = ref $_[0] ? shift : {@_};

   my $Self = bless {}, $Class;

   $Self->init($Args);

   return $Self;
}

# --------------------------------- init ---------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->setAccession            ( $Args->{Accession           } );
   $Self->setTotalInformation     ( $Args->{TotalInformation    } );
   $Self->setName                 ( $Args->{Name                } );
   $Self->setClass                ( $Args->{Class               } );
   $Self->setXdbAccession         ( $Args->{XdbAccession        } );
   $Self->setMedline              ( $Args->{Medline             } );
   $Self->setSeqDb                ( $Args->{SeqDb               } );
   $Self->setSpecies              ( $Args->{Species             } );
   $Self->setSysgroup             ( $Args->{Sysgroup            } );
   $Self->setType                 ( $Args->{Type                } );

   return $Self;
}

# ------------------------------ accessors -------------------------------

sub getAccession            { $_[0]->{'Accession'         } }
sub setAccession            { $_[0]->{'Accession'         } = $_[1]; $_[0] }

sub getTotalInformation     { $_[0]->{'TotalInformation'  } }
sub setTotalInformation     { $_[0]->{'TotalInformation'  } = $_[1]; $_[0] }

sub getName                 { $_[0]->{'Name'              } }
sub setName                 { $_[0]->{'Name'              } = $_[1]; $_[0] }

sub getClass                { $_[0]->{'Class'             } }
sub setClass                { $_[0]->{'Class'             } = $_[1]; $_[0] }

sub getXdbAccession         { $_[0]->{'XdbAccession'      } }
sub setXdbAccession         { $_[0]->{'XdbAccession'      } = $_[1]; $_[0] }

sub getMedline              { $_[0]->{'Medline'           } }
sub setMedline              { $_[0]->{'Medline'           } = $_[1]; $_[0] }

sub getSeqDb                { $_[0]->{'SeqDb'             } }
sub setSeqDb                { $_[0]->{'SeqDb'             } = $_[1]; $_[0] }

sub getSpecies              { $_[0]->{'Species'           } }
sub setSpecies              { $_[0]->{'Species'           } = $_[1]; $_[0] }

sub getSysgroup             { $_[0]->{'Sysgroup'          } }
sub setSysgroup             { $_[0]->{'Sysgroup'          } = $_[1]; $_[0] }

sub getType                 { $_[0]->{'Type'              } }
sub setType                 { $_[0]->{'Type'              } = $_[1]; $_[0] }

# ---------------------------- initFromString ----------------------------

sub initFromString {
   my $Self   = shift;
   my $String = shift;

   chomp $String;

   my @parts =  split /\s*;\s*/;
   my ($mac, $info, $name, $class) = split /\t/, $parts[0];
   my %atts = map { /(\S+) "(.+)"/; (ucfirst($1) => $2) } @parts;

   $Self->setAccession($mac);
   $Self->setTotalInformation($info);
   $Self->setName($name);
   $Self->setClass($class);

   $Self->setXdbAccession($atts{'Acc'});
   $Self->setMedline     ($atts{'Medline'});
   $Self->setSeqDb       ($atts{'Seqdb'});
   $Self->setSpecies     ($atts{'Species'});
   $Self->setSysgroup    ($atts{'Sysgroup'});
   $Self->setType        ($atts{'Type'});

   return $Self;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;

# ########################################################################
# ---------------- CBIL::Bio::DbFfWrapper::Jaspar::Matrix ----------------
# ########################################################################

package CBIL::Bio::DbFfWrapper::Jaspar::Matrix;

=pod

=head1 Purpose

Internal representation of a JASPAR matrix

=cut

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;
   my $Args  = ref $_[0] ? shift : {@_};

   my $Self = bless {}, $Class;

   $Self->init($Args);

   return $Self;
}

# --------------------------------- init ---------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->setAccession            ( $Args->{Accession           } );
   $Self->setObservations         ( $Args->{Observations        } );

   return $Self;
}

# ------------------------------ accessors -------------------------------

sub getAccession            { $_[0]->{'Accession'         } }
sub setAccession            { $_[0]->{'Accession'         } = $_[1]; $_[0] }

sub getObservations         { $_[0]->{'Observations'      } }
sub setObservations         { $_[0]->{'Observations'      } = $_[1]; $_[0] }

# ----------------------------- initFromFile -----------------------------

sub initFromFile {
   my $Self = shift;
   my $File = shift;

   my $_fh = CBIL::Util::Files::SmartOpenForRead($File);

   my @matrix;
   for (my $b = 0; $b < 4; $b++) {
      my $obs = <$_fh>;
      chomp $obs; $obs =~ s/^\s+//;
      my @obs = split /\s+/, $obs;
      for (my $i = 0; $i < @obs; $i++) {
         $matrix[$i]->[$b] = $obs[$i];
      }
   }
   $_fh->close();

   $Self->setObservations(\@matrix);

   return $Self;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;

# ########################################################################
# ----------------- CBIL::Bio::DbFfWrapper::Jaspar::Site -----------------
# ########################################################################

package CBIL::Bio::DbFfWrapper::Jaspar::Site;

=pod

=head1 Purpose

Internal representation of a JASPAR site.

=cut

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;
   my $Args  = ref $_[0] ? shift : {@_};

   my $Self = bless {}, $Class;

   $Self->init($Args);

   return $Self;
}

# --------------------------------- init ---------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->setAccession            ( $Args->{Accession           } );
   $Self->setMatrixAccession      ( $Args->{MatrixAccession     } );
   $Self->setName                 ( $Args->{Name                } );
   $Self->setSite                 ( $Args->{Site                } );

   return $Self;
}

# ------------------------------ accessors -------------------------------

sub getAccession            { $_[0]->{'Accession'         } }
sub setAccession            { $_[0]->{'Accession'         } = $_[1]; $_[0] }

sub getMatrixAccession      { $_[0]->{'MatrixAccession'   } }
sub setMatrixAccession      { $_[0]->{'MatrixAccession'   } = $_[1]; $_[0] }

sub getName                 { $_[0]->{'Name'              } }
sub setName                 { $_[0]->{'Name'              } = $_[1]; $_[0] }

sub getSite                 { $_[0]->{'Site'              } }
sub setSite                 { $_[0]->{'Site'              } = $_[1]; $_[0] }

# ---------------------------- initFromString ----------------------------

sub initFromStrings {
   my $Self  = shift;
   my $Title = shift;
   my $Site  = shift;

   $Title =~ s/^>//; chomp $Title;
   chomp $Site;
   my ($acc, $name, $ordinal) = split /\t/, $Title;

   $Self->setAccession("$acc-$ordinal");
   $Self->setMatrixAccession($acc);
   $Self->setName($name);
   $Self->setSite($Site);

   return $Self;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;
