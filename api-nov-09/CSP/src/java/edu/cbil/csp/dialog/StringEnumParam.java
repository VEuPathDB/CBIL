/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import edu.cbil.csp.*;

import java.util.*;

import javax.servlet.http.*;

/**
 * StringEnumParam.java
 *
 * This is a hybrid of an enumerated parameter.  The user may either
 * Type in a response, or choose from one of the enumerated values,
 * Or choose an enumerated value and then modify it by typing.
 * The options are all represented by Strings.<p>
 *
 * Created: Fri Feb  5 10:45:17 1999
 *
 * @author Phillip Le
 */
public class StringEnumParam extends Param {
    
    /**
     * HTML-specific; a constant used by the HTML rendering code to decide when to switch
     * from one representation (e.g.&nbsp;radio buttons or a &lt;SELECT&gt; list) to another.
     */
    protected final int TALL = 3;

    /**
     * HTML-specific; a constant used by the HTML rendering code to decide when to switch
     * from one representation (e.g.&nbsp;radio buttons or a &lt;SELECT&gt; list) to another.
     */
    protected final int GRANDE = 25;

    /**
     * The set of values allowed by the enumeration.
     */
    protected String values[];

    /**
     * The corresponding labels associated with <code>values</code>.
     * The user sees <code>labels</code>, whereas the target script or
     * program sees <code>values</code>.
     */
    protected String labels[];

    /**
     * The parameter's initial value.
     */
    protected String initial;

    /**
     * Cached value of <code>values.length</code>
     */
    protected int n_values;

    /**
     * A hint as to how many values should be displayed simultaneously.
     */
    protected int size_hint;

    /**
     * Hashtable that maps values to their labels.  Only used if labels
     * and values are different.
     */
    protected Hashtable value2label;

    /**
     * Constructor that accepts an initial value and a size hint.
     *
     * @param name        Unique String used to identify the parameter in the context
     *                    of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr       A short description of the element.
     * @param help        A help string describing the element's usage.
     * @param st          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                    element itself.
     * @param ht          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                    element's help text.
     * @param prompt      Prompt string used to goad a recalcitrant user into entering data.
     * @param values      The names for the enumeration values used internally.
     * @param labels      The names for the enumeration values presented to the user.
     * @param initial     Initial value.  Must be an element of <code>values</code>
     * @param optional    Whether the user is allowed to omit the parameter.
     * @param size_hint   Hint as to how many values should be displayed simultaneously.
     */
    protected StringEnumParam(String name, String descr, String help,
			StringTemplate st, StringTemplate ht, String prompt,
			String values[], String labels[], String initial, 
			boolean optional, int size_hint, Hashtable value2label)
    {
	super(name, descr, help, st, ht, prompt, optional);
	this.n_values = values.length;
	this.values = new String[n_values];
	for (int i = 0;i < n_values;i++) this.values[i] = values[i];

	if (labels != null) {
	    if (labels.length != n_values)
		throw new IllegalArgumentException("StringEnumParam: number of labels does not " +
						   "match number of values.");
	    this.labels = new String[n_values];
	    for (int i = 0;i < n_values;i++) this.labels[i] = labels[i];
	}
	this.initial = initial;
	this.size_hint = size_hint;

	if ((labels != null) && (values != null) && (labels != values) && (value2label == null)) {
	  this.value2label = new Hashtable();
	  for (int i = 0;i < n_values;i++) {
	    this.value2label.put(this.values[i], this.labels[i]);
	  }
	} else {
	  this.value2label = value2label;
	}
    }

    public StringEnumParam(String name, String descr, String help,
		     StringTemplate st, StringTemplate ht, String prompt,
		     String values[], String labels[], String initial, 
		     boolean optional, int size_hint) 
      {
	this(name, descr, help, st, ht, prompt, values, labels, initial, optional, size_hint, null);
      }

    /**
     * Constructor that accepts an initial value but not a size hint.
     */
    public StringEnumParam(String name, String descr, String help,
		     StringTemplate st, StringTemplate ht, String prompt,
		     String values[], String labels[], String initial,
		     boolean optional) 
      {
	this(name, descr, help, st, ht, prompt, values, labels, initial, optional, 5);
      }

