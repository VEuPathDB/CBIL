#/usr/bin/perl

package CBIL::Util::EasyCsp;

=pod

=head1 CBIL::Util::EasyCsp

This package helps process command line parameters including defining
error checks and providing help to the user.

See CBIL::Util::EasyCsp::Decl for a description of a single
declaration.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict 'vars';

use Carp;

use FileHandle;
require Getopt::Long;

use CBIL::Util::EasyCsp::Decl;

# ========================================================================
# ---------------------------- Object Methods ----------------------------
# ========================================================================

our $Global_Desc;
our $Global_Values;
our $Global_Usage;

our $AUTOLOAD;

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;
   my $Desc  = shift;
   my $Usage = shift;

   my $Self  = bless {}, $Class;

   $Global_Values = DoItAll($Desc, $Usage);

   return $Global_Values ? $Self : undef;
}

# ------------------------------- AUTOLOAD -------------------------------

sub AUTOLOAD {
   my $Self = shift;

   my $Rv;

   my $type = ref ($Self) or croak "$Self is not an object";

   my $name = $AUTOLOAD;
   $name =~ s/.*://;

   if (my $_desc = $Global_Desc->{$name}) {
      $Rv = $Global_Values->{$name};
   }
   else {
      croak "'$name' is not a legal command line option.";
   }

   return $Rv;
}

# ======================================================================
# --------------------------- TYPE NAMES -------------------------------
# ======================================================================

#$CBIL::Util::EasyCsp::String  = 'string';
#$CBIL::Util::EasyCsp::Float   = 'float';
#$CBIL::Util::EasyCsp::Int     = 'int';
#$CBIL::Util::EasyCsp::Boolean = 'boolean';

our $String  = 'string';
our $Float   = 'float';
our $Int     = 'int';
our $Boolean = 'boolean';

sub StringType  { $String  }
sub FloatType   { $Float   }
sub IntType     { $Int     }
sub BooleanType { $Boolean }

# ========================================================================
# ------------------------- Constraint Functions -------------------------
# ========================================================================

=pod

=head1 Constraint Functions

Constraint or error checking of user values can be performed by pre-
or user-defined constraint functions.  See this package for
pre-defined functions.

=cut

sub IsPositive     { scalar @_ ? $_[0] > 0 : 'must be > 0' }
sub IsNegative     { scalar @_ ? $_[0] < 0 : 'must be < 0' }
sub IsNonPositive  { scalar @_ ? $_[0] <= 0 : 'must be <= 0' }
sub IsNonNegative  { scalar @_ ? $_[0] >= 0 : 'must be >= 0' }

sub RelatesTo {
   my $Relation  = shift;
   my $Threshold = shift;

   return eval "sub { scalar \@_ ? \@_[0] $Relation $Threshold : 'must be $Relation $Threshold' }";
}

# ========================================================================
# ---------------------------- Class Methods -----------------------------
# ========================================================================

# ------------------------------- DoItAll --------------------------------

=pod

=head1 DoItAll

This is the main entry point for this class.  The function takes a
list of hashes that match the CBIL::Util::EasyCsp::Decl specification,
a usage string, and an optional list of files or packages that contain
pod relevant to the main program.

DoItAll gathers command line parameters from the user, error checks
them, then returns a hash of the values if there were no errors.  The
remaining, unused, arguments are in the dictionary at the tag 'ARGV'.
All other parameter values are at the 'o' or Option tag for their
declaration.  List parameters are always returned as list ref, even
when empty.

=cut

sub DoItAll {
   my $Desc  = shift;           # list or dictionary
   my $Usage = shift;           # string
   my $Files = shift || [ $0 ]; # Perl code to be pod2x'ed

   # make sure we're including the exe's pod.
   unshift(@$Files, $0) unless $Files->[0] eq $0;

   # dictionary of values.
   my $Rv;

   # convert all declarations to objects and make sure we have a
   # dictionary.
   if ( ref $Desc eq 'ARRAY') {
      $Desc = { map {
         my $_decl = CBIL::Util::EasyCsp::Decl->new($_);
         ( $_decl->getOption() => $_decl )
      } @$Desc };
   }

   # is already a dictionary.
   else {
      foreach (keys %$Desc) {
         $Desc->{$_} = CBIL::Util::EasyCsp::Decl->new($Desc->{$_});
      }
   }

   # gather the command line parameters
   $Rv = GetOptions( $Desc );

   # we will show help if user asked for it of if there was an error
   if ($Rv->{usage} || ! ErrorCheck( $Desc, $Rv )) {
      DoHelp($Desc, $Usage, $Files);
      $Rv = undef;
   }

   # add in the ARGV options as well.
   else {
      $Rv->{ARGV} = \@ARGV;
   }

   $Global_Desc   = $Desc;
   $Global_Usage  = $Usage;
   $Global_Values = $Rv;

   return $Rv;
}

