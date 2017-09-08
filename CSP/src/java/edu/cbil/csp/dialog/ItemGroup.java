/**
 * Copyright (C) 1999 Trustees of the University of Pennsylvania
 *
 * Computational Biology and Informatics Laboratory (CBIL), University of Pennsylvania Center for
 * Bioinformatics (www.pcbi.upenn.edu)
 */

package edu.cbil.csp.dialog;

import java.util.Hashtable;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;

import org.apache.oro.text.perl.Perl5Util;

import edu.cbil.csp.AH;
import edu.cbil.csp.HTMLUtil;
import edu.cbil.csp.StringTemplate;

/**
 * ItemGroup.java
 *
 * An {@link edu.cbil.csp.dialog.Item} that serves to group other <code>Item</code>s.
 * {@link edu.cbil.csp.dialog.Dialog} is itself an <code>Itemgroup</code>.
 * <P>
 *
 * Created: Thu Feb 4 08:03:37 1999
 *
 * @author Jonathan Crabtree
 */
public class ItemGroup extends Item {

  /**
   * The Items that belong to this item group.
   */
  protected Vector<Item> items;

  /**
   * Background color.
   */
  protected String bgcolor;

  /**
   * Constructor that accepts a background color.
   *
   * @param name
   *          Unique String used to identify the item in the context of a larger input structure (e.g. a
   *          {@link edu.cbil.csp.dialog.Dialog}).
   * @param descr
   *          A short description of the element.
   * @param help
   *          A help string describing the element's usage.
   * @param st
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element itself.
   * @param ht
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element's help text.
   * @param bgcolor
   *          Sugggested background color.
   */
  public ItemGroup(String name, String descr, String help, StringTemplate st, StringTemplate ht,
      String bgcolor) {
    super(name, descr, help, st, ht);
    this.items = new Vector<>();
    this.bgcolor = (bgcolor == null) ? "E0E0E0" : bgcolor;
  }

  /**
   * Constructor that does not accept a background color.
   *
   * @param name
   *          Unique String used to identify the item in the context of a larger input structure (e.g. a
   *          {@link edu.cbil.csp.dialog.Dialog}).
   * @param descr
   *          A short description of the element.
   * @param help
   *          A help string describing the element's usage.
   * @param st
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element itself.
   * @param ht
   *          {@link edu.cbil.csp.StringTemplate} that controls the appearance of the element's help text.
   */
  public ItemGroup(String name, String descr, String help, StringTemplate st, StringTemplate ht) {
    this(name, descr, help, st, ht, null);
  }

  // -------------------
  // Item
  // -------------------

  @Override
  public Item copy(String url_subs) {
    ItemGroup result = new ItemGroup(name, descr, help, template, help_template);
    copyItems(this, result, url_subs);
    return result;
  }

