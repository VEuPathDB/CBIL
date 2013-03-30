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
 * MultiParam.java
 *
 * An enumerated value parameter.  The user may choose more than <b>one</b>
 * of the enumerated options.  The options are all represented by
 * Strings.<p>
 *
 * Created: Fri Feb  5 10:45:17 1999
 *
 * @author Jonathan Crabtree
 */
public class MultiParam extends EnumParam {

    // --------------------------------------------
    // Constructors
    // --------------------------------------------

    /**
     * Constructor that does not take in a  <code>value2lable Hashtable</code>.
     *
     * @param name     Unique String used to identify the action in the context
     *                 of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr    A short description of the element.
     * @param help     A help string describing the element's usage.
     * @param st       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element itself.
     * @param ht       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element's help text.
     * @param prompt   Prompt string used to goad a recalcitrant user into entering data.
     * @param values   The names for the enumeration values used internally.
     * @param labels   The names for the enumeration values presented to the user.
     */
    public MultiParam(String name, String descr, String help,
		     StringTemplate st, StringTemplate ht, String prompt,
		     String values[], String labels[], boolean optional)
    {
	super(name, descr, help, st, ht, prompt, values, labels, null, optional); //, null, null);
    }

    /**
     * 
     * @param name     Unique String used to identify the action in the context
     *                 of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr    A short description of the element.
     * @param help     A help string describing the element's usage.
     * @param st       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element itself.
     * @param ht       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element's help text.
     * @param prompt   Prompt string used to goad a recalcitrant user into entering data.
     * @param values   The names for the enumeration values used internally.
     * @param labels   The names for the enumeration values presented to the user.
     * @param value2label Hashtable mapping of values to a label.
     */

    public MultiParam(String name, String descr, String help,
                      StringTemplate st, StringTemplate ht, String prompt,
                      String values[], String labels[], Hashtable value2label)
    {
	super(name, descr, help, st, ht, prompt, values, labels, null, false, 5, value2label);

    }

    public MultiParam(String name, String descr, String help,
                      StringTemplate st, StringTemplate ht, String prompt,
                      String values[], String labels[], boolean optional, Hashtable value2label)
    {
	super(name, descr, help, st, ht, prompt, values, labels, null, optional, 5, value2label);

    }


    // --------------------------------------------
    // Item
    // --------------------------------------------

   public Item copy(String url_subs) {
	MultiParam mp = new MultiParam(name, descr, help, template, help_template, 
				     prompt, values, labels, value2label);
        return mp;
    }

    /**
     * Used to store any value obtained in <code>storeHTMLServletInput</code>.
     */
    protected String[] current_values;
    
    public String getCurrentValue(){
        StringBuffer c_value = new StringBuffer("");
        for (int i = 0; i < current_values.length; i++) {
            c_value.append(current_values[i] + ",");
        }
        c_value.setLength((c_value.length() - 1));
        return c_value.toString();
    }

    public String[] getCurrentValues() { return current_values; }
    public void storeHTMLServletInput(HttpServletRequest rq) {
        String input_value[] = rq.getParameterValues(this.name);
        if (input_value != null) this.current_values = input_value;
    }

    public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
					    Hashtable inputH, Hashtable inputHTML) 
    {
	String input[] = rq.getParameterValues(this.name);

	if (!optional && (input == null)) {
	    errors.append("This parameter is required; you must choose one of " + 
			  "the options listed.");
	    return false;
	}
	
        for (int j = 0; j < input.length; j++) {
            boolean success = false;
            for (int i = 0;i < n_values; i++) {
                if (input[j].equals(values[i])) {
                    inputH.put(this.name, values[i]);
                    inputHTML.put(this.name, valueToLabel(values[i]));
                    success = true;
                    break;
                    // return true;
                }
            }

            if (!success) {
                errors.append("The value selected, '" + input[j] + "', is not among "
                              + "those permitted for this parameter.  Please return to "
                              + "the form and choose one of the available option2`s.  "
                              + "If you are not sure what to enter, return to the form "
                              + "and click on the link next to the parameter to " 
                              + "see more detailed help information. ");
                return false;
            }
        }
        return true;
    }

    public StringTemplate getDefaultTemplate() {
	String ps[] = StringTemplate.HTMLParams(3);
	return new StringTemplate(HTMLUtil.TR(HTMLUtil.TD(new AH
            (new String[] {"align", "right",
                           "valign", "middle"}), ps[0]) + "\n" +
                                              HTMLUtil.TD
                                              (left, "&nbsp;&nbsp;" + ps[1]) + "\n" +
                                              HTMLUtil.TD
                                              (new AH(new String[] {"align", "right",
                                                                    "valign", "top"}), 
                                               HTMLUtil.DIV(new AH(new String[] {"align", "center"}), ps[2]))) + "\n", ps);
    }
    public String[] getHTMLParams(String help_url) {
	String anchor = makeHTMLAnchor(false);
	String link = makeHTMLLink(true, help_url, "Help!");
        
        StringBuffer result = new StringBuffer();
        for (int i = 0;i < n_values;i++) {
            AH base = new AH(new String[] {"type", "checkbox",
                                           "name", name,
                                           "value", values[i]});
            result.append(HTMLUtil.INPUT(base) + "&nbsp;&nbsp;" + labels[i] + "<BR>\n");
        }
        return new String[] {anchor + prompt, result.toString(), link};
        
    }
}



