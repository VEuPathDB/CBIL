#!/usr/bin/perl

=pod 
=head1 Name

C<CBIL::CSP::Hify> - an object that makes creating HTML easy.
 
=head1 Description
 
these objects contain various methods that make it easy to create HTML 
entities.  Ideas are stolen shamelessly from Lincoln Stein CGI.pm.

=head1 Methods
=over 4
=cut

package CBIL::CSP::Hify;

@ISA = qw( A );

sub AUTOLOAD {
  my $M = shift;
  
  my $type = ref $M;
  return undef unless $type;
  
  my $name = $AUTOLOAD;
  
  $name =~ s/.*://;
  $name =~ tr/A-Z/a-z/;

  # a element method
  if ($name =~ /^e_([a-z]+)$/) {
    my $element = $1;
	
	return $M->_unwrapper( new CBIL::Util::A { 
	  tag => $element,
	  arg => \@_,
	} );
  }
 
  else {
	my $toCall = "CBIL::Util::A::$name";
	return $toCall( @_ );
  }
}

use strict "vars";

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
=item contentType

returns a file content type string.  Default type is 'text/html'.

=cut

sub contentType {
  my $me = shift;
  my $ar = shift;
  
  my $type = defined $ar->{ type } ? $ar->{ type } : 'text/html';
  
  return "Content-type: $type\n\n";
}

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

  #return undef unless $A->ensure('tag', 'atts', 'vals');

  my $html;

  # use new and old attributes
  my $k_tagType; foreach $k_tagType ( 'atts', 'depa' ) {

	# add all attributes of current type
	my $metatag; foreach $metatag ( @{ $A->{ $k_tagType } } ) {
	  
	  #print STDERR "CBIL::CSP::Tohtml: metatag=$metatag ";

	  # something with a value
	  if ($metatag =~ /\%/) {
		my $att = $metatag =~ /^([^%=]+)/ ? $1 : undef;
		
		#print STDERR "att=$att ";
		#print STDERR "arg{att}=$A->{vals}->{$att} ";
		
		if (defined $att and defined $A->{ vals }->{ $att }) {
		  $html .= " " . sprintf( $metatag, $A->{ vals }->{ $att });
		}
	  }
        
	  # something with presence only.
	  else {
		if ( $A->{ $_ } ) {
		  $html .= " $_"; 
		}
	  }

	  #print STDERR "\n";
	} # eo attributes
  } # eo attribute types
  
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
  if (not defined $A->{ BEGIN } or $A->{ BEGIN }) {
    $intro = $me->es( $A );
    $intro .= "\n" if $A->{ newline } or $A->{ inew };
  }

  # ending implied or requested
  if (not defined $A->{ END } or $A->{ END }) {
    $outro = "</$A->{tag}>";
    $outro .= "\n" if $A->{ newline } or $A->{ onew };
  }

  # ending implied or requested
  if (defined $intro and $outro) {
    return undef unless $A->{ vals }->ensure( 'viz' );
    $middle = $A->{ vals }->{ viz };
    $middle .= "\n" if ($A->{ newline } or $A->{ vnew }) and $middle !~ /\n$/;
  }

  return $intro . $middle . $outro;
}


# attribute names

