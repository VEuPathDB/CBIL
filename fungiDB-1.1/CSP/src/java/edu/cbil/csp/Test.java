/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp;

/**
 * Test.java
 *
 * An example test program for the CSP package. <p>
 *
 * Created: Mon Mar 15 08:52:59 1999
 *
 * @author Jonathan Crabtree
 * @version
 */
public class Test {

    /**
     * The method where all the fun happens.  See the source
     * code for this class for an explanation.  It can be
     * found in the documentation for {@link cbil.csp}.
     */
    public static void main(String args[]) {

	// Create an instance of {@link csp.AH} to represent the
	// HTML attributes for a TEXTAREA we'lll be creating.
	// It will have 5 rows and 70 columns.
	//
	AH ta_args = new AH(new String[] {
	    "rows", "5",
	    "cols", "70"});

	// Print an HTML &lt;BR&gt; tag.  <code>AH.E</code> is a 
	// predefined static variable of the class {@link csp.AH}
	// that contains an "empty" instance of <code>csp.AH</code>.
        // It's the same as saying <code>new AH(new String[] {})</code>
	// but avoids creating a new object.
	//
	System.out.println(HTMLUtil.br(AH.E));

	// This does exactly the same: BR has no required attributes,	
	// so the <code>AH.E</code> can be omitted.  Notice also that
	// both <code>HTMLUtil.BR</code> and <code>HTMLUtil.br</code>
	// are valid method calls.  Uppercase and lowercase versions 
	// of all the HTML elements are valid.
	//
	System.out.println(HTMLUtil.BR());

	// Create an HTML TEXTAREA with the specified contents, using
	// the object <code>ta_args</code> we created earlier.
	//
	System.out.println(HTMLUtil.textarea(ta_args, "This is a test!"));

	// "Lazy" mode: here we're using the methods of {@link csp.HTMLUtil}
	// that let us print only the begin or end tag of an HTML element.
	// These methods have two extra boolean parameters that say whether
	// to omit the begin and end tags.  Any attributes are always printed 
	// in the begin tag.

	// Print the begin tag.
	//
	// The <code>false, true</code> means don't omit the begin tag
	// (omit = false) but do omit the end tag (omit = true).
	//
	System.out.print(HTMLUtil.textarea(ta_args, false, true));

	// Print the TEXTAREA's contents.
	//
	System.out.print("Testing lazy mode...");

	// Print the end tag.
	//
	// Here the first argument could be left out, or set to
	// <code>AH.E</code>, because attributes are only printed
	// with the begin tag.  Notice that the booleans are reversed
	// from the call to print the begin tag.
	//
	System.out.println(HTMLUtil.TEXTAREA(ta_args, true, false));
    }
}
