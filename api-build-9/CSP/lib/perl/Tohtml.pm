#!/usr/bin/perl

=pod 
=head1 Name

C<Tohtml> - an object that makes creating HTML easy.
 
=head1 Description
 
these objects contain various methods that make it easy to create HTML 
entities.  Ideas are stolen shamelessly from Lincoln Stein CGI.pm.

=head1 Style_Config

=head1 Methods

=over 4

=cut

package CBIL::CSP::Tohtml;

#BEGIN {
#  warn ">>> CBIL::CSP::Tohtml\n";
#}

@ISA = qw( A );
@EXPORT = qw( head body anchor link );

use strict vars;
use CBIL::Util::A;


# ----------------------------------------------------------------------
=pod
=head1 new

is inherited from C<A>.

=cut

#sub new {
#  my $class = shift;
#  my $A = shift;
#  
#  my $me = o::new($class, $A);
#  
#  return $me;
#}

=pod
=item contents
=cut

sub contentType {
  my $me = shift;
  my $ar = shift;
  
  my $type = defined $ar->{type} ? $ar->{type} : 'text/html';
  
  return "Content-type: $type\n\n";
}

# ----------------------------------------------------------------------
=pod
=item head

create the <HEAD></HEAD> section

Arguments:

=cut

sub head {
  my $me = shift;
  my $A = shift;
  
 return $me->ep(new CBIL::Util::A {
   tag     => 'HEAD',
   atts    => [
   ],
   vals    => $A,
   newline => 1,
 });
}

# ----------------------------------------------------------------------
=pod
=item title

Creates the title section.

=cut

sub title {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A +{tag => 'TITLE',
			    atts => [],
			    vals => $A,
			    newline => 1
			   });
}

# ----------------------------------------------------------------------
=pod
=item body

=cut

sub body {
  my $me = shift;
  my $A = shift;
	
  return $me->ep(new CBIL::Util::A {
	tag     => 'BODY',
	atts    => [
	  'background="%s"',
	  'text="%s"',
	  'link="%s"',
	  'vlink="%s"',
	  'alink="%s"',
	  'bgcolor="%s"',
	],
	vals    => $A,
	newline => 1
  });
}

# ----------------------------------------------------------------------
=pod
=item heading

creates an HTML heading

Arguments:

C<level> (req)

C<viz> (req)

=cut

sub heading {
  my $me = shift;
  my $A = shift;

  return undef unless $A->ensure('level', 'viz');

  my $tag = "H$A->{level}";

  return $me->ep(new CBIL::Util::A +{tag => $tag,
			    atts => [],
			    vals => $A,
			    newline => 1,
			   });
}

# ----------------------------------------------------------------------
=pod
=item anchor

creates an HTML anchor

Arguments:

C<name> where to go

C<viz> what to show as the anchor.

others as allowed

=cut

sub anchor {
  my $me = shift;
  my $A = shift;
	
  return undef unless $A->ensure('name', 'viz');
	
  my $html;
	
  foreach ('name') {
    $html .= qq{ $_:"$A->{$_}" };
  }
  
  return qq{<A $html>$A->{viz}</A>};
}

# ----------------------------------------------------------------------
=pod
=item link

creates an HTML link

Arguments:

C<name> where to go

C<viz> what to show as the link.

others as allowed

=cut

sub link {
  my $me = shift;
  my $A = shift;
	
  return undef unless $A->ensure('href', 'viz');
	
  my $html;
	
  # required args
  # ....................

  foreach ('href') {
    $html .= qq{ $_="$A->{$_}" };
  }

  # optional
  # ....................

  foreach ('target') {
    $html .= qq{ $_="$A->{$_}" } if defined $A->{$_};
  }

  # final html
  # ....................

  return qq{<A $html>$A->{viz}</A>};
}

=pod
=item image
=cut

sub image {
  my $me = shift;
  my $ar = shift;
  
  return $me->es(new CBIL::Util::A +{
	tag =>  'IMG',
	atts   => [
	  'src="%s"',
	  'alt="%s"',
	  'longdesc="%s"',
	  'height="%s"',
	  'width="%s"',
	  'usemap="%s"',
	  'ismap',
	  'border=%d"',
	  'align="%s"',
	],
	vals   => $ar
  });
}

