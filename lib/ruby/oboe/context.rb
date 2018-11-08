########################################################################
module Oboe

class ContextObject

  # Accessor methods
  attr_reader :entities, :data, :pointer

  # Class constructor
  def initialize()
    @data = nil
    @pointer = nil
    @entities = {}
    # @entities[Entity::REFERENT] = ref_desc 
  end

  def get_data() return @data end
  def add_data(value) @data = value end
  def remove_data() @data = nil end

  def get_pointer() return @pointer end
  def add_pointer(value) @pointer = value end
  def remove_pointer() @pointer = nil end

  # Generic method to add an entity
  # (if the entity already exists it is quietly clobbered)
  def add_entity(entity)
    if Entity.is_entity_type?(entity.type)
      @entities[entity.type] = entity
    else
      raise "! Unknown entity type: #{entity.type}"
    end
    self
  end

  # Generic method to renove an entity
  def remove_entity(entity)
    if Entity.is_entity_type?(entity.type)
      @entities.delete(entity.type) if @entities.include?(entity.type)
    else
      raise "! Unknown entity type: #{entity.type}"
    end
    self
  end

  # Convenience methods to add an entity
  def add_referent(descriptor)
    add_entity(Entity::REFERENT, Entity.new(Entity::REFERENT, descriptor))
  end
  def add_referrer(descriptor)
    add_entity(Entity::REFERRER, Entity.new(Entity::REFERRER, descriptor))
  end
  def add_referring_entity(descriptor)
    add_entity(Entity::REFERRING_ENTITY, Entity.new(Entity::REFERRING_ENTITY, descriptor))
  end
  def add_requester(descriptor)
    add_entity(Entity::REQUESTER, Entity.new(Entity::REQUESTER, descriptor))
  end
  def add_resolver(descriptor)
    add_entity(Entity::RESOLVER, Entity.new(Entity::RESOLVER, descriptor))
  end
  def add_service_type(descriptor)
    add_entity(Entity::SERVICE_TYPE, Entity.new(Entity::SERVICE_TYPE, descriptor))
  end

  # Convenience methods to remove an entity
  def remove_referent(descriptor)
    remove_entity(Entity::REFERENT, descriptor)
  end
  def remove_referrer(descriptor)
    remove_entity(Entity::REFERRER, descriptor)
  end
  def remove_referring_entity(descriptor)
    remove_entity(Entity::REFERRING_ENTITY, descriptor)
  end
  def remove_requester(descriptor)
    remove_entity(Entity::REQUESTER, descriptor)
  end
  def remove_resolver(descriptor)
    remove_entity(Entity::RESOLVER, descriptor)
  end
  def remove_service_type(descriptor)
    remove_entity(Entity::SERVICE_TYPE, descriptor)
  end

  # Test method for entity of given type
  def entity_type?(type)
    return defined? @entities[type]
  end

  # Accessor method for entity of given type
  def get_entity_of_type(type)
    if Entity.is_entity_type?(type)
      if defined? @entities[type]
        return @entities[type]
      else
        return nil
      end
    else
      raise "! Unknown entity type: #{type}"
    end
  end

  # Convenience accessor methods for entity of given type
  def get_referent() get_entity_of_type(Entity::REFERENT) end
  def get_referrer() get_entity_of_type(Entity::REFERRER) end
  def get_referring_entity() get_entity_of_type(Entity::REFERRING_ENTITY) end
  def get_requester() get_entity_of_type(Entity::REQUESTER) end
  def get_resolver() get_entity_of_type(Entity::RESOLVER) end
  def get_service_type() get_entity_of_type(Entity::SERVICE_TYPE) end

  # Utility method to return a list of service directives
  def get_directives(service)
    a = []
    return a unless self.get_service_type
    if self.get_service_type.get_descriptors_id
      self.get_service_type.get_descriptors_id.each do |d|
        # d.value.each do |nid_id|
        nid_id = d.value
          id = Registry.get_id(nid_id)
          scheme = Registry.get_scheme(id)
          a << id if scheme == service
        # `end
      end
    end
    return a
  end

end