$HIFY::a_abbr           = 'abbr="%s"';
$HIFY::a_accept         = 'accept="%s"';
$HIFY::a_accept_charset = 'accept-charsets="%s"';
$HIFY::a_accesskey      = 'accesskey="%s"';
$HIFY::a_action         = 'action="%s"';
$HIFY::a_align          = 'align="%s"';
$HIFY::a_alt            = 'alt="%s"';
$HIFY::a_archive        = 'archive="%s"';
$HIFY::a_axis           = 'axis="%s"';
$HIFY::a_border         = 'border="%s"';
$HIFY::a_cellpadding    = 'cellpadding="%s"';
$HIFY::a_cellspacing    = 'cellspacing="%s"';
$HIFY::a_char           = 'char="%s"';
$HIFY::a_charoff        = 'charoff="%s"';
$HIFY::a_charset        = 'charset="%s"';
$HIFY::a_checked        = 'checked';
$HIFY::a_cite           = 'cite="%s"';
$HIFY::a_class          = 'class="%s"';
$HIFY::a_classid        = 'classid="%s"';
$HIFY::a_clear          = 'clear="%s"';
$HIFY::a_codebase       = 'codebase="%s"';
$HIFY::a_codetype       = 'codetype="%s"';
$HIFY::a_cols           = 'cols="%s"';
$HIFY::a_colspan        = 'colspan="%s"';
$HIFY::a_content        = 'content="%s"';
$HIFY::a_coords         = 'coords="%s"';
$HIFY::a_data           = 'data="%s"';
$HIFY::a_datetime       = 'datetime="%s"';
$HIFY::a_declare        = 'declare';
$HIFY::a_dir            = 'dir="%s"';
$HIFY::a_disabled       = 'disabled';
$HIFY::a_enctype        = 'enctype="%s"';
$HIFY::a_for            = 'for="%s"';
$HIFY::a_frame          = 'frame="%s"';
$HIFY::a_frameborder    = 'frameborder="%s"';
$HIFY::a_headers        = 'headers="%s"';
$HIFY::a_height         = 'height="%s"';
$HIFY::a_href           = 'href="%s"';
$HIFY::a_hreflang       = 'hreflang="%s"';
$HIFY::a_httpequiv      = 'http-equiv="%s"';
$HIFY::a_id             = 'id="%s"';
$HIFY::a_label          = 'label="%s"';
$HIFY::a_lang           = 'lang="%s"';
$HIFY::a_longdesc       = 'longdesc="%s"';
$HIFY::a_marginwidth    = 'marginwidth="%s"';
$HIFY::a_marginheight   = 'marginheight="%s"';
$HIFY::a_maxlength      = 'maxlength="%s"';
$HIFY::a_media          = 'media="%s"';
$HIFY::a_method         = 'method="%s"';
$HIFY::a_multiple       = 'multiple';
$HIFY::a_name           = 'name="%s"';
$HIFY::a_nohref         = 'nohref';
$HIFY::a_noresize       = 'noresize';
$HIFY::a_onblur         = 'onblur="%s"';
$HIFY::a_onchange       = 'onchange="%s"';
$HIFY::a_onclick        = 'onclick="%s"';
$HIFY::a_ondblclick     = 'ondblclick="%s"';
$HIFY::a_onfocus        = 'onfocus="%s"';
$HIFY::a_onkeydown      = 'onkeydown="%s"';
$HIFY::a_onkeypress     = 'onkeypress="%s"';
$HIFY::a_onkeyup        = 'onkeyup="%s"';
$HIFY::a_onload         = 'onload="%s"';
$HIFY::a_onmousedown    = 'onmousedown="%s"';
$HIFY::a_onmousemove    = 'onmousemove="%s"';
$HIFY::a_onmouseout     = 'onmouseout="%s"';
$HIFY::a_onmouseover    = 'onmouseover="%s"';
$HIFY::a_onmouseup      = 'onmouseup="%s"';
$HIFY::a_onreset        = 'onreset="%s"';
$HIFY::a_onselect       = 'onselect="%s"';
$HIFY::a_onsubmit       = 'onsubmit="%s"';
$HIFY::a_onunload       = 'onunload="%s"';
$HIFY::a_profile        = 'profile="%s"';
$HIFY::a_rel            = 'rel="%s"';
$HIFY::a_rev            = 'rev="%s"';
$HIFY::a_rows           = 'rows="%s"';
$HIFY::a_rowspan        = 'rowspan="%s"';
$HIFY::a_rules          = 'rules="%s"';
$HIFY::a_scheme         = 'scheme="%s"';
$HIFY::a_scope          = 'scope="%s"';
$HIFY::a_scrolling      = 'scrolling="%s"';
$HIFY::a_shape          = 'shape="%s"';
$HIFY::a_selected       = 'selected';
$HIFY::a_size           = 'size="%s"';
$HIFY::a_span           = 'span="%s"';
$HIFY::a_src            = 'src="%s"';
$HIFY::a_standby        = 'standby="%s"';
$HIFY::a_style          = 'style="%s"';
$HIFY::a_summary        = 'summary="%s"';
$HIFY::a_tabindex       = 'tabindex="%s"';
$HIFY::a_target         = 'target="%s"';
$HIFY::a_title          = 'title="%s"';
$HIFY::a_type           = 'type="%s"';
$HIFY::a_usemap         = 'usemap="%s"';
$HIFY::a_valign         = 'valign="%s"';
$HIFY::a_value          = 'value="%s"';
$HIFY::a_valuetype      = 'valuetype="%s"';
$HIFY::a_width          = 'width="%s"';