# ------------------------------ GetOptions ------------------------------

sub GetOptions {
   my $D = shift;               # a descriptor dictionary

   # arguments from command line.
   my %Rv = ();

   # standards
   my $so = &StandardOptions;

   # assemble an options descriptor
   my %cld;
   foreach my $_desc (values %$so, values %$D) {
      my @goDesc = $_desc->optionTag();
      foreach (@goDesc) {
         $cld{$_} = \$Rv{$_desc->getOption()};
      }
   }

   # process the arguments
   if (!Getopt::Long::GetOptions( %cld )) {
      %Rv = ( usage => 1 );
   }

   return wantarray ? %Rv : \%Rv;
}

# --------------------------- StandardOptions ----------------------------

=pod

=head1 Standard Options

Any program that uses CBIL::Util::EasyCsp automatically gets the
following boolean options: verbose, veryverbose, debug, and usage.

=cut

sub StandardOptions {

   return { map { $_->getOption() => $_ }
            (
             CBIL::Util::EasyCsp::Decl->new( o => 'verbose',
                                             t => CBIL::Util::EasyCsp::BooleanType,
                                             h => 'generate lots of output',
                                           ),

             CBIL::Util::EasyCsp::Decl->new( o => 'veryVerbose',
                                             t => CBIL::Util::EasyCsp::BooleanType,
                                             h => 'generate reams of output',
                                           ),

             CBIL::Util::EasyCsp::Decl->new( o => 'debug',
                                             t => CBIL::Util::EasyCsp::BooleanType,
                                             h => 'turn on debugging output',
                                           ),

             CBIL::Util::EasyCsp::Decl->new( o => 'usage',
                                             s => 'help',
                                             t => CBIL::Util::EasyCsp::BooleanType,
                                             h => 'get usage'
                                           ),
            )
          };
}

=pod
=head1 UsageString

=cut

sub _ftag {
   my $tag = shift;
   my $leader = defined $tag ? '--' : '  ';
   sprintf( "  %s%-24.24s", $leader, $tag );
}

# ----------------------------------------------------------------------
# generate usage string for a single option.

sub single_usage {
   my $O   = shift;
   my $Pod = shift;

   my $Rv;

   if (defined $O->getOption()) {

      my @lines;

      my $lead       = $Pod ? '=head2 ' : '  ';
      my $littleLead = $Pod ? '  ' : "\t";

      push(@lines, $lead. join(' ', map { "--$_" } grep { defined $_ && length $_ } ( $O->getOption(), $O->getShortOption())));
      push(@lines, '') if $Pod;
      push(@lines,   $littleLead. 'hint:     '. $O->getHint());
      push(@lines,   $littleLead. 'type:     '. $O->getType()) if defined $O->getType();
      if ($O->getIsList()) {
         my $delim = $O->getListDelimiter();
         push(@lines, $littleLead. "list:     delimit values with a '$delim'" );
         push(@lines, $littleLead. '          '. $O->explainListLength());
      }
      push(@lines,   $littleLead. 'check:    '. $O->errorCheckDescription());
      push(@lines,   $littleLead. 'default:  '. $O->getDefault()) if defined $O->getDefault();
      push(@lines,   $littleLead. 'REQUIRED!')                    if $O->getIsRequired();

      $Rv = join("\n", @lines). "\n";
   }

   return $Rv;
}


# ----------------------------------------------------------------------
# generate whole usage message.