class Entity

  # Accessor methods
  attr_reader :type, :descriptors, :descriptor_count
  # attr_writer :type, :descriptors

  # Entity types
  REFERENT = Registry.referent
  REFERRER = Registry.referrer
  REFERRING_ENTITY = Registry.referring_entity
  REQUESTER = Registry.requester
  RESOLVER = Registry.resolver
  SERVICE_TYPE = Registry.service_type

  # Entity type lookup table
  @@entity_types = [ REFERENT, REFERRER, REFERRING_ENTITY, REQUESTER,
                     RESOLVER, SERVICE_TYPE ]

  # List entity types
  def Entity.entity_types
    return @@entity_types
  end

  # Test if valid entity type
  def Entity.is_entity_type?(type)
    return @@entity_types.include?(type)
  end

  # Class constructor
  def initialize(type, *descriptors)
    if Entity.is_entity_type?(type)
      @type = type
      @descriptors = []
      @descriptor_count = 0
      if descriptors.length > 0 
        if Descriptor.is_descriptor_type?(descriptors[0].type)
          @descriptors << descriptors[0]
          @descriptor_count += 1
        else
          raise "! Unknown descriptor type"
        end
      end
    else
      raise "! Unknown entity type"
    end
    self
  end

  # Convenience constructors
  def Entity.referent(*descriptors)
    Entity.new(Entity::REFERENT, *descriptors)
  end
  def Entity.referrer(*descriptors)
    Entity.new(Entity::REFERRER, *descriptors)
  end
  def Entity.referring_entity(*descriptors)
    Entity.new(Entity::REFERRING_ENTITY, *descriptors)
  end
  def Entity.requester(*descriptors)
    Entity.new(Entity::REQUESTER, *descriptors)
  end
  def Entity.resolver(*descriptors)
    Entity.new(Entity::RESOLVER, *descriptors)
  end
  def Entity.service_type(*descriptors)
    Entity.new(Entity::SERVICE_TYPE, *descriptors)
  end

  #
  def add_descriptor(descriptor)
    if Descriptor.is_descriptor_type?(descriptor.type)
      @descriptors << descriptor
      @descriptor_count += 1
    else
      raise "! Unknown descriptor type"
    end
    self
  end

  # 
  def remove_descriptor(descriptor)
    if Descriptor.is_descriptor_type?(descriptor.type)
      @descriptors.delete(descriptor)
      @descriptor_count -= 1
    else
      raise "! Unknown descriptor type"
    end
    self
  end

  # Convenience methods to add descriptors by type
  def add_id(value)
    add_descriptor(Descriptor.new(Descriptor::ID, nil, value))
  end
  def add_metadata(format, value)
    add_descriptor(Descriptor.new(Descriptor::METADATA, format, value))
  end
  def add_metadata_ptr(format, value)
    add_descriptor(Descriptor.new(Descriptor::METADATA_PTR, format, value))
  end
  def add_private_data(value)
    add_descriptor(Descriptor.new(Descriptor::PRIVATE_DATA, nil, value))
  end

  # Test method for descriptor of given type
  def descriptor_type?(type)
    return @descriptors.include?(type) 
  end

  # Accessor method for descriptors of given type
  def get_descriptors_of_type(type)
    aDesc = []
    if Descriptor.is_descriptor_type?(type)
      @descriptors.each { |d| aDesc << d if d.type == type }
      return aDesc
    else
      raise "! Unknown descriptor type: #{type}"
    end
  end

  # Convenience accessor methods for descriptors of given type
  def get_descriptors_id() get_descriptors_of_type(Descriptor::ID) end
  def get_descriptors_metadata() get_descriptors_of_type(Descriptor::METADATA) end
  def get_descriptors_metadata_ptr() get_descriptors_of_type(Descriptor::METADATA_PTR) end
  def get_descriptors_private_data() get_descriptors_of_type(Descriptor::PRIVATE_DATA) end

end

class Descriptor

  # Accessor methods
  attr_reader :type, :format, :value
  # attr_writer :type - Must create new instance for type
  attr_writer :format, :value

  # Descriptor types
  ID = Registry.id
  METADATA = Registry.metadata
  METADATA_PTR = Registry.metadata_ptr
  PRIVATE_DATA = Registry.private_data

  # Descriptor type lookup table
  @@descriptor_types = [ ID, METADATA, METADATA_PTR, PRIVATE_DATA ]

  # List descriptor types
  def Descriptor.descriptor_types
    return @@descriptor_types
  end

  # Test if valid descriptor type
  def Descriptor.is_descriptor_type?(type)
    return @@descriptor_types.include?(type)
  end

  # Class constructor
  def initialize(type, format, value)
    if Descriptor::is_descriptor_type?(type)
      @type = type
      @format = format
      @value = value
    else
      raise "! Unknown descriptor type"
    end
    self
  end

end

end

########################################################################
__END__