# ======================================================================

=pod
=back

=head2 Tables
=over 4
=cut

=pod
=item table
=cut

sub table {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A {
	tag => "TABLE", 
	atts => [
	  'align="%s"',
	  'width="%s"',
	  'border=%d', 
	  'cellspacing=%d',
	  'cellpadding=%d',
	  '!%s',
	  ],
	vals => $A,
	newline => 1,
  });
}

=pod
=item tableRow
=cut

sub tableRow {
  my $me = shift;
  my $A = shift;
  
  return $me->ep(new CBIL::Util::A {
	tag => "TR",
	atts => [ 
	  'valign="%s"',
	  'align="%s"',
	  'bgcolor="%s"',
	  'background="%s"',
	  ],
	vals => $A, 
	newline => 1,
  });
}

=pod
=item tableHeader
=cut

sub tableHeader {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A {
	tag     => "TH", 
	atts    => [
	  'nowrap',
	  'rowspan=%d',
	  'colspan=%d',
	  'valign="%s"',
	  'align="%s"',
	  'width="%s"',
	  'height="%s"',
	  'bgcolor="%s"',
	  'background="%s"',
	  ],
	vals    => $A,
	newline => 1,
  });
}

=pod
=item tableData
=cut 

sub tableData {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A {
	tag     => "TD",
	atts    => [
	  'nowrap',
	  'rowspan=%d',
	  'colspan=%d',
	  'valign="%s"',
	  'align="%s"',
	  'width="%s"',
	  'height=%d',
	  'bgcolor="%s"',
	  'background="%s"',
	  ],
	vals    => $A,
	newline => 1,
  } );
}

=pod
=back
=cut

# ======================================================================
=pod
=head2 Simple Things

=over 4
=cut

# ----------------------------------------------------------------------
sub break {
  return "<br>\n";
}

sub rule {
  my $me = shift;
  my $ar = shift;
  
  return $me->es(new CBIL::Util::A {
	tag  => 'HR',
	atts => [
	  'noshade',
	  'size=%d',
	  'width="%s"',
	  'align="%s"',
	  ],
	vals => $ar,
	
  });
}
  
# ======================================================================
=pod
=back
=head2 Formating

These methods generate formatting HTML.

=over 4
=cut

# ----------------------------------------------------------------------
=pod
=item ep
=item es

These are utilities routines which are used to make other routines
easier to code.  They break from the standard argument passing model
for ease of use.

First argument is $A containing values from caller\'s caller.
  
Next argument is element tag.

Remining arguments are attribute names which can be inserted if
specified.

C<es> is for single tag elements, like C<HR>.

C<ep> is for paired tag elements like C<font.../font>.  C<ep> can
be prevented from including the beginning or ending tags by defining
C<BEGIN => 0> or C<END => 0> in the arguments.  This is handy for long
lazy contents.

=cut

sub es {
  my $me = shift;
  my $A = shift;

  return undef unless $A->ensure('tag', 'atts', 'vals');

  my $html;

  # add requested attributes.
  my $metatag; foreach $metatag (@ {$A->{atts}}) {

    #print STDERR "CBIL::CSP::Tohtml: metatag=$metatag ";

    # something with a value
    if ($metatag =~ /\%/) {
      my $att = $metatag =~ /^([^%=]+)/ ? $1 : undef;
      #print STDERR "att=$att ";
      #print STDERR "arg{att}=$A->{vals}->{$att} ";

      if (defined $att and defined $A->{vals}->{$att}) {
		$html .= " " . sprintf($metatag, $A->{vals}->{$att});
	  }
    }
	
    # something with presence only.
	else {
	  if ($A->{$_}) {
		$html .= " $_"; 
	  }
    }

	#print STDERR "\n";
  }
  
  # bracket the whole thing.
  return qq{<$A->{tag}$html>};

}

