/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import edu.cbil.csp.*;

import java.util.*;
import javax.servlet.http.*;

/**
 * ActionItemGroup.java
 *
 * An {@link edu.cbil.csp.dialog.ItemGroup} that also contains one or more 
 * actions.  These actions will typically affect the group's items in some 
 * way (e.g. adding and removing them).<p>
 *
 * Created: Tue Feb  9 15:45:56 1999
 *
 * @author Jonathan Crabtree
 * @version
 */
public class ActionItemGroup extends ItemGroup {
    
    /**
     * The list of actions.
     */
    protected Vector actions;

    /**
     * Background color of the element: a concession to customizability.
     */
    protected String bgcolor;

    /**
     * Constructor.
     *
     * @param name     Unique String used to identify the action in the context
     *                 of a larger input structure (e.g. a {@link edu.cbil.csp.dialog.Dialog}).
     * @param descr    A short description of the element.
     * @param help     A help string describing the element's usage.
     * @param st       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element itself.
     * @param ht       {@link edu.cbil.csp.StringTemplate} that controls the appearance of the
     *                 element's help text.
     * @param bgcolor  Suggested background color.
     */
    public ActionItemGroup(String name, String descr, String help, 
			   StringTemplate st, StringTemplate ht, String bgcolor) 
    {
	super(name, descr, help, st, ht);
	this.actions = new Vector();
	this.bgcolor = (bgcolor == null) ? "E0E0E0" : bgcolor;
    }

    // -------------------
    // Manipulate actions
    // -------------------

    /**
     * Get the number of actions.
     *
     * @return The number of <code>Action</code>s associated with the ActionItemGroup.
     */
    public int numActions() {
	return actions.size();
    }
    
    /**
     * Add an action.
     *
     * @param a The <code>Action</code> to add.
     */
    public void addAction(Action a) {
	actions.addElement(a);
    }

    /**
     * Remove an action.
     *
     * @param a The <code>Action</code> to remove.
     */
    public void removeAction(Action a) {
	actions.removeElement(a);
    }

    /**
     * Return the <code>Action</code> at a given index; by default actions
     * are indexed by the order in which they were added.
     *
     * @param in The index of the <code>Action</code> to return.
     * @return   The <code>Action</code> at the specified index.
     */
    public Action getActionAt(int in) {
	return (Action)(actions.elementAt(in));
    }

    /**
     * Copy a set of actions from one <code>ActionItemGroup</code> to another.
     * Used to support the <code>copy</code> operation.
     */
    protected void copyActions(ActionItemGroup from, ActionItemGroup to, String url_subs) {
	int n_actions = from.numActions();
	
	for (int i = 0;i < n_actions;i++) {
	    Action action = from.getActionAt(i);
	    to.addAction((Action)(action.copy(url_subs)));
	}
    }

    // -------------------
    // Item
    // -------------------

    public Item copy(String url_subs) {
	ActionItemGroup result = new ActionItemGroup(name, descr, help, 
						     template, help_template, bgcolor);
	copyItems(this, result, url_subs);
	copyActions(this, result, url_subs);
	return result;
    }

    public StringTemplate getDefaultTemplate() {
	String ps[] = StringTemplate.HTMLParams(3);

	return new StringTemplate(HTMLUtil.TR
				  (HTMLUtil.TD
				    (HTMLUtil.TABLE
				     (new AH(new String[] {"cellpadding", "5",
							       "width", "100%",
							       "border", "0",}),
				      HTMLUtil.TR
				      (HTMLUtil.TD
				       (new AH(new String[] {"bgcolor", bgcolor}),
					HTMLUtil.FONT
					(new AH(new String[] {"size", "+0"}),
					 HTMLUtil.B(ps[0])) + "&nbsp;&nbsp;" + ps[1]))) +
				     HTMLUtil.TABLE(ps[2]))), ps);
    }

    public String[] getHTMLParams(String help_url) {
	String super_params[] = super.getHTMLParams(help_url);

	StringBuffer action_str = new StringBuffer();
	int n_actions = actions.size();

	for (int i = 0;i < n_actions;i++) {
	    Action a = (Action)(actions.elementAt(i));
	    action_str.append(a.makeHTML(help_url));
	}

	return new String[] {super_params[0], 
				 action_str.toString(),
				 super_params[1]};
    }
    
} // ActionItemGroup
