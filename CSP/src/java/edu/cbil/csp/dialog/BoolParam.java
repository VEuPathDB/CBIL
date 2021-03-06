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
 * BoolParam.java
 *
 * Subclass of {@link edu.cbil.csp.dialog.Param} for <code>boolean</code> values.
 * <p>
 *
 * Created: Fri Feb 5 21:27:19 1999
 *
 * @author Jonathan Crabtree
 * @version
 */
public class BoolParam extends Param<Boolean> {

  /**
   * Initial value for the parameter.
   */
  protected boolean initial;

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
   * @param initial
   *          Initial value for the parameter.
   */
  public BoolParam(String name, String descr, String help, StringTemplate st, StringTemplate ht,
      String prompt, boolean initial) {
    super(name, descr, help, st, ht, prompt, false);
    this.initial = initial;
  }

  // ------------
  // Param
  // ------------

  @Override
  public Boolean[] getSampleValues() {
    return null;
  }

  // ------------
  // BoolParam
  // ------------

  @Override
  public BoolParam copyParam(String new_name) {
    return new BoolParam(new_name, descr, help, template, help_template, prompt, initial);
  }

  // --------
  // Item
  // --------

  @Override
  public BoolParam copy(String url_subs) {
    BoolParam b = this.copyParam(name);
    b.current_value = this.current_value;
    return b;
  }

  @Override
  public void storeHTMLServletInput(HttpServletRequest rq) {
    String value = rq.getParameter(this.name);
    current_value = (value == null) ? Boolean.FALSE : Boolean.TRUE;
  }

  @Override
  public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors, Hashtable<String,Object> inputH,
      Hashtable<String,String> inputHTML) {

    String input = rq.getParameter(this.name);

    if ((input == null) || (input.equals(""))) {
      inputH.put(this.name, Boolean.FALSE);
      inputHTML.put(this.name, "false");
    }
    else {
      inputH.put(this.name, Boolean.TRUE);
      inputHTML.put(this.name, "true");
    }

    // Always valid: if the input doesn't specify a value,
    // it's interpreted as being false.
    //
    return true;
  }

  @Override
  public StringTemplate getDefaultTemplate() {
    String ps[] = StringTemplate.HTMLParams(3);
    return new StringTemplate(HTMLUtil.TR(HTMLUtil.TD("&nbsp;") +
        HTMLUtil.TD(new AH(new String[] { "align", "right", "valign", "middle" }), ps[0]) +
        HTMLUtil.TD(left, "&nbsp;&nbsp;" + ps[1]) +
        HTMLUtil.TD(new AH(new String[] { "align", "right", "valign", "middle" }), ps[2])), ps);
  }

  @Override
  public String[] getHTMLParams(String help_url) {
    String anchor = makeHTMLAnchor(false);
    String link = makeHTMLLink(true, help_url, "Help!");

    AH cb = new AH(new String[] { "type", "checkbox", "name", name });

    // If we have a stored input value, use that. Otherwise use
    // any default value.
    //
    if (((current_value != null) && (current_value.booleanValue())) ||
        ((current_value == null) && (initial))) {
      if (initial)
        cb.put("checked", "");
    }

    String checkbox = HTMLUtil.INPUT(cb);

    return new String[] { anchor + prompt, checkbox, link };
  }

  @Override
  public Boolean convertToValue(String string) {
    return Boolean.valueOf(string);
  }

  @Override
  public String convertToString(Boolean value) {
    return value.toString();
  }

} // BoolParam