sub ep {
  my $me = shift;
  my $A = shift;

  my $intro;
  my $middle;
  my $outro;

  # beginning implied or reqested
  if (not defined $A->{BEGIN} or $A->{BEGIN}) {
    $intro = $me->es($A);
    $intro .= "\n" if $A->{newline} or $A->{inew};
  }

  # ending implied or requested
  if (not defined $A->{END} or $A->{END}) {
    $outro = "</$A->{tag}>";
    $outro .= "\n" if $A->{newline} or $A->{onew};
  }

  # ending implied or requested
  if (defined $intro and $outro) {
    return undef unless $A->{vals}->ensure('viz');
    $middle = $A->{vals}->{viz};
    $middle .= "\n" if ($A->{newline} or $A->{vnew}) and $middle !~ /\n$/;
  }

  return $intro . $middle . $outro;
}


# ----------------------------------------------------------------------
=pod
=item font
=cut

sub font {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A +{tag => 'FONT',
			    atts => ['size=%s', 'color=%s'],
			    vals => $A,
			   });
}

sub rule {
  my $me = shift;
  my $A = shift;
  
  return $me->es(new CBIL::Util::A +{tag => 'HR',
			    atts => [ 'align=%s', 'noshade', 'size=%s', 'width=%s'],
			    vals => $A,
			   });
}

sub bold {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A +{tag => 'B',
			    atts => [],
			    vals => $A,
			    });
}

sub it {
  my $me = shift;
  my $ar = shift;
  
  return $me->italics($ar);
}

sub italics {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A +{tag => 'I',
			    atts => [],
			    vals => $A,
			    });
}

sub underlined {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A +{tag => 'U',
			    atts => [],
			    vals => $A,
			    });
}

sub strike {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A +{tag => 'STRIKE',
			    atts => [],
			    vals => $A,
			    });
}

sub tt {
  my $me = shift;
  my $A = shift;

  return $me->ep(new CBIL::Util::A +{tag => 'TT',
			    atts => [],
			    vals => $A,
			    });
}


# ----------------------------------------------------------------------
=pod
=item pre

Preformatted text.

=cut

sub pre {
  my $me = shift;
  my $A = shift;

  return undef unless $A->ensure('viz');
  
  my $viz;
  
  # can take list ref for viz
  if (ref $A->{viz} eq 'ARRAY') {

	  my $newlinesQ = defined $A->{newlines} ? $A->{newlines} : 1;
	  my $joiner    = $newlinesQ ? "\n" : "";
	
	  $viz = join ($joiner, @ {$A->{viz}});
	}
	
	# normal string
	else {
	  $viz = $A->{viz};
	}
	
	return $me->ep(new CBIL::Util::A {tag => "pre",
     atts => [],
     vals => new CBIL::Util::A {viz => $viz},
     inew => 1,
     onew => 1,
    } );
}

=pod
=item center

Centered text.

=cut

sub center {
  my $me = shift;
  my $A = shift;

  return undef unless $A->ensure('viz');
  
  my $viz;
  
  # can take list ref for viz
  if (ref $A->{viz} eq 'ARRAY') {

    my $newlinesQ = defined $A->{newlines} ? $A->{newlines} : 1;
    my $joiner    = $newlinesQ ? "\n" : "";
	
    $viz = join ($joiner, @ {$A->{viz}});
  }
	
  # normal string
  else {
    $viz = $A->{viz};
  }
	
  return $me->ep(new CBIL::Util::A {
    tag => "center",
    atts => [],
    vals => new CBIL::Util::A {viz => $viz},
    inew => 1,
    onew => 1,
  });
}

# ======================================================================
=pod
=back
=head2 Forms and Input Methods

These methods generate HTML containing forms input widgets.

=over 4
=cut