    /**
     * Constructor that does <b>not</b> accept an initial value or a size hint.
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
    public StringEnumParam(String name, String descr, String help,
		     StringTemplate st, StringTemplate ht, String prompt,
		     String values[], String labels[])
    {
	this(name, descr, help, st, ht, prompt, values, labels, null, false);
    }

    // -----------
    // Item
    // -----------

    public String[] getSampleValues() { 
	return null; 
    }

    public Item copy(String url_subs) {
	StringEnumParam ep = new StringEnumParam(name, descr, help, template, help_template, 
				     prompt, values, labels, initial, optional,
				     size_hint, value2label);
	ep.current_value = this.current_value;
	return ep;
    }

    public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
					    Hashtable inputH, Hashtable inputHTML) 
    {
	String input = rq.getParameter(this.name);

	if (!optional && (input == null)) {
	    errors.append("This parameter is required; you must choose one of " + 
			  "the options listed.");
	    return false;
	}
	// Took out code from EnumParam here - Phil
	return true;
    }

    public StringTemplate getDefaultTemplate() {
	String ps[] = StringTemplate.HTMLParams(3);
	return new StringTemplate(HTMLUtil.TR
				  (HTMLUtil.TD("&nbsp;") + "\n" +
				   HTMLUtil.TD
				   (new AH(new String[] {"align", "right",
							     "valign", "middle"}), ps[0]) + "\n" +
				   HTMLUtil.TD
				   (left, "&nbsp;&nbsp;" + ps[1]) + "\n" +
				   HTMLUtil.TD
				   (new AH(new String[] {"align", "right",
							     "valign", "middle"}), 
				    HTMLUtil.DIV(new AH(new String[] {"align", "center"}), ps[2]))) + "\n", ps);
    }

    public String[] getHTMLParams(String help_url) {
	// This is a hybrid between EnumParam and TreeEnumParam
	// Because we need a select area and a text entry.
	
	String anchor = makeHTMLAnchor(false);
	String link = makeHTMLLink(true, help_url, "Help!");


	String size = Integer.toString(this.size_hint);
	StringBuffer result = new StringBuffer("\n");

	// Necessary for multiple-form pages
	//
	String formName = "0"; // specifies 1st form on the page; assumes there is only one

	// Avoid clashes between variables defined by other TreeEnumParams 
	// on the same HTML page.
	//
	StringBuffer sb = new StringBuffer();
	sb.append(makeFunc(name));
	sb.append("\n<BR>\n" + 
		  "<FONT SIZE=\"-1\">\n" +
		  "<INPUT TYPE=\"text\" NAME=\"" + name + "\" VALUE=\"");
	if (initial != null) // Puts in the initial value if there is one.
	    sb.append(initial);
	sb.append("\" SIZE=\"50\">\n" +
		  "<INPUT TYPE=\"hidden\" NAME=\"" + name + "_hidden\" VALUE=\"\">\n" +
		  "</FONT>\n" + 
		  "<BR CLEAR=\"both\">\n" +
		  
		  "<SELECT NAME=\"" + name + "_description\" SIZE=\""+ size +"\" " +
		  "ONCHANGE=\"makeSelect"+name+"('1', '" + formName + "', '" + name + "_description', '" + name + "');\">" +
		  makeOptionList() +  "</SELECT>\n" + 
		  "<SCRIPT LANGUAGE=\"JavaScript1.1\">\n" +
		  "<!--\n" +                                    // begin HTML comment
		  "makeSelect"+name+"('1', '" + formName + "', '" + name + 
		  "_description', '" + name + "');\n" + 
		  "// -->\n" +                                  // end HTML comment
		  "</SCRIPT>");
	String select = sb.toString();

	return new String[] {anchor + prompt, select, link};
    }


    protected String makeFunc(String name) {
	StringBuffer sb = new StringBuffer();

	sb.append("\n\n<SCRIPT LANGUAGE=\"JavaScript1.1\">\n");
	sb.append("<!--\n");                                    // begin HTML comment
	sb.append("\n");
	sb.append("function makeSelect"+name+"(id, formName, selName, modName) {\n");
	sb.append("  var select = document.forms[formName][selName];\n");
	sb.append("  var option;\n");
	sb.append("  var id;\n");
	sb.append("\n");
	sb.append("  if (select.selectedIndex != -1) {\n");
	sb.append("\n");
	sb.append("\n");
	sb.append("  option = select.options[select.selectedIndex];\n");
	//sb.append("  alert(option);\n");
	sb.append("  id = option.value;\n");
	sb.append("\n");
	sb.append("\n");
	sb.append("  document.forms[formName][modName].value = option.text;\n");
	sb.append("  }\n");
	sb.append("}\n");
	sb.append("// -->");                                    // end HTML comment
	sb.append("</SCRIPT>\n");
	return sb.toString();
    }

    protected String makeOptionList() {
	
	String size = (n_values <= GRANDE) ? "1" : Integer.toString(this.size_hint);
	StringBuffer result = new StringBuffer("\n");
	
	for (int i = 0;i < n_values;i++) {
	    if (((current_value != null) && (values[i].equals(current_value))) ||
		((current_value == null) && (initial != null) && (values[i].equals(initial)))) 
		{
		    result.append(HTMLUtil.OPTION
				  (new AH(new String[] {"selected", "",
							"value", values[i]}), 
				   (labels == null) ? values[i] : labels[i]));
		}
	    else 
		{
		    result.append(HTMLUtil.OPTION(new AH(new String[] {"value", values[i]}),
						  (labels == null) ? values[i] : labels[i]));
		}
	    result.append("\n");
	}

	return result.toString();
	
    }



    


    public Param copyParam(String new_name) {
        StringEnumParam ep = new StringEnumParam(new_name, descr, help, template, help_template, 
				     prompt, values, labels, initial, optional,
				     size_hint, value2label);
	return ep;
    }

    // -----------
    // StringEnumParam
    // -----------

    /**
     * Uses <code>value2label</code> to map a value to its corresponding label.
     */
    public String valueToLabel(String label) {
      if (this.value2label == null) return label;
      return (String)(this.value2label.get(label));
    }

} // StringEnumParam






