/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * Item.java
 *
 * A generic individual element of a {@link edu.cbil.csp.dialog.Dialog}.  
 * Subclasses of <code>Item</code> specialize it for particular purposes, 
 * such as embedding actions (@link edu.cbil.csp.dialog.Action) and 
 * parameters (@link edu.cbil.csp.dialog.Param) in the dialog.  Every
 * element of a <code>Dialog</code> is an <code>Item</code>, as is
 * <code>Dialog</code> itself.<p>
 *
 * NOTE:<BR>
 *
 * Requires that an <code>Item</code>'s name be unique within its 
 * enclosing Dialog, and currently assumes that no more than one Dialog
 * will appear on a single HTML page.  This limitation is because 
 * the various HREFs use the Item's name as a unique identifier.
 * It also assumes that Items will be rendered to HTML.<P>
 *
 * Created: Thu Feb  4 08:08:44 1999
 *
 * @author Jonathan Crabtree
 */
public abstract class Item<T> {

    /**
     * Hard-coded link to CSP "help" image.
     *
     * TO DO: eliminate hard-coding.
     */
    public static String HELP_IMG
	= "http://www.cbil.upenn.edu/CSP_Resources_v1.2/images/toHelp.jpg";

    /**
     * Hard-coded link to CSP "to form" image.
     *
     * TO DO: eliminate hard-coding.
     */
    public static String TOFORM_IMG
	= "http://www.cbil.upenn.edu/CSP_Resources_v1.2/images/toForm.jpg";

    /**
     * Formatting constant.
     */
    protected static AH left = new AH(new String[] {"align", "left"});

    /**
     * Formatting constant.
     */
    protected static AH right = new AH(new String[] {"align", "right"});

    /**
     * Constructor.
     *
     * @param name     Unique String used to identify the item in the context
     *                 of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr    A short description of the element.
     * @param help     A help string describing the element's usage.
     * @param st       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element itself.
     * @param ht       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element's help text.
     */
    public Item(String name, String descr, String help, 
		StringTemplate st, StringTemplate ht) 
    {
	this.name = name;
	this.descr = descr;
	this.help = help;
	this.template = st;
	this.help_template = ht;
    }

    // -----------------------------------------------------------------------
    // Generic (i.e. hopefully not specific to any output format) parameters.
    // -----------------------------------------------------------------------

    /**
     * Unique identifier for the item.  This string is assumed to uniquely 
     * identify the item with respect to its containing Dialog.  In the case
     * of data-gathering items (i.e. {@link edu.cbil.csp.dialog.Param}s) it is 
     * used as the HTML NAME of the corresponding FORM input element, and 
     * is therefore the name by which the user's input data can be retrieved
     * from the CGI input.
     */
    protected String name;

    /**
     * A human-readable description of the item.  Commonly displayed in the
     * help section of the dialog.
     */
    protected String descr;

    /**
     * Help text describing the item in more detail.  Appears in the help
     * section of the dialog.
     */
    protected String help;
    
    // -----------------------------------------------------------------------
    // Overtly HTML-specific parameters.
    // -----------------------------------------------------------------------

    /**
     * Controls the look and feel of the item itself (more specifically
     * that part of the item that appears within the main Dialog, rather
     * than its help section.)
     */
    protected StringTemplate template;

    /**
     * Controls the look and feel of the item's help text, which will
     * appear within the Dialog's help section.
     */
    protected StringTemplate help_template;

    // -------------------
    // Access methods
    // -------------------

    /**
     * Get the name.
     *
     * @return The name (unique identifier) of the item.
     */
    public String getName() { return name; }

    /**
     * Get the description.
     *
     * @return The item's human-readable description.
     */
    public String getDescription() { return descr; }

    // -------------------
    // Item
    // -------------------

    /**
     * Make a (recursive) copy of the item, applying the supplied Perl-style
     * substitution to any URLs found therein.
     *
     * @param url_subs  A {@link com.oroinc.text.perl} Perl substitution string 
     *                  to apply to each of the URLs in the item and its children.
     * @return          A copy of this item.
     */
    public abstract Item<T> copy(String url_subs);


    protected abstract T convertToNativeType(String parameter);

    /**
     * Set the item's description.
     *
     * @param new_descr  The item's new description.
     */
    public void setDescription(String new_descr) { this.descr = new_descr; }

    // -------------------
    // Input validation
    // -------------------

    /**
     * Recursively store the contents of a servlet request (i.e. the values 
     * the user has entered into a form so far) into the item and its descendants.
     * Each item checks whether one of the form fields corresponds to it and, if
     * so, records the appropriate piece of information.  Servlet-specific.
     *
     * @param rq       The servlet request containing the user's input.
     */
    public void storeHTMLServletInput(HttpServletRequest rq) {}

