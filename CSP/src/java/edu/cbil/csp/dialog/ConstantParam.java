/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import javax.servlet.http.HttpServletRequest;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * ConstantParam.java
 *
 * A subclass of {@link edu.cbil.csp.dialog.Param} that represents a 
 * parameter whose value is constant.  Yes, it is a bit of a 
 * contradiction in terms.<p>
 *
 * Created: Thu Feb  4 10:26:51 1999
 *
 * @author Jonathan Crabtree
 * @version $Revision$ $Date$ $Author$
*/
public class ConstantParam extends Param {
    
    /**
     * Whether the value of the parameter should be hidden from the user.
     */
    protected boolean hidden;

    /**
     * (Constant) value of the parameter.
     */
    protected String value;

    /**
     * Constructor.
     *
     * @param name     Unique String used to identify the action in the context
     *                 of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr    A short description of the element.
     * @param help     A help string describing the element's usage.
     * @param st       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element itself.
     * @param ht       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element's help text.
     * @param prompt   Prompt string used to goad the user into entering data.
     *                 In this case the user cannot enter data, so the prompt
     *                 serves instead as a description of the value (assuming that
     *                 the parameter is not hidden.)
     * @param hidden   Whether the parameter should be hidden from the user.
     * @param value    The (constant) value of the parameter.
     */
    public ConstantParam(String name, String descr, String help, 
			 StringTemplate st, StringTemplate ht, 
			 String prompt, boolean hidden, String value)
    {
	super(name, descr, help, st, ht, prompt, true);
	this.hidden = hidden;
	this.value = value;
    }

    /**
     * Formatting constant.
     */
    protected static AH zero_height = new AH(new String[] {"height", "0"});

    // --------
    // Item
    // --------

    public Item copy(String url_subs) {
	return new ConstantParam(name, descr, help, template, help_template, prompt, hidden, value);
    }

    /**
     * Since the parameter is constant a call to this method has no effect.
     */
    public void storeHTMLServletInput(HttpServletRequest rq) {}

    public String[] getHTMLParams(String help_url) {
	String input_elt = HTMLUtil.INPUT
	    (new AH(new String[] {"type", "hidden",
				  "name", name,
				  "value", value}));
	String items[] = null;

	if (hidden) return new String[] {input_elt, "", ""};
	return new String[] { input_elt + HTMLUtil.B(prompt), HTMLUtil.I(value), ""};
    }

    protected static AH left2 = new AH(new String[] {"align", "left", "colspan", "2"});

    public StringTemplate getDefaultTemplate() {
	if (hidden) {
	    String ps[] = StringTemplate.HTMLParams(3);
	    return new StringTemplate(HTMLUtil.TR
				      (HTMLUtil.TD
				       (left2, ps[0] + "&nbsp;")), ps);
	}
	return super.getDefaultTemplate();
    }
    
} // ConstantParam
