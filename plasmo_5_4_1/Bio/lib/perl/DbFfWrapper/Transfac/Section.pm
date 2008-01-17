
package CBIL::Bio::DbFfWrapper::Transfac::Section;

# ----------------------------------------------------------------------

use strict;

# ----------------------------------------------------------------------

use constant ConstDebugFlag => 0;

# ----------------------------------------------------------------------

sub tableParser {
   my $Self     = shift;
   my $Lines    = shift;
   my $Actions  = shift;
   my $EolWraps = shift;
   my $LahWraps = shift;
   my $Maps     = shift || {};

 LineScan: for (my $i = 0; $i < @$Lines; $i++) {

      my $j          = $i;
      my $line       = $Lines->[$i];
      my $code       = substr($line,0,2);
			my $mappedCode = $code;
      last if $code eq '//';

      ConstDebugFlag && print "$line\n";
      foreach my $pat (keys %$Maps) {
				 if ($code =~ /$pat/) {
						$mappedCode = $Maps->{$pat};
						last;
				 }
      }

      # text line that we will parse.
      my $text = substr($line,4);

      # see if next line belongs to this one; we'll just look at one.
      if (my $lahWrap = $LahWraps->{$mappedCode}) {
         if (substr($Lines->[$i+1],0,2) eq $code) {
            my $content = substr($Lines->[$i+1],4);
            if ($content !~ /$lahWrap/) {
               $text .= ' '. $content;
               $i++;
            }
         }
      }

      # see if we need to add next line to this one because this one
      # appears not to be done.
      if (my $wrap = $EolWraps->{$code}) {
         while ($text !~ /$wrap->[0]/) {
            $i++;
            $text .= ' '. substr($Lines->[$i],4);
         }
      }

      # get the action for this code
      if (my $_actions = $Actions->{$mappedCode}) {
         if (ref $_actions) {

            my $matched_b = 0;

          ActionScan: for (my $action_i = 0; $action_i < @$_actions; $action_i += 2) {
               if (my @parts = $text =~ /$_actions->[$action_i]/) {
                  #$_actions->[$action_i+1]->($1,$2,$3,$4,$5,$6,$7,$8,$9);
                  $_actions->[$action_i+1]->($code, @parts);
                  $matched_b = 1;
                  last ActionScan;
               }
            }

            if (!$matched_b) {
               printf STDERR "Poor format for %s (%d) in %s: '%s'\n",
               $code, $j, ref $Self, $line;
            }
         }
      }
      else {
         printf STDERR "Unknown line type %s (%d) in %s: '%s'\n",
         $code, $j, ref $Self, $line;
      }
   }

   return $Self;
}

# ----------------------------------------------------------------------

1;
