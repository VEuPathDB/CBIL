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
 * IntParam.java
 *
 * A potentially range-restricted integer-valued {@link edu.cbil.csp.dialog.Param}.
 * <P>
 *
 * Created: Sat Feb 6 11:05:46 1999
 *
 * @author Jonathan Crabtree
 */
public class IntParam extends Param<Integer> {

  /**
   * Minimum allowed value for the parameter (inclusive). No minimum if it is null.
   */
  protected Integer min;

  /**
   * Maximum allowed value for the parameter (inclusive). No maximum if it is null.
   */
  protected Integer max;

  /**
   * Human-readable string describing the range and type constraints imposed by the parameter (e.g. "an
   * integer between 1 and 10, inclusive"). This String is generated automatically.
   */
  protected String constraint;

  /**
   * Cached string versions of <code>sample_values</code>.
   */
  protected String sample_value_strs[];

  /**
   * Constructor.
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
   * @param min
   *          Minimum allowed value for the parameter, inclusive. A value of <code>null</code> means that
   *          there is no minimum.
   * @param max
   *          Maximum allowed value for the parameter, inclusive. A value of <code>null</code> means that
   *          there is no maximum.
   * @param initial
   *          Initial value for the parameter. May be null.
   * @param optional
   *          Whether the user is allowed to omit the parameter.
   * @param sample_values
   *          An array of sample values to present to the user along with the help text. May be null.
   */
  public IntParam(String name, String descr, String help, StringTemplate st, StringTemplate ht, String prompt,
      Integer min, Integer max, Integer initial, boolean optional, Integer[] sample_values) {
    super(name, descr, help, st, ht, prompt, optional);
    this.min = min;
    this.max = max;
    this.initial_value = initial;
    this.constraint = "&nbsp an integer &nbsp;";
    if (min != null) {
      constraint = constraint + ">= " + min + "&nbsp;";
      if (max != null)
        constraint = constraint + "and &nbsp; <= " + max;
    }
    else {
      if (max != null)
        constraint = constraint + "<= " + max;
    }
    if (sample_values != null) {
      this.sample_values = sample_values;
      int n_samples = sample_values.length;
      this.sample_value_strs = new String[n_samples];
      for (int i = 0; i < n_samples; i++) {
        this.sample_value_strs[i] = Integer.toString(sample_values[i]);
      }
    }
  }

  // -------
  // Item
  // -------

  @Override
  public Item copy(String url_subs) {
    return new IntParam(name, descr, help, template, help_template, prompt, min, max, initial_value, optional,
        sample_values);
  }

  @Override
  public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
      Hashtable<String,Object> inputH, Hashtable<String,String> inputHTML) {
    String input = rq.getParameter(this.name);
    int inval;

    if (!optional && (input == null) || (input.equals(""))) {
      errors.append(
          "This parameter is required; you must enter an integer in " + "the range specified (if any).");
      return false;
    }

    try {
      inval = Integer.parseInt(input);
    }
    catch (NumberFormatException nfe) {
      errors.append("The system was unable to parse the value entered, '" + input +
          "', as a valid integer.  Please enter an integral " +
          "value using only the digits <TT>0-9</TT>, with no leading zeros.");
      return false;
    }

    if ((min != null) && (inval < min.intValue())) {
      errors.append("The entered value '" + inval + "' is less than the minimum " +
          "value for this parameter, " + min + ".  Please enter a " +
          "larger number (but one that is less than the indicated maximum, " + "if shown.)");
      return false;
    }

    if ((max != null) && (inval > max.intValue())) {
      errors.append("The entered value " + inval + " is greater than the maximum " + "for this parameter, " +
          max + ".  Please enter a smaller " +
          "number (but one that is greater than the indicated minimum, " + "if shown.)");
      return false;
    }

    inputH.put(this.name, new Integer(inval));
    inputHTML.put(this.name, Integer.toString(inval));
    return true;
  }

  @Override
  public String[] getHTMLParams(String help_url) {
    String anchor = makeHTMLAnchor(false);
    String link = makeHTMLLink(true, help_url, "Help!");
    String value = getStringValue();

    return new String[] { anchor + prompt,
        HTMLUtil.INPUT(
            new AH(new String[] { "name", this.name, "type", "text", "size", "20", "value", value })) +
            HTMLUtil.I(HTMLUtil.FONT(new AH(new String[] { "size", "-1" }), constraint)),
        link };
  }

  @Override
  public IntParam copyParam(String new_name) {
    return new IntParam(new_name, descr, help, template, help_template, prompt, min, max, initial_value, optional,
        sample_values);
  }

  @Override
  public Integer convertToValue(String string) {
    return Integer.valueOf(string);
  }

  @Override
  public String convertToString(Integer value) {
    return String.valueOf(value);
  }

} // IntParam