  @Override
  public void storeHTMLServletInput(HttpServletRequest rq) {
    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      di.storeHTMLServletInput(rq);
    }
  }

  @Override
  public boolean validateHTMLServletInput(HttpServletRequest rq, StringBuffer errors,
      Hashtable<String,Object> inputH, Hashtable<String,String> inputHTML) {
    boolean all_ok = true;

    int n_items = items.size();
    StringBuffer item_errors = new StringBuffer();

    // Validate each element in turn
    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      StringBuffer error = new StringBuffer();
      if (di instanceof Param)
        error.append(HTMLUtil.B(((Param<?>)di).prompt) + HTMLUtil.BR());

      if (!di.validateHTMLServletInput(rq, error, inputH, inputHTML)) {
        all_ok = false;
        item_errors.append(HTMLUtil.TABLE(HTMLUtil.TR(HTMLUtil.TD(error.toString()))));
      }
    }

    if (!all_ok) {
      errors.append(HTMLUtil.TABLE(HTMLUtil.TR(HTMLUtil.TD(HTMLUtil.B(this.descr))) +
          HTMLUtil.TR(HTMLUtil.TD(item_errors.toString()))));
    }
    return all_ok;
  }

  @Override
  public StringTemplate getDefaultTemplate() {
    String ps[] = StringTemplate.HTMLParams(2);

    return new StringTemplate(HTMLUtil.TR(new AH(new String[] { "bgcolor", bgcolor }),
        HTMLUtil.TD(HTMLUtil.FONT(
            new AH(new String[] { "size", "+0", "face", "helvetica,sans-serif", "color", "#ffffff" }),
            HTMLUtil.B(ps[0])))) +
        "\n" +
        HTMLUtil.TR(HTMLUtil.TD(HTMLUtil.TABLE(
            new AH(new String[] { "width", "100%", "border", "0", "cellpadding", "0", "cellspacing", "0" }),
            ps[1]))) +
        "\n", ps);
  }

  @Override
  public String[] getHTMLParams(String help_url) {
    StringBuffer itemtext = new StringBuffer();

    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      itemtext.append(di.makeHTML(help_url));
      itemtext.append("\n");
    }

    return new String[] { (descr == null) ? "" : this.descr, itemtext.toString() };
  }

  protected static AH fullwidth = new AH(new String[] { "width", "100%" });
  protected static AH caption_ah = new AH(new String[] { "cellpadding", "2", "border", "0" });
  protected static AH debugtable = new AH(new String[] { "width", "100%", "border", "0" });

  @Override
  public StringTemplate getDefaultHelpTemplate() {
    String ps[] = StringTemplate.HTMLParams(2);
    return new StringTemplate(HTMLUtil.TR(HTMLUtil.TD(HTMLUtil.TABLE(caption_ah,
        HTMLUtil.TR(HTMLUtil.TD(new AH(new String[] { "bgcolor", bgcolor }), HTMLUtil.B(ps[0])))) +
        HTMLUtil.TABLE(fullwidth, (ps[1])))), ps);
  }

  @Override
  public String[] getHTMLHelpParams(String form_url) {
    StringBuffer helpText = new StringBuffer();

    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      helpText.append(di.makeHTMLHelp(form_url));
      helpText.append("\n");
    }

    return new String[] { this.help, helpText.toString() };
  }

  // -------------------
  // ItemGroup
  // -------------------

  /**
   * Helper routine used by <code>copy</code>.
   *
   * @param from
   *          Source item group.
   * @param to
   *          Source item group.
   * @param url_subs
   *          Perl-style substitution to apply to any URLs
   */
  protected void copyItems(ItemGroup from, ItemGroup to, String url_subs) {
    int n_items = from.numItems();

    for (int i = 0; i < n_items; i++) {
      Item item = from.getItemAt(i);
      to.addItem(item.copy(url_subs));
    }
  }

  // -------------------
  // Add/remove items
  // -------------------

  /**
   * The number of items in this item group.
   *
   * @return The current number of contained items.
   */
  public int numItems() {
    return items.size();
  }

  /**
   * Retrieve an item at a particular index. By default the items within an item group are indexed by the
   * order that they were initially added.
   *
   * @param index
   *          The 0-based index of the desired item.
   * @return The Item stored at index <code>index</code>
   */
  public Item getItemAt(int index) {
    return items.elementAt(index);
  }

  /**
   * Add an item at a particular index. Similar to {@link java.util.Vector#insertElementAt}.
   *
   * @param di
   *          The item to add.
   * @param index
   *          The index at which to add the new item.
   * @return A boolean indicating whether the operation succeeded.
   */
  public boolean addItemAt(Item di, int index) {
    items.insertElementAt(di, index);
    return true;
  }

  /**
   * Add an item. By default it will occupy the next available index.
   *
   * @param di
   *          The item to add.
   * @return A boolean indicating whether the operation succeeded.
   */
  public boolean addItem(Item di) {
    items.addElement(di);
    return true;
  }

  /**
   * Add an item to a specific item group (either this one or one contained within it.) Performs a recursive
   * search if necessary.
   *
   * @param ig
   *          The item group to add to.
   * @param di
   *          The item to add.
   * @return A boolean indicating whether the operation succeeded.
   */
  public boolean addItemTo(ItemGroup ig, Item di) {
    if (ig == this) {
      this.addItem(di);
      return true;
    }

    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item item = items.elementAt(i);
      if (item instanceof ItemGroup) {
        ItemGroup grp = (ItemGroup) item;
        if (grp.addItemTo(ig, di))
          return true;
      }
    }
    return false;
  }

  /**
   * Remove the first occurrence of a specified {@link edu.cbil.csp.dialog.Item}.
   *
   * @param di
   *          The item to remove.
   * @param recurse
   *          Whether to recursively search for the item.
   * @return A boolean indicating whether the operation succeeded.
   */
  public boolean removeItem(Item di, boolean recurse) {

    // First check if it's an immediate child of this group
    //
    int idx = items.indexOf(di);

    if (idx != -1) {
      items.removeElementAt(idx);
    }
    else if (recurse) {
      int n_items = items.size();

      for (int i = 0; i < n_items; i++) {
        Item item = items.elementAt(i);
        if (item instanceof ItemGroup) {
          ItemGroup ig = (ItemGroup) item;
          if (ig.removeItem(di, true))
            return true;
        }
      }
    }
    return false;
  }

  /**
   * Handles regular expression matching.
   */
  protected static Perl5Util perl = new Perl5Util();

  /**
   * Remove an item by its name.
   *
   * @param itemName
   *          The name of the item(s) to remove.
   * @param recurse
   *          Whether to recursively search for the item(s).
   * @param remove_all
   *          Whether to remove all occurrences (<code>true</code>) or only the first (<code>false</code>).
   * @return The number of occurrences that were actually removed.
   */
  public int removeItemByName(String itemName, boolean recurse, boolean remove_all) {
    return removeItemByPattern("/^" + itemName + "$/", recurse, remove_all);
  }

  /**
   * Remove an item by name, using a regular expression.
   *
   * @param pattern
   *          Items whose names match this regex will be removed.
   * @param recurse
   *          Whether to recursively search for the item(s).
   * @param remove_all
   *          Whether to remove all occurrences (<code>true</code>) or only the first (<code>false</code>).
   * @return The number of occurrences that were actually removed.
   */
  public int removeItemByPattern(String pattern, boolean recurse, boolean remove_all) {
    int n_items = items.size();
    int n_removed = 0;

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      if (perl.match(pattern, di.name)) {
        items.removeElementAt(i);
        if (!remove_all)
          return 1;
        n_removed++;
      }
    }

    if (recurse) {
      for (int i = 0; i < n_items; i++) {
        Item di = items.elementAt(i);
        if (di instanceof ItemGroup) {
          ItemGroup ig = (ItemGroup) di;
          n_removed += (ig.removeItemByName(name, true, remove_all));
          if (!remove_all)
            return n_removed;
        }
      }
    }
    return n_removed;
  }

  // TO DO - The following method is essentially the same as removeItemByName.

  /**
   * @param itemName
   *          The name of the item to be replaced.
   * @param new_item
   *          A replacement for the named item.
   * @param recurse
   *          Whether to recursively search for the item.
   * @return A boolean indicating whether the operation succeeded.
   */
  public boolean replaceItemByName(String itemName, Item new_item, boolean recurse) {
    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      if (di.name.equals(itemName)) {
        items.setElementAt(new_item, i);
        return true;
      }
    }

    if (recurse) {
      for (int i = 0; i < n_items; i++) {
        Item di = items.elementAt(i);
        if (di instanceof ItemGroup) {
          ItemGroup ig = (ItemGroup) di;
          if (ig.replaceItemByName(itemName, new_item, true))
            return true;
        }
      }
    }
    return false;
  }

  /**
   * Get the immediate parent of the named item.
   *
   * @param parentName
   *          The name of the item to find.
   * @param recurse
   *          Whether to recursively search for the named item.
   * @return The ItemGroup that is the parent of the item named <code>name</code>, or <code>null</code> if
   *         that item cannot be found.
   */
  public ItemGroup getParentByName(String parentName, boolean recurse) {
    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      if (di.name.equals(parentName))
        return this;
    }

    if (recurse) {
      for (int i = 0; i < n_items; i++) {
        Item di = items.elementAt(i);
        if (di instanceof ItemGroup) {
          ItemGroup ig = (ItemGroup) di;
          ItemGroup parent = ig.getParentByName(parentName, recurse);
          if (parent != null)
            return parent;
        }
      }
    }
    return null;
  }

  /**
   * Get <b>all</b> items whose name matches a regular expression.
   *
   * @param pattern
   *          Regular expression used to select the items to be returned.
   * @return An array of {@link edu.cbil.csp.dialog.Item}s, each of which has a name that matches
   *         <code>pattern</code>. Never returns <code>null</code>, but can return a 0-length array.
   */
  public Item[] getItemsByPattern(String pattern) {
    Vector<Item> v = new Vector<>();
    getItemsByPattern_aux(pattern, v);
    Item result[] = new Item[v.size()];
    v.copyInto(result);
    return result;
  }

  /**
   * Helper method for <code>getItemsByPattern</code>.
   *
   * @param pattern
   *          Regular expression against which to match item names.
   * @param v
   *          Vector in which current search results are stored.
   */
  protected void getItemsByPattern_aux(String pattern, Vector<Item> v) {
    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      if (perl.match(pattern, di.name))
        v.addElement(di);
    }

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      if (di instanceof ItemGroup) {
        ItemGroup ig = (ItemGroup) di;
        ig.getItemsByPattern_aux(pattern, v);
      }
    }
  }

  /**
   * Get <b>all</b> items of a specific (exact) class. Does not return instances of subclasses of the given
   * class, only direct instances.
   *
   * @param c
   *          The class whose instances are to be retrieved.
   * @param An
   *          array of the {@link edu.cbil.csp.dialog.Item}s found.
   */
  public <S extends Item> Item[] getItemsByClass(Class<S> c) {
    Vector<S> v = new Vector<>();
    getItemsByClass_aux(c, v);
    Item result[] = new Item[v.size()];
    v.copyInto(result);
    return result;
  }

  /**
   * A helper method for <code>getItemsByClass</code>.
   *
   * @param c
   *          Class whose instances are to be retrieved.
   * @param v
   *          Vector in which current search results are stored.
   */
  protected <S extends Item> void getItemsByClass_aux(Class<S> c, Vector<S> v) {
    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      System.out.println("item = " + di + "name = " + di.getName() + " class = " + di.getClass());
      if (di.getClass().equals(c)) {
        @SuppressWarnings("unchecked")
        S typedItem = (S) di;
        v.addElement(typedItem);
      }
    }

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      if (di instanceof ItemGroup) {
        ItemGroup ig = (ItemGroup) di;
        ig.getItemsByClass_aux(c, v);
      }
    }
  }

  /**
   * Get an item given its name.
   *
   * @param itemName
   *          The name of the desired {@link edu.cbil.csp.dialog.Dialog}
   * @param recurse
   *          Whether to search for the item recursively.
   * @return The named item, or <code>null</code> if it could not be found.
   */
  public Item getItemByName(String itemName, boolean recurse) {
    int n_items = items.size();

    for (int i = 0; i < n_items; i++) {
      Item di = items.elementAt(i);
      if (di.name.equals(itemName))
        return di;
    }

    if (recurse) {
      for (int i = 0; i < n_items; i++) {
        Item di = items.elementAt(i);
        if (di instanceof ItemGroup) {
          ItemGroup ig = (ItemGroup) di;
          Item item = ig.getItemByName(itemName, recurse);
          if (item != null)
            return item;
        }
      }
    }
    return null;
  }

} // ItemGroup
