/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */


package edu.cbil.csp.dialog;

/**
 * StringValidatorI.java
 *
 * Interface describing the string validators accepted by 
 * <code>FreeTextParam</code>.
 *
 * Created: Fri Apr  16 19:03:19 1999
 *
 * @author Jonathan Crabtree
 *
 */
public interface StringValidatorI {

  /**
   * Called by <code>FreeTextParam</code> to ascertain if the value
   * in <code>text</code> is valid.  If the value is invalid, the
   * method may append a more specific error message to <code>errors</code>.
   *
   * @param text    The text to be validated.
   * @param errors  StringBuffer containing error messages, to which
   *                the method may append a message if it returns <code>false</code>.
   *
   * @return Whether the contents of <code>text</code> are valid.
   */
  public boolean isStringValid(String text, StringBuffer errors);

}
