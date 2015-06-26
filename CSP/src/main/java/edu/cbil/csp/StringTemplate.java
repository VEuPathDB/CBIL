/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp;

/**
 * StringTemplate.java
 *
 * A parameterized string used to substitute different
 * strings into a string "template".  A string
 * template is a string containing a number of placeholders 
 * or parameters (distinguished strings) for which one can
 * substitute different values (also strings) at runtime.
 * For example, the template "$1 + $1 + $2"--where "$1" and "$2" are 
 * the parameters or placeholders--could be instantiated to 
 * "4 + 4 + 5", "one + one + two", etc., by performing the obvious 
 * string  substitutions.<p>
 *
 * Created: Fri Feb  5 07:48:09 1999
 *
 * @author Jonathan Crabtree
 * @version 
*/
public class StringTemplate {
    
    /**
     * Template string, which contains a number of distinguished substrings.
     */
    protected String template;

    /**
     * Distinguished substrings appearing in <code>template</code>
     */
    protected String params[];

    /**
     * Cached value of <code>params.length</code>
     */
    protected int n_params;
	
    /**
     * Constructor takes a template string and a list of the distinguished
     * substrings appearing therein.
     *
     * @param template      The parameterized string or "string template".
     * @param params        The set of strings appearing in <code>template</code>
     *                      that can be replaced with different values.
     */
    public StringTemplate(String template, String params[]) {
	this.template = template;
	this.params = params;
	this.n_params = params.length;
    }
    
    /**
     * Returns a copy of the template with each of the parameter strings replaced
     * by the respective string in <code>values</code>  Substitution is 
     * not recursive: each occurrence of each parameter is replaced by the corresponding
     * value, but the resulting string is not subject to further substitutions
     * with respect to the same parameter.  For example, the template
     * "$1 + $1 + $2" with parameters $1="$1$1" and $2="$2$2" would become
     * "$1$1 + $1$1 + $2$2".
     *
     * @param values  The values to substitute for the parameters in the template.
     * @return        The string template instantiated at the values <code>values</code>.
     */
    public String instantiate(String values[]) {
	if (values.length < n_params)
	    throw 
		new IllegalArgumentException("StringTemplate: number of values is less than " +
					     "the number of parameters in the template.");

	String result = template;

	for (int i = 0;i < n_params;i++) {
	    result = substituteAllOccurrences(result, params[i], values[i]);
	}

	return result;
    }

    /**
     * Replaces each and every occurrence of <code>replace</code> in
     * <code>src</code> with <code>with</code>.
     *
     * @param src      Source string.
     * @param replace  Replace this substring of <code>src</code>.
     * @param with     What to replace <code>replace</code> with.
     * @return A copy of <code>src</code> with <code>replace</code> replaced with <code>with</code>.
     */
    protected String substituteAllOccurrences(String src, String replace, String with) {
	int rlength = replace.length();
	StringBuffer result = new StringBuffer();

	int posn = 0;
	int last_posn = 0;

	while (posn != -1) {
	    posn = src.indexOf(replace, posn);
	    if (posn != -1) {
		result.append(src.substring(last_posn, posn));
		result.append(with);
		posn += rlength;
		last_posn = posn;
	    } else {
		result.append(src.substring(last_posn));
	    }
	}
	return result.toString();
    }

    @Override
    public String toString() { return template; }

    // -------------------------------------------------------------------
    // Methods to generate parameter strings for different languages:
    //
    // The strings returned should be chosen so as to make conflicts
    // with valid strings in the language as unlikely as possible.
    // -------------------------------------------------------------------

    /**
     * Generates a distinguished substring suitable for embedding in 
     * an HTML StringTemplate.  The string returned corresponds to 
     * an HTML comment.
     *
     * @param pnum  An integer that can be used to identify the 
     *              generated string.
     * @return A substring suitable for inclusion in an HTML StringTemplate.
     */
    public static String HTMLParam(int pnum) {
      return HTMLParam("ST", pnum);
    }

    public static String HTMLParam(String prefix, int pnum) {
	// Embed the parameter number in an HTML comment:
	//
      return "<!--" + prefix + pnum + "-->";
    }

    /**
     * Generate an array of consecutive HTML parameter strings.
     * 
     * @param n_params The number of parameter strings to generate.
     * @return An array of values generated by calls to <code>HTMLParam(int)</code>.
     */
    public static String[] HTMLParams(int n_params) {
      return HTMLParams("ST", n_params);
    }

    public static String[] HTMLParams(String prefix, int n_params) {
	String result[] = new String[n_params];

	for (int i = 0;i < n_params;i++) {
	    result[i] = HTMLParam(prefix, i);
	}
	return result;
    }

    /**
     * Generate a distinguished substring suitable for embedding in OQL.
     *
     * @param pnum  An integer that can be used to identify the 
     *              generated string.
     * @return A substring suitable for inclusion in an OQL statement.
     */
    public static String OQLParam(int pnum) {
	return "$$" + pnum + "$$";
    }

    /**
     * Generate an array of consecutive OQL parameter strings.
     * 
     * @param n_params The number of parameter strings to generate.
     * @return An array of values generated by calls to <code>OQLParam</code>.
     */
    public static String[] OQLParams(int n_params) {
	String result[] = new String[n_params];

	for (int i = 0;i < n_params;i++) {
	    result[i] = OQLParam(i);
	}
	return result;
    }

    public static String SQLParam(int pnum) { return OQLParam(pnum); }
    public static String[] SQLParams(int n_params) { return OQLParams(n_params); }

} // StringTemplate