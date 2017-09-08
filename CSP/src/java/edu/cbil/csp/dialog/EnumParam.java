/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL), University of Pennsylvania Center for
 * Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * EnumParam.java
 *
 * An enumerated value parameter. The user may choose only <b>one</b> of the enumerated options. The options
 * are all represented by Strings.
 * <p>
 *
 * Created: Fri Feb 5 10:45:17 1999
 *
 * @author Jonathan Crabtree
 */
public class EnumParam extends StringParam {

  /**
   * HTML-specific; a constant used by the HTML rendering code to decide when to switch from one
   * representation (e.g.&nbsp;radio buttons or a &lt;SELECT&gt; list) to another.
   */
  protected final int TALL = 3;

  /**
   * HTML-specific; a constant used by the HTML rendering code to decide when to switch from one
   * representation (e.g.&nbsp;radio buttons or a &lt;SELECT&gt; list) to another.
   */
  protected final int GRANDE = 25;

  /**
   * The set of values allowed by the enumeration.
   */
  protected String values[];

  /**
   * The corresponding labels associated with <code>values</code>. The user sees <code>labels</code>, whereas
   * the target script or program sees <code>values</code>.
   */
  protected String labels[];

  /**
   * Cached value of <code>values.length</code>
   */
  protected int n_values;

  /**
   * A hint as to how many values should be displayed simultaneously.
   */
  protected int size_hint;

  /**
   * Hashtable that maps values to their labels. Only used if labels and values are different.
   */
  protected Hashtable<String,String> value2label;

  /**
   * Constructor that accepts an initial value and a size hint.
   *
   * @param name
   *          Unique String used to identify the parameter in the context of a larger input structure (e.g. a
   *          {@link edu.cbil.csp.dialog.Dialog}).
   * @param descr
   *          A short description of the element.
   * @param help
   *          A help string describing the element's usage.
   * @param st
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element itself.
   * @param ht
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element's help text.
   * @param prompt
   *          Prompt string used to goad a recalcitrant user into entering data.
   * @param values
   *          The names for the enumeration values used internally.
   * @param labels
   *          The names for the enumeration values presented to the user.
   * @param initial
   *          Initial value. Must be an element of <code>values</code>
   * @param optional
   *          Whether the user is allowed to omit the parameter.
   * @param size_hint
   *          Hint as to how many values should be displayed simultaneously.
   */
  protected EnumParam(String name, String descr, String help, StringTemplate st, StringTemplate ht,
      String prompt, String values[], String labels[], String initial, boolean optional, int size_hint,
      Hashtable<String,String> value2label) {
    super(name, descr, help, st, ht, prompt, optional);
    this.n_values = values.length;
    this.values = new String[n_values];
    for (int i = 0; i < n_values; i++)
      this.values[i] = values[i];

    if (labels != null) {
      if (labels.length != n_values)
        throw new IllegalArgumentException(
            "EnumParam: number of labels does not " + "match number of values.");
      this.labels = new String[n_values];
      for (int i = 0; i < n_values; i++)
        this.labels[i] = labels[i];
    }
    this.initial_value = initial;
    this.size_hint = size_hint;

    if ((labels != null) && (labels != values) && (value2label == null)) {
      this.value2label = new Hashtable<>();
      for (int i = 0; i < n_values; i++) {
        this.value2label.put(this.values[i], this.labels[i]);
      }
    }
    else {
      this.value2label = value2label;
    }
  }

  public EnumParam(String name, String descr, String help, StringTemplate st, StringTemplate ht,
      String prompt, String values[], String labels[], String initial, boolean optional, int size_hint) {
    this(name, descr, help, st, ht, prompt, values, labels, initial, optional, size_hint, null);
  }

  /**
   * Constructor that accepts an initial value but not a size hint.
   */
  public EnumParam(String name, String descr, String help, StringTemplate st, StringTemplate ht,
      String prompt, String values[], String labels[], String initial, boolean optional) {
    this(name, descr, help, st, ht, prompt, values, labels, initial, optional, 5);
  }

  /**
   * Constructor that does <b>not</b> accept an initial value or a size hint.
   *
   * @param name
   *          Unique String used to identify the action in the context of a larger input structure (e.g. a
   *          {@link edu.cbil.csp.dialog.Dialog}).
   * @param descr
   *          A short description of the element.
   * @param help
   *          A help string describing the element's usage.
   * @param st
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element itself.
   * @param ht
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element's help text.
   * @param prompt
   *          Prompt string used to goad a recalcitrant user into entering data.
   * @param values
   *          The names for the enumeration values used internally.
   * @param labels
   *          The names for the enumeration values presented to the user.
   */
  public EnumParam(String name, String descr, String help, StringTemplate st, StringTemplate ht,
      String prompt, String values[], String labels[]) {
    this(name, descr, help, st, ht, prompt, values, labels, null, false);
  }

