
package CBIL::Util::EasyCsp::Decl;

=pod

=head1 Purpose

This package encapsulates all a single command line argument
declaration.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

use CBIL::Util::EasyCsp;

# ========================================================================
# ------------------------------- Methods --------------------------------
# ========================================================================

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;

   my $Self = bless {}, $Class;

   $Self->init(@_);

   return $Self;
}

# --------------------------------- init ---------------------------------

sub init {
   my $Self = shift;
   my $Args = ref $_[0] ? shift : {@_};

   $Self->setOption               ( $Args->{Option              } || $Args->{o}  );
   $Self->setShortOption          ( $Args->{ShortOption         } || $Args->{s}  );
   $Self->setHint                 ( $Args->{Hint                } || $Args->{h}  || 'no hint supplied' );
   $Self->setDefault              ( $Args->{Default             } || $Args->{d}  );
   $Self->setErrorCheck           ( $Args->{ErrorCheck          } || $Args->{e}  );
   $Self->setIsList               ( $Args->{IsList              } || $Args->{l}  );
   $Self->setListDelimiter        ( $Args->{ListDelimiter       } || $Args->{ld} || ',' );
   $Self->setType                 ( $Args->{Type                } || $Args->{t}  || CBIL::Util::EasyCsp::BooleanType() );
   $Self->setIsRequired           ( $Args->{IsRequired          } || $Args->{r}  );

   return $Self;
}

# ------------------------------ accessors -------------------------------

=pod

=head1 Attributes

For each attribute there are two flags that can be used.  The first is
a long, standard, form which matches the attribute accessor methods.
The second is a terse form historically used in most program
definitions.

  Long Name          Short Name  Description
  ----------------   ----------- ---------------------------------
  Option             o           name of option, this is what program
                                 will use to retrieve, user will type
                                 --OPTION.

  ShortOption        so          another (terser) name for the option.

  Hint               h           short explanation of option

  Default            d           default value

  ErrorCheck         e           scalar   : match this regexp
                                 list ref : match one of these regexps
                                 code ref : if no args return description
                                            else return 1 if value is ok

  IsList             l           user can supply a list of values

  ListDelimiters     ld          what delimits members of list, default is comma.

  Type               t           what kind of variable, use
                                 CBIL::Util::EasyCsp::*Type functions!

  IsRequired         r           user must specify a value when this is true.

=cut

sub getOption               { $_[0]->{'Option'                      } }
sub setOption               { $_[0]->{'Option'                      } = $_[1]; $_[0] }
sub getName                 { $_[0]->{'Option'                      } }
sub setName                 { $_[0]->{'Option'                      } = $_[1]; $_[0] }

sub getShortOption          { $_[0]->{'ShortOption'                 } }
sub setShortOption          { $_[0]->{'ShortOption'                 } = $_[1]; $_[0] }

sub getHint                 { $_[0]->{'Hint'                        } }
sub setHint                 { $_[0]->{'Hint'                        } = $_[1]; $_[0] }

sub getDefault              { $_[0]->{'Default'                     } }
sub setDefault              { $_[0]->{'Default'                     } = $_[1]; $_[0] }

sub getErrorCheck           { $_[0]->{'ErrorCheck'                  } }
sub setErrorCheck           { $_[0]->{'ErrorCheck'                  } = $_[1]; $_[0] }

sub getIsList               { $_[0]->{'IsList'                      } }
sub setIsList               { $_[0]->{'IsList'                      } = $_[1]; $_[0] }

sub getListDelimiter        { $_[0]->{'ListDelimiter'               } }
sub setListDelimiter        { $_[0]->{'ListDelimiter'               } = $_[1]; $_[0] }

sub getType                 { $_[0]->{'Type'                        } }
sub setType                 { $_[0]->{'Type'                        } = $_[1]; $_[0] }

sub getIsRequired           { $_[0]->{'IsRequired'                  } }
sub setIsRequired           { $_[0]->{'IsRequired'                  } = $_[1]; $_[0] }

# ========================================================================
# --------------------------- Special Methods ----------------------------
# ========================================================================

# ------------------------------ optionTag -------------------------------

# Convert a declaration into a GetOpt long string.  The mapping is
# fairly forgiving to support legacy code, but this should be tighted
# up.

sub optionTag {
	my $Self = shift;

  my @Rv;

  foreach my $tag ( $Self->getOption(), $Self->getShortOption() ) {

     next unless $tag;

     my $goDesc = $tag;

     $goDesc =~ s/=.$//;
     $goDesc =~ s/!//;

     # lists are always specified as a string
     if ( $Self->getIsList() ) {
        push(@Rv, "$goDesc=s");
     }

     else {

        my $type = $Self->getType();

        # identify common types
        if ( $type =~ /^s(t(r(i(n(g)?)?)?)?)?$/i ) {
           push(@Rv, "$goDesc=s");
        }
        elsif ( $type =~ /^f(l(o(a(t)?)?)?)?$/i ) {
           push(@Rv, "$goDesc=f");
        }
        elsif ( $type =~ /^i(n(t)?)?$/i ) {
           push(@Rv, "$goDesc=i");
        }
        elsif ( $type =~ /^b(o(o(l(e(a(n)?)?)?)?)?)?$/i ) {
           push(@Rv, "$goDesc!");
        }

        # default to string
        else {
           push(@Rv, "$goDesc=s");
        }
     }
  }

  return wantarray ? @Rv : \@Rv;
}

# ------------------------------ errorCheck ------------------------------

=pod

=head1 Error Checking


=cut

sub errorCheck {
   my $Self   = shift;
   my @Values = ref $_[0] ? @{$_[0]} : @_;

   my @Rv;

   # only check if there is some check specified
   if (my $checks = $Self->getErrorCheck()) {

      # figure out how to check these.
      my $kind = ref $checks;

      # code ref, call on each value
      if ($kind eq 'CODE') {
         foreach my $value (@Values) {
            $checks->($value) || push(@Rv, $value);
         }
      }

      # list or instance of patterns to compare.
      elsif ($kind eq 'ARRAY' || ! $kind) {

         # get a list of checks
         my @checks = $kind ? @$checks : ( $checks );

       ALL_CHECK:
         foreach my $value (@Values) {
            my $b_ok = 0;

          IDV_CHECK:
            foreach my $pat_rx (@checks) {
               if ($value =~ $pat_rx) {
                  $b_ok = 1;
                  last;
               }
            }

            unless ($b_ok) {
               push(@Rv, $value);
            }
         }
      }

      # bad type
      else {
         die "$kind is not a support error check type";
      }
   }

   return wantarray ? @Rv : \@Rv;
}

# -----------------------rrorCheckDescription -----------------------

sub errorCheckDescription {
   my $Self = shift;

   my $Rv;

   if (my $_ec = $Self->getErrorCheck()) {
      my $kind = ref $_ec;

      # string value
      if (!$kind) {
         $Rv = "Value must match this regular expression: $_ec";
      }

      # list of expression
      elsif ($kind eq 'ARRAY') {
         $Rv = "Value must match one of these regular expression: ". join(',', @$_ec);
      }

      # procedural check
      elsif ($kind eq 'CODE') {
         $Rv = $_ec->();
      }

      # unsupported
      else {
         $Rv = "ERROR: $kind is not a supported error check mechanism";
      }
   }

   else {
      $Rv = "Value is not constrained";
   }

   return $Rv;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;
