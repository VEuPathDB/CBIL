/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import org.apache.oro.text.perl.Perl5Util;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * Action.java
 *
 * An action that a user can invoke from a {@link edu.cbil.csp.dialog.Dialog}.  
 * In the context of an HTML form, it will typically be rendered as 
 * a "submit" input element, but if constructed with its own URL, it can 
 * also be rendered as a plain hyperlink (with the obvious proviso that
 * when a user clicks on the link, any data entered into the form itself
 * will be lost).<p>
 *
 * Created: Thu Feb  4 10:11:54 1999
 *
 * @author Jonathan Crabtree
*/
public class Action extends Item<String> implements ActionHandler {
    
    // HTML-specific parameters

    /**
     * HTML-specific; either "reset" or "submit."
     */
    protected String type;

    /**
     * HTML-specific; the value of the HTML INPUT "value" attribute.
     */
    protected String value;

    /**
     * HTML-specific; the URL to use if the <code>Action</code> 
     * is to be rendered as a hyperlink.
     */
    protected String url;

    /**
     * Constructor for an <code>Action</code> that corresponds to an HTML INPUT element.
     *
     * @param name   Unique String used to identify the action in the context
     *               of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr  A short description of the element.
     * @param help   A help string describing the element's usage.
     * @param st     {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *               element itself.
     * @param ht     {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *               element's help text.
     * @param type   The type of input element, either "reset" or "submit" (HTML-specific)
     * @param value  A value to be submitted with the HTML form when the Action is invoked.
     */
    public Action(String name, String descr, String help, 
		  StringTemplate st, StringTemplate ht,
		  String type, String value) 
    {
	this(name, descr, help, st, ht, type, value, null);
    }

    /**
     * Constructor for an <code>Action</code> that corresponds to an HTML hyperlink.
     *
     * An alternate constructor that accepts a URL; in an HTML context 
     * this allows the Action to be rendered as a simple hyperlink 
     * rather than as a button.
     *
     * @param name   Unique String used to identify the action in the context
     *               of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr  A short description of the element.
     * @param help   A help string describing the element's usage.
     * @param st     {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *               element itself.
     * @param ht     {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *               element's help text.
     * @param type   The type of input element, either "reset" or "submit" (HTML-specific)
     * @param value  A value to be submitted with the HTML form when the Action is invoked.
     * @param url   The URL to fetch when the Action is invoked.
     */
    public Action(String name, String descr, String help, 
		  StringTemplate st, StringTemplate ht,
		  String type, String value, String url) 
    {
	super(name, descr, help, st, ht);
	this.value = value;
	this.type = type.toLowerCase();
	this.url = url;

	if (!type.equals("reset") && !type.equals("submit"))
	    throw new IllegalArgumentException("Action: type must be 'reset' or 'submit'; '" 
					       + type + "' is not allowed.");
    }

    // --------
    // Action
    // --------

    /**
     * Handles regular expression matching.
     */
    protected static Perl5Util perl = new Perl5Util();

    @Override
    public Item<String> copy(String url_substitution) {
      String new_url = (url == null) ? null : perl.substitute(url_substitution, url);
      return new Action(name, descr, help, template, help_template, type, value, new_url);
    }

    // --------------
    // ActionHandler
    // --------------

    @Override
    public boolean handleAction(String action) {
	return true;
    }

    // --------
    // Item
    // --------

    @Override
    public StringTemplate getDefaultTemplate() { 
	String ps[] = StringTemplate.HTMLParams(1);
	return new StringTemplate(ps[0] + "&nbsp;&nbsp", ps);
    }

    @Override
    public String[] getHTMLParams(String help_url) {

	// Hyperlink/GET version - does not support "reset"
	//
	if ((url != null) && (!type.equals("reset")))
	    return new String[] {
	    HTMLUtil.A(new AH(new String[] {"href", url + "&" +
						encodeUtf8(name) + "=" + 
						encodeUtf8(value)}), 
		       "[" + value + "]")
		};
	else {

	    // "INPUT" version
	    //
	    return new String[] {
		(HTMLUtil.INPUT
		 (new AH(new String[] {"type", type,
				       "name", name,
				       "value", value})))};
	}
    }
    
    private static String encodeUtf8(String s) {
      try { return URLEncoder.encode(s, "UTF-8"); }
      catch (UnsupportedEncodingException e) { throw new RuntimeException(e); }
    }

    @Override
    protected String convertToNativeType(String parameter) {
      return parameter;
    }
}
