#! @perl@

=pod

=head1 Synopsis

  cuAccessors.pl [OPTIONS] FIELD NAMES

=head1 Purpose

C<cuAccessors.pl> generates standard accessor method Perl code as well
as a call suitable for an init method.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;
use lib "$ENV{GUS_HOME}/lib/perl";

use CBIL::Util::V;
use CBIL::Util::EasyCsp;

# ========================================================================
# --------------------------------- Body ---------------------------------
# ========================================================================

$| = 1;

run(cla());

# --------------------------------- run ----------------------------------

=pod

=head1 Details

=head2 Initialization Calls

The initialization calls to the 'set' accessor assume the values are
being extracted from a hash ref with the value stored using the field
names as keys.  If the --Prefix is set to a value then the
initialization method will also allow setting from a hash key of the
form PREFIX.FIELDNAME.  Try it; you will see what I mean.

=head2 Storing Attribute Values

C<cuAccessors.pl> assumes that the underlying Perl object is a hash
reference and stores the attributes at keys that match the supplied
field name.  If the --PackageFieldNames is true the package name of
the object is prepended to the field name using the __PACKAGE__ macro.

=cut

sub run {
   my $Cla = shift;

   # get maximum length of attributes
   my $w      = CBIL::Util::V::max( 20, map { length($_) } @ARGV );
	 my $w_fmt  = '%-'. $w. '.'. $w. 's';

   my $pw     = CBIL::Util::V::max( 20, map { length($_)+length($Cla->{Prefix}) } @ARGV );
   my $pw_fmt = '%-'. $pw. '.'. $pw. 's';

   # generate initialization code.
   # ........................................

   foreach my $attribute (@ARGV) {
      my $fmt = $Cla->{Prefix}
      ? "\$Self->set$w_fmt ( \$Args->{$w_fmt} || \$Args->{$pw_fmt});\n"
      : "\$Self->set$w_fmt ( \$Args->{$w_fmt} );\n";
      printf $fmt, $attribute, $attribute, $Cla->{Prefix}.$attribute;
   }

   print "\n\n";

   # generate accessors code
   # ........................................

   my $fnPrefix = $Cla->{PackageFieldNames} ? '__PACKAGE__ . ' : '';
   my $fw  = CBIL::Util::V::max( 20, map { length($_)+length($fnPrefix)+2 } @ARGV );
   my $fw_fmt  = '%-'. $fw. '.'. $fw. 's';

   foreach my $attribute (@ARGV) {
      my $fmt = join("\n",
                     "sub get$w_fmt { \$_[0]->{$fw_fmt} }",
                     "sub set$w_fmt { \$_[0]->{$fw_fmt} = \$_[1]; \$_[0] }",
                     '',
                     ''
                    );
      printf $fmt,
      $attribute, "$fnPrefix'$attribute'",
      $attribute, "$fnPrefix'$attribute'";
   }
}

# --------------------------------- cla ----------------------------------

sub cla {

   my $purpose = 'generate boilerplate Perl accessor code';

   my $options = [ { h => 'include __PACKAGE__ prefix in hash fieldnames',
                     t => CBIL::Util::EasyCsp::BooleanType,
                     o => 'PackageFieldNames',
                   },

                   { h => 'allow init with or without this prefix',
                     t => CBIL::Util::EasyCsp::StringType,
                     o => 'Prefix',
                   }
                 ];

   my $cla = CBIL::Util::EasyCsp::DoItAll($options, $purpose) || exit 0;

   return $cla;
}

