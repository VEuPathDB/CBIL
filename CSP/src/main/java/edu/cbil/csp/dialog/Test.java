/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

/**
 * Test.java
 *
 * A test class for edu.cbil.csp.dialog. 
 *
 * Created: Thu Feb  4 08:25:02 1999
 *
 * @author Jonathan Crabtree
 * @version
 */
public class Test {
    
    /**
     * The method where all the fun happens.  See the source
     * code for this class for an explanation.  It can be
     * found in the documentation for {@link edu.cbil.csp.dialog}.
     */
    public static void main(String args[]) {

	// Create a new Dialog.  The first argument is a string describing
	// the dialog's purpose.  The second is the URL to which the form
	// data should be submitted.  It's currently assumed that a Java
        // Servlet will be listening at that URL.
        //	
	Dialog dialog = new Dialog("Give me your hard-earned data", 
                                   "file:///dev/null");

	// Create a logical group of dialog items.  The first parameter is
	// the name of the item.  Most if not all subclasses of 
	// {@link edu.cbil.csp.dialog.Item} require a name as their first parameter.
	// This name is used for a couple of important things: first, it is used
	// as the value of the HTML NAME attribute for those items that become
	// input elements in a form.  Second, it is used as a unique identifier
	// with which the {@link edu.cbil.csp.dialog.Item} can be retrieved from its 
	// containing  {@link edu.cbil.csp.dialog.ItemGroup}.  The second parameter
	// is a description of the item group that will appear on the HTML form
	// generated.  The third parameter is a help string that will be displayed
	// in the separate help section.  The last two parameters are 
	// {@link edu.cbil.csp.StringTemplate}s that can be used to customize the
	// HTML generated by the item group.
        //
	ItemGroup ig1 = new ItemGroup("igroup1", 
		                      "Enter your first name and age", 
	                              "Sorry, you're on your own here.", 
                                      null, null);

	// Add the item group to the dialog.  We could do this later, if we
	// wanted, after we've populated the item group itself with items.
	//
	dialog.addItem(ig1);

	// Create and add two parameters to the item group.  Remember that each 
	// instance of {@link edu.cbil.csp.dialog.Param} represents some piece of
	// data you'd like the user to enter.

	// {@link edu.cbil.csp.dialog.Param} is not only the superclass of all 
	// parameters, but it can be used on its own to request an unconstrained
	// string from the user, as we're doing here.
	//
	// The first argument is again the name of the item, and also the key 
	// we'll need to retrieve the information from the form after the user
	// submits it.  The second argument is a description of the item that
	// will appear in the help section.  The third argument is the help 
	// string again, and the next two are {@link edu.cbil.csp.StringTemplate}s.
	// The next argument is a new one, the prompt that will be displayed
	// to the user in the form.  Finally, the last argument is an optional
	// array of "sample values" that will appear in the help section.
        //	
	ig1.addItem(new Param<String>("name", 
			      "First name", 
  		              "Enter your first name or nickname in the space provided.", 
                              null, null, 
                              "First name: ",    // prompt
                              false));

	// {@link edu.cbil.csp.dialog.IntParam} expects the user to enter an integer
	// value.  The first six arguments (up to and including the "prompt") are 
	// the same as for {@link edu.cbil.csp.dialog.Param}.  The rest are described
	// below:
	//
	ig1.addItem(new IntParam("age", 
                                 "Age", 
				 "Enter your age (in human years, wise guy.)", 
		                 null, null, 
		                 "Age: ",            // prompt 
				 new Integer(0),     // minimum
				 new Integer(150),   // maximum
				 null,               // initial value
				 false,              // optional parameter?
                                 null));             // array of sample values

	// Hierarchical controlled vocabulary
	//
	TreeNode tn1 = new TreeNode("label1", "key1", new TreeNode[] {});
	TreeNode tn2 = new TreeNode("label2", "key2", new TreeNode[] {tn1});
	TreeNode tn3 = new TreeNode("label3", "key3", new TreeNode[] {});
	TreeNode tn4 = new TreeNode("label4", "key4", new TreeNode[] {tn2, tn3});
	TreeNode root = new TreeNode("root", "-1", new TreeNode[] {tn4});

	ig1.addItem(new TreeEnumParam("tree", "Tree", "Choose a term from the tree of terms.",
				      null, 
				      null, 
				      "Tree:", false, 10, root));

	ig1.addItem(new TreeEnumParam("tree2", "Tree", "Choose a term from the tree of terms.",
				      null, 
				      null, 
				      "Tree2:", false, 10, root));

	// Create a second item group.  This one will simply hold the
	// "Submit" and "Reset" buttons for the form.
	//
	ItemGroup ig2 = new ItemGroup("ig2", 
                                      "Submit data", 
                                      "Click on the submit button to enter your information.", 
				      null, null);
	dialog.addItem(ig2);

	// Add the {@link edu.cbil.csp.dialog.Action}s for the two buttons.
	//
	ig2.addItem(new Action("reset",             // name
		 	       "Reset the form.",   // description
			       null,                // (unhelpful) help string
			       null, null,          // StringTemplates
			       "reset",             // must be either "reset" or "submit"
			       "Clear Form"));      // button label
	
	ig2.addItem(new Action("go",                // name
		               "Submit the form.",  // description
			       null,                // (unhelpful) help string
			       null, null,          // StringTemplates
			       "submit",            // must be either "reset" or "submit"
			       "Submit data"));     // button label

	// Call the method that turns the dialog into HTML.  The argument
	// gives the URL at which the help information will be located, in
	// order that links can be created.  If the help information will
	// be on the same page as the form, this argument should be the
	// empty string, as in this case.
        //
	System.out.println("<HTML><BODY BGCOLOR=\"#ffffff\">");
	System.out.println(dialog.makeHTML(""));

	// The separate call required to generate the dialog's help section.
	// This one takes the URL of the page where the form is located, 
	// again so that links can be created correctly.
	//
	System.out.println(dialog.makeHTMLHelp(""));
	System.out.println("</BODY></HTML>");
    }
    
} // Test