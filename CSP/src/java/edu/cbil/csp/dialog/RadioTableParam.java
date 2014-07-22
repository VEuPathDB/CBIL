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
 * RadioTable.java
 *
 * An enumerated value parameter specifically for a small number of enumerated values.
 * It will create an HTML table with three columns (radio button, value , description)
 * The user may choose only <b>one</b> of the enumerated options.  
 * The options are all represented by Strings.<p>
 *
 * Created: Thu Jun 19 12:38:14 EDT 2003
 *
 * @author Angel Pizarro
 * @version $Revision$ $Date$ $Author$
 */
public class RadioTableParam extends Param {
    
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
   * The corresponding description associated with <code>labels</code>.
   */
  protected String defs[];

  /**
   * The parameter"s initial value.
   */
  protected String initial;
  
  /**
   * Cached value of <code>values.length</code>
   */
  protected int n_values;

  /**
   * Hashtable that maps values to their labels.  Only used if labels
   * and values are different.
   */
  protected Hashtable value2label;
  
  /**
   * Constructor that accepts an initial value.
   *
   * @param name        Unique String used to identify the parameter in the context
   *                    of a larger input structure (e.g. a {@link cbil.csp.dialog.Dialog}).
   * @param descr       A short description of the element.
   * @param help        A help string describing the element"s usage.
   * @param st          {@link cbil.csp.StringTemplate} that controls the appearance of the
   *                    element itself.
   * @param ht          {@link cbil.csp.StringTemplate} that controls the appearance of the
   *                    element"s help text.
   * @param prompt      Prompt string used to goad a recalcitrant user into entering data.
   * @param values      The names for the enumeration values used internally.
   * @param labels      The names for the enumeration values presented to the user.
   * @param defs        The definitions for the enumeration values presented to the user.
   * @param initial     Initial value.  Must be an element of <code>values</code>
   * @param optional    Whether the user is allowed to omit the parameter.
   */
  protected RadioTableParam(String name, String descr, String help,
                      StringTemplate st, StringTemplate ht, String prompt,
                      String values[], String labels[], String defs[], String initial, 
                      boolean optional, Hashtable value2label)
  {
    super(name, descr, help, st, ht, prompt, optional);
    this.n_values = values.length;
    this.values = new String[n_values];
    for (int i = 0;i < n_values;i++) this.values[i] = values[i];
    
    if (labels != null) {
      if (labels.length != n_values)
        throw new IllegalArgumentException("RadioTableParam: number of labels does not " +
                                           "match number of values.");
      this.labels = new String[n_values];
      for (int i = 0;i < n_values;i++) this.labels[i] = labels[i];
    }
    if (defs != null) {
      if (defs.length != n_values)
        throw new IllegalArgumentException("RadioTableParam: number of definitions does not " +
                                           "match number of values.");
      this.defs = new String[n_values];
      for (int i = 0;i < n_values;i++) this.defs[i] = defs[i];
    }

    this.initial = initial;
    
    if ((labels != null) && (values != null) && (labels != values) && (value2label == null)) {
      this.value2label = new Hashtable();
      for (int i = 0;i < n_values;i++) {
	    this.value2label.put(this.values[i], this.labels[i]);
      }
    } else {
      this.value2label = value2label;
    }
  }


  /**
   * Constructor that accepts an initial value.
   */
  public RadioTableParam(String name, String descr, String help,
                   StringTemplate st, StringTemplate ht, String prompt,
                   String values[], String labels[], String defs[], String initial, 
                   boolean optional) 
  {
    this(name, descr, help, st, ht, prompt, values, labels, defs, initial, optional, null);
  }

  /**
   * Constructor that does <b>not</b> accept an initial value or a size hint.
   *
   * @param name     Unique String used to identify the action in the context
   *                 of a larger input structure (e.g. a {@link cbil.csp.dialog.Dialog}).
   * @param descr    A short description of the element.
   * @param help     A help string describing the element"s usage.
   * @param st       {@link cbil.csp.StringTemplate} that controls the appearance of the
   *                 element itself.
   * @param ht       {@link cbil.csp.StringTemplate} that controls the appearance of the
   *                 element"s help text.
   * @param prompt   Prompt string used to goad a recalcitrant user into entering data.
   * @param values   The names for the enumeration values used internally.
   * @param labels   The names for the enumeration values presented to the user.
   * @param defs        The definitions for the enumeration values presented to the user.
   */
  public RadioTableParam(String name, String descr, String help,
                   StringTemplate st, StringTemplate ht, String prompt,
                   String values[], String labels[], String defs[])
  {
	this(name, descr, help, st, ht, prompt, values, labels, defs, null, false);
  }

