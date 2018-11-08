########################################################################
module Oboe

  class Registry

  @@registry_properties_file = "oboe/registry.props"
  @@props = {}

  @@hKeys = {}; @@hKeys_01 = {}; @@hFmtKeys = {};
  @@hNIDs = {}; @@hNIDs_01 = {}

  @@hEnts = {}; @@hDscs = {}

  def Registry.read_properties
    lines = File.new(@@registry_properties_file).readlines(nil)[0]  
    lines.gsub!(/\\\n\s*/, "").split("\n").each do |line|
      next if line =~ /\s*#/	# skip comments
      next unless line=~ /\S/ 	# skip blank lines
      line=~ /\s*(\S+)\s*[:=]*\s*(\S*.*)/
      @@props[$1] = $2
    end
  end
  
  # BEGIN {

    # Read the registry properties file
    Registry.read_properties
  
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

    # Build descriptor name lookup table
    @@props['registry.key.dscs'].scan(/\S+/) do |dsc|
      @@hDscs[@@props[dsc]] = @@props["registry.dsc.nam.#{@@props[dsc]}"]
    end

  # }

    def Registry.get_entity_type(key)
      return @@hEnts[key]
    end

    def Registry.get_descriptor_type(key)
      return @@hDscs[key]
    end

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

    def Registry.key_version
      return @@props['registry.key.adm_ver']
    end

    def Registry.key_context_pointer
      return @@props['registry.key.ctx_ptr']
    end

    def Registry.key_format
      return @@props['registry.key.ref_valfmt']
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

    def Registry.has_key_01?(key)
      return @@hKeys_01.has_key?(key)
    end

    def Registry.has_nid_01?(key)
      return @@hNIDs_01.has_key?(key)
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

    def Registry.get_context

    end

    def Registry.get_nid(nid_id)
      nid_id =~ /^(\w+):/
      nid = $1
      return nid
    end

    def Registry.get_id(nid_id)
      nid_id =~ /^\w+:(.*)/
      id = $1
      return id
    end

    def Registry.nid?(id)
      id_nid = nil; id_scheme = nil

      id =~ /^(\w+):/
      id_scheme = $1

      return @@props['registry.nid.gri'] unless id_scheme

      @@props['registry.nids'].scan(/\S+/).reverse do |nid|
        unless id_nid
          @@props["registry.nids.#{nid}.schemes"].scan(/\S+/) do |scheme|
            id_nid = nid if id_scheme == scheme
          end
        end
      end

      id_nid = @@props['registry.nid.gri'] unless id_nid
      return id_nid
    end

  end

end

########################################################################
__END__
