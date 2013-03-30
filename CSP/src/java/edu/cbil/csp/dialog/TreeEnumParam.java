/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;

import org.apache.oro.text.perl.Perl5Util;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * TreeEnumParam.java
 *
 * A hierarchical enumerated value/controlled vocabulary.  
 * Capable of generating either HTML or JavaScript.
 *
 * TO DO: 
 *
 * Generate only 1 copy of the JavaScript makeSelect function in the
 * case where there are multiple TreeEnumParams on one page (the
 * form will still work correctly, but there will be multiple redundant
 * copies of the JavaScript function.)
 *
 * Created: Sat Apr  1 16:18:07 EST 2000
 *
 * @author Jonathan Crabtree
 * @version $Revision$ $Date$ $Author$
 */
public class TreeEnumParam extends Param {

    /**
     * Controlled vocabulary this object represents.
     */
    protected TreeNode vocab;

    /**
     * Mapping from keys to names (descriptions).
     */
    protected Hashtable keyToNameHash;

    /**
     * How many rows to display in the select list.
     */
    protected int sizeHint;

    // --------------------------------------------
    // Constructor
    // --------------------------------------------
    
    public TreeEnumParam(String name, String descr, String help, 
			 StringTemplate st, StringTemplate ht, 
			 String prompt, boolean optional, int sizeHint,
			 TreeNode vocab)
    {
	super(name, descr, help, st, ht, prompt, optional);
	this.vocab = vocab;
	this.sizeHint = sizeHint;
	this.keyToNameHash = new Hashtable();
	updateKeyToNameHash(vocab, "", true);
    }

    // --------------------------------------------
    // Item
    // --------------------------------------------

    public String[] getSampleValues() { return null; }

    public Item copy(String url_subs) {
	return new TreeEnumParam(name, descr, help, template, help_template, 
				 prompt, optional, sizeHint, vocab);
    }