# attribute names
my $a_accept_charset = 'accept-charsets="%s"';
my $a_accesskey      = 'accesskey="%s"';
my $a_action         = 'action="%s"';
my $a_alt            = 'alt="%s"';
my $a_checked        = 'checked';
my $a_cols           = 'cols="%s"';
my $a_dir            = 'dir="%s";
my $a_disabled       = 'disabled';
my $a_enctype        = 'enctype="%s"';
my $a_for            = 'for="%s"';
my $a_label          = 'label="%s"';
my $a_maxlength      = 'maxlength="%s"';
my $a_method         = 'method="%s"';
my $a_multiple       = 'multiple';
my $a_name           = 'name="%s"';
my $a_name           = 'name="%s"';
my $a_onblur         = 'onblur="%s"';
my $a_onchange       = 'onchange="%s"';
my $a_onclick        = 'onclick="%s"';
my $a_ondblclick     = 'ondblclick="%s"';
my $a_onfocus        = 'onfocus="%s"';
my $a_onkeydown      = 'onkeydown="%s"';
my $a_onkeypress     = 'onkeypress="%s"';
my $a_onkeyup        = 'onkeyup="%s";
my $a_onmousedown    = 'onmousedown="%s"';
my $a_onmousemove    = 'onmousemovec="%s"';
my $a_onmouseout     = 'onmouseout="%s"';
my $a_onmouseover    = 'onmouseover="%s"';
my $a_onmouseup      = 'onmouseup="%s"';
my $a_onreset        = 'onreset="%s"';
my $a_onselect       = 'onselect="%s"';
my $a_onsubmit       = 'onsubmit="%s"';
my $a_rows           = 'rows="%s"';
my $a_selected       = 'selected;
my $a_size           = 'size="%s"';
my $a_src            = 'src="%s"';
my $a_tabindex       = 'tabindex="%s";
my $a_type           = 'type="%s"';
my $a_value          = 'value="%s"';

# lists of common attribute clusters.

my @a_CoreAttrs = (
  $a_id, $hra_class, $a_style, $a_title,
  );

my @a_i18n = ( 
  $a_lang, $a_dir 
  );

my $a_FocusEvents = (
  $a_onfocus, $a_onblur, $a_select, $a_onchange
  );
  
my $a_Events = (
  $a_onclick, $a_ondblclick, $a_onmousedown, $a_onmouseup,
  $a_onmouseover, $a_onmousemove, $a_onmouseout,
  $a_onkeypress, $a_onkeydown, $a_onkeyup,
  );
  
my @a_IntrinsicEvents 
= (
   $a_onfocus  ,   
   $a_onblur  ,
   $a_onselect    ,
   $a_onchange    ,
   $a_onclick     ,
   $a_ondblclick  ,
   $a_onmousedown ,
   $a_onmouseup   ,
   $a_onmouseover ,
   $a_onmousemove ,
   $a_onmouseout  ,
   $a_onkeypress  ,
   $a_onkeydown   ,
   $a_onkeyup,
   );
   
my @a_InputCommon
= (
  $a_id,
  $a_class ,
  $a_lang ,
  $a_title ,
  $a_style ,
  $a_readonly ,
  $a_disabled ,
  $a_tabindex ,
);

my %PhraseElementDescription
= (
	p => 1,
	a => [
	  @a_CoreAttrs, @a_i18n, @a_Events,
	],
  },
);

my %QuoteDescription

my %ItemDescriptionTable
= (

  abbr    => \%PhraseElementDescription,
  
  acronym => \%PhraseElementDescription,

  cite    => \%PhraseElementDescription,
  
  code    => \%PhraseElementDescription,

  dfn     => \%PhraseElementDescription,

  em      =>  \%PhraseElementDescription,
  
  fieldset => {
	p => 1,
    a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  ],
	},
  
  form     => {
	p => 1,
	a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  $a_action, $a_method, $a_enctype, 
	  $a_onsubmit, $a_onreset, $a_accept_charset,
	  ],
	},
			  
  input    => {
	p => 0,
	a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  $a_type, $a_name, $a_value, $a_checked, $a_disabled, $a_readonly,
	  $a_size, $a_maxlength, $a_src, $a_alt, $a_usemap, $a_tabindex, $a_accesskey,
	  ],
	},
			
  kbd      => \%PhraseElementDescription,
	
  label    => {
	p => 1,
	a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  $a_for, $a_accesskey
	  ],
	},

  legend   => {
	p => 1,
	a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  $a_accesskey,
	  ],
	},
  
  optgroup => {
	p => 1,
	a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  $a_disabled, $a_label,
	  ],
	},
			  
  option   => {
	p => 1,
	a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  $a_selected, $a_disabled, $a_label, $a_value,
	  ],
	},
	
  pre      => {
	p => 1,
	a => [
	  @a_CoreAttrs, @a_i18n, @a_Events,
	],
  },
  
  samp     => \%PhraseElementDescription,
  
  select   => {
	p => 1,
	a => [
	  @_CoreAttrs, @_i18n, @_Events,
	  $a_name, $a_size, $a_multiple, $a_disabled, $a_tabindex,
	  ],
	},
   
  strong   => \%PhraseElementDescription,

  textarea => {
	p => 1,
	a => [ 
	  $a_name, $a_rows, $a_cols,
	  @a_InputCommon, @a_IntrinsicEvents,
	  ],
	},
	
  var      => \%PhraseElementDescription,
	
);