  // -----------
  // Item
  // -----------

  @Override
  public String[] getSampleValues() {
    return null;
  }

  @Override
  public Item copy(String url_subs) {
    EnumParam ep = new EnumParam(name, descr, help, template, help_template, prompt, values, labels, initial_value,
        optional, size_hint, value2label);
    ep.current_value = this.current_value;
    return ep;
  }

  @Override
  public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors, Hashtable<String,Object> inputH,
      Hashtable<String,String> inputHTML) {
    String input = rq.getParameter(this.name);

    if (!optional && (input == null)) {
      errors.append("This parameter is required; you must choose one of " + "the options listed.");
      return false;
    }

    for (int i = 0; i < n_values; i++) {
      if (input.equals(values[i])) {
        inputH.put(this.name, values[i]);
        inputHTML.put(this.name, valueToLabel(values[i]));
        return true;
      }
    }

    errors.append("The value selected, '" + input + "', is not among those " +
        "permitted for this parameter.  Please return to the form " +
        "and choose one of the available options.  If you are not " +
        "sure what to enter, return to the form and click on the " +
        "link next to the parameter to see more detailed help information. ");
    return false;
  }

  @Override
  public StringTemplate getDefaultTemplate() {
    String ps[] = StringTemplate.HTMLParams(3);
    return new StringTemplate(HTMLUtil.TR(HTMLUtil.TD("&nbsp;") + "\n" +
        HTMLUtil.TD(new AH(new String[] { "align", "right", "valign", "middle" }), ps[0]) + "\n" +
        HTMLUtil.TD(left, "&nbsp;&nbsp;" + ps[1]) + "\n" +
        HTMLUtil.TD(new AH(new String[] { "align", "right", "valign", "middle" }),
            HTMLUtil.DIV(new AH(new String[] { "align", "center" }), ps[2]))) +
        "\n", ps);
  }

  @Override
  public String[] getHTMLParams(String help_url) {
    String anchor = makeHTMLAnchor(false);
    String link = makeHTMLLink(true, help_url, "Help!");

    // Only use radio buttons if labels are the same as values: radio buttons
    // don't let us display separate labels.
    //
    if ((n_values <= TALL) && (labels == null)) {
      StringBuffer result = new StringBuffer();
      for (int i = 0; i < n_values; i++) {
        AH base = new AH(new String[] { "type", "radio", "name", name, "value", values[i] });

        if (((current_value != null) && (values[i].equals(current_value))) ||
            ((current_value == null) && (initial_value != null) && (values[i].equals(initial_value)))) {
          base.put("checked", "");
        }

        result.append(HTMLUtil.INPUT(base) + values[i] + "&nbsp;&nbsp;");
      }
      return new String[] { anchor + prompt, result.toString(), link };
    }
    else {
      String size = (n_values <= GRANDE) ? "1" : Integer.toString(this.size_hint);
      StringBuffer result = new StringBuffer("\n");

      for (int i = 0; i < n_values; i++) {
        if (((current_value != null) && (values[i].equals(current_value))) ||
            ((current_value == null) && (initial_value != null) && (values[i].equals(initial_value)))) {
          result.append(HTMLUtil.OPTION(new AH(new String[] { "selected", "", "value", values[i] }),
              (labels == null) ? values[i] : labels[i]));
        }
        else {
          result.append(HTMLUtil.OPTION(new AH(new String[] { "value", values[i] }),
              (labels == null) ? values[i] : labels[i]));
        }
        result.append("\n");
      }

      String select = HTMLUtil.SELECT(new AH(new String[] { "name", name, "size", size }), result.toString());
      return new String[] { anchor + prompt, select, link };
    }
  }

  @Override
  public EnumParam copyParam(String new_name) {
    EnumParam ep = new EnumParam(new_name, descr, help, template, help_template, prompt, values, labels,
        initial_value, optional, size_hint, value2label);
    return ep;
  }

  // -----------
  // EnumParam
  // -----------

  /**
   * Uses <code>value2label</code> to map a value to its corresponding label.
   */
  public String valueToLabel(String label) {
    if (this.value2label == null)
      return label;
    return this.value2label.get(label);
  }

} // EnumParam
