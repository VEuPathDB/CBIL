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
 * FreeTextParam.java
 *
 * Created: Thu Apr 8 11:09:33 1999
 *
 * @author Jonathan Crabtree
 *
 */
public class FreeTextParam extends Param {

  protected String initial_value;
  protected String sample_values[];
  protected int width_hint, height_hint;
  protected StringValidatorI validator;

  public FreeTextParam(String name, String descr, String help,
		       StringTemplate st, StringTemplate ht, String prompt,
		       boolean optional, int width_hint, int height_hint,
		       String initial_value, String sample_values[],
		       StringValidatorI validator)
    {
      super(name, descr, help, st, ht, prompt, optional);
      this.initial_value = initial_value;
      this.sample_values = sample_values;
      this.width_hint = width_hint;
      this.height_hint = height_hint;
      this.validator = validator;
    }

  public FreeTextParam(String name, String descr, String help,
		       StringTemplate st, StringTemplate ht, String prompt,
		       boolean optional, int width_hint, int height_hint,
		       String initial_value, String sample_values[]) 
    {
      this(name, descr, help, st, ht, prompt, optional, width_hint, height_hint,
	   initial_value, sample_values, null);
    }
  
  // -------
  // Item
  // -------
  
  public String[] getSampleValues() 
    { 
      return sample_values;
    }

  public Item copy(String url_subs) {
    return new FreeTextParam(name, descr, help, template, help_template,
			     prompt, optional, width_hint, height_hint,
			     initial_value, sample_values, validator);
  }

  protected AH textarea = new AH(new String[] {"colspan", "3"});

  public StringTemplate getDefaultTemplate() {
    String ps[] = StringTemplate.HTMLParams(3);
    return new StringTemplate(HTMLUtil.TR
			      (HTMLUtil.TD() +
			       HTMLUtil.TD(left, ps[0]) +
			       HTMLUtil.TD(right, ps[2])) +
			      HTMLUtil.TR
			      (HTMLUtil.TD() + 
			       HTMLUtil.TD(textarea, ps[1])), ps);
  }

  public String[] getHTMLParams(String help_url) 
    {
      String anchor = makeHTMLAnchor(false);
      String link = makeHTMLLink(true, help_url, "Help!");
      String val;
      
      return new String[] {anchor + prompt,
			   HTMLUtil.TEXTAREA
			     (new AH(new String[] {"name", this.name,
						   "rows", Integer.toString(height_hint),
						   "cols", Integer.toString(width_hint)}),
			      (initial_value == null) ? "" : initial_value) 
			   //			   + HTMLUtil.BR() + 
			   //			   HTMLUtil.INPUT(new AH(new String[] {"type", "file",
			   //							       "name", this.name + "_file"}))
			   , link};
    }

    public Param copyParam(String new_name) 
      {
	return new FreeTextParam(new_name, descr, help, template, 
				 help_template, prompt, optional,
				 width_hint, height_hint,
				 initial_value, sample_values, validator);
      }

  // -------
  // Param
  // -------
  
  public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
					  Hashtable inputH, Hashtable inputHTML) 
    {
	String input = rq.getParameter(this.name);

	// Take text box input over an uploaded file.
	//
	if ((input == null) || (input.equals(""))) {
	    input = rq.getParameter(this.name + "_file");
	}
	
	boolean valid = true;

	if (!optional && ((input == null) || (input.equals("")))) {
	    errors.append("This parameter is required and no value was entered.");
	    return false;
	}
	
	if (validator != null) {
	    valid = validator.isStringValid(input, errors);
	}

	if (valid) {
	    inputH.put(this.name, input);
	    inputHTML.put(this.name, input);
	}
	return valid;
  }
}