=pod
=item _unwrapper

implements polymorphism at the argument level.

=cut

sub _unwrapper {
  my $M = shift;
  my $A = shift;
  
  my $h_rv;
  
  my $arg  = $A->{ arg };
  
  # not a reference, just a string.
  if ( not ref $arg ) {
	return $M->_dispatcher( new CBIL::Util::A {
	  arg => new CBIL::Util::A { viz => $arg },
	  tag => $A->{ tag },
	} );
  }
  
  # list of something or other
  elsif ( ref $arg eq 'LIST' ) {
	return join( '',
	             map { 
				   $M->_unwrapper( new CBIL::Util::A { 
					 arg => new CBIL::Util::A { viz => $_ },
					 tag => $A->{ tag },
				   } )
				 } @ {$arg}
				 );
  }
  
  # assume it's an object, what we wanted in the first.
  else {
	return $M->_dispatcher( $A );
  }
  
}

=pod
=item _dispatcher

uses table description of HTML constructs to generate HTML from arguments.

C<arg> contains value(s) passed from ultimate caller.

C<tag> is the type of HTML item to process, i.e., it is the key into the 
tabular description.

=cut

sub _dispatcher {
  my $M = shift;
  my $A = shift;
  
  my $desc = $ItemDescriptionTable{ $A->{ tag } };
  
  return undef if not defined $desc;
  
  # is paired?
  if ( $desc->{ p } ) {
	return $M->ep( new CBIL::Util::A { 
	  tag  => $A->{ tag },
	  atts => $desc->{ a },
	  vals => $A->{ arg },
	});
  }
  
  # or single
  else {
	return $M->es( new CBIL::Util::A {
	  tag  => $A->{ tag },
	  atts => $desc->{ a },
	  vals => $A->{ arg },
	} );
  }
}

# ----------------------------------------------------------------------
=pod
=item Form

=cut

sub form {
  my $me = shift;
  my $A = shift;

  return undef unless $A->ensure('action', 'viz');

  return $me->ep(new CBIL::Util::A +{tag => 'FORM',
  atts => ['action="%s"', 'method="%s"', 'enctype="%s"'],
  vals => $A,
  newline => 1
  });
}

# ----------------------------------------------------------------------
=pod
=item submit

create a button.

Arguments:

C<name> (req) name of the button

C<value> (req) value to send

=cut

sub submit {
  my $me = shift;
  my $A = shift;
  
  return undef unless $A->ensure('name', 'value');
  
  my $myArgs = new CBIL::Util::A +{type => 'submit'};
  $myArgs->copy($A, 'name', 'value');
  
  my $button 
    = $me->es(new CBIL::Util::A +{tag => 'INPUT',
			 atts => [ 'type="%s"', 'name="%s"', 'value="%s"' ],
			 vals => $myArgs,
			});
  warn $button . "\n";

  return $button;
}


# ----------------------------------------------------------------------
=pod
=item textField

create a text field.

Arguments:

C<name> (req)

C<value> (req)

C<width> (req)

=cut

sub textField {
  my $me = shift;
  my $A = shift;
  
  return undef unless $A->ensure('name', 'value', 'width');
  
  return 
  qq{<input type="text" name="$A->{name}" value="$A->{value}" width="$A->{width}">};
}

# ----------------------------------------------------------------------

=back

=cut

#END {
#  warn "<<< CBIL::CSP::Tohtml\n";
#}


1;