sub UsageString {
   my $D = shift;
   my $T = shift;

   my $Rv;

   $Rv .= $T. "\n";
   $Rv .= "Usage:\n";

   my @all_options = sort {
      lc $a->getOption() cmp lc $b->getOption()
   } ( (values %{&StandardOptions}), (values %$D) );

   $Rv .= join("\n",
               map {single_usage($_)} @all_options
              ). "\n";

   return $Rv;
}

# ------------------------------- PodUsage -------------------------------

sub PodUsage {
   my $D = shift;
   my $T = shift;

   my $Rv;

   my $_fh = FileHandle->new("|pod2text -c -t")
   || die "Can not open pod2text to give help: $!";

   my @all_options = sort {
      lc $a->getOption() cmp lc $b->getOption()
   } ( (values %{&StandardOptions}), (values %$D) );

   my $options_pod = join("\n",
                          map {single_usage($_,1)} @all_options
                         ). "\n";

   print $_fh "=pod\n\n";
   print $_fh "=head1 Short Description\n\n";
   print $_fh "$T\n\n";
   print $_fh "=head1 Command Line Arguments\n\n";
   print $_fh "$options_pod\n\n";

   $_fh->close();
}

# ------------------------------ ErrorCheck ------------------------------

=pod

=head1 Error Check

Returns false if an error was detected.

Errors can be a required option that was not specified, or a specified
value that does not match the error checking pattern list.

=cut

sub ErrorCheck {
   my $D = shift;               # dictionary of declarations
   my $V = shift;               # values for declarations

   my $Rv = 1;

   # process all options in the tag.
   foreach my $tag ( sort keys %$D ) {

      my $_decl = $D->{$tag};

      # set default values
      if ( ! defined $V->{$tag} && defined $_decl->getDefault()) {
         $V->{$tag} = $_decl->getDefault();
      }

      # check for required values
      if ($_decl->getIsRequired()) {
         if (not defined $V->{$tag}) {
            print STDERR "No value supplied for required option $tag.\n";
            $Rv = 0;
         }
      }

      # split lists on delimiter
      if ( $_decl->getIsList() ) {
         my $ld = $_decl->getListDelimiter();
         $V->{$tag} = [ split( /$ld/, $V->{$tag} ) ];
      }

      # check for valid list length
      if ( my $err = $_decl->checkListLength(scalar @{$V->{$tag} || []})) {
         print STDERR join("\t",
                           'ERR',
                           "--$tag",
                           $err
                          ), "\n";
         $Rv = 0;
      }

      # enforce pattern matching requirements if defined
      if (defined $V->{$tag}) {
         if (my @bad_values = $_decl->errorCheck($V->{$tag})) {
            print STDERR join("\t",
                              'BADVAL(S)',
                              "--$tag",
                              join(', ', map {"'$_'"} @bad_values),
                             ), "\n";
            $Rv = 0;
         }
      }
   }

   return $Rv;
}

# -------------------------------- DoHelp --------------------------------

sub DoHelp {
   my $Desc  = shift;
   my $Usage = shift;
   my $Files = shift;

   $| = 1;

   #print STDERR UsageString( $Desc, $Usage );
   PodUsage($Desc, $Usage);

   if ($Files) {

      #printf STDERR "\n%s\n\n", '=' x 70;

      # consider each file
      foreach my $file (@$Files) {

         # get file which may be a package name
         my $_f = $file;
         if ($_f =~ /::/) {
            eval "require $_f";
            $_f = "$_f.pm"; $_f =~ s/::/\//g; $_f = $INC{$_f};
         }

         # if we can find the file convert it to pod.
         if ($_f) {
            if ($_f ne $0) {
               print  '-' x 70, "\n";
               print  "$file\n";
               print  '-' x 70, "\n\n";
            }
            system "pod2text -c -t $_f";
         }

         # bad file
         else {
            print "Couldn't process help file '$file'/\n";
         }
      }
   }
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;

__END__


my $ecd = { map {($_->{o},$_)}
            ( { h => 'sequence logo',
                t => 'string',
                r => 1,
                e => [ 'a+c+g+t+' ],
                o => 'Logo'
              },
            )
          };

my $cla = DoItAll( $ecd, 'Test of CBIL::Util::EasyCsp.pm' );

require CBIL::Util::Disp;
CBIL::Util::Disp::Display( $cla );


