/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * Dialog.java
 *
 * An object that represents a "dialog" (information gathering session!)
 * with a user.  Such an object might be rendered as an HTML form in
 * an HTML/CGI setting, or as a Java applet or Javascript-enhanced
 * form in others.  It serves to define an abstract specification of
 * what information is to be retrieved from the user, rather than how
 * the resulting form should be displayed.<p>
 *
 * <B>NOTE</B>: Most of the classes in this package, including this one,
 * currently only support rendering to HTML.  Furthermore, this assumption
 * is hard-coded in a number of locations, and this will need to be fixed
 * at some point.  Of interest in this regard is the Java Apache Project's
 * effort to define a set of classes (SPFC) that are to HTML forms what the JFC
 * are to on-screen GUIs. See <A HREF = "http://java.apache.org/spfc/index.html">
 * http://java.apache.org/spfc/index.html</A><p>
 *
 * Created: Thu Feb  4 07:51:31 1999
 *
 * @author Jonathan Crabtree
*/
public class Dialog extends ItemGroup {
    
    /**
     * A human-readable description of the dialog and its purpose.
     */
    protected String purpose;

    /**
     * URL to which an HTML version of the dialog should be directed.
     */
    protected String cgi_url;

    /**
     * Either "get" or "post".
     */
    protected String cgi_method;

    /**
     * A set of parameters which are hidden, both from the HTML end-user
     * and also from the superclass ItemGroup methods.
     */
    protected ConstantParam hiddenParams[];

    /**
     * Constructor.
     *
     * @param abstract      Short description of the dialog's purpose in life.
     * @param cgi-url       Required if an HTML form is to be generated; is
     *                      specifies the back-end program that will handle the
     *                      form input.
     * @param hiddenParams  Optional set of hidden parameters to place at the
     *                      beginning or end of the form.
     */
    public Dialog(String purpose, String cgi_url, String cgi_method, 
		  ConstantParam hiddenParams[]) 
    {
	this(purpose, cgi_url, cgi_method, hiddenParams, null, null);
    }

    public Dialog(String purpose, String cgi_url, String cgi_method, 
		  ConstantParam hiddenParams[], StringTemplate st, StringTemplate ht) 
    {
	super(null, null, "Help", st, ht);
	this.purpose = purpose;
	this.cgi_url = cgi_url;
	this.cgi_method = cgi_method;
	this.hiddenParams = hiddenParams;
    }

    public Dialog(String purpose, String cgi_url) {
	this(purpose, cgi_url, "POST", null);
    }

    // -------------------
    // Item
    // -------------------

    public Item copy(String url_subs) {
      Dialog result = new Dialog(purpose, cgi_url, cgi_method, hiddenParams, template, help_template);
      copyItems(this, result, url_subs);
      return result;
    }

    // -------------------
    // HTML Generation
    // -------------------

    /**
     * Formatting constant.
     */
    protected static AH fullwidth = new AH(new String[] {"width", "100%"});
    protected static AH fullwidthTable = new AH(new String[] {"width", "100%", 
							      "cellspacing", "2", 
							      "cellpadding", "1"});
    protected static AH fullwidth_debug = new AH(new String[] {"width", "100%", "border", "1"});

    public String[] getHTMLParams(String help_url) {
	StringBuffer itemText = new StringBuffer();
	int n_items = items.size();
	for (int i = 0;i < n_items;i++) {
	    Item di = (Item)items.elementAt(i);
	    itemText.append(di.makeHTML(help_url));
	    itemText.append("\n");
	}

	StringBuffer hiddenText = new StringBuffer();
	if (hiddenParams != null) {
	    int n_hidden = hiddenParams.length;
	    for (int i = 0;i < n_hidden;i++) {
		itemText.append(hiddenParams[i].makeHTML(help_url));
		itemText.append("\n");
	    }
	}

	return new String[] {hiddenText.toString(), itemText.toString()};
    }

    public StringTemplate getDefaultTemplate() {
	String ps[] = StringTemplate.HTMLParams(2);

	//	if (hiddenParams != null) {
	//	}

	return new StringTemplate(HTMLUtil.FORM
				  (new AH(new String[] {"action", cgi_url,
							"method", cgi_method}),
				   ps[0] + HTMLUtil.TABLE(fullwidth_debug, ps[1])) + "\n", ps);
    }

    public StringTemplate getDefaultHelpTemplate() {
	String ps[] = StringTemplate.HTMLParams(3);
	return new StringTemplate(ps[0] +
				  HTMLUtil.HR(fullwidth) +
				  HTMLUtil.TABLE
				  (fullwidth, HTMLUtil.TR
				   (HTMLUtil.TD 
				    (new AH (new String[] {"bgcolor", "#000000"}),
				    (HTMLUtil.FONT
				     (new AH(new String[] {"size", "+1",
							   "face", "Helvetica,sans-serif",
							   "color", "#ffffff"}),
				      HTMLUtil.B(ps[1]) +
				      HTMLUtil.BR()))))) + "\n" +
				  HTMLUtil.TABLE
				  (new AH(new String[] {"width", "100%", "border", "0"}),
				   ps[2]) + "\n", ps);
    }
    
    public String[] getHTMLHelpParams(String form_url) {
	StringBuffer space = new StringBuffer();
	for (int i = 0;i < 40;i++) space.append(HTMLUtil.BR());

	String super_params[] = super.getHTMLHelpParams(form_url);

	return new String[] {
	    space.toString(),
		super_params[0],
		super_params[1]
	};
    }

} // Dialog
