package edu.cbil.csp;

import java.util.Hashtable;

/**
 * AH
 *
 * An easy-to-initialize class that extends Hashtable<String,String>.
 * <P>
 *
 * @author CBIL::CSP::HifytoJava.pm
 *
 *         Sat May 20 14:37:01 2000
 */
public class AH extends Hashtable<String, String> {

  private static final long serialVersionUID = 1L;

  /**
   * Construct a new instance from an even-length array of objects. Throws an exception if the array does not
   * contain an even number of elements.
   *
   * @param arr
   *          An even-length array of <code>Object</code>s. The array is assumed to alternate between keys and
   *          values.
   */
  public AH(String arr[]) {
    super(Math.max(arr.length, 1));
    int a_length = arr.length;

    if ((a_length % 2) != 0)
      throw new IllegalArgumentException("AH: ERROR " + "- length of input array is not even.");

    for (int i = 0; i < a_length; i += 2) {
      this.put(arr[i], arr[i + 1]);
    }
  }

  /**
   * An "empty" instance of <code>AH</code>, provided for your programming convenience.
   */
  public static AH E = new AH(new String[] {});

}
