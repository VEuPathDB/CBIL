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
 * DoubleParam.java
 *
 * A potentially range-restricted double or "real"-valued {@link edu.cbil.csp.dialog.Param}.
 * <P>
 *
 * Created: Sat Feb  6 14:45:33 1999
 *
 * @author Jonathan Crabtree
 */
public class DoubleParam extends Param<Double> {

    // TO DO - factor out the elements common to this class and IntParam ?
    
    /**
     * Minimum allowed value for the parameter (inclusive).
     * No minimum if it is null.
     */
    protected Double min;

    /**
     * Maximum allowed value for the parameter (inclusive).
     * No maximum if it is null.
     */
    protected Double max;

    /**
     * Initial value of the parameter.  None if null.
     */
    protected Double initial;

    /**
     * Human-readable string describing the range and type constraints 
     * imposed by the parameter  (i.e. "This is a decimal value between
     * 0.25 and 0.50 inclusive.")  This String is generated automatically.
     */
    protected String constraint;

    /**
     * Array of sample values that can be presented to indecisive, 
     * confused, or lazy users.  These values must meet the 
     * constraints imposed by the parameter.
     */
    protected double sample_values[];

    /**
     * Cached <code>String</code> versions of <code>sample_values</code>.
     */
    protected String sample_value_strs[];

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
     * @param min      Minimum allowed value for the parameter, inclusive.
     *                 A value of <code>null</code> means that there is no minimum.
     * @param max      Maximum allowed value for the parameter, inclusive.
     *                 A value of <code>null</code> means that there is no maximum.
     * @param initial        Initial value for the parameter.  May be null.
     * @param optional       Whether the user is allowed to omit the parameter.
     * @param sample_values  An array of sample values to present to the user along
     *                       with the help text.  May be null.
     */
    public DoubleParam(String name, String descr, String help,
		      StringTemplate st, StringTemplate ht, String prompt,
		      Double min, Double max, Double initial, boolean optional,
		       double sample_values[])  
    {
	super(name, descr, help, st, ht, prompt, optional);
	this.min = min;
	this.max = max;
	this.initial = initial;
	this.constraint = "&nbsp a real number &nbsp;";
	if (min != null) {
	    constraint = constraint + ">= " + min + "&nbsp;";
	    if (max != null) constraint = constraint + "and &nbsp; <= " + max;
	} else {
	    if (max != null) constraint = constraint + "<= " + max;
	}
	if (sample_values != null) {
	    this.sample_values = sample_values;
	    int n_samples = sample_values.length;
	    this.sample_value_strs = new String[n_samples];
	    for (int i = 0;i < n_samples;i++) {
		this.sample_value_strs[i] = Double.toString(sample_values[i]);
	    }
	}
    }

    // --------
    // Item
    // --------

    @Override
    public Item<Double> copy(String url_subs) {
	return new DoubleParam(name, descr, help, template, 
			       help_template, prompt, min, max, initial, 
			       optional, sample_values);
    }

    @Override
    public String[] getSampleValues() { 
	return sample_value_strs; 
    }

    @Override
    public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
					    Hashtable<String, Object> inputH, Hashtable<String, String> inputHTML) 
    {
	String input = rq.getParameter(this.name);
	double inval;

	if (!optional && (input == null) || (input.equals(""))) {
	    errors.append("This parameter is required; you must enter a real number in " +
			  "the range specified (if any).");
	    return false;
	}

	Double inDouble = null;

	try {
	    inDouble = new Double(input);
	    inval = inDouble.doubleValue();
	} catch (NumberFormatException nfe) {
	    errors.append("The system was unable to parse the value entered, '" +
			  input + "', as a valid real number.  Please enter a real " +
			  "(i.e. double precision) number.  The following are examples " +
			  "of valid real numbers: 2.00005, 32.4E-5, 2e10.");
	    return false;
	}

	if ((min != null) && (inval < min.doubleValue())) {
	    errors.append("The entered value '" + inval + "' is less than the minimum " +
			  "value for this parameter, " + min + ".  Please enter a " +
			  "larger number (but one that is less than the indicated maximum, " +
			  "if shown.)");
	    return false;
	}

	if ((max != null) && (inval > max.doubleValue())) {
	    errors.append("The entered value " + inval + " is greater than the maximum " +
			  "for this parameter, " + max + ".  Please enter a smaller " +
			  "number (but one that is greater than the indicated minimum, " +
			  "if shown.)");
	    return false;
	}

	inputH.put(this.name, inDouble);
	inputHTML.put(this.name, inDouble.toString());
	return true;
    }

    @Override
    public String[] getHTMLParams(String help_url) {
	String anchor = makeHTMLAnchor(false);
	String link = makeHTMLLink(true, help_url, "Help!");
	String val;

	if (current_value != null) {
	    val = String.valueOf(current_value);
	} else {
	    val = (initial != null) ? Double.toString(initial.doubleValue()) : "";
	}

	return new String[] {anchor + prompt,
				 HTMLUtil.INPUT
				 (new AH(new String[] {"name", this.name,
							   "type", "text",
							   "size", "20",
							   "value", val})) + 
				 HTMLUtil.I
				     (HTMLUtil.FONT
				      (new AH(new String[] {"size", "-1"}),
				       constraint)),
				 link};
    }

    @Override
    public Param<Double> copyParam(String new_name) {
	return new DoubleParam(new_name, descr, help, template, 
			       help_template, prompt, min, max, initial, 
			       optional, sample_values);
    }

    @Override
    protected Double convertToNativeType(String parameter) {
      return Double.valueOf(parameter);
    }
} // DoubleParam
