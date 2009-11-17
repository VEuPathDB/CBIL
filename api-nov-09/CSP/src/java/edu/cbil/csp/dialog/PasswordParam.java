/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import edu.cbil.csp.*;

import javax.servlet.http.*;

/**
 * PasswordParam.java
 *
 * Subclass of {@link edu.cbil.csp.dialog.Param} that accepts a password.
 * It differs from <code>Param</code> only insofar as it renders to an 
 * HTML element that does not echo its output to the screen.
 * <p>
 *
 * Created: Mon Mar  8 19:23:50 1999
 *
 * @author Jonathan Crabtree
 * @version
 */
public class PasswordParam extends Param {
    
    /**
     * Constructor.
     *
     * @param name     Unique String used to identify the parameter in the context
     *                 of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr    A short description of the element.
     * @param help     A help string describing the element's usage.
     * @param st       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element itself.
     * @param ht       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element's help text.
     * @param prompt   Prompt string used to goad a recalcitrant user into entering data.
     * @param optional Whether the parameter is optional (usually not the case for passwords).
     */
    public PasswordParam(String name, String descr, String help,
			 StringTemplate st, StringTemplate ht, String prompt,
			 boolean optional) 
    {
	super(name, descr, help, st, ht, prompt, optional);
	
    }

    // --------
    // Item
    // --------

    public String[] getHTMLParams(String help_url) {
	return new String [] {
	    makeHTMLAnchor(false) + prompt, 
		HTMLUtil.INPUT
		(new AH(new String[] {
		    "name", this.name,
			"value", ((current_value != null) ? current_value : ""),
			"type", "password",
			"size", "25" })),
		makeHTMLLink(true, help_url, "Help!")};
    }

    // --------
    // Param
    // --------

    public Item copy(String url_subs) {
	return new PasswordParam(name, descr, help, template, help_template, prompt, optional);
    }

} // PasswordParam
