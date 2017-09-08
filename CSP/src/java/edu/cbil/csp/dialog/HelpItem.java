/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL), University of Pennsylvania Center for
 * Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * HelpItem.java
 *
 * A help item that can appear in the middle of a dialog, instead of the dialog's help section. The one
 * unusual aspect of this class is that it can potentially have additional help information associated with it
 * (which <b>will</b> appear in the help section.)
 * <p>
 *
 * Created: Tue Mar 9 07:50:15 1999
 *
 * @author Jonathan Crabtree
 */
public class HelpItem extends Item {

  /**
   * The help text that is to appear in the main dialog.
   */
  protected String help_text;

  /**
   * Constructor.
   *
   * @param name
   *          Unique String used to identify the action in the context of a larger input structure (e.g. a
   *          {@link edu.cbil.csp.dialog.Dialog}).
   * @param descr
   *          A short description of the element.
   * @param help_text
   *          The help text that will appear in the main dialog.
   * @param extra_help
   *          The "regular" help for the item, which <b>will</b> appear in the dialog's help section.
   * @param st
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element itself.
   * @param ht
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element's help text.
   */
  public HelpItem(String name, String descr, String help_text, String extra_help, StringTemplate st,
      StringTemplate ht) {
    super(name, descr, extra_help, st, ht);
    this.help_text = help_text;
  }

  // --------
  // Item
  // --------

  @Override
  public Item copy(String url_subs) {
    return new HelpItem(name, descr, help_text, help, template, help_template);
  }

  /**
   * Formatting constant.
   */
  protected AH fwidth = new AH(new String[] { "colspan", "3" });

  @Override
  public StringTemplate getDefaultTemplate() {
    String ps[] = StringTemplate.HTMLParams(1);
    return new StringTemplate(HTMLUtil.TR(HTMLUtil.TD(fwidth, ps[0])), ps);
  }

  @Override
  public String[] getHTMLParams(String help_url) {
    return new String[] {
        makeHTMLAnchor(false) + help_text + ((help != null) ? makeHTMLLink(true, help_url, "Help!") : "") };
  }

} // HelpItem
