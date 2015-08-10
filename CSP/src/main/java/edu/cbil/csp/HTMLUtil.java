package edu.cbil.csp;

import org.apache.oro.text.perl.Perl5Util;


/**
 * Element
 *
 * A representation for HTML elements.<P>
 *
 * @author CBIL::CSP::HifytoJava.pm
 *
 * Sat May 20 14:37:01 2000
 */
 class Element  {


    // Canonical tag for the element.
    //
    public String tag;

    // Whether the element is comprised of paired tags.
    //
    public boolean paired;

    // Allowed attributes
    //
    public AH attribs;

    // Deprecated attributes
    //
    public AH depr;

    public Element(String tag, boolean paired, AH attribs, 
                           AH depr)
    {
	this.tag = tag;
	this.paired = paired;
	this.attribs = attribs;
	this.depr = depr;
    }

}

/**
 * HTMLUtil
 *
 * A set of routines that support HTML generation.<P>
 *
 * @author CBIL::CSP::HifytoJava.pm
 *
 * Sat May 20 14:37:01 2000
 */
public class HTMLUtil  {

	protected static Element elements[] = 
	{
		// TAG = "a"
		new Element("A", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"charset", "%s",
			"type", "%s",
			"name", "%s",
			"href", "%s",
			"hreflang", "%s",
			"rel", "%s",
			"rev", "%s",
			"accesskey", "%s",
			"shape", "%s",
			"coords", "%s",
			"tabindex", "%s",
			"target", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "abbr"
		new Element("ABBR", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "acronym"
		new Element("ACRONYM", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "address"
		new Element("ADDRESS", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "area"
		new Element("AREA", false,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"shape", "%s",
			"coords", "%s",
			"href", "%s",
			"nohref", "",
			"alt", "%s",
			"tabindex", "%s",
			"accesskey", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "b"
		new Element("B", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "base"
		new Element("BASE", false,
		  new AH(new String[] {
			"href", "%s",
			"target", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "basefont"
		new Element("BASEFONT", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"size", "%s",
			"color", "%s",
			"face", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "big"
		new Element("BIG", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "blockquote"
		new Element("BLOCKQUOTE", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"cite", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "body"
		new Element("BODY", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"onload", "%s",
			"onunload", "%s",
		  }),
		  new AH(new String[] {
			"background", "%s",
			"text", "%s",
			"link", "%s",
			"vlink", "%s",
			"alink", "%s",
			"bgcolor", "%s",
		  })),
		// TAG = "br"
		new Element("BR", false,
		  new AH(new String[] {
			"clear", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "caption"
		new Element("CAPTION", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
			"align", "%s",
		  })),
		// TAG = "cite"
		new Element("CITE", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "code"
		new Element("CODE", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "col"
		new Element("COL", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"span", "%s",
			"width", "%s",
			"align", "%s",
			"", "",
			"char", "%s",
			"charoff", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "colgroup"
		new Element("COLGROUP", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"span", "%s",
			"width", "%s",
			"align", "%s",
			"", "",
			"char", "%s",
			"charoff", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "dd"
		new Element("DD", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "del"
		new Element("DEL", true,
		  new AH(new String[] {
			"cite", "%s",
			"datetime", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "dfn"
		new Element("DFN", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "div"
		new Element("DIV", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
			"align", "%s",
		  })),
		// TAG = "dl"
		new Element("DL", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "dt"
		new Element("DT", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "em"
		new Element("EM", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "fieldset"
		new Element("FIELDSET", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "font"
		new Element("FONT", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"size", "%s",
			"color", "%s",
			"face", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "form"
		new Element("FORM", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"action", "%s",
			"method", "%s",
			"enctype", "%s",
			"onsubmit", "%s",
			"onreset", "%s",
			"accept-charsets", "%s",
			"accept", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "frame"
		new Element("FRAME", false,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"longdesc", "%s",
			"name", "%s",
			"src", "%s",
			"frameborder", "%s",
			"marginwidth", "%s",
			"marginheight", "%s",
			"noresize", "",
			"scrolling", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "frameset"
		new Element("FRAMESET", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"rows", "%s",
			"cols", "%s",
			"onload", "%s",
			"onunload", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "h1"
		new Element("H1", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "h2"
		new Element("H2", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "h3"
		new Element("H3", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "h4"
		new Element("H4", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "h5"
		new Element("H5", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "h6"
		new Element("H6", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "head"
		new Element("HEAD", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"profile", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "hr"
		new Element("HR", false,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"noshade", "",
			"size", "%s",
			"width", "%s",
			"align", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "html"
		new Element("HTML", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "i"
		new Element("I", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "iframe"
		new Element("IFRAME", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"longdesc", "%s",
			"name", "%s",
			"src", "%s",
			"frameborder", "%s",
			"marginwidth", "%s",
			"marginheight", "%s",
			"scrolling", "%s",
			"align", "%s",
			"height", "%s",
			"width", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "img"
		new Element("IMG", false,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"src", "%s",
			"alt", "%s",
			"longdesc", "%s",
			"name", "%s",
			"height", "%s",
			"width", "%s",
			"usemap", "%s",
			"", "",
			"border", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "input"
		new Element("INPUT", false,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"type", "%s",
			"name", "%s",
			"value", "%s",
			"checked", "",
			"disabled", "",
			"", "",
			"size", "%s",
			"maxlength", "%s",
			"src", "%s",
			"alt", "%s",
			"usemap", "%s",
			"tabindex", "%s",
			"accesskey", "%s",
			"border", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "ins"
		new Element("INS", true,
		  new AH(new String[] {
			"cite", "%s",
			"datetime", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "kbd"
		new Element("KBD", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "label"
		new Element("LABEL", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"for", "%s",
			"accesskey", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "legend"
		new Element("LEGEND", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"accesskey", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "li"
		new Element("LI", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "map"
		new Element("MAP", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"name", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "media"
		new Element("MEDIA", false,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"charset", "%s",
			"href", "%s",
			"hreflang", "%s",
			"type", "%s",
			"rel", "%s",
			"rev", "%s",
			"media", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "meta"
		new Element("META", false,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"http-equiv", "%s",
			"name", "%s",
			"content", "%s",
			"scheme", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "noframes"
		new Element("NOFRAMES", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "object"
		new Element("OBJECT", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"declare", "",
			"classid", "%s",
			"codebase", "%s",
			"data", "%s",
			"type", "%s",
			"codetype", "%s",
			"archive", "%s",
			"standby", "%s",
			"height", "%s",
			"width", "%s",
			"usemap", "%s",
			"name", "%s",
			"tabindex", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "ol"
		new Element("OL", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "optgroup"
		new Element("OPTGROUP", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"disabled", "",
			"label", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "option"
		new Element("OPTION", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"selected", "",
			"disabled", "",
			"label", "%s",
			"value", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "p"
		new Element("P", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "param"
		new Element("PARAM", false,
		  new AH(new String[] {
			"id", "%s",
			"name", "%s",
			"value", "%s",
			"valuetype", "%s",
			"type", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "pre"
		new Element("PRE", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "quote"
		new Element("QUOTE", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"cite", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "s"
		new Element("S", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "samp"
		new Element("SAMP", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "select"
		new Element("SELECT", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"name", "%s",
			"size", "%s",
			"multiple", "",
			"disabled", "",
			"tabindex", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "small"
		new Element("SMALL", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "span"
		new Element("SPAN", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "strike"
		new Element("STRIKE", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "strong"
		new Element("STRONG", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "style"
		new Element("STYLE", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"type", "%s",
			"media", "%s",
			"title", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "sub"
		new Element("SUB", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "sup"
		new Element("SUP", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "table"
		new Element("TABLE", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"summary", "%s",
			"width", "%s",
			"border", "%s",
			"frame", "%s",
			"rules", "%s",
			"cellpadding", "%s",
			"cellspacing", "%s",
		  }),
		  new AH(new String[] {
			"align", "%s",
			"bgcolor", "%s",
			"height", "%s",
		  })),
		// TAG = "tbody"
		new Element("TBODY", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"align", "%s",
			"char", "%s",
			"charoff", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "td"
		new Element("TD", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"abbr", "%s",
			"axis", "%s",
			"headers", "%s",
			"scope", "%s",
			"rowspan", "%s",
			"colspan", "%s",
			"align", "%s",
			"char", "%s",
			"charoff", "%s",
			"valign", "%s",
		  }),
		  new AH(new String[] {
			"bgcolor", "%s",
			"height", "%s",
			"width", "%s",
		  })),
		// TAG = "textarea"
		new Element("TEXTAREA", true,
		  new AH(new String[] {
			"name", "%s",
			"rows", "%s",
			"cols", "%s",
			"id", "%s",
			"class", "%s",
			"lang", "%s",
			"title", "%s",
			"style", "%s",
			"", "",
			"disabled", "",
			"tabindex", "%s",
			"onfocus", "%s",
			"onblur", "%s",
			"onselect", "%s",
			"onchange", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "tfoot"
		new Element("TFOOT", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"align", "%s",
			"char", "%s",
			"charoff", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "th"
		new Element("TH", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"abbr", "%s",
			"axis", "%s",
			"headers", "%s",
			"scope", "%s",
			"rowspan", "%s",
			"colspan", "%s",
			"align", "%s",
			"char", "%s",
			"charoff", "%s",
			"bgcolor", "%s",
		  }),
		  new AH(new String[] {
			"bgcolor", "%s",
			"height", "%s",
			"width", "%s",
		  })),
		// TAG = "thead"
		new Element("THEAD", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"align", "%s",
			"char", "%s",
			"charoff", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "title"
		new Element("TITLE", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "tr"
		new Element("TR", true,
		  new AH(new String[] {
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
			"span", "%s",
			"width", "%s",
			"align", "%s",
			"", "",
			"char", "%s",
			"charoff", "%s",
			"bgcolor", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "tt"
		new Element("TT", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "u"
		new Element("U", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		// TAG = "ul"
		new Element("UL", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
			"type", "%s",
			"start", "%s",
			"value", "%s",
			"compact", "",
		  })),
		// TAG = "var"
		new Element("VAR", true,
		  new AH(new String[] {
			"id", "%s",
			"class", "%s",
			"style", "%s",
			"title", "%s",
			"lang", "%s",
			"dir", "%s",
			"onclick", "%s",
			"ondblclick", "%s",
			"onmousedown", "%s",
			"onmouseup", "%s",
			"onmouseover", "%s",
			"onmousemove", "%s",
			"onmouseout", "%s",
			"onkeypress", "%s",
			"onkeydown", "%s",
			"onkeyup", "%s",
		  }),
		  new AH(new String[] {
		  })),
		};

    protected final static Perl5Util util = new Perl5Util();

    protected final static String beginTag(Element el, AH args) {
	StringBuffer result = new StringBuffer();
	result.append('<');
	result.append(el.tag);

	AH attr = el.attribs;
	AH depr = el.depr;

	java.util.Enumeration<?> attrs = args.keys();

	while (attrs.hasMoreElements()) {
	    String att = (String)(attrs.nextElement());
	    String descr = attr.get(att);

	    if (descr == null) {
		// TO DO: deprecated warning
		descr = depr.get(att);
	    }

	    if (descr == null) {
		System.err.println("Unknown/illegal attribute '" + att + "'" +
				   " for tag '" + el.tag + "'");
	    }

	    if (descr.equals("%s")) {
		// Attribute requires value
		String val = args.get(att);

		if (val == null) {
		    System.err.println("No value specified for attribute '" + att + "'" +
				       " of tag '" + el.tag + "'");
		}

                result.append(' ');
	        result.append(att);
		result.append("=\"" + val + "\"");
	    } else {
		// Present/absent only
		//
                result.append(' ');
	        result.append(att);
	    }
	}

	result.append('>');
        return result.toString();
    }

    protected final static String endTag(Element el, AH args) {
	StringBuffer result = new StringBuffer();
	result.append("</");
	result.append(el.tag);
	result.append('>');
	return result.toString();
    }

    protected final static String handler(int tagnum, AH args, String content,
					  boolean omit_begin, boolean omit_end) {
	Element el = elements[tagnum];

	if (el == null) {
	    throw new IllegalArgumentException("UNKNOWN HTML TAGNUM '" + tagnum + "'");
	}
	
	StringBuffer result = new StringBuffer();

	if (!omit_begin) result.append(beginTag(el, args));

	if (!omit_begin && !omit_end && content != null) {
	    if (!el.paired) {
		System.err.println("Error - content specified for unpaired tag '" 
				   + el.tag + "'");
	    }
	    result.append(content);
	}

	if (!omit_end && el.paired) result.append(endTag(el, args));
	return result.toString();
    }

public final static String A(String content)
{
    return handler(0, AH.E, content, false, false);
}

public final static String A(AH args, String content)
{
    return handler(0, args, content, false, false);
}

public final static String A(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(0, args, content, omit_begin, omit_end);
}

public final static String A()
{
    return handler(0, AH.E, null, false, false);
}

public final static String A(AH args)
{
    return handler(0, args, null, false, false);
}

public final static String A(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(0, args, null, omit_begin, omit_end);
}

public final static String A(boolean omit_begin, boolean omit_end)
{
    return handler(0, AH.E, null, omit_begin, omit_end);
}

public final static String a(String content)
{
    return handler(0, AH.E, content, false, false);
}

public final static String a(AH args, String content)
{
    return handler(0, args, content, false, false);
}

public final static String a(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(0, args, content, omit_begin, omit_end);
}

public final static String a()
{
    return handler(0, AH.E, null, false, false);
}

public final static String a(AH args)
{
    return handler(0, args, null, false, false);
}

public final static String a(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(0, args, null, omit_begin, omit_end);
}

public final static String a(boolean omit_begin, boolean omit_end)
{
    return handler(0, AH.E, null, omit_begin, omit_end);
}

public final static String ABBR(String content)
{
    return handler(1, AH.E, content, false, false);
}

public final static String ABBR(AH args, String content)
{
    return handler(1, args, content, false, false);
}

public final static String ABBR(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(1, args, content, omit_begin, omit_end);
}

public final static String ABBR()
{
    return handler(1, AH.E, null, false, false);
}

public final static String ABBR(AH args)
{
    return handler(1, args, null, false, false);
}

public final static String ABBR(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(1, args, null, omit_begin, omit_end);
}

public final static String ABBR(boolean omit_begin, boolean omit_end)
{
    return handler(1, AH.E, null, omit_begin, omit_end);
}

public final static String abbr(String content)
{
    return handler(1, AH.E, content, false, false);
}

public final static String abbr(AH args, String content)
{
    return handler(1, args, content, false, false);
}

public final static String abbr(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(1, args, content, omit_begin, omit_end);
}

public final static String abbr()
{
    return handler(1, AH.E, null, false, false);
}

public final static String abbr(AH args)
{
    return handler(1, args, null, false, false);
}

public final static String abbr(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(1, args, null, omit_begin, omit_end);
}

public final static String abbr(boolean omit_begin, boolean omit_end)
{
    return handler(1, AH.E, null, omit_begin, omit_end);
}

public final static String ACRONYM(String content)
{
    return handler(2, AH.E, content, false, false);
}

public final static String ACRONYM(AH args, String content)
{
    return handler(2, args, content, false, false);
}

public final static String ACRONYM(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(2, args, content, omit_begin, omit_end);
}

public final static String ACRONYM()
{
    return handler(2, AH.E, null, false, false);
}

public final static String ACRONYM(AH args)
{
    return handler(2, args, null, false, false);
}

public final static String ACRONYM(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(2, args, null, omit_begin, omit_end);
}

public final static String ACRONYM(boolean omit_begin, boolean omit_end)
{
    return handler(2, AH.E, null, omit_begin, omit_end);
}

public final static String acronym(String content)
{
    return handler(2, AH.E, content, false, false);
}

public final static String acronym(AH args, String content)
{
    return handler(2, args, content, false, false);
}

public final static String acronym(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(2, args, content, omit_begin, omit_end);
}

public final static String acronym()
{
    return handler(2, AH.E, null, false, false);
}

public final static String acronym(AH args)
{
    return handler(2, args, null, false, false);
}

public final static String acronym(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(2, args, null, omit_begin, omit_end);
}

public final static String acronym(boolean omit_begin, boolean omit_end)
{
    return handler(2, AH.E, null, omit_begin, omit_end);
}

public final static String ADDRESS(String content)
{
    return handler(3, AH.E, content, false, false);
}

public final static String ADDRESS(AH args, String content)
{
    return handler(3, args, content, false, false);
}

public final static String ADDRESS(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(3, args, content, omit_begin, omit_end);
}

public final static String ADDRESS()
{
    return handler(3, AH.E, null, false, false);
}

public final static String ADDRESS(AH args)
{
    return handler(3, args, null, false, false);
}

public final static String ADDRESS(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(3, args, null, omit_begin, omit_end);
}

public final static String ADDRESS(boolean omit_begin, boolean omit_end)
{
    return handler(3, AH.E, null, omit_begin, omit_end);
}

public final static String address(String content)
{
    return handler(3, AH.E, content, false, false);
}

public final static String address(AH args, String content)
{
    return handler(3, args, content, false, false);
}

public final static String address(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(3, args, content, omit_begin, omit_end);
}

public final static String address()
{
    return handler(3, AH.E, null, false, false);
}

public final static String address(AH args)
{
    return handler(3, args, null, false, false);
}

public final static String address(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(3, args, null, omit_begin, omit_end);
}

public final static String address(boolean omit_begin, boolean omit_end)
{
    return handler(3, AH.E, null, omit_begin, omit_end);
}

public final static String AREA()
{
    return handler(4, AH.E, null, false, false);
}

public final static String AREA(AH args)
{
    return handler(4, args, null, false, false);
}

public final static String AREA(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(4, args, null, omit_begin, omit_end);
}

public final static String AREA(boolean omit_begin, boolean omit_end)
{
    return handler(4, AH.E, null, omit_begin, omit_end);
}

public final static String area()
{
    return handler(4, AH.E, null, false, false);
}

public final static String area(AH args)
{
    return handler(4, args, null, false, false);
}

public final static String area(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(4, args, null, omit_begin, omit_end);
}

public final static String area(boolean omit_begin, boolean omit_end)
{
    return handler(4, AH.E, null, omit_begin, omit_end);
}

public final static String B(String content)
{
    return handler(5, AH.E, content, false, false);
}

public final static String B(AH args, String content)
{
    return handler(5, args, content, false, false);
}

public final static String B(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(5, args, content, omit_begin, omit_end);
}

public final static String B()
{
    return handler(5, AH.E, null, false, false);
}

public final static String B(AH args)
{
    return handler(5, args, null, false, false);
}

public final static String B(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(5, args, null, omit_begin, omit_end);
}

public final static String B(boolean omit_begin, boolean omit_end)
{
    return handler(5, AH.E, null, omit_begin, omit_end);
}

public final static String b(String content)
{
    return handler(5, AH.E, content, false, false);
}

public final static String b(AH args, String content)
{
    return handler(5, args, content, false, false);
}

public final static String b(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(5, args, content, omit_begin, omit_end);
}

public final static String b()
{
    return handler(5, AH.E, null, false, false);
}

public final static String b(AH args)
{
    return handler(5, args, null, false, false);
}

public final static String b(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(5, args, null, omit_begin, omit_end);
}

public final static String b(boolean omit_begin, boolean omit_end)
{
    return handler(5, AH.E, null, omit_begin, omit_end);
}

public final static String BASE()
{
    return handler(6, AH.E, null, false, false);
}

public final static String BASE(AH args)
{
    return handler(6, args, null, false, false);
}

public final static String BASE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(6, args, null, omit_begin, omit_end);
}

public final static String BASE(boolean omit_begin, boolean omit_end)
{
    return handler(6, AH.E, null, omit_begin, omit_end);
}

public final static String base()
{
    return handler(6, AH.E, null, false, false);
}

public final static String base(AH args)
{
    return handler(6, args, null, false, false);
}

public final static String base(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(6, args, null, omit_begin, omit_end);
}

public final static String base(boolean omit_begin, boolean omit_end)
{
    return handler(6, AH.E, null, omit_begin, omit_end);
}

public final static String BASEFONT(String content)
{
    return handler(7, AH.E, content, false, false);
}

public final static String BASEFONT(AH args, String content)
{
    return handler(7, args, content, false, false);
}

public final static String BASEFONT(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(7, args, content, omit_begin, omit_end);
}

public final static String BASEFONT()
{
    return handler(7, AH.E, null, false, false);
}

public final static String BASEFONT(AH args)
{
    return handler(7, args, null, false, false);
}

public final static String BASEFONT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(7, args, null, omit_begin, omit_end);
}

public final static String BASEFONT(boolean omit_begin, boolean omit_end)
{
    return handler(7, AH.E, null, omit_begin, omit_end);
}

public final static String basefont(String content)
{
    return handler(7, AH.E, content, false, false);
}

public final static String basefont(AH args, String content)
{
    return handler(7, args, content, false, false);
}

public final static String basefont(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(7, args, content, omit_begin, omit_end);
}

public final static String basefont()
{
    return handler(7, AH.E, null, false, false);
}

public final static String basefont(AH args)
{
    return handler(7, args, null, false, false);
}

public final static String basefont(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(7, args, null, omit_begin, omit_end);
}

public final static String basefont(boolean omit_begin, boolean omit_end)
{
    return handler(7, AH.E, null, omit_begin, omit_end);
}

public final static String BIG(String content)
{
    return handler(8, AH.E, content, false, false);
}

public final static String BIG(AH args, String content)
{
    return handler(8, args, content, false, false);
}

public final static String BIG(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(8, args, content, omit_begin, omit_end);
}

public final static String BIG()
{
    return handler(8, AH.E, null, false, false);
}

public final static String BIG(AH args)
{
    return handler(8, args, null, false, false);
}

public final static String BIG(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(8, args, null, omit_begin, omit_end);
}

public final static String BIG(boolean omit_begin, boolean omit_end)
{
    return handler(8, AH.E, null, omit_begin, omit_end);
}

public final static String big(String content)
{
    return handler(8, AH.E, content, false, false);
}

public final static String big(AH args, String content)
{
    return handler(8, args, content, false, false);
}

public final static String big(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(8, args, content, omit_begin, omit_end);
}

public final static String big()
{
    return handler(8, AH.E, null, false, false);
}

public final static String big(AH args)
{
    return handler(8, args, null, false, false);
}

public final static String big(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(8, args, null, omit_begin, omit_end);
}

public final static String big(boolean omit_begin, boolean omit_end)
{
    return handler(8, AH.E, null, omit_begin, omit_end);
}

public final static String BLOCKQUOTE(String content)
{
    return handler(9, AH.E, content, false, false);
}

public final static String BLOCKQUOTE(AH args, String content)
{
    return handler(9, args, content, false, false);
}

public final static String BLOCKQUOTE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(9, args, content, omit_begin, omit_end);
}

public final static String BLOCKQUOTE()
{
    return handler(9, AH.E, null, false, false);
}

public final static String BLOCKQUOTE(AH args)
{
    return handler(9, args, null, false, false);
}

public final static String BLOCKQUOTE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(9, args, null, omit_begin, omit_end);
}

public final static String BLOCKQUOTE(boolean omit_begin, boolean omit_end)
{
    return handler(9, AH.E, null, omit_begin, omit_end);
}

public final static String blockquote(String content)
{
    return handler(9, AH.E, content, false, false);
}

public final static String blockquote(AH args, String content)
{
    return handler(9, args, content, false, false);
}

public final static String blockquote(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(9, args, content, omit_begin, omit_end);
}

public final static String blockquote()
{
    return handler(9, AH.E, null, false, false);
}

public final static String blockquote(AH args)
{
    return handler(9, args, null, false, false);
}

public final static String blockquote(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(9, args, null, omit_begin, omit_end);
}

public final static String blockquote(boolean omit_begin, boolean omit_end)
{
    return handler(9, AH.E, null, omit_begin, omit_end);
}

public final static String BODY(String content)
{
    return handler(10, AH.E, content, false, false);
}

public final static String BODY(AH args, String content)
{
    return handler(10, args, content, false, false);
}

public final static String BODY(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(10, args, content, omit_begin, omit_end);
}

public final static String BODY()
{
    return handler(10, AH.E, null, false, false);
}

public final static String BODY(AH args)
{
    return handler(10, args, null, false, false);
}

public final static String BODY(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(10, args, null, omit_begin, omit_end);
}

public final static String BODY(boolean omit_begin, boolean omit_end)
{
    return handler(10, AH.E, null, omit_begin, omit_end);
}

public final static String body(String content)
{
    return handler(10, AH.E, content, false, false);
}

public final static String body(AH args, String content)
{
    return handler(10, args, content, false, false);
}

public final static String body(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(10, args, content, omit_begin, omit_end);
}

public final static String body()
{
    return handler(10, AH.E, null, false, false);
}

public final static String body(AH args)
{
    return handler(10, args, null, false, false);
}

public final static String body(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(10, args, null, omit_begin, omit_end);
}

public final static String body(boolean omit_begin, boolean omit_end)
{
    return handler(10, AH.E, null, omit_begin, omit_end);
}

public final static String BR()
{
    return handler(11, AH.E, null, false, false);
}

public final static String BR(AH args)
{
    return handler(11, args, null, false, false);
}

public final static String BR(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(11, args, null, omit_begin, omit_end);
}

public final static String BR(boolean omit_begin, boolean omit_end)
{
    return handler(11, AH.E, null, omit_begin, omit_end);
}

public final static String br()
{
    return handler(11, AH.E, null, false, false);
}

public final static String br(AH args)
{
    return handler(11, args, null, false, false);
}

public final static String br(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(11, args, null, omit_begin, omit_end);
}

public final static String br(boolean omit_begin, boolean omit_end)
{
    return handler(11, AH.E, null, omit_begin, omit_end);
}

public final static String CAPTION(String content)
{
    return handler(12, AH.E, content, false, false);
}

public final static String CAPTION(AH args, String content)
{
    return handler(12, args, content, false, false);
}

public final static String CAPTION(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(12, args, content, omit_begin, omit_end);
}

public final static String CAPTION()
{
    return handler(12, AH.E, null, false, false);
}

public final static String CAPTION(AH args)
{
    return handler(12, args, null, false, false);
}

public final static String CAPTION(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(12, args, null, omit_begin, omit_end);
}

public final static String CAPTION(boolean omit_begin, boolean omit_end)
{
    return handler(12, AH.E, null, omit_begin, omit_end);
}

public final static String caption(String content)
{
    return handler(12, AH.E, content, false, false);
}

public final static String caption(AH args, String content)
{
    return handler(12, args, content, false, false);
}

public final static String caption(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(12, args, content, omit_begin, omit_end);
}

public final static String caption()
{
    return handler(12, AH.E, null, false, false);
}

public final static String caption(AH args)
{
    return handler(12, args, null, false, false);
}

public final static String caption(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(12, args, null, omit_begin, omit_end);
}

public final static String caption(boolean omit_begin, boolean omit_end)
{
    return handler(12, AH.E, null, omit_begin, omit_end);
}

public final static String CITE(String content)
{
    return handler(13, AH.E, content, false, false);
}

public final static String CITE(AH args, String content)
{
    return handler(13, args, content, false, false);
}

public final static String CITE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(13, args, content, omit_begin, omit_end);
}

public final static String CITE()
{
    return handler(13, AH.E, null, false, false);
}

public final static String CITE(AH args)
{
    return handler(13, args, null, false, false);
}

public final static String CITE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(13, args, null, omit_begin, omit_end);
}

public final static String CITE(boolean omit_begin, boolean omit_end)
{
    return handler(13, AH.E, null, omit_begin, omit_end);
}

public final static String cite(String content)
{
    return handler(13, AH.E, content, false, false);
}

public final static String cite(AH args, String content)
{
    return handler(13, args, content, false, false);
}

public final static String cite(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(13, args, content, omit_begin, omit_end);
}

public final static String cite()
{
    return handler(13, AH.E, null, false, false);
}

public final static String cite(AH args)
{
    return handler(13, args, null, false, false);
}

public final static String cite(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(13, args, null, omit_begin, omit_end);
}

public final static String cite(boolean omit_begin, boolean omit_end)
{
    return handler(13, AH.E, null, omit_begin, omit_end);
}

public final static String CODE(String content)
{
    return handler(14, AH.E, content, false, false);
}

public final static String CODE(AH args, String content)
{
    return handler(14, args, content, false, false);
}

public final static String CODE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(14, args, content, omit_begin, omit_end);
}

public final static String CODE()
{
    return handler(14, AH.E, null, false, false);
}

public final static String CODE(AH args)
{
    return handler(14, args, null, false, false);
}

public final static String CODE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(14, args, null, omit_begin, omit_end);
}

public final static String CODE(boolean omit_begin, boolean omit_end)
{
    return handler(14, AH.E, null, omit_begin, omit_end);
}

public final static String code(String content)
{
    return handler(14, AH.E, content, false, false);
}

public final static String code(AH args, String content)
{
    return handler(14, args, content, false, false);
}

public final static String code(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(14, args, content, omit_begin, omit_end);
}

public final static String code()
{
    return handler(14, AH.E, null, false, false);
}

public final static String code(AH args)
{
    return handler(14, args, null, false, false);
}

public final static String code(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(14, args, null, omit_begin, omit_end);
}

public final static String code(boolean omit_begin, boolean omit_end)
{
    return handler(14, AH.E, null, omit_begin, omit_end);
}

public final static String COL(String content)
{
    return handler(15, AH.E, content, false, false);
}

public final static String COL(AH args, String content)
{
    return handler(15, args, content, false, false);
}

public final static String COL(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(15, args, content, omit_begin, omit_end);
}

public final static String COL()
{
    return handler(15, AH.E, null, false, false);
}

public final static String COL(AH args)
{
    return handler(15, args, null, false, false);
}

public final static String COL(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(15, args, null, omit_begin, omit_end);
}

public final static String COL(boolean omit_begin, boolean omit_end)
{
    return handler(15, AH.E, null, omit_begin, omit_end);
}

public final static String col(String content)
{
    return handler(15, AH.E, content, false, false);
}

public final static String col(AH args, String content)
{
    return handler(15, args, content, false, false);
}

public final static String col(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(15, args, content, omit_begin, omit_end);
}

public final static String col()
{
    return handler(15, AH.E, null, false, false);
}

public final static String col(AH args)
{
    return handler(15, args, null, false, false);
}

public final static String col(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(15, args, null, omit_begin, omit_end);
}

public final static String col(boolean omit_begin, boolean omit_end)
{
    return handler(15, AH.E, null, omit_begin, omit_end);
}

public final static String COLGROUP(String content)
{
    return handler(16, AH.E, content, false, false);
}

public final static String COLGROUP(AH args, String content)
{
    return handler(16, args, content, false, false);
}

public final static String COLGROUP(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(16, args, content, omit_begin, omit_end);
}

public final static String COLGROUP()
{
    return handler(16, AH.E, null, false, false);
}

public final static String COLGROUP(AH args)
{
    return handler(16, args, null, false, false);
}

public final static String COLGROUP(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(16, args, null, omit_begin, omit_end);
}

public final static String COLGROUP(boolean omit_begin, boolean omit_end)
{
    return handler(16, AH.E, null, omit_begin, omit_end);
}

public final static String colgroup(String content)
{
    return handler(16, AH.E, content, false, false);
}

public final static String colgroup(AH args, String content)
{
    return handler(16, args, content, false, false);
}

public final static String colgroup(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(16, args, content, omit_begin, omit_end);
}

public final static String colgroup()
{
    return handler(16, AH.E, null, false, false);
}

public final static String colgroup(AH args)
{
    return handler(16, args, null, false, false);
}

public final static String colgroup(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(16, args, null, omit_begin, omit_end);
}

public final static String colgroup(boolean omit_begin, boolean omit_end)
{
    return handler(16, AH.E, null, omit_begin, omit_end);
}

public final static String DD(String content)
{
    return handler(17, AH.E, content, false, false);
}

public final static String DD(AH args, String content)
{
    return handler(17, args, content, false, false);
}

public final static String DD(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(17, args, content, omit_begin, omit_end);
}

public final static String DD()
{
    return handler(17, AH.E, null, false, false);
}

public final static String DD(AH args)
{
    return handler(17, args, null, false, false);
}

public final static String DD(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(17, args, null, omit_begin, omit_end);
}

public final static String DD(boolean omit_begin, boolean omit_end)
{
    return handler(17, AH.E, null, omit_begin, omit_end);
}

public final static String dd(String content)
{
    return handler(17, AH.E, content, false, false);
}

public final static String dd(AH args, String content)
{
    return handler(17, args, content, false, false);
}

public final static String dd(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(17, args, content, omit_begin, omit_end);
}

public final static String dd()
{
    return handler(17, AH.E, null, false, false);
}

public final static String dd(AH args)
{
    return handler(17, args, null, false, false);
}

public final static String dd(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(17, args, null, omit_begin, omit_end);
}

public final static String dd(boolean omit_begin, boolean omit_end)
{
    return handler(17, AH.E, null, omit_begin, omit_end);
}

public final static String DEL(String content)
{
    return handler(18, AH.E, content, false, false);
}

public final static String DEL(AH args, String content)
{
    return handler(18, args, content, false, false);
}

public final static String DEL(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(18, args, content, omit_begin, omit_end);
}

public final static String DEL()
{
    return handler(18, AH.E, null, false, false);
}

public final static String DEL(AH args)
{
    return handler(18, args, null, false, false);
}

public final static String DEL(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(18, args, null, omit_begin, omit_end);
}

public final static String DEL(boolean omit_begin, boolean omit_end)
{
    return handler(18, AH.E, null, omit_begin, omit_end);
}

public final static String del(String content)
{
    return handler(18, AH.E, content, false, false);
}

public final static String del(AH args, String content)
{
    return handler(18, args, content, false, false);
}

public final static String del(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(18, args, content, omit_begin, omit_end);
}

public final static String del()
{
    return handler(18, AH.E, null, false, false);
}

public final static String del(AH args)
{
    return handler(18, args, null, false, false);
}

public final static String del(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(18, args, null, omit_begin, omit_end);
}

public final static String del(boolean omit_begin, boolean omit_end)
{
    return handler(18, AH.E, null, omit_begin, omit_end);
}

public final static String DFN(String content)
{
    return handler(19, AH.E, content, false, false);
}

public final static String DFN(AH args, String content)
{
    return handler(19, args, content, false, false);
}

public final static String DFN(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(19, args, content, omit_begin, omit_end);
}

public final static String DFN()
{
    return handler(19, AH.E, null, false, false);
}

public final static String DFN(AH args)
{
    return handler(19, args, null, false, false);
}

public final static String DFN(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(19, args, null, omit_begin, omit_end);
}

public final static String DFN(boolean omit_begin, boolean omit_end)
{
    return handler(19, AH.E, null, omit_begin, omit_end);
}

public final static String dfn(String content)
{
    return handler(19, AH.E, content, false, false);
}

public final static String dfn(AH args, String content)
{
    return handler(19, args, content, false, false);
}

public final static String dfn(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(19, args, content, omit_begin, omit_end);
}

public final static String dfn()
{
    return handler(19, AH.E, null, false, false);
}

public final static String dfn(AH args)
{
    return handler(19, args, null, false, false);
}

public final static String dfn(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(19, args, null, omit_begin, omit_end);
}

public final static String dfn(boolean omit_begin, boolean omit_end)
{
    return handler(19, AH.E, null, omit_begin, omit_end);
}

public final static String DIV(String content)
{
    return handler(20, AH.E, content, false, false);
}

public final static String DIV(AH args, String content)
{
    return handler(20, args, content, false, false);
}

public final static String DIV(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(20, args, content, omit_begin, omit_end);
}

public final static String DIV()
{
    return handler(20, AH.E, null, false, false);
}

public final static String DIV(AH args)
{
    return handler(20, args, null, false, false);
}

public final static String DIV(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(20, args, null, omit_begin, omit_end);
}

public final static String DIV(boolean omit_begin, boolean omit_end)
{
    return handler(20, AH.E, null, omit_begin, omit_end);
}

public final static String div(String content)
{
    return handler(20, AH.E, content, false, false);
}

public final static String div(AH args, String content)
{
    return handler(20, args, content, false, false);
}

public final static String div(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(20, args, content, omit_begin, omit_end);
}

public final static String div()
{
    return handler(20, AH.E, null, false, false);
}

public final static String div(AH args)
{
    return handler(20, args, null, false, false);
}

public final static String div(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(20, args, null, omit_begin, omit_end);
}

public final static String div(boolean omit_begin, boolean omit_end)
{
    return handler(20, AH.E, null, omit_begin, omit_end);
}

public final static String DL(String content)
{
    return handler(21, AH.E, content, false, false);
}

public final static String DL(AH args, String content)
{
    return handler(21, args, content, false, false);
}

public final static String DL(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(21, args, content, omit_begin, omit_end);
}

public final static String DL()
{
    return handler(21, AH.E, null, false, false);
}

public final static String DL(AH args)
{
    return handler(21, args, null, false, false);
}

public final static String DL(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(21, args, null, omit_begin, omit_end);
}

public final static String DL(boolean omit_begin, boolean omit_end)
{
    return handler(21, AH.E, null, omit_begin, omit_end);
}

public final static String dl(String content)
{
    return handler(21, AH.E, content, false, false);
}

public final static String dl(AH args, String content)
{
    return handler(21, args, content, false, false);
}

public final static String dl(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(21, args, content, omit_begin, omit_end);
}

public final static String dl()
{
    return handler(21, AH.E, null, false, false);
}

public final static String dl(AH args)
{
    return handler(21, args, null, false, false);
}

public final static String dl(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(21, args, null, omit_begin, omit_end);
}

public final static String dl(boolean omit_begin, boolean omit_end)
{
    return handler(21, AH.E, null, omit_begin, omit_end);
}

public final static String DT(String content)
{
    return handler(22, AH.E, content, false, false);
}

public final static String DT(AH args, String content)
{
    return handler(22, args, content, false, false);
}

public final static String DT(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(22, args, content, omit_begin, omit_end);
}

public final static String DT()
{
    return handler(22, AH.E, null, false, false);
}

public final static String DT(AH args)
{
    return handler(22, args, null, false, false);
}

public final static String DT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(22, args, null, omit_begin, omit_end);
}

public final static String DT(boolean omit_begin, boolean omit_end)
{
    return handler(22, AH.E, null, omit_begin, omit_end);
}

public final static String dt(String content)
{
    return handler(22, AH.E, content, false, false);
}

public final static String dt(AH args, String content)
{
    return handler(22, args, content, false, false);
}

public final static String dt(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(22, args, content, omit_begin, omit_end);
}

public final static String dt()
{
    return handler(22, AH.E, null, false, false);
}

public final static String dt(AH args)
{
    return handler(22, args, null, false, false);
}

public final static String dt(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(22, args, null, omit_begin, omit_end);
}

public final static String dt(boolean omit_begin, boolean omit_end)
{
    return handler(22, AH.E, null, omit_begin, omit_end);
}

public final static String EM(String content)
{
    return handler(23, AH.E, content, false, false);
}

public final static String EM(AH args, String content)
{
    return handler(23, args, content, false, false);
}

public final static String EM(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(23, args, content, omit_begin, omit_end);
}

public final static String EM()
{
    return handler(23, AH.E, null, false, false);
}

public final static String EM(AH args)
{
    return handler(23, args, null, false, false);
}

public final static String EM(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(23, args, null, omit_begin, omit_end);
}

public final static String EM(boolean omit_begin, boolean omit_end)
{
    return handler(23, AH.E, null, omit_begin, omit_end);
}

public final static String em(String content)
{
    return handler(23, AH.E, content, false, false);
}

public final static String em(AH args, String content)
{
    return handler(23, args, content, false, false);
}

public final static String em(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(23, args, content, omit_begin, omit_end);
}

public final static String em()
{
    return handler(23, AH.E, null, false, false);
}

public final static String em(AH args)
{
    return handler(23, args, null, false, false);
}

public final static String em(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(23, args, null, omit_begin, omit_end);
}

public final static String em(boolean omit_begin, boolean omit_end)
{
    return handler(23, AH.E, null, omit_begin, omit_end);
}

public final static String FIELDSET(String content)
{
    return handler(24, AH.E, content, false, false);
}

public final static String FIELDSET(AH args, String content)
{
    return handler(24, args, content, false, false);
}

public final static String FIELDSET(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(24, args, content, omit_begin, omit_end);
}

public final static String FIELDSET()
{
    return handler(24, AH.E, null, false, false);
}

public final static String FIELDSET(AH args)
{
    return handler(24, args, null, false, false);
}

public final static String FIELDSET(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(24, args, null, omit_begin, omit_end);
}

public final static String FIELDSET(boolean omit_begin, boolean omit_end)
{
    return handler(24, AH.E, null, omit_begin, omit_end);
}

public final static String fieldset(String content)
{
    return handler(24, AH.E, content, false, false);
}

public final static String fieldset(AH args, String content)
{
    return handler(24, args, content, false, false);
}

public final static String fieldset(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(24, args, content, omit_begin, omit_end);
}

public final static String fieldset()
{
    return handler(24, AH.E, null, false, false);
}

public final static String fieldset(AH args)
{
    return handler(24, args, null, false, false);
}

public final static String fieldset(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(24, args, null, omit_begin, omit_end);
}

public final static String fieldset(boolean omit_begin, boolean omit_end)
{
    return handler(24, AH.E, null, omit_begin, omit_end);
}

public final static String FONT(String content)
{
    return handler(25, AH.E, content, false, false);
}

public final static String FONT(AH args, String content)
{
    return handler(25, args, content, false, false);
}

public final static String FONT(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(25, args, content, omit_begin, omit_end);
}

public final static String FONT()
{
    return handler(25, AH.E, null, false, false);
}

public final static String FONT(AH args)
{
    return handler(25, args, null, false, false);
}

public final static String FONT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(25, args, null, omit_begin, omit_end);
}

public final static String FONT(boolean omit_begin, boolean omit_end)
{
    return handler(25, AH.E, null, omit_begin, omit_end);
}

public final static String font(String content)
{
    return handler(25, AH.E, content, false, false);
}

public final static String font(AH args, String content)
{
    return handler(25, args, content, false, false);
}

public final static String font(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(25, args, content, omit_begin, omit_end);
}

public final static String font()
{
    return handler(25, AH.E, null, false, false);
}

public final static String font(AH args)
{
    return handler(25, args, null, false, false);
}

public final static String font(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(25, args, null, omit_begin, omit_end);
}

public final static String font(boolean omit_begin, boolean omit_end)
{
    return handler(25, AH.E, null, omit_begin, omit_end);
}

public final static String FORM(String content)
{
    return handler(26, AH.E, content, false, false);
}

public final static String FORM(AH args, String content)
{
    return handler(26, args, content, false, false);
}

public final static String FORM(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(26, args, content, omit_begin, omit_end);
}

public final static String FORM()
{
    return handler(26, AH.E, null, false, false);
}

public final static String FORM(AH args)
{
    return handler(26, args, null, false, false);
}

public final static String FORM(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(26, args, null, omit_begin, omit_end);
}

public final static String FORM(boolean omit_begin, boolean omit_end)
{
    return handler(26, AH.E, null, omit_begin, omit_end);
}

public final static String form(String content)
{
    return handler(26, AH.E, content, false, false);
}

public final static String form(AH args, String content)
{
    return handler(26, args, content, false, false);
}

public final static String form(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(26, args, content, omit_begin, omit_end);
}

public final static String form()
{
    return handler(26, AH.E, null, false, false);
}

public final static String form(AH args)
{
    return handler(26, args, null, false, false);
}

public final static String form(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(26, args, null, omit_begin, omit_end);
}

public final static String form(boolean omit_begin, boolean omit_end)
{
    return handler(26, AH.E, null, omit_begin, omit_end);
}

public final static String FRAME()
{
    return handler(27, AH.E, null, false, false);
}

public final static String FRAME(AH args)
{
    return handler(27, args, null, false, false);
}

public final static String FRAME(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(27, args, null, omit_begin, omit_end);
}

public final static String FRAME(boolean omit_begin, boolean omit_end)
{
    return handler(27, AH.E, null, omit_begin, omit_end);
}

public final static String frame()
{
    return handler(27, AH.E, null, false, false);
}

public final static String frame(AH args)
{
    return handler(27, args, null, false, false);
}

public final static String frame(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(27, args, null, omit_begin, omit_end);
}

public final static String frame(boolean omit_begin, boolean omit_end)
{
    return handler(27, AH.E, null, omit_begin, omit_end);
}

public final static String FRAMESET(String content)
{
    return handler(28, AH.E, content, false, false);
}

public final static String FRAMESET(AH args, String content)
{
    return handler(28, args, content, false, false);
}

public final static String FRAMESET(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(28, args, content, omit_begin, omit_end);
}

public final static String FRAMESET()
{
    return handler(28, AH.E, null, false, false);
}

public final static String FRAMESET(AH args)
{
    return handler(28, args, null, false, false);
}

public final static String FRAMESET(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(28, args, null, omit_begin, omit_end);
}

public final static String FRAMESET(boolean omit_begin, boolean omit_end)
{
    return handler(28, AH.E, null, omit_begin, omit_end);
}

public final static String frameset(String content)
{
    return handler(28, AH.E, content, false, false);
}

public final static String frameset(AH args, String content)
{
    return handler(28, args, content, false, false);
}

public final static String frameset(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(28, args, content, omit_begin, omit_end);
}

public final static String frameset()
{
    return handler(28, AH.E, null, false, false);
}

public final static String frameset(AH args)
{
    return handler(28, args, null, false, false);
}

public final static String frameset(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(28, args, null, omit_begin, omit_end);
}

public final static String frameset(boolean omit_begin, boolean omit_end)
{
    return handler(28, AH.E, null, omit_begin, omit_end);
}

public final static String H1(String content)
{
    return handler(29, AH.E, content, false, false);
}

public final static String H1(AH args, String content)
{
    return handler(29, args, content, false, false);
}

public final static String H1(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(29, args, content, omit_begin, omit_end);
}

public final static String H1()
{
    return handler(29, AH.E, null, false, false);
}

public final static String H1(AH args)
{
    return handler(29, args, null, false, false);
}

public final static String H1(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(29, args, null, omit_begin, omit_end);
}

public final static String H1(boolean omit_begin, boolean omit_end)
{
    return handler(29, AH.E, null, omit_begin, omit_end);
}

public final static String h1(String content)
{
    return handler(29, AH.E, content, false, false);
}

public final static String h1(AH args, String content)
{
    return handler(29, args, content, false, false);
}

public final static String h1(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(29, args, content, omit_begin, omit_end);
}

public final static String h1()
{
    return handler(29, AH.E, null, false, false);
}

public final static String h1(AH args)
{
    return handler(29, args, null, false, false);
}

public final static String h1(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(29, args, null, omit_begin, omit_end);
}

public final static String h1(boolean omit_begin, boolean omit_end)
{
    return handler(29, AH.E, null, omit_begin, omit_end);
}

public final static String H2(String content)
{
    return handler(30, AH.E, content, false, false);
}

public final static String H2(AH args, String content)
{
    return handler(30, args, content, false, false);
}

public final static String H2(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(30, args, content, omit_begin, omit_end);
}

public final static String H2()
{
    return handler(30, AH.E, null, false, false);
}

public final static String H2(AH args)
{
    return handler(30, args, null, false, false);
}

public final static String H2(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(30, args, null, omit_begin, omit_end);
}

public final static String H2(boolean omit_begin, boolean omit_end)
{
    return handler(30, AH.E, null, omit_begin, omit_end);
}

public final static String h2(String content)
{
    return handler(30, AH.E, content, false, false);
}

public final static String h2(AH args, String content)
{
    return handler(30, args, content, false, false);
}

public final static String h2(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(30, args, content, omit_begin, omit_end);
}

public final static String h2()
{
    return handler(30, AH.E, null, false, false);
}

public final static String h2(AH args)
{
    return handler(30, args, null, false, false);
}

public final static String h2(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(30, args, null, omit_begin, omit_end);
}

public final static String h2(boolean omit_begin, boolean omit_end)
{
    return handler(30, AH.E, null, omit_begin, omit_end);
}

public final static String H3(String content)
{
    return handler(31, AH.E, content, false, false);
}

public final static String H3(AH args, String content)
{
    return handler(31, args, content, false, false);
}

public final static String H3(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(31, args, content, omit_begin, omit_end);
}

public final static String H3()
{
    return handler(31, AH.E, null, false, false);
}

public final static String H3(AH args)
{
    return handler(31, args, null, false, false);
}

public final static String H3(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(31, args, null, omit_begin, omit_end);
}

public final static String H3(boolean omit_begin, boolean omit_end)
{
    return handler(31, AH.E, null, omit_begin, omit_end);
}

public final static String h3(String content)
{
    return handler(31, AH.E, content, false, false);
}

public final static String h3(AH args, String content)
{
    return handler(31, args, content, false, false);
}

public final static String h3(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(31, args, content, omit_begin, omit_end);
}

public final static String h3()
{
    return handler(31, AH.E, null, false, false);
}

public final static String h3(AH args)
{
    return handler(31, args, null, false, false);
}

public final static String h3(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(31, args, null, omit_begin, omit_end);
}

public final static String h3(boolean omit_begin, boolean omit_end)
{
    return handler(31, AH.E, null, omit_begin, omit_end);
}

public final static String H4(String content)
{
    return handler(32, AH.E, content, false, false);
}

public final static String H4(AH args, String content)
{
    return handler(32, args, content, false, false);
}

public final static String H4(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(32, args, content, omit_begin, omit_end);
}

public final static String H4()
{
    return handler(32, AH.E, null, false, false);
}

public final static String H4(AH args)
{
    return handler(32, args, null, false, false);
}

public final static String H4(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(32, args, null, omit_begin, omit_end);
}

public final static String H4(boolean omit_begin, boolean omit_end)
{
    return handler(32, AH.E, null, omit_begin, omit_end);
}

public final static String h4(String content)
{
    return handler(32, AH.E, content, false, false);
}

public final static String h4(AH args, String content)
{
    return handler(32, args, content, false, false);
}

public final static String h4(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(32, args, content, omit_begin, omit_end);
}

public final static String h4()
{
    return handler(32, AH.E, null, false, false);
}

public final static String h4(AH args)
{
    return handler(32, args, null, false, false);
}

public final static String h4(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(32, args, null, omit_begin, omit_end);
}

public final static String h4(boolean omit_begin, boolean omit_end)
{
    return handler(32, AH.E, null, omit_begin, omit_end);
}

public final static String H5(String content)
{
    return handler(33, AH.E, content, false, false);
}

public final static String H5(AH args, String content)
{
    return handler(33, args, content, false, false);
}

public final static String H5(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(33, args, content, omit_begin, omit_end);
}

public final static String H5()
{
    return handler(33, AH.E, null, false, false);
}

public final static String H5(AH args)
{
    return handler(33, args, null, false, false);
}

public final static String H5(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(33, args, null, omit_begin, omit_end);
}

public final static String H5(boolean omit_begin, boolean omit_end)
{
    return handler(33, AH.E, null, omit_begin, omit_end);
}

public final static String h5(String content)
{
    return handler(33, AH.E, content, false, false);
}

public final static String h5(AH args, String content)
{
    return handler(33, args, content, false, false);
}

public final static String h5(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(33, args, content, omit_begin, omit_end);
}

public final static String h5()
{
    return handler(33, AH.E, null, false, false);
}

public final static String h5(AH args)
{
    return handler(33, args, null, false, false);
}

public final static String h5(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(33, args, null, omit_begin, omit_end);
}

public final static String h5(boolean omit_begin, boolean omit_end)
{
    return handler(33, AH.E, null, omit_begin, omit_end);
}

public final static String H6(String content)
{
    return handler(34, AH.E, content, false, false);
}

public final static String H6(AH args, String content)
{
    return handler(34, args, content, false, false);
}

public final static String H6(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(34, args, content, omit_begin, omit_end);
}

public final static String H6()
{
    return handler(34, AH.E, null, false, false);
}

public final static String H6(AH args)
{
    return handler(34, args, null, false, false);
}

public final static String H6(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(34, args, null, omit_begin, omit_end);
}

public final static String H6(boolean omit_begin, boolean omit_end)
{
    return handler(34, AH.E, null, omit_begin, omit_end);
}

public final static String h6(String content)
{
    return handler(34, AH.E, content, false, false);
}

public final static String h6(AH args, String content)
{
    return handler(34, args, content, false, false);
}

public final static String h6(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(34, args, content, omit_begin, omit_end);
}

public final static String h6()
{
    return handler(34, AH.E, null, false, false);
}

public final static String h6(AH args)
{
    return handler(34, args, null, false, false);
}

public final static String h6(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(34, args, null, omit_begin, omit_end);
}

public final static String h6(boolean omit_begin, boolean omit_end)
{
    return handler(34, AH.E, null, omit_begin, omit_end);
}

public final static String HEAD(String content)
{
    return handler(35, AH.E, content, false, false);
}

public final static String HEAD(AH args, String content)
{
    return handler(35, args, content, false, false);
}

public final static String HEAD(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(35, args, content, omit_begin, omit_end);
}

public final static String HEAD()
{
    return handler(35, AH.E, null, false, false);
}

public final static String HEAD(AH args)
{
    return handler(35, args, null, false, false);
}

public final static String HEAD(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(35, args, null, omit_begin, omit_end);
}

public final static String HEAD(boolean omit_begin, boolean omit_end)
{
    return handler(35, AH.E, null, omit_begin, omit_end);
}

public final static String head(String content)
{
    return handler(35, AH.E, content, false, false);
}

public final static String head(AH args, String content)
{
    return handler(35, args, content, false, false);
}

public final static String head(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(35, args, content, omit_begin, omit_end);
}

public final static String head()
{
    return handler(35, AH.E, null, false, false);
}

public final static String head(AH args)
{
    return handler(35, args, null, false, false);
}

public final static String head(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(35, args, null, omit_begin, omit_end);
}

public final static String head(boolean omit_begin, boolean omit_end)
{
    return handler(35, AH.E, null, omit_begin, omit_end);
}

public final static String HR()
{
    return handler(36, AH.E, null, false, false);
}

public final static String HR(AH args)
{
    return handler(36, args, null, false, false);
}

public final static String HR(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(36, args, null, omit_begin, omit_end);
}

public final static String HR(boolean omit_begin, boolean omit_end)
{
    return handler(36, AH.E, null, omit_begin, omit_end);
}

public final static String hr()
{
    return handler(36, AH.E, null, false, false);
}

public final static String hr(AH args)
{
    return handler(36, args, null, false, false);
}

public final static String hr(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(36, args, null, omit_begin, omit_end);
}

public final static String hr(boolean omit_begin, boolean omit_end)
{
    return handler(36, AH.E, null, omit_begin, omit_end);
}

public final static String HTML(String content)
{
    return handler(37, AH.E, content, false, false);
}

public final static String HTML(AH args, String content)
{
    return handler(37, args, content, false, false);
}

public final static String HTML(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(37, args, content, omit_begin, omit_end);
}

public final static String HTML()
{
    return handler(37, AH.E, null, false, false);
}

public final static String HTML(AH args)
{
    return handler(37, args, null, false, false);
}

public final static String HTML(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(37, args, null, omit_begin, omit_end);
}

public final static String HTML(boolean omit_begin, boolean omit_end)
{
    return handler(37, AH.E, null, omit_begin, omit_end);
}

public final static String html(String content)
{
    return handler(37, AH.E, content, false, false);
}

public final static String html(AH args, String content)
{
    return handler(37, args, content, false, false);
}

public final static String html(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(37, args, content, omit_begin, omit_end);
}

public final static String html()
{
    return handler(37, AH.E, null, false, false);
}

public final static String html(AH args)
{
    return handler(37, args, null, false, false);
}

public final static String html(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(37, args, null, omit_begin, omit_end);
}

public final static String html(boolean omit_begin, boolean omit_end)
{
    return handler(37, AH.E, null, omit_begin, omit_end);
}

public final static String I(String content)
{
    return handler(38, AH.E, content, false, false);
}

public final static String I(AH args, String content)
{
    return handler(38, args, content, false, false);
}

public final static String I(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(38, args, content, omit_begin, omit_end);
}

public final static String I()
{
    return handler(38, AH.E, null, false, false);
}

public final static String I(AH args)
{
    return handler(38, args, null, false, false);
}

public final static String I(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(38, args, null, omit_begin, omit_end);
}

public final static String I(boolean omit_begin, boolean omit_end)
{
    return handler(38, AH.E, null, omit_begin, omit_end);
}

public final static String i(String content)
{
    return handler(38, AH.E, content, false, false);
}

public final static String i(AH args, String content)
{
    return handler(38, args, content, false, false);
}

public final static String i(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(38, args, content, omit_begin, omit_end);
}

public final static String i()
{
    return handler(38, AH.E, null, false, false);
}

public final static String i(AH args)
{
    return handler(38, args, null, false, false);
}

public final static String i(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(38, args, null, omit_begin, omit_end);
}

public final static String i(boolean omit_begin, boolean omit_end)
{
    return handler(38, AH.E, null, omit_begin, omit_end);
}

public final static String IFRAME(String content)
{
    return handler(39, AH.E, content, false, false);
}

public final static String IFRAME(AH args, String content)
{
    return handler(39, args, content, false, false);
}

public final static String IFRAME(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(39, args, content, omit_begin, omit_end);
}

public final static String IFRAME()
{
    return handler(39, AH.E, null, false, false);
}

public final static String IFRAME(AH args)
{
    return handler(39, args, null, false, false);
}

public final static String IFRAME(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(39, args, null, omit_begin, omit_end);
}

public final static String IFRAME(boolean omit_begin, boolean omit_end)
{
    return handler(39, AH.E, null, omit_begin, omit_end);
}

public final static String iframe(String content)
{
    return handler(39, AH.E, content, false, false);
}

public final static String iframe(AH args, String content)
{
    return handler(39, args, content, false, false);
}

public final static String iframe(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(39, args, content, omit_begin, omit_end);
}

public final static String iframe()
{
    return handler(39, AH.E, null, false, false);
}

public final static String iframe(AH args)
{
    return handler(39, args, null, false, false);
}

public final static String iframe(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(39, args, null, omit_begin, omit_end);
}

public final static String iframe(boolean omit_begin, boolean omit_end)
{
    return handler(39, AH.E, null, omit_begin, omit_end);
}

public final static String IMG()
{
    return handler(40, AH.E, null, false, false);
}

public final static String IMG(AH args)
{
    return handler(40, args, null, false, false);
}

public final static String IMG(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(40, args, null, omit_begin, omit_end);
}

public final static String IMG(boolean omit_begin, boolean omit_end)
{
    return handler(40, AH.E, null, omit_begin, omit_end);
}

public final static String img()
{
    return handler(40, AH.E, null, false, false);
}

public final static String img(AH args)
{
    return handler(40, args, null, false, false);
}

public final static String img(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(40, args, null, omit_begin, omit_end);
}

public final static String img(boolean omit_begin, boolean omit_end)
{
    return handler(40, AH.E, null, omit_begin, omit_end);
}

public final static String INPUT()
{
    return handler(41, AH.E, null, false, false);
}

public final static String INPUT(AH args)
{
    return handler(41, args, null, false, false);
}

public final static String INPUT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(41, args, null, omit_begin, omit_end);
}

public final static String INPUT(boolean omit_begin, boolean omit_end)
{
    return handler(41, AH.E, null, omit_begin, omit_end);
}

public final static String input()
{
    return handler(41, AH.E, null, false, false);
}

public final static String input(AH args)
{
    return handler(41, args, null, false, false);
}

public final static String input(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(41, args, null, omit_begin, omit_end);
}

public final static String input(boolean omit_begin, boolean omit_end)
{
    return handler(41, AH.E, null, omit_begin, omit_end);
}

public final static String INS(String content)
{
    return handler(42, AH.E, content, false, false);
}

public final static String INS(AH args, String content)
{
    return handler(42, args, content, false, false);
}

public final static String INS(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(42, args, content, omit_begin, omit_end);
}

public final static String INS()
{
    return handler(42, AH.E, null, false, false);
}

public final static String INS(AH args)
{
    return handler(42, args, null, false, false);
}

public final static String INS(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(42, args, null, omit_begin, omit_end);
}

public final static String INS(boolean omit_begin, boolean omit_end)
{
    return handler(42, AH.E, null, omit_begin, omit_end);
}

public final static String ins(String content)
{
    return handler(42, AH.E, content, false, false);
}

public final static String ins(AH args, String content)
{
    return handler(42, args, content, false, false);
}

public final static String ins(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(42, args, content, omit_begin, omit_end);
}

public final static String ins()
{
    return handler(42, AH.E, null, false, false);
}

public final static String ins(AH args)
{
    return handler(42, args, null, false, false);
}

public final static String ins(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(42, args, null, omit_begin, omit_end);
}

public final static String ins(boolean omit_begin, boolean omit_end)
{
    return handler(42, AH.E, null, omit_begin, omit_end);
}

public final static String KBD(String content)
{
    return handler(43, AH.E, content, false, false);
}

public final static String KBD(AH args, String content)
{
    return handler(43, args, content, false, false);
}

public final static String KBD(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(43, args, content, omit_begin, omit_end);
}

public final static String KBD()
{
    return handler(43, AH.E, null, false, false);
}

public final static String KBD(AH args)
{
    return handler(43, args, null, false, false);
}

public final static String KBD(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(43, args, null, omit_begin, omit_end);
}

public final static String KBD(boolean omit_begin, boolean omit_end)
{
    return handler(43, AH.E, null, omit_begin, omit_end);
}

public final static String kbd(String content)
{
    return handler(43, AH.E, content, false, false);
}

public final static String kbd(AH args, String content)
{
    return handler(43, args, content, false, false);
}

public final static String kbd(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(43, args, content, omit_begin, omit_end);
}

public final static String kbd()
{
    return handler(43, AH.E, null, false, false);
}

public final static String kbd(AH args)
{
    return handler(43, args, null, false, false);
}

public final static String kbd(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(43, args, null, omit_begin, omit_end);
}

public final static String kbd(boolean omit_begin, boolean omit_end)
{
    return handler(43, AH.E, null, omit_begin, omit_end);
}

public final static String LABEL(String content)
{
    return handler(44, AH.E, content, false, false);
}

public final static String LABEL(AH args, String content)
{
    return handler(44, args, content, false, false);
}

public final static String LABEL(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(44, args, content, omit_begin, omit_end);
}

public final static String LABEL()
{
    return handler(44, AH.E, null, false, false);
}

public final static String LABEL(AH args)
{
    return handler(44, args, null, false, false);
}

public final static String LABEL(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(44, args, null, omit_begin, omit_end);
}

public final static String LABEL(boolean omit_begin, boolean omit_end)
{
    return handler(44, AH.E, null, omit_begin, omit_end);
}

public final static String label(String content)
{
    return handler(44, AH.E, content, false, false);
}

public final static String label(AH args, String content)
{
    return handler(44, args, content, false, false);
}

public final static String label(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(44, args, content, omit_begin, omit_end);
}

public final static String label()
{
    return handler(44, AH.E, null, false, false);
}

public final static String label(AH args)
{
    return handler(44, args, null, false, false);
}

public final static String label(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(44, args, null, omit_begin, omit_end);
}

public final static String label(boolean omit_begin, boolean omit_end)
{
    return handler(44, AH.E, null, omit_begin, omit_end);
}

public final static String LEGEND(String content)
{
    return handler(45, AH.E, content, false, false);
}

public final static String LEGEND(AH args, String content)
{
    return handler(45, args, content, false, false);
}

public final static String LEGEND(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(45, args, content, omit_begin, omit_end);
}

public final static String LEGEND()
{
    return handler(45, AH.E, null, false, false);
}

public final static String LEGEND(AH args)
{
    return handler(45, args, null, false, false);
}

public final static String LEGEND(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(45, args, null, omit_begin, omit_end);
}

public final static String LEGEND(boolean omit_begin, boolean omit_end)
{
    return handler(45, AH.E, null, omit_begin, omit_end);
}

public final static String legend(String content)
{
    return handler(45, AH.E, content, false, false);
}

public final static String legend(AH args, String content)
{
    return handler(45, args, content, false, false);
}

public final static String legend(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(45, args, content, omit_begin, omit_end);
}

public final static String legend()
{
    return handler(45, AH.E, null, false, false);
}

public final static String legend(AH args)
{
    return handler(45, args, null, false, false);
}

public final static String legend(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(45, args, null, omit_begin, omit_end);
}

public final static String legend(boolean omit_begin, boolean omit_end)
{
    return handler(45, AH.E, null, omit_begin, omit_end);
}

public final static String LI(String content)
{
    return handler(46, AH.E, content, false, false);
}

public final static String LI(AH args, String content)
{
    return handler(46, args, content, false, false);
}

public final static String LI(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(46, args, content, omit_begin, omit_end);
}

public final static String LI()
{
    return handler(46, AH.E, null, false, false);
}

public final static String LI(AH args)
{
    return handler(46, args, null, false, false);
}

public final static String LI(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(46, args, null, omit_begin, omit_end);
}

public final static String LI(boolean omit_begin, boolean omit_end)
{
    return handler(46, AH.E, null, omit_begin, omit_end);
}

public final static String li(String content)
{
    return handler(46, AH.E, content, false, false);
}

public final static String li(AH args, String content)
{
    return handler(46, args, content, false, false);
}

public final static String li(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(46, args, content, omit_begin, omit_end);
}

public final static String li()
{
    return handler(46, AH.E, null, false, false);
}

public final static String li(AH args)
{
    return handler(46, args, null, false, false);
}

public final static String li(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(46, args, null, omit_begin, omit_end);
}

public final static String li(boolean omit_begin, boolean omit_end)
{
    return handler(46, AH.E, null, omit_begin, omit_end);
}

public final static String MAP(String content)
{
    return handler(47, AH.E, content, false, false);
}

public final static String MAP(AH args, String content)
{
    return handler(47, args, content, false, false);
}

public final static String MAP(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(47, args, content, omit_begin, omit_end);
}

public final static String MAP()
{
    return handler(47, AH.E, null, false, false);
}

public final static String MAP(AH args)
{
    return handler(47, args, null, false, false);
}

public final static String MAP(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(47, args, null, omit_begin, omit_end);
}

public final static String MAP(boolean omit_begin, boolean omit_end)
{
    return handler(47, AH.E, null, omit_begin, omit_end);
}

public final static String map(String content)
{
    return handler(47, AH.E, content, false, false);
}

public final static String map(AH args, String content)
{
    return handler(47, args, content, false, false);
}

public final static String map(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(47, args, content, omit_begin, omit_end);
}

public final static String map()
{
    return handler(47, AH.E, null, false, false);
}

public final static String map(AH args)
{
    return handler(47, args, null, false, false);
}

public final static String map(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(47, args, null, omit_begin, omit_end);
}

public final static String map(boolean omit_begin, boolean omit_end)
{
    return handler(47, AH.E, null, omit_begin, omit_end);
}

public final static String MEDIA()
{
    return handler(48, AH.E, null, false, false);
}

public final static String MEDIA(AH args)
{
    return handler(48, args, null, false, false);
}

public final static String MEDIA(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(48, args, null, omit_begin, omit_end);
}

public final static String MEDIA(boolean omit_begin, boolean omit_end)
{
    return handler(48, AH.E, null, omit_begin, omit_end);
}

public final static String media()
{
    return handler(48, AH.E, null, false, false);
}

public final static String media(AH args)
{
    return handler(48, args, null, false, false);
}

public final static String media(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(48, args, null, omit_begin, omit_end);
}

public final static String media(boolean omit_begin, boolean omit_end)
{
    return handler(48, AH.E, null, omit_begin, omit_end);
}

public final static String META()
{
    return handler(49, AH.E, null, false, false);
}

public final static String META(AH args)
{
    return handler(49, args, null, false, false);
}

public final static String META(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(49, args, null, omit_begin, omit_end);
}

public final static String META(boolean omit_begin, boolean omit_end)
{
    return handler(49, AH.E, null, omit_begin, omit_end);
}

public final static String meta()
{
    return handler(49, AH.E, null, false, false);
}

public final static String meta(AH args)
{
    return handler(49, args, null, false, false);
}

public final static String meta(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(49, args, null, omit_begin, omit_end);
}

public final static String meta(boolean omit_begin, boolean omit_end)
{
    return handler(49, AH.E, null, omit_begin, omit_end);
}

public final static String NOFRAMES(String content)
{
    return handler(50, AH.E, content, false, false);
}

public final static String NOFRAMES(AH args, String content)
{
    return handler(50, args, content, false, false);
}

public final static String NOFRAMES(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(50, args, content, omit_begin, omit_end);
}

public final static String NOFRAMES()
{
    return handler(50, AH.E, null, false, false);
}

public final static String NOFRAMES(AH args)
{
    return handler(50, args, null, false, false);
}

public final static String NOFRAMES(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(50, args, null, omit_begin, omit_end);
}

public final static String NOFRAMES(boolean omit_begin, boolean omit_end)
{
    return handler(50, AH.E, null, omit_begin, omit_end);
}

public final static String noframes(String content)
{
    return handler(50, AH.E, content, false, false);
}

public final static String noframes(AH args, String content)
{
    return handler(50, args, content, false, false);
}

public final static String noframes(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(50, args, content, omit_begin, omit_end);
}

public final static String noframes()
{
    return handler(50, AH.E, null, false, false);
}

public final static String noframes(AH args)
{
    return handler(50, args, null, false, false);
}

public final static String noframes(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(50, args, null, omit_begin, omit_end);
}

public final static String noframes(boolean omit_begin, boolean omit_end)
{
    return handler(50, AH.E, null, omit_begin, omit_end);
}

public final static String OBJECT(String content)
{
    return handler(51, AH.E, content, false, false);
}

public final static String OBJECT(AH args, String content)
{
    return handler(51, args, content, false, false);
}

public final static String OBJECT(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(51, args, content, omit_begin, omit_end);
}

public final static String OBJECT()
{
    return handler(51, AH.E, null, false, false);
}

public final static String OBJECT(AH args)
{
    return handler(51, args, null, false, false);
}

public final static String OBJECT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(51, args, null, omit_begin, omit_end);
}

public final static String OBJECT(boolean omit_begin, boolean omit_end)
{
    return handler(51, AH.E, null, omit_begin, omit_end);
}

public final static String object(String content)
{
    return handler(51, AH.E, content, false, false);
}

public final static String object(AH args, String content)
{
    return handler(51, args, content, false, false);
}

public final static String object(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(51, args, content, omit_begin, omit_end);
}

public final static String object()
{
    return handler(51, AH.E, null, false, false);
}

public final static String object(AH args)
{
    return handler(51, args, null, false, false);
}

public final static String object(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(51, args, null, omit_begin, omit_end);
}

public final static String object(boolean omit_begin, boolean omit_end)
{
    return handler(51, AH.E, null, omit_begin, omit_end);
}

public final static String OL(String content)
{
    return handler(52, AH.E, content, false, false);
}

public final static String OL(AH args, String content)
{
    return handler(52, args, content, false, false);
}

public final static String OL(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(52, args, content, omit_begin, omit_end);
}

public final static String OL()
{
    return handler(52, AH.E, null, false, false);
}

public final static String OL(AH args)
{
    return handler(52, args, null, false, false);
}

public final static String OL(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(52, args, null, omit_begin, omit_end);
}

public final static String OL(boolean omit_begin, boolean omit_end)
{
    return handler(52, AH.E, null, omit_begin, omit_end);
}

public final static String ol(String content)
{
    return handler(52, AH.E, content, false, false);
}

public final static String ol(AH args, String content)
{
    return handler(52, args, content, false, false);
}

public final static String ol(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(52, args, content, omit_begin, omit_end);
}

public final static String ol()
{
    return handler(52, AH.E, null, false, false);
}

public final static String ol(AH args)
{
    return handler(52, args, null, false, false);
}

public final static String ol(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(52, args, null, omit_begin, omit_end);
}

public final static String ol(boolean omit_begin, boolean omit_end)
{
    return handler(52, AH.E, null, omit_begin, omit_end);
}

public final static String OPTGROUP(String content)
{
    return handler(53, AH.E, content, false, false);
}

public final static String OPTGROUP(AH args, String content)
{
    return handler(53, args, content, false, false);
}

public final static String OPTGROUP(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(53, args, content, omit_begin, omit_end);
}

public final static String OPTGROUP()
{
    return handler(53, AH.E, null, false, false);
}

public final static String OPTGROUP(AH args)
{
    return handler(53, args, null, false, false);
}

public final static String OPTGROUP(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(53, args, null, omit_begin, omit_end);
}

public final static String OPTGROUP(boolean omit_begin, boolean omit_end)
{
    return handler(53, AH.E, null, omit_begin, omit_end);
}

public final static String optgroup(String content)
{
    return handler(53, AH.E, content, false, false);
}

public final static String optgroup(AH args, String content)
{
    return handler(53, args, content, false, false);
}

public final static String optgroup(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(53, args, content, omit_begin, omit_end);
}

public final static String optgroup()
{
    return handler(53, AH.E, null, false, false);
}

public final static String optgroup(AH args)
{
    return handler(53, args, null, false, false);
}

public final static String optgroup(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(53, args, null, omit_begin, omit_end);
}

public final static String optgroup(boolean omit_begin, boolean omit_end)
{
    return handler(53, AH.E, null, omit_begin, omit_end);
}

public final static String OPTION(String content)
{
    return handler(54, AH.E, content, false, false);
}

public final static String OPTION(AH args, String content)
{
    return handler(54, args, content, false, false);
}

public final static String OPTION(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(54, args, content, omit_begin, omit_end);
}

public final static String OPTION()
{
    return handler(54, AH.E, null, false, false);
}

public final static String OPTION(AH args)
{
    return handler(54, args, null, false, false);
}

public final static String OPTION(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(54, args, null, omit_begin, omit_end);
}

public final static String OPTION(boolean omit_begin, boolean omit_end)
{
    return handler(54, AH.E, null, omit_begin, omit_end);
}

public final static String option(String content)
{
    return handler(54, AH.E, content, false, false);
}

public final static String option(AH args, String content)
{
    return handler(54, args, content, false, false);
}

public final static String option(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(54, args, content, omit_begin, omit_end);
}

public final static String option()
{
    return handler(54, AH.E, null, false, false);
}

public final static String option(AH args)
{
    return handler(54, args, null, false, false);
}

public final static String option(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(54, args, null, omit_begin, omit_end);
}

public final static String option(boolean omit_begin, boolean omit_end)
{
    return handler(54, AH.E, null, omit_begin, omit_end);
}

public final static String P(String content)
{
    return handler(55, AH.E, content, false, false);
}

public final static String P(AH args, String content)
{
    return handler(55, args, content, false, false);
}

public final static String P(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(55, args, content, omit_begin, omit_end);
}

public final static String P()
{
    return handler(55, AH.E, null, false, false);
}

public final static String P(AH args)
{
    return handler(55, args, null, false, false);
}

public final static String P(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(55, args, null, omit_begin, omit_end);
}

public final static String P(boolean omit_begin, boolean omit_end)
{
    return handler(55, AH.E, null, omit_begin, omit_end);
}

public final static String p(String content)
{
    return handler(55, AH.E, content, false, false);
}

public final static String p(AH args, String content)
{
    return handler(55, args, content, false, false);
}

public final static String p(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(55, args, content, omit_begin, omit_end);
}

public final static String p()
{
    return handler(55, AH.E, null, false, false);
}

public final static String p(AH args)
{
    return handler(55, args, null, false, false);
}

public final static String p(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(55, args, null, omit_begin, omit_end);
}

public final static String p(boolean omit_begin, boolean omit_end)
{
    return handler(55, AH.E, null, omit_begin, omit_end);
}

public final static String PARAM()
{
    return handler(56, AH.E, null, false, false);
}

public final static String PARAM(AH args)
{
    return handler(56, args, null, false, false);
}

public final static String PARAM(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(56, args, null, omit_begin, omit_end);
}

public final static String PARAM(boolean omit_begin, boolean omit_end)
{
    return handler(56, AH.E, null, omit_begin, omit_end);
}

public final static String param()
{
    return handler(56, AH.E, null, false, false);
}

public final static String param(AH args)
{
    return handler(56, args, null, false, false);
}

public final static String param(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(56, args, null, omit_begin, omit_end);
}

public final static String param(boolean omit_begin, boolean omit_end)
{
    return handler(56, AH.E, null, omit_begin, omit_end);
}

public final static String PRE(String content)
{
    return handler(57, AH.E, content, false, false);
}

public final static String PRE(AH args, String content)
{
    return handler(57, args, content, false, false);
}

public final static String PRE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(57, args, content, omit_begin, omit_end);
}

public final static String PRE()
{
    return handler(57, AH.E, null, false, false);
}

public final static String PRE(AH args)
{
    return handler(57, args, null, false, false);
}

public final static String PRE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(57, args, null, omit_begin, omit_end);
}

public final static String PRE(boolean omit_begin, boolean omit_end)
{
    return handler(57, AH.E, null, omit_begin, omit_end);
}

public final static String pre(String content)
{
    return handler(57, AH.E, content, false, false);
}

public final static String pre(AH args, String content)
{
    return handler(57, args, content, false, false);
}

public final static String pre(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(57, args, content, omit_begin, omit_end);
}

public final static String pre()
{
    return handler(57, AH.E, null, false, false);
}

public final static String pre(AH args)
{
    return handler(57, args, null, false, false);
}

public final static String pre(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(57, args, null, omit_begin, omit_end);
}

public final static String pre(boolean omit_begin, boolean omit_end)
{
    return handler(57, AH.E, null, omit_begin, omit_end);
}

public final static String QUOTE(String content)
{
    return handler(58, AH.E, content, false, false);
}

public final static String QUOTE(AH args, String content)
{
    return handler(58, args, content, false, false);
}

public final static String QUOTE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(58, args, content, omit_begin, omit_end);
}

public final static String QUOTE()
{
    return handler(58, AH.E, null, false, false);
}

public final static String QUOTE(AH args)
{
    return handler(58, args, null, false, false);
}

public final static String QUOTE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(58, args, null, omit_begin, omit_end);
}

public final static String QUOTE(boolean omit_begin, boolean omit_end)
{
    return handler(58, AH.E, null, omit_begin, omit_end);
}

public final static String quote(String content)
{
    return handler(58, AH.E, content, false, false);
}

public final static String quote(AH args, String content)
{
    return handler(58, args, content, false, false);
}

public final static String quote(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(58, args, content, omit_begin, omit_end);
}

public final static String quote()
{
    return handler(58, AH.E, null, false, false);
}

public final static String quote(AH args)
{
    return handler(58, args, null, false, false);
}

public final static String quote(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(58, args, null, omit_begin, omit_end);
}

public final static String quote(boolean omit_begin, boolean omit_end)
{
    return handler(58, AH.E, null, omit_begin, omit_end);
}

public final static String S(String content)
{
    return handler(59, AH.E, content, false, false);
}

public final static String S(AH args, String content)
{
    return handler(59, args, content, false, false);
}

public final static String S(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(59, args, content, omit_begin, omit_end);
}

public final static String S()
{
    return handler(59, AH.E, null, false, false);
}

public final static String S(AH args)
{
    return handler(59, args, null, false, false);
}

public final static String S(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(59, args, null, omit_begin, omit_end);
}

public final static String S(boolean omit_begin, boolean omit_end)
{
    return handler(59, AH.E, null, omit_begin, omit_end);
}

public final static String s(String content)
{
    return handler(59, AH.E, content, false, false);
}

public final static String s(AH args, String content)
{
    return handler(59, args, content, false, false);
}

public final static String s(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(59, args, content, omit_begin, omit_end);
}

public final static String s()
{
    return handler(59, AH.E, null, false, false);
}

public final static String s(AH args)
{
    return handler(59, args, null, false, false);
}

public final static String s(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(59, args, null, omit_begin, omit_end);
}

public final static String s(boolean omit_begin, boolean omit_end)
{
    return handler(59, AH.E, null, omit_begin, omit_end);
}

public final static String SAMP(String content)
{
    return handler(60, AH.E, content, false, false);
}

public final static String SAMP(AH args, String content)
{
    return handler(60, args, content, false, false);
}

public final static String SAMP(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(60, args, content, omit_begin, omit_end);
}

public final static String SAMP()
{
    return handler(60, AH.E, null, false, false);
}

public final static String SAMP(AH args)
{
    return handler(60, args, null, false, false);
}

public final static String SAMP(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(60, args, null, omit_begin, omit_end);
}

public final static String SAMP(boolean omit_begin, boolean omit_end)
{
    return handler(60, AH.E, null, omit_begin, omit_end);
}

public final static String samp(String content)
{
    return handler(60, AH.E, content, false, false);
}

public final static String samp(AH args, String content)
{
    return handler(60, args, content, false, false);
}

public final static String samp(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(60, args, content, omit_begin, omit_end);
}

public final static String samp()
{
    return handler(60, AH.E, null, false, false);
}

public final static String samp(AH args)
{
    return handler(60, args, null, false, false);
}

public final static String samp(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(60, args, null, omit_begin, omit_end);
}

public final static String samp(boolean omit_begin, boolean omit_end)
{
    return handler(60, AH.E, null, omit_begin, omit_end);
}

public final static String SELECT(String content)
{
    return handler(61, AH.E, content, false, false);
}

public final static String SELECT(AH args, String content)
{
    return handler(61, args, content, false, false);
}

public final static String SELECT(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(61, args, content, omit_begin, omit_end);
}

public final static String SELECT()
{
    return handler(61, AH.E, null, false, false);
}

public final static String SELECT(AH args)
{
    return handler(61, args, null, false, false);
}

public final static String SELECT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(61, args, null, omit_begin, omit_end);
}

public final static String SELECT(boolean omit_begin, boolean omit_end)
{
    return handler(61, AH.E, null, omit_begin, omit_end);
}

public final static String select(String content)
{
    return handler(61, AH.E, content, false, false);
}

public final static String select(AH args, String content)
{
    return handler(61, args, content, false, false);
}

public final static String select(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(61, args, content, omit_begin, omit_end);
}

public final static String select()
{
    return handler(61, AH.E, null, false, false);
}

public final static String select(AH args)
{
    return handler(61, args, null, false, false);
}

public final static String select(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(61, args, null, omit_begin, omit_end);
}

public final static String select(boolean omit_begin, boolean omit_end)
{
    return handler(61, AH.E, null, omit_begin, omit_end);
}

public final static String SMALL(String content)
{
    return handler(62, AH.E, content, false, false);
}

public final static String SMALL(AH args, String content)
{
    return handler(62, args, content, false, false);
}

public final static String SMALL(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(62, args, content, omit_begin, omit_end);
}

public final static String SMALL()
{
    return handler(62, AH.E, null, false, false);
}

public final static String SMALL(AH args)
{
    return handler(62, args, null, false, false);
}

public final static String SMALL(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(62, args, null, omit_begin, omit_end);
}

public final static String SMALL(boolean omit_begin, boolean omit_end)
{
    return handler(62, AH.E, null, omit_begin, omit_end);
}

public final static String small(String content)
{
    return handler(62, AH.E, content, false, false);
}

public final static String small(AH args, String content)
{
    return handler(62, args, content, false, false);
}

public final static String small(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(62, args, content, omit_begin, omit_end);
}

public final static String small()
{
    return handler(62, AH.E, null, false, false);
}

public final static String small(AH args)
{
    return handler(62, args, null, false, false);
}

public final static String small(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(62, args, null, omit_begin, omit_end);
}

public final static String small(boolean omit_begin, boolean omit_end)
{
    return handler(62, AH.E, null, omit_begin, omit_end);
}

public final static String SPAN(String content)
{
    return handler(63, AH.E, content, false, false);
}

public final static String SPAN(AH args, String content)
{
    return handler(63, args, content, false, false);
}

public final static String SPAN(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(63, args, content, omit_begin, omit_end);
}

public final static String SPAN()
{
    return handler(63, AH.E, null, false, false);
}

public final static String SPAN(AH args)
{
    return handler(63, args, null, false, false);
}

public final static String SPAN(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(63, args, null, omit_begin, omit_end);
}

public final static String SPAN(boolean omit_begin, boolean omit_end)
{
    return handler(63, AH.E, null, omit_begin, omit_end);
}

public final static String span(String content)
{
    return handler(63, AH.E, content, false, false);
}

public final static String span(AH args, String content)
{
    return handler(63, args, content, false, false);
}

public final static String span(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(63, args, content, omit_begin, omit_end);
}

public final static String span()
{
    return handler(63, AH.E, null, false, false);
}

public final static String span(AH args)
{
    return handler(63, args, null, false, false);
}

public final static String span(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(63, args, null, omit_begin, omit_end);
}

public final static String span(boolean omit_begin, boolean omit_end)
{
    return handler(63, AH.E, null, omit_begin, omit_end);
}

public final static String STRIKE(String content)
{
    return handler(64, AH.E, content, false, false);
}

public final static String STRIKE(AH args, String content)
{
    return handler(64, args, content, false, false);
}

public final static String STRIKE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(64, args, content, omit_begin, omit_end);
}

public final static String STRIKE()
{
    return handler(64, AH.E, null, false, false);
}

public final static String STRIKE(AH args)
{
    return handler(64, args, null, false, false);
}

public final static String STRIKE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(64, args, null, omit_begin, omit_end);
}

public final static String STRIKE(boolean omit_begin, boolean omit_end)
{
    return handler(64, AH.E, null, omit_begin, omit_end);
}

public final static String strike(String content)
{
    return handler(64, AH.E, content, false, false);
}

public final static String strike(AH args, String content)
{
    return handler(64, args, content, false, false);
}

public final static String strike(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(64, args, content, omit_begin, omit_end);
}

public final static String strike()
{
    return handler(64, AH.E, null, false, false);
}

public final static String strike(AH args)
{
    return handler(64, args, null, false, false);
}

public final static String strike(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(64, args, null, omit_begin, omit_end);
}

public final static String strike(boolean omit_begin, boolean omit_end)
{
    return handler(64, AH.E, null, omit_begin, omit_end);
}

public final static String STRONG(String content)
{
    return handler(65, AH.E, content, false, false);
}

public final static String STRONG(AH args, String content)
{
    return handler(65, args, content, false, false);
}

public final static String STRONG(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(65, args, content, omit_begin, omit_end);
}

public final static String STRONG()
{
    return handler(65, AH.E, null, false, false);
}

public final static String STRONG(AH args)
{
    return handler(65, args, null, false, false);
}

public final static String STRONG(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(65, args, null, omit_begin, omit_end);
}

public final static String STRONG(boolean omit_begin, boolean omit_end)
{
    return handler(65, AH.E, null, omit_begin, omit_end);
}

public final static String strong(String content)
{
    return handler(65, AH.E, content, false, false);
}

public final static String strong(AH args, String content)
{
    return handler(65, args, content, false, false);
}

public final static String strong(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(65, args, content, omit_begin, omit_end);
}

public final static String strong()
{
    return handler(65, AH.E, null, false, false);
}

public final static String strong(AH args)
{
    return handler(65, args, null, false, false);
}

public final static String strong(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(65, args, null, omit_begin, omit_end);
}

public final static String strong(boolean omit_begin, boolean omit_end)
{
    return handler(65, AH.E, null, omit_begin, omit_end);
}

public final static String STYLE(String content)
{
    return handler(66, AH.E, content, false, false);
}

public final static String STYLE(AH args, String content)
{
    return handler(66, args, content, false, false);
}

public final static String STYLE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(66, args, content, omit_begin, omit_end);
}

public final static String STYLE()
{
    return handler(66, AH.E, null, false, false);
}

public final static String STYLE(AH args)
{
    return handler(66, args, null, false, false);
}

public final static String STYLE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(66, args, null, omit_begin, omit_end);
}

public final static String STYLE(boolean omit_begin, boolean omit_end)
{
    return handler(66, AH.E, null, omit_begin, omit_end);
}

public final static String style(String content)
{
    return handler(66, AH.E, content, false, false);
}

public final static String style(AH args, String content)
{
    return handler(66, args, content, false, false);
}

public final static String style(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(66, args, content, omit_begin, omit_end);
}

public final static String style()
{
    return handler(66, AH.E, null, false, false);
}

public final static String style(AH args)
{
    return handler(66, args, null, false, false);
}

public final static String style(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(66, args, null, omit_begin, omit_end);
}

public final static String style(boolean omit_begin, boolean omit_end)
{
    return handler(66, AH.E, null, omit_begin, omit_end);
}

public final static String SUB(String content)
{
    return handler(67, AH.E, content, false, false);
}

public final static String SUB(AH args, String content)
{
    return handler(67, args, content, false, false);
}

public final static String SUB(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(67, args, content, omit_begin, omit_end);
}

public final static String SUB()
{
    return handler(67, AH.E, null, false, false);
}

public final static String SUB(AH args)
{
    return handler(67, args, null, false, false);
}

public final static String SUB(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(67, args, null, omit_begin, omit_end);
}

public final static String SUB(boolean omit_begin, boolean omit_end)
{
    return handler(67, AH.E, null, omit_begin, omit_end);
}

public final static String sub(String content)
{
    return handler(67, AH.E, content, false, false);
}

public final static String sub(AH args, String content)
{
    return handler(67, args, content, false, false);
}

public final static String sub(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(67, args, content, omit_begin, omit_end);
}

public final static String sub()
{
    return handler(67, AH.E, null, false, false);
}

public final static String sub(AH args)
{
    return handler(67, args, null, false, false);
}

public final static String sub(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(67, args, null, omit_begin, omit_end);
}

public final static String sub(boolean omit_begin, boolean omit_end)
{
    return handler(67, AH.E, null, omit_begin, omit_end);
}

public final static String SUP(String content)
{
    return handler(68, AH.E, content, false, false);
}

public final static String SUP(AH args, String content)
{
    return handler(68, args, content, false, false);
}

public final static String SUP(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(68, args, content, omit_begin, omit_end);
}

public final static String SUP()
{
    return handler(68, AH.E, null, false, false);
}

public final static String SUP(AH args)
{
    return handler(68, args, null, false, false);
}

public final static String SUP(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(68, args, null, omit_begin, omit_end);
}

public final static String SUP(boolean omit_begin, boolean omit_end)
{
    return handler(68, AH.E, null, omit_begin, omit_end);
}

public final static String sup(String content)
{
    return handler(68, AH.E, content, false, false);
}

public final static String sup(AH args, String content)
{
    return handler(68, args, content, false, false);
}

public final static String sup(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(68, args, content, omit_begin, omit_end);
}

public final static String sup()
{
    return handler(68, AH.E, null, false, false);
}

public final static String sup(AH args)
{
    return handler(68, args, null, false, false);
}

public final static String sup(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(68, args, null, omit_begin, omit_end);
}

public final static String sup(boolean omit_begin, boolean omit_end)
{
    return handler(68, AH.E, null, omit_begin, omit_end);
}

public final static String TABLE(String content)
{
    return handler(69, AH.E, content, false, false);
}

public final static String TABLE(AH args, String content)
{
    return handler(69, args, content, false, false);
}

public final static String TABLE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(69, args, content, omit_begin, omit_end);
}

public final static String TABLE()
{
    return handler(69, AH.E, null, false, false);
}

public final static String TABLE(AH args)
{
    return handler(69, args, null, false, false);
}

public final static String TABLE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(69, args, null, omit_begin, omit_end);
}

public final static String TABLE(boolean omit_begin, boolean omit_end)
{
    return handler(69, AH.E, null, omit_begin, omit_end);
}

public final static String table(String content)
{
    return handler(69, AH.E, content, false, false);
}

public final static String table(AH args, String content)
{
    return handler(69, args, content, false, false);
}

public final static String table(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(69, args, content, omit_begin, omit_end);
}

public final static String table()
{
    return handler(69, AH.E, null, false, false);
}

public final static String table(AH args)
{
    return handler(69, args, null, false, false);
}

public final static String table(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(69, args, null, omit_begin, omit_end);
}

public final static String table(boolean omit_begin, boolean omit_end)
{
    return handler(69, AH.E, null, omit_begin, omit_end);
}

public final static String TBODY(String content)
{
    return handler(70, AH.E, content, false, false);
}

public final static String TBODY(AH args, String content)
{
    return handler(70, args, content, false, false);
}

public final static String TBODY(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(70, args, content, omit_begin, omit_end);
}

public final static String TBODY()
{
    return handler(70, AH.E, null, false, false);
}

public final static String TBODY(AH args)
{
    return handler(70, args, null, false, false);
}

public final static String TBODY(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(70, args, null, omit_begin, omit_end);
}

public final static String TBODY(boolean omit_begin, boolean omit_end)
{
    return handler(70, AH.E, null, omit_begin, omit_end);
}

public final static String tbody(String content)
{
    return handler(70, AH.E, content, false, false);
}

public final static String tbody(AH args, String content)
{
    return handler(70, args, content, false, false);
}

public final static String tbody(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(70, args, content, omit_begin, omit_end);
}

public final static String tbody()
{
    return handler(70, AH.E, null, false, false);
}

public final static String tbody(AH args)
{
    return handler(70, args, null, false, false);
}

public final static String tbody(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(70, args, null, omit_begin, omit_end);
}

public final static String tbody(boolean omit_begin, boolean omit_end)
{
    return handler(70, AH.E, null, omit_begin, omit_end);
}

public final static String TD(String content)
{
    return handler(71, AH.E, content, false, false);
}

public final static String TD(AH args, String content)
{
    return handler(71, args, content, false, false);
}

public final static String TD(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(71, args, content, omit_begin, omit_end);
}

public final static String TD()
{
    return handler(71, AH.E, null, false, false);
}

public final static String TD(AH args)
{
    return handler(71, args, null, false, false);
}

public final static String TD(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(71, args, null, omit_begin, omit_end);
}

public final static String TD(boolean omit_begin, boolean omit_end)
{
    return handler(71, AH.E, null, omit_begin, omit_end);
}

public final static String td(String content)
{
    return handler(71, AH.E, content, false, false);
}

public final static String td(AH args, String content)
{
    return handler(71, args, content, false, false);
}

public final static String td(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(71, args, content, omit_begin, omit_end);
}

public final static String td()
{
    return handler(71, AH.E, null, false, false);
}

public final static String td(AH args)
{
    return handler(71, args, null, false, false);
}

public final static String td(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(71, args, null, omit_begin, omit_end);
}

public final static String td(boolean omit_begin, boolean omit_end)
{
    return handler(71, AH.E, null, omit_begin, omit_end);
}

public final static String TEXTAREA(String content)
{
    return handler(72, AH.E, content, false, false);
}

public final static String TEXTAREA(AH args, String content)
{
    return handler(72, args, content, false, false);
}

public final static String TEXTAREA(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(72, args, content, omit_begin, omit_end);
}

public final static String TEXTAREA()
{
    return handler(72, AH.E, null, false, false);
}

public final static String TEXTAREA(AH args)
{
    return handler(72, args, null, false, false);
}

public final static String TEXTAREA(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(72, args, null, omit_begin, omit_end);
}

public final static String TEXTAREA(boolean omit_begin, boolean omit_end)
{
    return handler(72, AH.E, null, omit_begin, omit_end);
}

public final static String textarea(String content)
{
    return handler(72, AH.E, content, false, false);
}

public final static String textarea(AH args, String content)
{
    return handler(72, args, content, false, false);
}

public final static String textarea(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(72, args, content, omit_begin, omit_end);
}

public final static String textarea()
{
    return handler(72, AH.E, null, false, false);
}

public final static String textarea(AH args)
{
    return handler(72, args, null, false, false);
}

public final static String textarea(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(72, args, null, omit_begin, omit_end);
}

public final static String textarea(boolean omit_begin, boolean omit_end)
{
    return handler(72, AH.E, null, omit_begin, omit_end);
}

public final static String TFOOT(String content)
{
    return handler(73, AH.E, content, false, false);
}

public final static String TFOOT(AH args, String content)
{
    return handler(73, args, content, false, false);
}

public final static String TFOOT(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(73, args, content, omit_begin, omit_end);
}

public final static String TFOOT()
{
    return handler(73, AH.E, null, false, false);
}

public final static String TFOOT(AH args)
{
    return handler(73, args, null, false, false);
}

public final static String TFOOT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(73, args, null, omit_begin, omit_end);
}

public final static String TFOOT(boolean omit_begin, boolean omit_end)
{
    return handler(73, AH.E, null, omit_begin, omit_end);
}

public final static String tfoot(String content)
{
    return handler(73, AH.E, content, false, false);
}

public final static String tfoot(AH args, String content)
{
    return handler(73, args, content, false, false);
}

public final static String tfoot(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(73, args, content, omit_begin, omit_end);
}

public final static String tfoot()
{
    return handler(73, AH.E, null, false, false);
}

public final static String tfoot(AH args)
{
    return handler(73, args, null, false, false);
}

public final static String tfoot(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(73, args, null, omit_begin, omit_end);
}

public final static String tfoot(boolean omit_begin, boolean omit_end)
{
    return handler(73, AH.E, null, omit_begin, omit_end);
}

public final static String TH(String content)
{
    return handler(74, AH.E, content, false, false);
}

public final static String TH(AH args, String content)
{
    return handler(74, args, content, false, false);
}

public final static String TH(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(74, args, content, omit_begin, omit_end);
}

public final static String TH()
{
    return handler(74, AH.E, null, false, false);
}

public final static String TH(AH args)
{
    return handler(74, args, null, false, false);
}

public final static String TH(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(74, args, null, omit_begin, omit_end);
}

public final static String TH(boolean omit_begin, boolean omit_end)
{
    return handler(74, AH.E, null, omit_begin, omit_end);
}

public final static String th(String content)
{
    return handler(74, AH.E, content, false, false);
}

public final static String th(AH args, String content)
{
    return handler(74, args, content, false, false);
}

public final static String th(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(74, args, content, omit_begin, omit_end);
}

public final static String th()
{
    return handler(74, AH.E, null, false, false);
}

public final static String th(AH args)
{
    return handler(74, args, null, false, false);
}

public final static String th(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(74, args, null, omit_begin, omit_end);
}

public final static String th(boolean omit_begin, boolean omit_end)
{
    return handler(74, AH.E, null, omit_begin, omit_end);
}

public final static String THEAD(String content)
{
    return handler(75, AH.E, content, false, false);
}

public final static String THEAD(AH args, String content)
{
    return handler(75, args, content, false, false);
}

public final static String THEAD(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(75, args, content, omit_begin, omit_end);
}

public final static String THEAD()
{
    return handler(75, AH.E, null, false, false);
}

public final static String THEAD(AH args)
{
    return handler(75, args, null, false, false);
}

public final static String THEAD(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(75, args, null, omit_begin, omit_end);
}

public final static String THEAD(boolean omit_begin, boolean omit_end)
{
    return handler(75, AH.E, null, omit_begin, omit_end);
}

public final static String thead(String content)
{
    return handler(75, AH.E, content, false, false);
}

public final static String thead(AH args, String content)
{
    return handler(75, args, content, false, false);
}

public final static String thead(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(75, args, content, omit_begin, omit_end);
}

public final static String thead()
{
    return handler(75, AH.E, null, false, false);
}

public final static String thead(AH args)
{
    return handler(75, args, null, false, false);
}

public final static String thead(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(75, args, null, omit_begin, omit_end);
}

public final static String thead(boolean omit_begin, boolean omit_end)
{
    return handler(75, AH.E, null, omit_begin, omit_end);
}

public final static String TITLE(String content)
{
    return handler(76, AH.E, content, false, false);
}

public final static String TITLE(AH args, String content)
{
    return handler(76, args, content, false, false);
}

public final static String TITLE(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(76, args, content, omit_begin, omit_end);
}

public final static String TITLE()
{
    return handler(76, AH.E, null, false, false);
}

public final static String TITLE(AH args)
{
    return handler(76, args, null, false, false);
}

public final static String TITLE(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(76, args, null, omit_begin, omit_end);
}

public final static String TITLE(boolean omit_begin, boolean omit_end)
{
    return handler(76, AH.E, null, omit_begin, omit_end);
}

public final static String title(String content)
{
    return handler(76, AH.E, content, false, false);
}

public final static String title(AH args, String content)
{
    return handler(76, args, content, false, false);
}

public final static String title(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(76, args, content, omit_begin, omit_end);
}

public final static String title()
{
    return handler(76, AH.E, null, false, false);
}

public final static String title(AH args)
{
    return handler(76, args, null, false, false);
}

public final static String title(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(76, args, null, omit_begin, omit_end);
}

public final static String title(boolean omit_begin, boolean omit_end)
{
    return handler(76, AH.E, null, omit_begin, omit_end);
}

public final static String TR(String content)
{
    return handler(77, AH.E, content, false, false);
}

public final static String TR(AH args, String content)
{
    return handler(77, args, content, false, false);
}

public final static String TR(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(77, args, content, omit_begin, omit_end);
}

public final static String TR()
{
    return handler(77, AH.E, null, false, false);
}

public final static String TR(AH args)
{
    return handler(77, args, null, false, false);
}

public final static String TR(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(77, args, null, omit_begin, omit_end);
}

public final static String TR(boolean omit_begin, boolean omit_end)
{
    return handler(77, AH.E, null, omit_begin, omit_end);
}

public final static String tr(String content)
{
    return handler(77, AH.E, content, false, false);
}

public final static String tr(AH args, String content)
{
    return handler(77, args, content, false, false);
}

public final static String tr(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(77, args, content, omit_begin, omit_end);
}

public final static String tr()
{
    return handler(77, AH.E, null, false, false);
}

public final static String tr(AH args)
{
    return handler(77, args, null, false, false);
}

public final static String tr(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(77, args, null, omit_begin, omit_end);
}

public final static String tr(boolean omit_begin, boolean omit_end)
{
    return handler(77, AH.E, null, omit_begin, omit_end);
}

public final static String TT(String content)
{
    return handler(78, AH.E, content, false, false);
}

public final static String TT(AH args, String content)
{
    return handler(78, args, content, false, false);
}

public final static String TT(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(78, args, content, omit_begin, omit_end);
}

public final static String TT()
{
    return handler(78, AH.E, null, false, false);
}

public final static String TT(AH args)
{
    return handler(78, args, null, false, false);
}

public final static String TT(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(78, args, null, omit_begin, omit_end);
}

public final static String TT(boolean omit_begin, boolean omit_end)
{
    return handler(78, AH.E, null, omit_begin, omit_end);
}

public final static String tt(String content)
{
    return handler(78, AH.E, content, false, false);
}

public final static String tt(AH args, String content)
{
    return handler(78, args, content, false, false);
}

public final static String tt(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(78, args, content, omit_begin, omit_end);
}

public final static String tt()
{
    return handler(78, AH.E, null, false, false);
}

public final static String tt(AH args)
{
    return handler(78, args, null, false, false);
}

public final static String tt(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(78, args, null, omit_begin, omit_end);
}

public final static String tt(boolean omit_begin, boolean omit_end)
{
    return handler(78, AH.E, null, omit_begin, omit_end);
}

public final static String U(String content)
{
    return handler(79, AH.E, content, false, false);
}

public final static String U(AH args, String content)
{
    return handler(79, args, content, false, false);
}

public final static String U(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(79, args, content, omit_begin, omit_end);
}

public final static String U()
{
    return handler(79, AH.E, null, false, false);
}

public final static String U(AH args)
{
    return handler(79, args, null, false, false);
}

public final static String U(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(79, args, null, omit_begin, omit_end);
}

public final static String U(boolean omit_begin, boolean omit_end)
{
    return handler(79, AH.E, null, omit_begin, omit_end);
}

public final static String u(String content)
{
    return handler(79, AH.E, content, false, false);
}

public final static String u(AH args, String content)
{
    return handler(79, args, content, false, false);
}

public final static String u(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(79, args, content, omit_begin, omit_end);
}

public final static String u()
{
    return handler(79, AH.E, null, false, false);
}

public final static String u(AH args)
{
    return handler(79, args, null, false, false);
}

public final static String u(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(79, args, null, omit_begin, omit_end);
}

public final static String u(boolean omit_begin, boolean omit_end)
{
    return handler(79, AH.E, null, omit_begin, omit_end);
}

public final static String UL(String content)
{
    return handler(80, AH.E, content, false, false);
}

public final static String UL(AH args, String content)
{
    return handler(80, args, content, false, false);
}

public final static String UL(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(80, args, content, omit_begin, omit_end);
}

public final static String UL()
{
    return handler(80, AH.E, null, false, false);
}

public final static String UL(AH args)
{
    return handler(80, args, null, false, false);
}

public final static String UL(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(80, args, null, omit_begin, omit_end);
}

public final static String UL(boolean omit_begin, boolean omit_end)
{
    return handler(80, AH.E, null, omit_begin, omit_end);
}

public final static String ul(String content)
{
    return handler(80, AH.E, content, false, false);
}

public final static String ul(AH args, String content)
{
    return handler(80, args, content, false, false);
}

public final static String ul(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(80, args, content, omit_begin, omit_end);
}

public final static String ul()
{
    return handler(80, AH.E, null, false, false);
}

public final static String ul(AH args)
{
    return handler(80, args, null, false, false);
}

public final static String ul(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(80, args, null, omit_begin, omit_end);
}

public final static String ul(boolean omit_begin, boolean omit_end)
{
    return handler(80, AH.E, null, omit_begin, omit_end);
}

public final static String VAR(String content)
{
    return handler(81, AH.E, content, false, false);
}

public final static String VAR(AH args, String content)
{
    return handler(81, args, content, false, false);
}

public final static String VAR(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(81, args, content, omit_begin, omit_end);
}

public final static String VAR()
{
    return handler(81, AH.E, null, false, false);
}

public final static String VAR(AH args)
{
    return handler(81, args, null, false, false);
}

public final static String VAR(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(81, args, null, omit_begin, omit_end);
}

public final static String VAR(boolean omit_begin, boolean omit_end)
{
    return handler(81, AH.E, null, omit_begin, omit_end);
}

public final static String var(String content)
{
    return handler(81, AH.E, content, false, false);
}

public final static String var(AH args, String content)
{
    return handler(81, args, content, false, false);
}

public final static String var(AH args, boolean omit_begin, boolean omit_end, String content)
{
    return handler(81, args, content, omit_begin, omit_end);
}

public final static String var()
{
    return handler(81, AH.E, null, false, false);
}

public final static String var(AH args)
{
    return handler(81, args, null, false, false);
}

public final static String var(AH args, boolean omit_begin, boolean omit_end)
{
    return handler(81, args, null, omit_begin, omit_end);
}

public final static String var(boolean omit_begin, boolean omit_end)
{
    return handler(81, AH.E, null, omit_begin, omit_end);
}

}