    /**
     * Check that the user input contained in a servlet request conforms to
     * the constraints of this item and its descendants.  The validated 
     * (and potentially post-processed) user input is stored in the 
     * hashtable <code>input</code>.
     *
     * @param rq         The servlet request containing the user's input.
     * @param errors     A StringBuffer to which errors generated by the item
     *                   and its descendants should be appended.
     * @param input      A Hashtable that will be populated with the valid
     *                   input values.
     * @param inputHTML  HTML representations of the values in <code>input</code>
     * @return           True if all the recognized input validates.
     */
    public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
					    Hashtable<String,Object> input, Hashtable<String,String> inputHTML) 
    {
	return true;
    }

    // -------------------
    // HTML Generation
    // -------------------

    /**
     * Default {@link edu.cbil.csp.StringTemplate} to use in formatting this 
     * item if none was passed to its constructor.
     */
    public abstract StringTemplate getDefaultTemplate();

    /**
     * Default {@link edu.cbil.csp.StringTemplate} to use in formatting this
     * item's help text if none was passed to its constructor.
     */
    public StringTemplate getDefaultHelpTemplate() {
	String ps[] = StringTemplate.HTMLParams(3);
	return new StringTemplate(HTMLUtil.TR
				  (HTMLUtil.TD
				   (left, HTMLUtil.B(ps[0])) +
				   HTMLUtil.TD
				   (right, ps[2])) +
				  HTMLUtil.TR
				  (HTMLUtil.TD(ps[1])) +
				  HTMLUtil.TR(HTMLUtil.TD()), ps);
    }

    /**
     * Return the parameter values used to instantiate the HTML template.
     *
     * @param help_url  URL indicating the location at which the item's help 
     *                  text will be generated.  Allows the creation of
     *                  cross references.
     * @return The values that will be substituted into the item's 
     *         HTML {@link edu.cbil.csp.StringTemplate} before it is 
     *         displayed.
     */
    public abstract String[] getHTMLParams(String help_url);

    /**
     * Return the parameter values used to instantiate the HTML help template.
     *
     * @param form_url  URL indicating the location at which the item itself
     *                  will be displayed.  Allows the creation of cross references.
     * @return The values that will be substituted into the item's 
     *         HTML help section {@link edu.cbil.csp.StringTemplate} before it
     *         is displayed.
     */

    public String[] getHTMLHelpParams(String form_url) {
	return new String[]
	    { makeHTMLAnchor(true) + descr, 
		  help, 
		  makeHTMLLink(false, form_url, "Back To Form")};
    }

    /**
     * Generate the HTML text for the item.
     *
     * @param help_url URL at which the help text for the item will reside;
     *                 used to generate an HREF link.
     * @return The HTML generated.
     */
    public String makeHTML(String help_url) {
	if (template == null) template = getDefaultTemplate();

	// DEBUG
	//	System.out.println("template = " + template);
	//	System.out.println("n_params = " + getHTMLParams(help_url).length);

	return template.instantiate(getHTMLParams(help_url));
    }

    /**
     * Generate the HTML text that will represent the item's
     * help information.
     *
     * @param form_url URL at which the HTML for the item will reside; used
     *                 to generate a link back to the form from the help 
     *                 section.
     * @return The HTML generated.
     */
    public String makeHTMLHelp(String form_url) {
	if (help == null) return "";
	if (help_template == null) help_template = getDefaultHelpTemplate();
	return help_template.instantiate(getHTMLHelpParams(form_url));
    }

    /**
     * Helper method that creates an HTML anchor for the item or its
     * helptext.
     *
     * @param helptext Whether the anchor is for the helptext (true)
     *                 or the item itself (false).
     */
    protected String makeHTMLAnchor(boolean helptext) {
	String anchor = helptext ? ("HELP_" + this.name) : this.name;
	return HTMLUtil.A(new AH(new String[] {"name", anchor}));
    }

    /**
     * Helper method that creates a link to one of the HTML anchors
     * generated by <code>makeHTMLAnchor</code>.
     *
     * @param helptext Whether to link <em>TO</em> the help section (true) or
     *                 the item proper (false).
     * @param url      URL at which the item to be linked TO resides.
     * @param alt      Alternate text for the HTML link.
     */
    protected String makeHTMLLink(boolean helptext, String url, String alt) {
	if (url == null) return "";
	String target = helptext ? ("#HELP_" + this.name) : ("#" + this.name);
	String img_src = helptext ? HELP_IMG : TOFORM_IMG;
	return HTMLUtil.A(new AH(new String[] {"href", url + target}), 
			  HTMLUtil.IMG(new AH(new String[] {"src", img_src,
								"border", "0",
								"alt", alt})));
    }

} // Item
