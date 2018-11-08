/*
  ########################################################################
  #
  # oboe.lib.Descriptor - A Java class for manipulating OpenURL Descriptors
  #
  # Author - Tony Hammond <tony_hammond@harcourt.com>
  # 
  # Copyright (c) 2002 Elsevier Science Ltd. All rights reserved.
  #
  ########################################################################
*/

package oboe.lib;

import java.io.*;
import java.util.*;

/**
 * Class for defining <code>Descriptor</code>'s for an {@link Entity}.
 *
 * @author    Tony Hammond &lt;<a href="mailto:tony_hammond@harcourt.com">mailto:tony_hammond@harcourt.com</a>&gt;
 * @version	0.1.0
 */
public class Descriptor {

  // Descriptor types
  public static final String ID = "id";
  public static final String METADATA = "metadata";
  public static final String METADATA_PTR = "metadata_ptr";
  public static final String PRIVATE_DATA = "private_data";

  static private Hashtable _dict = new Hashtable();

  static {
    _dict.put(ID, 1); 
    _dict.put(METADATA, 1); 
    _dict.put(METADATA_PTR, 1); 
    _dict.put(PRIVATE_DATA, 1); 
  };

  /**
   * Test for a legitimate <code>Descriptor</code> type.
   *
   * @return boolean
   */
  static public boolean isDescriptorType(String type) {
    return _dict.containsKey(type);
  }

  /**
   * Constructor for a <code>Descriptor</code>.
   */
  public Descriptor(String type, String value) {
    if (isDescriptorType(type)) {
      type = type;
      value = value;
    }
    else {
      // throw Exception
    }
    return this;
  }

}