# list of deprecated attributes.

$HIFY::d_align          = 'align="%s"';
$HIFY::d_alink          = 'alink="%s"';
$HIFY::d_background     = 'background="%s"';
$HIFY::d_bgcolor        = 'bgcolor="%s"';
$HIFY::d_color          = 'color="%s"';
$HIFY::d_compact        = 'compact';
$HIFY::d_face           = 'face="%s"';
$HIFY::d_link           = 'link="%s"';
$HIFY::d_noshade        = 'noshade';
$HIFY::d_size           = 'size="%s"';
$HIFY::d_start          = 'start="%s"';
$HIFY::d_text           = 'text="%s"';
$HIFY::d_type           = 'type="%s"';
$HIFY::d_value          = 'value="%s"';
$HIFY::d_vlink          = 'vlink="%s"';
$HIFY::d_width          = 'width="%s"';
$HIFY::d_height         = 'height="%s"';

# lists of common attribute clusters.

@HIFY::a_CoreAttrs = (
  $HIFY::a_id, $HIFY::a_class, $HIFY::a_style, $HIFY::a_title,
  );

@HIFY::a_i18n = ( 
  $HIFY::a_lang, $HIFY::a_dir 
  );

@HIFY::a_FocusEvents = (
  $HIFY::a_onfocus, $HIFY::a_onblur
  );

@HIFY::a_ValueEvents = (
  $HIFY::a_onselect, $HIFY::a_onchange
);

@HIFY::a_Events = (
  $HIFY::a_onclick, $HIFY::a_ondblclick, $HIFY::a_onmousedown, 
  $HIFY::a_onmouseup, $HIFY::a_onmouseover, $HIFY::a_onmousemove, 
  $HIFY::a_onmouseout, $HIFY::a_onkeypress, $HIFY::a_onkeydown, 
  $HIFY::a_onkeyup,
  );
  
@HIFY::a_IntrinsicEvents 
= (
   $HIFY::a_onfocus  ,   
   $HIFY::a_onblur  ,
   $HIFY::a_onselect    ,
   $HIFY::a_onchange    ,
   $HIFY::a_onclick     ,
   $HIFY::a_ondblclick  ,
   $HIFY::a_onmousedown ,
   $HIFY::a_onmouseup   ,
   $HIFY::a_onmouseover ,
   $HIFY::a_onmousemove ,
   $HIFY::a_onmouseout  ,
   $HIFY::a_onkeypress  ,
   $HIFY::a_onkeydown   ,
   $HIFY::a_onkeyup,
   );

@HIFY::a_InputCommon
= (
  $HIFY::a_id,
  $HIFY::a_class ,
  $HIFY::a_lang ,
  $HIFY::a_title ,
  $HIFY::a_style ,
  $HIFY::a_readonly ,
  $HIFY::a_disabled ,
  $HIFY::a_tabindex ,
);

%HIFY::PhraseElementDescription
= (
  p => 1,
  a => [
    @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
  ],
);

%HIFY::BasicPairDescription
= (
  p => 1,
  a => [
   @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
  ],
);

