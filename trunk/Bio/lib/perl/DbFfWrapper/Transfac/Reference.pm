
package CBIL::Bio::DbFfWrapper::Transfac::Reference;

use vars qw($oid_counter);

use strict;

# ----------------------------------------------------------------------

sub new {
   my $C = shift;
   my $Args = shift;

   my $m = bless {}, $C;

   $m->init($Args);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   return $Self
}

# ----------------------------------------------------------------------

sub getId      { $_[0]->{Id} }
sub setId      { $_[0]->{Id} = $_[1]; $_[0] }
sub makeId {
   my $Self = shift;

   my $medline = $Self->getMedline;
   if ($medline) {
      $Self->setId("ML$medline");
   }
   else {
      my $id = lc join(':',
                       $Self->getYear,$Self->getVolume,
                       $Self->getPages,$Self->getJournal,
                       ,);
      $id =~ s/[^0-9a-zA-Z:]//g;
      $Self->setId($id);
   }

   return $Self
}

sub getOrdinal { $_[0]->{Ordinal} }
sub setOrdinal { $_[0]->{Ordinal} = $_[1]; $_[0] }

sub getTitle { $_[0]->{Title} }
sub setTitle { $_[0]->{Title} = $_[1]; $_[0] }
sub addTitle {
   my $Self = shift;
   my $Args = shift;

   my $title = $Self->getTitle;
   if ($title) {
      if (substr($title,-1,1) eq ' ') {
         $Self->setTitle("$title$Args");
      }
      else {
         $Self->setTitle("$title $Args");
      }
   }
   else {
      $Self->setTitle($Args);
   }

   return $Self
}

sub getAuthors { $_[0]->{Authors} }
sub setAuthors { $_[0]->{Authors} = $_[1]; $_[0] }
sub addAuthors {
   my $Self = shift;
   my $Args = shift;

   my $authors = $Self->getAuthors;
   if ($authors) {
      if (substr($authors,-1,1) eq ' ') {
         $Self->setAuthors("$authors$Args");
      }
      else {
         $Self->setAuthors("$authors $Args");
      }
   }
   else {
      $Self->setAuthors($Args);
   }

   return $Self
}

sub getJournal { $_[0]->{Journal} }
sub setJournal { $_[0]->{Journal} = $_[1]; $_[0] }

sub getVolume { $_[0]->{Volume} }
sub setVolume { $_[0]->{Volume} = $_[1]; $_[0] }

sub getPages { $_[0]->{Pages} }
sub setPages { $_[0]->{Pages} = $_[1]; $_[0] }

sub getYear { $_[0]->{Year} }
sub setYear { $_[0]->{Year} = $_[1]; $_[0] }

sub getMedline { $_[0]->{Medline} }
sub setMedline { $_[0]->{Medline} = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $Args = shift; # [string] : text from file in array ref.
   my $I = shift; # \integer : start parsing from this place in array.

   my $started;
   my $i;
   for ($i = $$I; $i < @$Args; $i++) {

      my $line = $Args->[$i];

      # end of record
      if ($line =~ /^XX/ || $line =~ m.^//.) {
         $i++;
      }

      # ordinal
      elsif ($line =~ /^RN  \[(\d+)\]/) {
         if ($started) {
            last;
         }
         else {
            $Self->setOrdinal($1);
         }
      }

      # medline reference
      elsif ($line =~ /^RX  MEDLINE; (\d+)/) {
         $Self->setMedline($1);
      }

      # Authors
      elsif ($line =~ /^RA  (.+)/) {
         $Self->addAuthors($1);
      }

      # Title
      elsif ($line =~ /^RT  (.+)/) {
         $Self->addTitle($1);
      }

      # Journal
      elsif ($line =~ /^RL  (.+)/) {
         my $text = $1;

				 # general journal format
         if ($text =~ /(.+)\s+(\S+):(.+) \((\d+)\)\./) {
            my $pages = $3; $pages=~ s/ //g;
            $Self->setJournal($1);
            $Self->setVolume($2);
            $Self->setPages($pages);
            $Self->setYear($4);
         }

				 # special cases
				 elsif ($text =~ /Internet : \((\d*)\)\./) {
						$Self->setJournal('Internet');
						$Self->setYear   ($1);
				 }

				 elsif ($text =~ /(direct submission) \((.+)\) : \((\d*)\)\./) {
						$Self->setJournal($1);
						$Self->setAuthors($2);
						$Self->setYear   ($3);
				 }

				 # the one book in v7.3
				 elsif ($text =~ /(.+),.+(\d+) \d+:(\d+-\d+)/) {
						$Self->setJournal($1);
						$Self->setYear   ($2);
						$Self->setPages  ($3);
				 }

         else {
            print STDERR "unexpected RL line:'$text'\n";
         }
      }

      # unexpected
      else {
         print STDERR "unexpected Reference line: '$line'\n";
         last;
      }

      $started = 1;

   }

   # record progress.
   $$I = $i;

   return $Self
}

# ----------------------------------------------------------------------

1