    public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
					    Hashtable inputH, Hashtable inputHTML) 
    {
	String input1 = rq.getParameter(this.name + "_hidden");
	String input2 = rq.getParameter(this.name);

	if ((input1 == null) || (keyToNameHash.get(input1) == null)) {
	    if (((input2 == null) || (keyToNameHash.get(input2) == null)) && (!optional)) {
		errors.append("This parameter is required; you must choose one of " +
			      "the options listed.");
		return false;
	    } else {
		inputH.put(this.name, input2);
		inputHTML.put(this.name, keyToNameHash.get(input2));
	    }
	} else {
	    inputH.put(this.name, input1);
	    inputHTML.put(this.name, keyToNameHash.get(input1));
	}

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

    public String[] getHTMLParams(String helpURL) {
	String anchor = makeHTMLAnchor(false);
	String link = makeHTMLLink(true, helpURL, "Help!");

	String size = Integer.toString(this.sizeHint);
	StringBuffer result = new StringBuffer("\n");

	// Necessary for multiple-form pages
	//
	String formName = "0"; // specifies 1st form on the page; assumes there is only one

	// Avoid clashes between variables defined by other TreeEnumParams 
	// on the same HTML page.
	//
	Perl5Util p5 = new Perl5Util();
	String JavaScriptSafeName = p5.substitute("s/[:]/_/g", name);

	String treeVar = JavaScriptSafeName + "_t";

	String select = (makeJavaScript(treeVar) + "\n<BR>\n" + 
			 "<FONT SIZE=\"-1\">\n" +
			 "<INPUT TYPE=\"text\" NAME=\"" + name + "_description\" VALUE=\"\" SIZE=\"80\">\n" +
			 "<INPUT TYPE=\"hidden\" NAME=\"" + name + "_hidden\" VALUE=\"\">\n" +
			 "</FONT>\n" + 
			 "<BR CLEAR=\"both\">\n" +
			 "<SELECT NAME=\"" + name + "\" SIZE=\""+ size +"\" " +
			 "ONCHANGE=\"makeSelect('1', '" + formName + "', '" + name +
			 "', '-1', " + treeVar + ");\">" +
			 makeOptionList() + "</SELECT>\n" + 
			 "<SCRIPT LANGUAGE=\"JavaScript1.1\">\n" +
			 "<!--\n" +                                    // begin HTML comment
			 "makeSelect('-1', '" + formName + "', '" + name + 
			 "', '-1', " + treeVar + ");\n" + 
			 "// -->\n" +                                  // end HTML comment
			 "</SCRIPT>");

	return new String[] {anchor + prompt, select, link};
    }

    public Param copyParam(String newName) {
	return new TreeEnumParam(newName, descr, help, template, help_template, 
				 prompt, optional, sizeHint, vocab);
    }

    // --------------------------------------------
    // TreeEnumParam
    // --------------------------------------------
    
    protected class IntHolder {
	int i;
	protected IntHolder(int i) { this.i = i; }
    }

    protected void updateKeyToNameHash(TreeNode t, String prefix, boolean isRoot) {
	String pfix = prefix.equals("") ? "" : prefix + ":";

	TreeNode kids[] = t.kids;
	int nKids = kids.length;
	keyToNameHash.put(t.key, (isRoot ? "" : pfix + t.label));

	for (int i = 0;i < nKids;++i) {
	    updateKeyToNameHash(kids[i], (isRoot ? "" : pfix + t.label), false);
	}
    }

    protected void appendJavaScriptData(TreeNode t, String treeVar, StringBuffer sb, 
					boolean isRoot, String parentID) 
    {
	TreeNode kids[] = t.kids;
	int nKids = kids.length;

	if (isRoot) {
	    sb.append(treeVar + "['-1']='root:-1:1';\n");
	} else {
	    sb.append(treeVar + "['" + t.key + "']='" + t.label + ":" + parentID);
	    sb.append(":" + ((nKids > 0) ? '1' : '0') + "';\n");
	}

	// Create the child nodes
	//
	for (int i = 0;i < nKids;++i) {
	    appendJavaScriptData(kids[i], treeVar, sb, false, t.key);
	}
    }

    /**
     * Generate JavaScript that implements the multilevel selection capability.
     * The JavaScript is escaped to prevent it being interpreted by non-compliant
     * browsers.
     */
    protected String makeJavaScript(String treeVar) {
	StringBuffer sb = new StringBuffer();

	sb.append("\n\n<SCRIPT LANGUAGE=\"JavaScript1.1\">\n");
	sb.append("<!--\n");                                    // begin HTML comment
	sb.append("var " + treeVar + " = new Object();\n\n");

	// Build the JavaScript data structure that represents the vocabulary.
	//
	appendJavaScriptData(vocab, treeVar, sb, true, "-1");

	// JavaScript function that recomputes the select list on user input
	//
	// id = Displays the children of this node in the select list.
	//
	sb.append("\n");
	sb.append("function makeSelect(id, formName, selName, rootID, lookup) {\n");
	sb.append("  var select = document.forms[formName][selName];\n");
	sb.append("  var option;\n");
	sb.append("  var id;\n");
	sb.append("  var top;\n");
	sb.append("  var top_vals;\n");
	sb.append("\n");
	sb.append("  if (id != rootID) {\n");
	sb.append("    option = select.options[select.selectedIndex];\n");
	sb.append("    id = option.value;\n");
	sb.append("  }\n");
	sb.append("\n");
	sb.append("  top = lookup[id];\n");
	sb.append("\n");
	sb.append("  if (typeof(top) == 'undefined') {\n");
	sb.append("    if (id != rootID) { return; }\n");
	sb.append("  }\n");
	sb.append("  top_vals = top.split(\":\");\n");
	sb.append("\n");
	sb.append("  document.forms[formName][selName + '_hidden'].value = (id == rootID ? '' : id);\n");
	sb.append("\n");
	sb.append("  var kids = new Array();\n");
	sb.append("  var j = 0;\n");
	sb.append("\n");
	sb.append("  for (var k in lookup) {\n");
	sb.append("    var v = lookup[k];\n");
	sb.append("    var v_vals = v.split(\":\");\n");
	sb.append("\n");
	sb.append("    if ((v_vals[1] == id) && (k != rootID)) {\n");
	sb.append("      kids[j++] = k;\n");
	sb.append("    }\n");
	sb.append("  }\n");
	sb.append("\n");
	sb.append("  var opt = 0;\n");
	sb.append("\n");
	sb.append("  if (kids.length > 0) {\n");
	sb.append("    select.options.length = 0;\n");
	sb.append("    if (id != rootID) {\n");
	sb.append("      select.options[opt++] = new Option('<- back', top_vals[1]);\n");
	sb.append("    }\n");
	sb.append("    for (var i = 0;i < kids.length;++i) {\n");
	sb.append("      var kid = lookup[kids[i]];\n");
	sb.append("      var kid_vals = kid.split(\":\");\n");
	sb.append("      var nm = kid_vals[0];\n");
	sb.append("\n");
	sb.append("      if (typeof(kids[i]['kids']) != 'undefined') { nm = '-> ' + nm; }\n");
	sb.append("      if (kid_vals[2] == 1) {\n");
	sb.append("        select.options[opt++] = new Option( \"->\" + nm, kids[i]);\n");
	sb.append("      } else {\n");
	sb.append("        select.options[opt++] = new Option(nm, kids[i]);\n");
	sb.append("      }\n");
	sb.append("    }\n");
	sb.append("  }\n");
	sb.append("\n");
	sb.append("  var des = '';\n");
	sb.append("  var i = 0;\n");
	sb.append("\n");
	sb.append("  while (id != rootID) {\n");
	sb.append("    des = top_vals[0] + ((i++ > 0) ? ':' : '') + des;\n");
	sb.append("    top = lookup[top_vals[1]];\n");
	sb.append("    id = top_vals[1];\n");
	sb.append("    top_vals = top.split(\":\");\n");
	sb.append("  }\n");
	sb.append("  document.forms[formName][selName + '_description'].value = des;\n");
	sb.append("}\n");
	sb.append("// -->");                                    // end HTML comment
	sb.append("</SCRIPT>\n");
	return sb.toString();
    }

    /**
     * Generate a plain HTML list of <OPTION>s (for reverse compatability with
     * non-JavaScript browsers.)
     */
    protected String makeOptionList() {
	StringBuffer sb = new StringBuffer();
	makeOptionList_aux(vocab, "", sb, true);
	return sb.toString();
    }

    protected void makeOptionList_aux(TreeNode t, String prefix, StringBuffer sb, boolean isRoot) {
	String newPrefix = prefix;

	if (!isRoot) {
	    sb.append("<OPTION VALUE=\"" + t.key + "\">\n");
	    sb.append(prefix);
	    sb.append(t.label);
	    newPrefix = prefix + "...";
	}
	int nKids = t.kids.length;

	for (int i = 0;i < nKids;++i) {
	    makeOptionList_aux(t.kids[i], newPrefix, sb, false);
	}
    }

} // TreeEnumParam
