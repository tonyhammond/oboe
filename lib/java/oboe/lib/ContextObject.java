/*
  ########################################################################
  #
  # oboe.lib.ContextObject - A Java class for manipulating ContextObjects
  #
  # Author - Tony Hammond <tony_hammond@harcourt.com>
  #
  ########################################################################
*/

package oboe.lib;

import java.io.*;
import java.util.*;

/**
 * Class for defining a <code>ContextObject</code>.
 *
 * @author    Tony Hammond &lt;<a href="mailto:tony_hammond@harcourt.com">mailto:tony_hammond@harcourt.com</a>&gt;
 * @version	0.1.0
 */
public class ContextObject {

  protected Map context;

  /**
   * Constructor for a <code>Entity</code>.
   */
  public ContextObject() {

    context = new HashMap();

  }

  // Generic method to add an entity
  // (if the entity already exists it is quietly clobbered)
  public ContextObject addEntity(Entity entity) {
    if (Entity.isEntityType(entity.getType())) {
      context.put(entity.getType(), entity);
    }
    else {
      // raise "! Unknown entity type: #{entity.type}"
    }
    return this;
  }

  // Generic method to renove an entity
  public ContextObject removeEntity(Entity entity) {
    if (Entity.isEntityType(entity.getType())) {
      if (context.containsKey(entity.getType())) {
        context.delete(entity.getType());
      }
    }
    else {
      // raise "! Unknown entity type: #{entity.type}"
    }
    return this;
  }

  // Convenience methods to add an entity
  public ContextObject addReferent(Descriptor descriptor) {
    addEntity(Entity::REFERENT, new Entity(Entity::REFERENT, descriptor));
  }
  public ContextObject addReferrer(Descriptor descriptor) {
    addEntity(Entity::REFERRER, new Entity(Entity::REFERRER, descriptor));
  }
  public ContextObject addReferringEntity(Descriptor descriptor) {
    addEntity(Entity::REFERRING_ENTITY, new Entity(Entity::REFERRING_ENTITY, descriptor));
  }
  public ContextObject addRequester(Descriptor descriptor) {
    addEntity(Entity::REQUESTER, new Entity(Entity::REQUESTER, descriptor));
  }
  public ContextObject addResolver(Descriptor descriptor) {
    addEntity(Entity::RESOLVER, new Entity(Entity::RESOLVER, descriptor));
  }
  public ContextObject addServiceType(Descriptor descriptor) {
    addEntity(Entity::SERVICE_TYPE, new Entity(Entity::SERVICE_TYPE, descriptor));
  }

  // Convenience methods to remove an entity
  public ContextObject removeReferent(Descriptor descriptor) {
    removeEntity(Entity::REFERENT, descriptor);
  }
  public ContextObject removeReferrer(Descriptor descriptor) {
    removeEntity(Entity::REFERRER, descriptor);
  }
  public ContextObject removeReferringEntity(Descriptor descriptor) {
    removeEntity(Entity::REFERRING_ENTITY, descriptor);
  }
  public ContextObject removeRequester(Descriptor descriptor) {
    removeEntity(Entity::REQUESTER, descriptor);
  }
  public ContextObject removeResolver(Descriptor descriptor) {
    removeEntity(Entity::RESOLVER, descriptor);
  }
  public ContextObject removeServiceType(Descriptor descriptor) {
    removeEntity(Entity::SERVICE_TYPE, descriptor);
  }

  // Accessor method for entity of given type
  public Entity getEntityOfType(type) {
    if (Entity.isEntityType(type)) {
      return (Entity) context.get(type);
    }
    else {
      // raise "! Unknown entity type: #{type}"
    }
  }

  // Convenience accessor methods for entity of given type
  public Entity getReferent() {
    getEntityOfType(Entity::REFERENT);
  }
  public Entity getReferrer() {
    getEntityOfType(Entity::REFERRER);
  }
  public Entity getReferringEntity() {
    getEntityOfType(Entity::REFERRING_ENTITY);
  }
  public Entity getRequester() {
    getEntityOfType(Entity::REQUESTER);
  }
  public Entity getResolver() {
    getEntityOfType(Entity::RESOLVER);
  }
  public Entity getServiceType() {
    getEntityOfType(Entity::SERVICE_TYPE);
  }

}
