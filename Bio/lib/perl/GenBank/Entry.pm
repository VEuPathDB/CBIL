
package CBIL::Bio::GenBank::Entry;

@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use CBIL::Bio::GenBank::BaseObject;
use CBIL::Bio::GenBank::IoStream;
use CBIL::Bio::GenBank::Sequence;

use strict 'vars';

sub parse {
  my $M   = shift;
  my $IOS = shift;

  my $sectionObj;
  my $line;
	# my $header; ## place to put header info

  # skip to next left justified line-exclude things of the form .seq-e.g. GBROD2.SEQ
  while ( $line = $IOS->getLine() ) {
    last unless $line =~ /^\s/ || $line =~ /^\w+\./;
		# $header .= $line;
  }
  $IOS->putLine($line);

  # parse away
  while ( $line = $IOS->getLine() ) {

    # lead line
    if ( $line =~ /^[A-Z]/ ) {
      my ($section)     = substr( $line, 0, 12 );
      $section =~ s/\s+$//;
      my $sectionClass  = join( '',
                                map {
                                  ucfirst lc $_
                                } split( /\s+/, $section )
                              );
      my $sectionRequire = eval "require CBIL::Bio::GenBank::$sectionClass";
      if ( $@ ) {
        $M->reportError( $IOS,
                         'unrequireable class',
                         $sectionClass,
                         $@,
                       );
      }
      else {
        $IOS->putLine($line);
        my $sectionObject = eval "CBIL::Bio::GenBank::$sectionClass->new( { ios => \$IOS } )";
        if ( $@ ) {
          $M->reportError( $IOS,
                           'object parse error',
                           $sectionClass,
                           $@,
                           $line,
                         );
          $IOS->getLine();
        }
        else {
					print join("\t", 'VLD', ref $sectionObject, $sectionObject->getValidity), "\n";
          push( @{ $M->{$section} }, $sectionObject );
					$M->setValidity(0) unless $sectionObject->getValidity;
        }
      }
    }

    # sequence
    elsif ( $line =~ /^\s+\d+\s/ ) {
      $IOS->putLine($line);
      $M->{Sequence} = CBIL::Bio::GenBank::Sequence->new( { ios => $IOS } );
    }

    # end of entry
    elsif ( $line =~ /^\/\// ) {
      last;
    }

    # don't recognize
    else {
      $M->reportError( $IOS,
                       'unparsed line',
                       $line
                     );
    }
  }

	# Put file header information in object
	#	if ($header) {  $M->{Header} = $header; }

  # return new me.
  $M
}


1;


__END__