%HIFY::BasicSingleDescription
= (
  p => 1,
  a => [
  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
  ],
);

%HIFY::QuoteDescription
= (
  p => 1,
  a => [
  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
  $HIFY::a_cite,
  ],
);

%HIFY::HeadingElementDescription
= (
  p => 1,
  a => [
    @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
  ],
);

%HIFY::FontStyleElementDescription
= (
  p => 1,
  a => [
    @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
  ],
);

%HIFY::ElementDictionary
= (

  a       => {
	p => 1,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_charset, 
      $HIFY::a_type, $HIFY::a_name, $HIFY::a_href, $HIFY::a_hreflang, 
      $HIFY::a_rel, $HIFY::a_rev, $HIFY::a_accesskey, $HIFY::a_shape, 
      $HIFY::a_coords, $HIFY::a_tabindex, $HIFY::a_target,
	],
  },

  abbr    => \%HIFY::PhraseElementDescription,
  
  acronym => \%HIFY::PhraseElementDescription,
  
  address => {
	p => 1,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },
  
  area    => {
	p => 0,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_shape, $HIFY::a_coords, $HIFY::a_href, $HIFY::a_nohref, 
	  $HIFY::a_alt, $HIFY::a_tabindex, $HIFY::a_accesskey,
	]
  },
  
  base       => {
	p => 0,
	a => [
	  $HIFY::a_href, $HIFY::a_target
	],
  },
  
  b       => \%HIFY::FontStyleElementDescription,

  basefont     => {
	p => 1,
    a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::d_size, $HIFY::d_color, $HIFY::d_face,
	],
	dep => 1,
  },
  
  big     => \%HIFY::FontStyleElementDescription,
	
  blockquote => \%HIFY::QuoteDescription,
  
  body    => {
    p => 1,
    a => [
      @HIFY::a_CoreAttr, @HIFY::a_i18n, @HIFY::a_Events,
      $HIFY::a_onload, $HIFY::a_onunload,
    ],
    d => [
      $HIFY::d_background, $HIFY::d_text, $HIFY::d_link, $HIFY::d_vlink, 
      $HIFY::d_alink, $HIFY::d_bgcolor
    ]
  },
  

  br      => {
    p => 0,
    a => [
      @HIFY::a_CoreAttr, $HIFY::a_clear,
    ],
  },
  
  caption => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttr, @HIFY::a_i18n, @HIFY::a_Events,
	],
	d => [
	  $HIFY::d_align,
	]
  },
  
  cite    => \%HIFY::PhraseElementDescription,
  
  code    => \%HIFY::PhraseElementDescription,
  
  col     => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttr, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_span, $HIFY::a_width, $HIFY::a_align, $HIFY::a_halign,
	  $HIFY::a_char, $HIFY::a_charoff
	],
  },
  
  colgroup  => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttr, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_span, $HIFY::a_width, $HIFY::a_align, $HIFY::a_halign,
	  $HIFY::a_char, $HIFY::a_charoff
	],
  },
  
  del     => {
    p => 1,
    a => [
      @HIFY::a_CoreAttr, $HIFY::a_cite, $HIFY::a_datetime
    ],
  },

  dfn     => \%HIFY::PhraseElementDescription,
  
  dd      => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },
  
  div     => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
	d => [
	  $HIFY::d_align
        ]
  },
  
  dl      => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },
  
  dt      => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },

  em      =>  \%HIFY::PhraseElementDescription,
  
  fieldset => {
	p => 1,
    a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },
		
  font     => {
	p => 1,
    a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::d_size, $HIFY::d_color, $HIFY::d_face,
	],
	dep => 1,
  },
		
  form     => {
    p => 1,
    a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_action, 
      $HIFY::a_method, $HIFY::a_enctype, $HIFY::a_onsubmit, $HIFY::a_onreset, 
      $HIFY::a_accept_charset, $HIFY::a_accept
    ],
  },
  
  frame    => {
	p => 0,
	a => [
	 $HIFY::a_id, $HIFY::a_class, $HIFY::a_style, $HIFY::a_title,
	 $HIFY::a_longdesc, $HIFY::a_name, $HIFY::a_src, $HIFY::a_frameborder, $HIFY::a_marginwidth, $HIFY::a_marginheight,
	 $HIFY::a_noresize, $HIFY::a_scrolling,
	],
  },
  
  frameset => {
	p => 1,
	a => [
      $HIFY::a_id, $HIFY::a_class, $HIFY::a_style, $HIFY::a_title,
	  $HIFY::a_rows, $HIFY::a_cols, $HIFY::a_onload, $HIFY::a_onunload,
	],
  },
  
  h1       => \%HIFY::HeadingElementDescription,
  h2       => \%HIFY::HeadingElementDescription,
  h3       => \%HIFY::HeadingElementDescription,
  h4       => \%HIFY::HeadingElementDescription,
  h5       => \%HIFY::HeadingElementDescription,
  h6       => \%HIFY::HeadingElementDescription,

  head     => {
    p => 1,
    a => [
      @HIFY::a_i18n, $HIFY::a_profile,
    ],
  },
  
  html     => {
    p => 1,
    a => [
      @HIFY::a_i18n,
    ],
  },
  
  hr       => {
	p => 0,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::d_noshade, $HIFY::d_size, $HIFY::d_width, $HIFY::d_align
	],
	dep => 1,
  },
  

  i        => \%HIFY::FontStyleElementDescription,
  
  iframe   => {
	p => 1,
	a => [
      $HIFY::a_id, $HIFY::a_class, $HIFY::a_style, $HIFY::a_title, 
      $HIFY::a_longdesc, $HIFY::a_name, $HIFY::a_src, $HIFY::a_frameborder, 
      $HIFY::a_marginwidth, $HIFY::a_marginheight, $HIFY::a_scrolling, 
      $HIFY::a_align, $HIFY::a_height, $HIFY::a_width,
	],
  },
  
  img      => {
	p => 0,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_src, $HIFY::a_alt, $HIFY::a_longdesc, $HIFY::a_name, $HIFY::a_height,
	  $HIFY::a_width, $HIFY::a_usemap, $HIFY::a_ismap, $HIFY::a_border
	],
  },
  
  input    => {
	p => 0,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_type, 
      $HIFY::a_name, $HIFY::a_value, $HIFY::a_checked, $HIFY::a_disabled, 
      $HIFY::a_readonly, $HIFY::a_size, $HIFY::a_maxlength, $HIFY::a_src, 
      $HIFY::a_alt, $HIFY::a_usemap, $HIFY::a_tabindex, $HIFY::a_accesskey,
      $HIFY::a_border
	],
  },
                        
  ins     => {
    p => 1,
    a => [
      @HIFY::a_CoreAttr, $HIFY::a_cite, $HIFY::a_datetime
    ],
  },

  kbd      => \%HIFY::PhraseElementDescription,
        
  label    => {
	p => 1,
	a => [
       @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_for, 
       $HIFY::a_accesskey
	 ],
   },

  legend   => {
	p => 1,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_accesskey,
	],
  },

  li   => {
      p => 1,
      a => [
	    @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	    ],
  },

  map      => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_name,
	],
  },
  
  media    => {
	p => 0,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_charset, 
      $HIFY::a_href, $HIFY::a_hreflang, $HIFY::a_type, $HIFY::a_rel, 
      $HIFY::a_rev, $HIFY::a_media,
	],
  },
  
  meta     => {
    p => 0,
    a => [
      @HIFY::a_i18n, $HIFY::a_httpequiv, $HIFY::a_name, $HIFY::a_content, 
      $HIFY::a_scheme,
    ],
  },
  
  noframes => {
	p => 1,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },
  
  object   => {
	p => 1,
	a => [
      @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_declare, 
	  $HIFY::a_classid, $HIFY::a_codebase, $HIFY::a_data, $HIFY::a_type, 
	  $HIFY::a_codetype, $HIFY::a_archive, $HIFY::a_standby, $HIFY::a_height, 
	  $HIFY::a_width, $HIFY::a_usemap, $HIFY::a_name, $HIFY::a_tabindex,
	],
  },
  
  ol       => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },
  
  optgroup => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_disabled, $HIFY::a_label,
	],
  },
                          
  option   => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_selected, $HIFY::a_disabled, $HIFY::a_label, $HIFY::a_value,
	],
  },
        
  p        => \%HIFY::BasicPairDescription,

  param    => {
	p => 0,
	a => [
	  $HIFY::a_id, $HIFY::a_name, $HIFY::a_value, $HIFY::a_valuetype, $HIFY::a_type
	]
  },
  
  pre      => {
    p => 1,
    a => [
    @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
    ],
  },
  
  quote    => \%HIFY::QuoteDescription,
  
  s        => {
	%HIFY::FontStyleElementDescription,
	dep => 1,
  },
	
  samp     => \%HIFY::PhraseElementDescription,
  
  select   => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events, $HIFY::a_name, 
	  $HIFY::a_size, $HIFY::a_multiple, $HIFY::a_disabled, $HIFY::a_tabindex,
	],
  },
   
  small   => \%HIFY::FontStyleElementDescription,

  span    => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
  },
  
  strike   => {
	%HIFY::FontStyleElementDescription,
	dep => 1,
  },
	
  strong   => \%HIFY::PhraseElementDescription,
  
  style    => {
	p => 1,
	a => [
	  @HIFY::a_i18n,
	  $HIFY::a_type, $HIFY::a_media, $HIFY::a_title,
	],
  },
  
  sub      => \%HIFY::BasicPairDescription,
  
  sup      => \%HIFY::BasicPairDescription,
  
  table    => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_summary, $HIFY::a_width, $HIFY::a_border, $HIFY::a_frame,
	  $HIFY::a_rules, $HIFY::a_cellpadding, $HIFY::a_cellspacing,
	],
	d  => [
	  $HIFY::d_align, $HIFY::d_bgcolor, $HIFY::d_height
	],
  },
  
  tbody    => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_align, $HIFY::a_char, $HIFY::a_charoff,
	],
  },

  td       => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttr, @HIFY::a_i18n, @HIFY::a_Events,
	      $HIFY::a_abbr, $HIFY::a_axis, $HIFY::a_headers, $HIFY::a_scope, 
	      $HIFY::a_rowspan, $HIFY::a_colspan, $HIFY::a_align, $HIFY::a_char, 
	      $HIFY::a_charoff, $HIFY::a_valign
	      ],
        d => [
	      $HIFY::d_bgcolor, $HIFY::d_height, $HIFY::d_width
	      ],
  },
  
  textarea => {
        p => 1,
        a => [ 
          $HIFY::a_name, $HIFY::a_rows, $HIFY::a_cols,
          @HIFY::a_InputCommon, @HIFY::a_IntrinsicEvents,
          ],
        },

  tfoot    => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_align, $HIFY::a_char, $HIFY::a_charoff,
	],
  },

  th       => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttr, @HIFY::a_i18n, @HIFY::a_Events,
      $HIFY::a_abbr, $HIFY::a_axis, $HIFY::a_headers, $HIFY::a_scope, 
	  $HIFY::a_rowspan, $HIFY::a_colspan, $HIFY::a_align, $HIFY::a_char, 
	  $HIFY::a_charoff, $HIFY::d_bgcolor
	  ],
	d => [
	      $HIFY::d_bgcolor, $HIFY::d_height, $HIFY::d_width
	      ],
  },
  
  thead    => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_align, $HIFY::a_char, $HIFY::a_charoff,
	],
  },

  title    => {
    p => 1,
    a => [
      @HIFY::a_i18n
    ],
  },
  
  tr       => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttr, @HIFY::a_i18n, @HIFY::a_Events,
	  $HIFY::a_span, $HIFY::a_width, $HIFY::a_align, $HIFY::a_halign,
	  $HIFY::a_char, $HIFY::a_charoff, $HIFY::d_bgcolor
	],
  },
  
  tt       => \%HIFY::FontStyleElementDescription,
  
  u        => {
	%HIFY::FontStyleElementDescription,
	dep => 1,
  },
	
  ul       => {
	p => 1,
	a => [
	  @HIFY::a_CoreAttrs, @HIFY::a_i18n, @HIFY::a_Events,
	],
	d => [
	  $HIFY::d_type, $HIFY::d_start, $HIFY::d_value, $HIFY::d_compact,
	],
  },
  
        
  var      => \%HIFY::PhraseElementDescription,
        
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
  elsif ( ref $arg eq 'ARRAY' ) {
        return join( '',
		             map { 
					   $M->_unwrapper( new CBIL::Util::A { 
						 tag => $A->{ tag },
						 arg => $_,
					   } )
					 } @{ $arg }
					 );
  }
  
  # ref of a ref
  elsif ( ref $arg eq 'REF' ) {
	return $M->_unwrapper( new CBIL::Util::A {
	  arg => $ { $arg },
	  tag => $A->{ tag },
	} );
  }
  
  # a plain hash
  elsif ( ref $arg eq 'HASH' ) {
	return $M->_dispatcher( $A );
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

  my $desc = $HIFY::ElementDictionary{ $A->{ tag } };
  
  return undef if not defined $desc;
  
  # is paired?
  if ( $desc->{ p } ) {
        return $M->ep( new CBIL::Util::A { 
          tag  => $A->{ tag },
          atts => $desc->{ a },
	  depa => $desc->{ d },
          vals => $A->{ arg },
        } );
  }
  
  # or single
  else {
        return $M->es( new CBIL::Util::A {
          tag  => $A->{ tag },
          atts => $desc->{ a },
	  depa => $desc->{ d },
          vals => $A->{ arg },
        } );
  }
}

