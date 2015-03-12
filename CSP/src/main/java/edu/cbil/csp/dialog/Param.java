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
 * Param.java
 *
 * A dialog Item that represents a piece of information to be
 * requested from the dialog user.  By default, an instance of
 * this class expects a short string.  Subclasses will be used
 * to represent more or less constrained forms of input.<p>
 *
 * Created: Thu Feb  4 08:47:06 1999
 *
 * @author Jonathan Crabtree
 * @version
 */
public class Param<T> extends Item<T> {

    /**
     * Prompt to spur the user into telling us something useful.
     */
    protected String prompt;

    /**
     * Whether this parameter is optional.
     */
    protected boolean optional;

    /**
     * Sample values for the parameter.
     */
    protected String sample_vals[];

    /**
     * Initial value.
     */
    protected T initial_value;

    /**
     * Constructor that takes an array of sample values.
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
     * @param optional Whether the parameter is optional.
     * @param sample_values  An array of sample inputs to be displayed in the help section.
     */
    public Param(String name, String descr, String help, 
		 StringTemplate st, StringTemplate ht, String prompt,
		 boolean optional, String sample_values[]) 
    {
      this(name, descr, help, st, ht, prompt, optional, null, sample_values);
    }

    /**
     * Constructor that does not take an array of sample values.
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
     * @param optional Whether the parameter is optional.
     */
    public Param(String name, String descr, String help, 
		 StringTemplate st, StringTemplate ht, String prompt,
		 boolean optional) 
    {
	this(name, descr, help, st, ht, prompt, optional, null, null);
    }

    /**
     * Constructor that takes an array of sample values and an initial value.
     *
     * @param name           Unique String used to identify the parameter in the context
     *                       of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr          A short description of the element.
     * @param help           A help string describing the element's usage.
     * @param st             {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                       element itself.
     * @param ht             {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                       element's help text.
     * @param prompt         Prompt string used to goad a recalcitrant user into entering data.
     * @param initial_value  An initial value.
     * @param optional       Whether the parameter is optional.
     * @param sample_values  An array of sample inputs to be displayed in the help section.
     */
    public Param(String name, String descr, String help, 
		 StringTemplate st, StringTemplate ht, String prompt,
		 boolean optional, T initial_value, String sample_values[]) 
    {
	super(name, descr, help, st, ht);
	this.prompt = prompt;
	this.optional = optional;
	this.sample_vals = sample_values;
	this.initial_value = initial_value;
    }

    /**
     * Constructor that takes an initial value, but not take an array of sample values.
     *
     * @param name           Unique String used to identify the parameter in the context
     *                       of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr          A short description of the element.
     * @param help           A help string describing the element's usage.
     * @param st             {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                       element itself.
     * @param ht             {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                       element's help text.
     * @param prompt         Prompt string used to goad a recalcitrant user into entering data.
     * @param initial_value  An initial value.
     * @param optional       Whether the parameter is optional.
     */
    public Param(String name, String descr, String help, 
		 StringTemplate st, StringTemplate ht, String prompt,
		 T initial_value, boolean optional) 
    {
	this(name, descr, help, st, ht, prompt, optional, initial_value, null);
    }

    // --------
    // Param
    // --------

    @Override
    public Item<T> copy(String url_subs) {
	Param<T> p = new Param<T>(name, descr, help, template, help_template, prompt, 
			    optional, initial_value, sample_vals);
	p.current_value = this.current_value;
	return p;
    }

    public String[] getSampleValues() { return sample_vals; }

    public String getPrompt() { return prompt; }

    // --------
    // Item
    // --------

    @Override
    public StringTemplate getDefaultHelpTemplate() {
	String ps[] = StringTemplate.HTMLParams(4);
	return new StringTemplate(HTMLUtil.TR
				  (HTMLUtil.TD
				   (left, HTMLUtil.B(ps[0])) +
				   HTMLUtil.TD
				   (right, ps[2])) +
				  HTMLUtil.TR
				  (HTMLUtil.TD(ps[1])) +
				  HTMLUtil.TR(HTMLUtil.TD(ps[3])), ps);
    }

    @Override
    public String[] getHTMLHelpParams(String form_url) {
	String sample_vals[] = getSampleValues();
	StringBuffer samples = new StringBuffer("");
	if (sample_vals != null) {
	    samples.append(HTMLUtil.B("Sample value(s):&nbsp"));
	    int n_samples = sample_vals.length;
	    for (int i = 0;i < n_samples;i++) {
		if (i > 0) samples.append(",&nbsp;");
		samples.append(sample_vals[i]);
	    }
	}

	return new String[]
	    { makeHTMLAnchor(true) + descr, 
		  help, 
		  makeHTMLLink(false, form_url, "Back To Form"),
		  samples.toString()};
    }

    /**
     * Used to store any value obtained in <code>storeHTMLServletInput</code>.
     */
    protected T current_value;

    public T getCurrentValue() { return current_value; }

    @Override
    public void storeHTMLServletInput(HttpServletRequest rq) {
	String input_value = rq.getParameter(this.name);
	if (input_value != null) this.current_value = convertToNativeType(input_value);
    }

    @Override
    public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
					    Hashtable<String,Object> inputH, Hashtable<String,String> inputHTML) 
    {
	T input = convertToNativeType(rq.getParameter(this.name));
	
	if (!optional && ((input == null) || (input.equals("")))) {
	    errors.append("This parameter is required and no value was entered.");
	    return false;
	}

	inputH.put(this.name, input);
	inputHTML.put(this.name, String.valueOf(input));

	return true;
    }

    @Override
    public StringTemplate getDefaultTemplate() {
	String ps[] = StringTemplate.HTMLParams(3);
	return new StringTemplate(HTMLUtil.TR
				  (HTMLUtil.TD() + "\n" +
				   HTMLUtil.TD(right, ps[0]) + "\n" +
				   HTMLUtil.TD(left, "&nbsp;&nbsp;" + ps[1]) + "\n" +
				   HTMLUtil.TD(right, 
					       HTMLUtil.DIV
					       (new AH(new String[] {"align", "center"}), 
						ps[2]))) + "\n", ps);
    }

    @Override
    public String[] getHTMLParams(String help_url) {
        String value = "";

	if (current_value != null) 
	  value = String.valueOf(current_value);
	else if (initial_value != null)
	  value = String.valueOf(initial_value);

	return new String [] {
	    makeHTMLAnchor(false) + prompt, 
		HTMLUtil.INPUT
		(new AH(new String[] {
		    "name", this.name,
			"value", value,
			"type", "text",
			"size", "25" })) + (optional ? "&nbsp;" + 
					       HTMLUtil.FONT(new AH(new String[] {"size", "-1"}),
							     HTMLUtil.I("(optional)")) : ""),
		makeHTMLLink(true, help_url, "Help!")};
    }

    // --------
    // Param
    // --------

    /**
     * Create copy of the parameter, but give it a different name.  This is a
     * factory method that supports making many identical parameter objects 
     * from the same template object.
     *
     * @param new_name  Name for the newly-created object.
     * @return          A new instance of <code>Param</code> with name <code>new_name</code>.
     */
    public Param<T> copyParam(String new_name) {
      Param<T> p = new Param<T>(new_name, descr, help, template, help_template, prompt, 
			  optional, initial_value, sample_vals);
      p.current_value = this.current_value;
      return p;
    }

    @SuppressWarnings("unchecked")
    @Override
    protected T convertToNativeType(String parameter) {
      // assume String type unless overridden
      return (T)parameter;
    }
}