  /**
   * Constructor that does <b>not</b> accept a list of definitions. This will create a two-column table.
   *
   * @param name     Unique String used to identify the action in the context
   *                 of a larger input structure (e.g. a {@link cbil.csp.dialog.Dialog}).
   * @param descr    A short description of the element.
   * @param help     A help string describing the element"s usage.
   * @param st       {@link cbil.csp.StringTemplate} that controls the appearance of the
   *                 element itself.
   * @param ht       {@link cbil.csp.StringTemplate} that controls the appearance of the
   *                 element"s help text.
   * @param prompt   Prompt string used to goad a recalcitrant user into entering data.
   * @param values   The names for the enumeration values used internally.
   * @param labels   The names for the enumeration values presented to the user.
   */
  public RadioTableParam(String name, String descr, String help,
                   StringTemplate st, StringTemplate ht, String prompt,
                   String values[], String labels[])
  {
	this(name, descr, help, st, ht, prompt, values, labels, null, null, false);
  }
  
  // -----------
  // Item
  // -----------
  
  public String[] getSampleValues() { 
    return null; 
  }

  public Item copy(String url_subs) {
    RadioTableParam ep = new RadioTableParam(name, descr, help, template, help_template, 
                                             prompt, values, labels, defs, initial, optional,
                                             value2label);
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
    
    for (int i = 0;i < n_values; i++) {
	    if (input.equals(values[i])) {
        inputH.put(this.name, values[i]);
        inputHTML.put(this.name, valueToLabel(values[i]));
        return true;
	    }
    }
    
    errors.append("The value selected, " + input + ", is not among those " +
                  "permitted for this parameter.  Please return to the form " +
                  "and choose one of the available options.  If you are not " +
                  "sure what to enter, return to the form and click on the " +
                  "link next to the parameter to see more detailed help information. ");
    return false;
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
    String anchor = makeHTMLAnchor(false);
    String link = makeHTMLLink(true, help_url, "Help!");
    
    // Only use radio buttons if labels are the same as values: radio buttons
    // don"t let us display separate labels.
    //
    StringBuffer result = new StringBuffer("\n");
    result.append(HTMLUtil.TABLE(new AH ( new String[] {"border", "1"}), false,true));
    for (int i = 0;i < n_values;i++) {
      AH base = new AH(new String[] {"type", "radio",
                                     "name", name,
                                     "value", values[i]});
      
      if (((current_value != null) && (values[i].equals(current_value))) ||
          ((current_value == null) && (initial != null) && (values[i].equals(initial)))) 
        {
          base.put("checked", "");
        }
      
      result.append(HTMLUtil.TR
                    ( HTMLUtil.TD
                      (new AH( new String[]{"bgcolor","#CFCFCF"}),
                      HTMLUtil.INPUT(base) ) +
                      HTMLUtil.TD(((labels == null) ? values[i] : labels[i]) + "&nbsp;&nbsp;") + 
                      ((defs == null) ? "" : 
                      HTMLUtil.TD(new AH ( new String[] {"align", "right"}) , defs[i] + "&nbsp;&nbsp;"))
                     ));
    }
    result.append(HTMLUtil.TABLE(true,false) + "\n");
    return new String[] {anchor + prompt, result.toString(), link};
  }
  
  public Param copyParam(String new_name) {
    RadioTableParam ep = new RadioTableParam(new_name, descr, help, template, help_template, 
                                             prompt, values, labels, defs, initial, optional,
                                             value2label);
    return ep;
  }
  
  // -----------
  // RadioTableParam
  // -----------
  
  /**
   * Uses <code>value2label</code> to map a value to its corresponding label.
   */
  public String valueToLabel(String label) {
    if (this.value2label == null) return label;
    return (String)(this.value2label.get(label));
  }
  
} // RadioTableParam
