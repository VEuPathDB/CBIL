/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL),
 * University of Pennsylvania Center for Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

/**
 * ActionHandler.java
 *
 * {@link edu.cbil.csp.dialog.Item}s that can be the targets of actions must
 * implement this interface.
 * <p>
 *
 * Created: Thu Feb 18 14:45:58 1999
 *
 * @author Jonathan Crabtree
 */
public interface ActionHandler {

    // TO DO - implement action handling properly, with real listener interfaces
    
    /**
     * Handles an action expressed as a String. 
     *
     * @param action  Action request (free text).
     * @return        Whether this object was able to successfully handle the action.
     */
    public boolean handleAction(String action);

} // ActionHandler