=pod
=item ElementAttributes

returns a list of the attributes for an element.

=cut

sub ElementAttributes {
  my $M = shift;
  my $A = shift;
  
  my $k_el;
  
  if ( not ref $A ) {
	$k_el = $A;
  }
  elsif ( ref $A ) {
	$k_el = $A->{ element };
  }
  
  return [ sort @{ $HIFY::ElementDictionary{ $k_el }->{ a } } ];
}

=pod
=item InlineStyle

returns a string containing style information formatted as an inline
style.

=cut

sub InlineStyle {
  my $M = shift;
  my $A = shift;

  return join( '; ', map { "$_: $A->{ $_ }" } sort keys %{ $A } );
}

=pod
=item SheetStyle

=cut

sub SheetStyle {
  my $M = shift;
  my $A = shift;
  
  my $s_element = $A->{ element };
  my $s_class   = defined $A->{ class } ? ".$A->{ class }" : "";
  my $s_id      = defined $A->{ id }    ? "#$A->{ id }" : "";

  return $s_element. $s_class. $s_id. '{ '. $A->{ style }. ' }'. "\n";
}

# ......................................................................
# test code

=pod
=item __test

executes a few subtroutines to test the methods.

=cut

sub __test {
  
  my $hify = new CBIL::CSP::Hify;
  
  require FileHandle;
  
  #my $fh_out
  #= new FileHandle ">Hify.to";
  
  #if ( defined $fh_out ) {
	
  print  $hify->e_BR( CBIL::Util::A::e );
	
  print  $hify->E_textarea( new CBIL::Util::A {
	viz  => "That's what I'm talkin' 'bout!",
	rows => 5,
	cols => 70,
  } );
	
  #$fh_out->close();
  #}
  #else {
  #	print STDERR "Unable to open 'hify.out'.\n";
  #}
  
  return 0;
  
}

# ----------------------------------------------------------------------

=pod
=back
=cut

#__test();

1;
