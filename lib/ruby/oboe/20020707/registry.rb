########################################################################
module Oboe

  class Registry

  @@registry_properties_file = "oboe/registry.props"
  @@props = {}

  @@hKeys = {}; @@hKeys_01 = {}; @@hFmtKeys = {};
  @@hNIDs = {}; @@hNIDs_01 = {}

  @@hEnts = {}; @@hDscs = {}
  @@hEntKeys = {}; @@hDscKeys = {}

  @@hSchemes = {}

  def Registry.read_property_file(file)
    Registry.read_properties(File.new(file).readlines(nil)[0])
  end

  def Registry.read_properties(lines)
    hash = {}
    lines.gsub(/\\\n\s*/, "").split("\n").each do |line|
      next if line =~ /\s*#/	# skip comments
      next unless line=~ /\S/ 	# skip blank lines
      line=~ /\s*(\S+)\s*[:=]*\s*(\S*.*)/
      hash[$1] = $2
    end
    return hash
  end
  
  def Registry.read_registry_properties
    file = @@registry_properties_file
    @@props = Registry.read_property_file(file)
  end
  
  def Registry.get_context(nid_id)
    hash = {}
    return nil unless Registry.get_nid(nid_id) == 'uri'
    id = Registry.get_id(nid_id)
    return nil unless Registry.get_scheme(id) == 'http'
    properties = Utils.get_html(id)
    if properties 
      hash = Registry.read_properties(properties)
    else
      return nil
    end
    unless hash.empty?
      return hash
    else
      return nil
    end
  end

  # BEGIN {

    # Read the registry properties file
    Registry.read_registry_properties
  
    # Build key table
    @@props['registry.keys'].scan(/\S+/) do |key|
      @@hKeys[@@props[key]] = 1
    end

    # Build NID table
    @@props['registry.nids'].scan(/\S+/) do |nid|
      @@hNIDs[@@props[nid]] = 1
    end

    # Build legacy key table
    @@props['registry.keys_01'].scan(/\S+/) do |key|
      @@hKeys_01[@@props[key]] = 1
    end

    # Build legacy NID table
    @@props['registry.nids_01'].scan(/\S+/) do |nid|
      @@hNIDs_01[@@props[nid]] = 1
    end

    # Build entity name lookup table
    @@props['registry.key.ents'].scan(/\S+/) do |ent|
      @@hEnts[@@props[ent]] = @@props["registry.ent.nam.#{@@props[ent]}"]
    end

    # Build entity key name lookup table
    @@props['registry.key.ents'].scan(/\S+/) do |ent|
      @@hEntKeys[@@props["registry.ent.nam.#{@@props[ent]}"]] = @@props[ent]
    end

    # Build descriptor name lookup table
    @@props['registry.key.dscs'].scan(/\S+/) do |dsc|
      @@hDscs[@@props[dsc]] = @@props["registry.dsc.nam.#{@@props[dsc]}"]
    end

    # Build descriptor key name lookup table
    @@props['registry.key.dscs'].scan(/\S+/) do |dsc|
      @@hDscKeys[@@props["registry.dsc.nam.#{@@props[dsc]}"]] = @@props[dsc]
    end

  # }

    def Registry.get_entity_type(key)
      return @@hEnts[key]
    end

    def Registry.get_entity_key_type(key)
      return @@hEntKeys[key]
    end

    def Registry.get_descriptor_type(key)
      return @@hDscs[key]
    end

    def Registry.get_descriptor_key_type(key)
      return @@hDscKeys[key]
    end

    # Define entity type accessor methods
    def Registry.referent
      return @@props['registry.ent.nam.ref']
    end
    def Registry.referrer
      return @@props['registry.ent.nam.rfr']
    end
    def Registry.referring_entity
      return @@props['registry.ent.nam.rfe']
    end
    def Registry.requester
      return @@props['registry.ent.nam.req']
    end
    def Registry.resolver
      return @@props['registry.ent.nam.res']
    end
    def Registry.service_type
      return @@props['registry.ent.nam.srv']
    end

    # Define descriptor type accessor methods
    def Registry.id
      return @@props['registry.dsc.nam.id']
    end
    def Registry.metadata
      return @@props['registry.dsc.nam.valfmt']
    end
    def Registry.metadata_ptr
      return @@props['registry.dsc.nam.reffmt']
    end
    def Registry.private_data
      return @@props['registry.dsc.nam.pid']
    end

    # Define admin key accessor methods
    def Registry.key_admin_char_set
      return @@props['registry.key.adm_set']
    end
    def Registry.key_admin_timestamp
      return @@props['registry.key.adm_tim']
    end
    def Registry.key_admin_version
      return @@props['registry.key.adm_ver']
    end

    # Define format key accessor method
    def Registry.key_format
      return @@props['registry.key.ref_valfmt']
    end

    # Define remote resource key accessor methods
    def Registry.key_context_pointer
      return @@props['registry.key.ctx_ptr']
    end
    def Registry.key_metadata_pointer
      return @@props['registry.key.ref_ptr']
    end

    def Registry.has_key?(key)
      return @@hKeys.has_key?(key)
    end

    def Registry.keys
      return @@hKeys.keys
    end

    def Registry.has_fmt_key?(key)
      return @@hFmtKeys.has_key?(key)
    end

    def Registry.fmt_keys
      return @@hFmtKeys.keys
    end

    def Registry.has_nid?(key)
      return @@hNIDs.has_key?(key)
    end

    def Registry.nids
      return @@hNIDs.keys
    end

    def Registry.has_key_01?(key)
      return @@hKeys_01.has_key?(key)
    end

    def Registry.has_nid_01?(key)
      return @@hNIDs_01.has_key?(key)
    end

    def Registry.nids_01
      return @@hNIDs_01.keys
    end

    def Registry.schemas
      a = []
      @@props['registry.schemas'].scan(/\S+/) do |schema|
        a << @@props[schema]
      end
      return a
    end

    def Registry.set_format(format)
      # format = Registry.get_id(format[0])
      format = format[0]
      # Check whether format is legal
      schema_keys = nil
      @@props['registry.schemas'].scan(/\S+/) do |schema|
        if format == @@props[schema]
          schema_keys = "#{schema}_keys"
          break          
        end
      end
      if schema_keys
        # Build format key table
        @@props[schema_keys].scan(/\S+/) do |key|
          @@hFmtKeys[key] = 1
        end
      else
        # illegal format - raise cain
      end
    end

    def Registry.get_nid(nid_id)
      nid = nil
      if nid_id =~ /^(\w+):/ then nid = $1 end
      return nid
    end

    def Registry.get_id(nid_id)
      id = nil
      if nid_id =~ /^\w+:(.*)/ then id = $1 end
      return id
    end

    def Registry.get_scheme(id)
      scheme = nil
      if id =~ /^(\w+):/ then scheme = $1 end
      return scheme
    end

    def Registry.nid?(id)
      id_nid = nil; id_scheme = nil

      id =~ /^(\w+):/
      id_scheme = $1

      # return @@props['registry.nid._ri'] unless id_scheme

      @@props['registry.nids'].scan(/\S+/).reverse do |nid|
        unless id_nid
          @@props["registry.nids.#{nid}.schemes"].scan(/\S+/) do |scheme|
            id_nid = nid if id_scheme == scheme
          end
        end
      end

      id_nid = @@props['registry.nid._ri'] unless id_nid
      return id_nid
    end

    def Registry.has_scheme?(nid, scheme)

      # return true if nid == @@props['registry.nid._ri']
      has_scheme = false

      @@props['registry.nids'].scan(/\S+/) do |_nid|
        if nid == @@props[_nid]
          @@props["#{_nid}.schemes"].scan(/\S+/) do |_scheme|
            has_scheme = true if scheme == @@props[_scheme]
          end
        end
      end

      return has_scheme
    end

    def Registry._ri_schemes
      @@hSchemes['_ri'] = []
      @@props['registry.nid._ri.schemes'].scan(/\S+/) do |scheme|
        @@hSchemes['_ri'] << @@props[scheme]
      end
      return @@hSchemes['_ri']
    end

    def Registry.ori_schemes
      @@hSchemes['ori'] = []
      @@props['registry.nid.ori.schemes'].scan(/\S+/) do |scheme|
        @@hSchemes['ori'] << @@props[scheme]
      end
      return @@hSchemes['ori']
    end

    def Registry.uri_schemes
      @@hSchemes['uri'] = []
      @@props['registry.nid.uri.schemes'].scan(/\S+/) do |scheme|
        @@hSchemes['uri'] << @@props[scheme]
      end
      return @@hSchemes['uri']
    end

  end

end

########################################################################
__END__
