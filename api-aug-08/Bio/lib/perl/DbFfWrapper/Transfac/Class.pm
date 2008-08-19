
package CBIL::Bio::DbFfWrapper::Transfac::Class;

use strict;

use CBIL::Bio::DbFfWrapper::Transfac::History;
use CBIL::Bio::DbFfWrapper::Transfac::DbRef;

# ----------------------------------------------------------------------

sub new {
   my $Class = shift;
   my $Args  = shift;

   my $m = bless {}, $Class;

   $m->init($Args);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->parse($Args) if ref $Args eq 'ARRAY';

   return $Self
}

# ----------------------------------------------------------------------

sub getAccession { $_[0]->{Accession} }
sub setAccession { $_[0]->{Accession} = $_[1]; $_[0] }

sub getId { $_[0]->{Id} }
sub setId { $_[0]->{Id} = $_[1]; $_[0] }

sub getHistory { $_[0]->{History} }
sub setHistory { $_[0]->{History} = $_[1]; $_[0] }
sub addHistory { push(@{$_[0]->{History}}, $_[1]); $_[0] }

sub getClass { $_[0]->{Class} }
sub setClass { $_[0]->{Class} = $_[1]; $_[0] }

sub getDescription { $_[0]->{Description} }
sub setDescription { $_[0]->{Description} = $_[1]; $_[0] }
sub addDescription { push(@{$_[0]->{Description}},$_[1]); $_[0] }
sub fixDescription {
   $_[0]->{Description} = join(' ', @{$_[0]->{Description}})
   if ref $_[0]->{Description} eq 'ARRAY';
   $_[0]
}

sub getFactors { $_[0]->{Factors} }
sub setFactors { $_[0]->{Factors} = $_[1]; $_[0] }
sub addFactor  { push(@{$_[0]->{Factors}},$_[1]); $_[0] }

sub getDbRef    { $_[0]->{DbRef} }
sub setDbRef    { $_[0]->{DbRef} = $_[1]; $_[0] }
sub addDbRef    { push(@{$_[0]->{DbRef}},$_[1]); $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $E = shift; # [string] : lines from file

   my $line;
   my $code;
   my $text;

	 my $wraps   =
	 { BF => [ '\.$' ],
	 };

   my $actions =
   {
    AC => [ '(C\d{4})'        , sub { $Self->setAccession($_[0]);        } ],
    ID => [ '(\S+)'           , sub { $Self->setId($_[0]);               } ],
    DT => [ '(.+)'            , sub { my $history = CBIL::Bio::DbFfWrapper::Transfac::History->new();
																			$history->parse($_[0]);
																			$Self->addHistory($history);
																	 } ],
		BS => [ '(R\d{5}); (.+)\.', sub { } ],
		CL => [ '(.+)'            , sub { $Self->setClass($_[0]);            } ],
    CD => [ '(.+)'            , sub { $Self->addDescription($_[0]);      },
						'\s*',            , sub {},
					],
    CC => [ '(.+)'            , sub { $Self->addDescription($_[0]);      } ],
		CO => 0,
    BF => [ '(T\d{5})'        , sub { $Self->addFactor($_[0]);           } ],
    DR => [ '(.+)\.'          , sub { $Self->addDbRef(CBIL::Bio::DbFfWrapper::Transfac::DbRef->new($_[0])); } ],
    RN => 0,
    RX => 0,
    RA => 0,
    RT => 0,
    RL => 0,
    XX => 0,
   };

   my $map = { '\d\d' => '00' };
 
 LINE_SCAN:
   for (my $i = 0; $i < @$E; $i++) {
      $line = $E->[$i];
      $code = substr($line,0,2);
      last if $code eq '//';

      foreach my $pat (keys %$map) {
         $code = $map->{$pat} if $code =~ /$pat/;
      }

			my $text = substr($line,4);

			# see if we need to add next line to this one.
			my $wrap = $wraps->{$code};
			if (defined $wrap) {
				 while ($text !~ /$wrap->[0]/) {
						$i++;
						$text .= substr($E->[$i],4);
				 }
			}

      my $act  = $actions->{$code};
      if (defined $act) {
         if ($act) {
						my $handled_b = 0;
						for (my $i = 0; $i < @$act; $i += 2) {
							 if ($text =~ /$act->[$i+0]/) {
									$act->[$i+1]->($1,$2,$3,$4,$5,$6,$7,$8,$9);
									$handled_b = 1;
									last;
							 }
						}

            unless ($handled_b) {
               print STDERR "Poor format in Class: '$line'\n";
            }
         }
      }
      else {
         print STDERR "Unexpected line in Class: '$line'\n";
      }
   }

   $Self
   ->fixDescription
   ;

   #Disp::Display($Self);

   return $Self
}

# ----------------------------------------------------------------------

1
