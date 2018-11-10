/*
  ########################################################################
  #
  # oboe.lib.Entity - A Java class for manipulating OpenURL Entities
  #
  # Author - Tony Hammond <tony_hammond@harcourt.com>
  #
  ########################################################################
*/

package oboe.lib;

import java.io.*;
import java.util.*;

/**
 * Class for defining <code>Entity</code>'s for a {@link ContextObject}.
 *
 * @author    Tony Hammond &lt;<a href="mailto:tony_hammond@harcourt.com">mailto:tony_hammond@harcourt.com</a>&gt;
 * @version	0.1.0
 */
public class Entity {

  // Entity types
  public static final String REFERENT = "referent";
  public static final String REFERRER = "referrer";
  public static final String REFERRING_ENTITY = "referring-entity";
  public static final String REQUESTER = "requester";
  public static final String RESOLVER = "resolver";
  public static final String SERVICE_TYPE = "service-type";

  static private Map _dict = new Hashmap();

  static {
    _dict.put(REFERENT, 1);
    _dict.put(REFERRER, 1);
    _dict.put(REFERRING_ENTITY, 1);
    _dict.put(REQUESTER, 1);
    _dict.put(RESOLVER, 1);
    _dict.put(SERVICE_TYPE, 1);
  };

  /**
   * Test for a legitimate <code>Entity</code> type.
   *
   * @return boolean
   */
  static public boolean isEntityType(String type) {
    return _dict.containsKey(type);
  }

  protected String type;		// Entity type
  protected List descriptors;		// Descriptor list

  /**
   * Constructor for a <code>Entity</code>.
   */
  public Entity(String type, Descriptor descriptor) {
    type = null;
    descriptors =  new ArrayList();
    if (isEntityType(type)) {
      type = type;
      if (descriptors.length > 0) {
        if (Descriptor.isDescriptorType(descriptor.getType())) {
          descriptors.push(descriptor);
        }
        else {
          // raise "! Unknown descriptor type"
        }
      }
    }
    else {
      // raise "! Unknown entity type"
    }
    return this;
  }

  // Convenience constructors
  static public Entity referent(Descriptor descriptor) {
    new Entity(Entity::REFERENT, descriptor)
  }
  static public Entity referrer(Descriptor descriptor) {
    new Entity(Entity::REFERRER, descriptor)
  }
  static public Entity referring_entity(Descriptor descriptor) {
    new Entity(Entity::REFERRING_ENTITY, descriptor)
  }
  static public Entity requester(Descriptor descriptor) {
    new Entity(Entity::REQUESTER, descriptor)
  }
  static public Entity resolver(Descriptor descriptor) {
    new Entity(Entity::RESOLVER, descriptor)
  }
  static public Entity service_type(Descriptor descriptor) {
    new Entity(Entity::SERVICE_TYPE, descriptor)
  }

  //
  public Entity addDescriptor(Descriptor descriptor) {
    if (Descriptor.isDescriptorType(descriptor.getType())) {
      descriptors.add(descriptor);
    }
    else {
      // raise "! Unknown descriptor type"
    }
    return this;
  }

  //
  public Entity removeDescriptor(Descriptor descriptor) {
    if (Descriptor.isDescriptorType(descriptor.getType())) {
      descriptors.remove(descriptor);
    }
    else {
      // raise "! Unknown descriptor type"
    }
    return this;
  }

  // Convenience methods to add descriptors by type
  public Entity addId(String value) {
    addDescriptor(new Descriptor(Descriptor::ID, value));
  }
  public Entity addMetadata(String value) {
    addDescriptor(new Descriptor(Descriptor::METADATA, value));
  }
  public Entity addMetadataPtr(String value) {
    addDescriptor(new Descriptor(Descriptor::METADATA_PTR, value));
  }
  public Entity addPrivateData(String value) {
    addDescriptor(new Descriptor(Descriptor::PRIVATE_DATA, value));
  }

  // Accessor method for descriptors of given type
  public ArrayList getDescriptorsOfType(type) {
    List l = new ArrayList();
    if (Descriptor.isDescriptorType(type)) {
      for (Iterator i_ = descriptors.iterator(); i_.hasNext(); ) {
        if (d.type == type) {
          l.add(i_.next());
        }
      }
      return (ArrayList) l;
    }
    else {
      // raise "! Unknown descriptor type: #{type}"
    }
  }

  // Convenience accessor methods for descriptors of given type
  public ArrayList getId() {
    get_descriptors_of_type(Descriptor::ID);
  }
  public ArrayList getMetadata() {
    get_descriptors_of_type(Descriptor::METADATA);
  }
  public ArrayList getMetadataPtr() {
    get_descriptors_of_type(Descriptor::METADATA_PTR);
  }
  public ArrayList getPrivateData(){
    get_descriptors_of_type(Descriptor::PRIVATE_DATA);
  }

}
