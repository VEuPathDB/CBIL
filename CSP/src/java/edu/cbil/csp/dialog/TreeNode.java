package edu.cbil.csp.dialog;

/**
 * Used by TreeEnumParam.
 *
 * Created: Sat Apr 1 16:29:37 EST 2000
 *
 * @author Jonathan Crabtree
 * @version $Revision$ $Date$ $Author$
 */
public class TreeNode {

  String label;
  String key;
  TreeNode kids[];

  public TreeNode(String l, String k, TreeNode kids[]) {
    this.label = l;
    this.key = k;
    this.kids = kids;
  }

}
