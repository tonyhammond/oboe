#

module Oboe

  class OpenURL

  def initialize(*args)

    @hArgs = {}
    @hArgs = args[0]

    @admin = Hash.new(nil)
    @context = nil
    @resolver = nil

    # Is this in OpenURL v1.0 format?
    if @hArgs.has_key?(Registry.key_admin_version)
      @version = "1.0"
      @admin['version'] = @hArgs[Registry.key_admin_version]
    else
      # Assume this is in OpenURL 0.1 format
      # and convert to OpenURL 1.0 format
      self.upgrade_version
    end

    if @hArgs.has_key?(Registry.key_admin_timestamp)
      @admin['timestamp'] = @hArgs[Registry.key_admin_timestamp]
    end

    if @hArgs.has_key?(Registry.key_admin_char_set)
      @admin['char_set'] = @hArgs[Registry.key_admin_char_set]
    end

    if @hArgs.has_key?(Registry.key_format)
      Registry.set_format(@hArgs[Registry.key_format])
    end

    @context = self.get_context

    return self

  end

  def get_context

    hEntities = Hash.new(0)

    # Run though keys and get descriptor counts for each entity
    Entity.entity_types().each do |ent_type|
      @hArgs.each_key do |key|
        if Registry.keys.include?(key)
          ent, dsc = key.split(/_/)
          next unless Registry.get_entity_type(ent) == ent_type
          hEntities[ent_type] += 1
        end
      end
    end

    ctx = ContextObject.new
    Entity.entity_types.each do |ent_type|
      next unless hEntities[ent_type] > 0
      e = Entity.new(ent_type)
      Descriptor.descriptor_types.each do |dsc_type|
        @hArgs.each do |key, vals|
          if Registry.has_key?(key)
            ent, dsc = key.split(/_/)
            next unless Registry.get_entity_type(ent) == ent_type \
                        and Registry.get_descriptor_type(dsc) == dsc_type
            vals.each do |val|
              case dsc_type
                when Descriptor::ID
                  d = Descriptor.new(dsc_type, nil, val)
                when Descriptor::METADATA
                  aFmts = []
                  Registry.fmt_keys.each do |fmt_key|
                    if @hArgs.has_key?(fmt_key)
                      fmt_vals = @hArgs[fmt_key]
                      fmt_vals.each do |fmt_val|
                        aFmts << "#{fmt_key}=#{fmt_val}"
                      end
                    end 
                  end 
                  d = Descriptor.new(dsc_type, val, aFmts)
                when Descriptor::METADATA_PTR
                  if @hArgs.has_key?(Registry.key_metadata_pointer)
                    ptr = @hArgs[Registry.key_metadata_pointer]
                    d = Descriptor.new(dsc_type, val, ptr)
                  else
                    d = Descriptor.new(dsc_type, val, nil)
                  end
                when Descriptor::PRIVATE_DATA
                  d = Descriptor.new(dsc_type, nil, val)
              end
              e.add_descriptor(d)
            end
          end
        end
      end
      ctx.add_entity(e) if hEntities[ent_type] > 0
    end

    return ctx

  end

  def is_valid?

    begin
      self.validate
    rescue
      return false
    else
      return true
    end

  end

  def validate

    # Check on the admin version first
    unless @admin['version']
      raise "! No admin version declared"
    end
    # unless @admin['version'] =~ /Z39.*/
    #   raise "! Unrecognized admin version: \"#{@admin['version']}\""
    # end

    if @hArgs.has_key?(Registry.key_context_pointer)
      ctx_ptr = @hArgs[Registry.key_context_pointer][0]
      ctx_ptr_type = "context-pointer, identifier"
      ctx_ptr_key = Registry.key_context_pointer
      nid = Registry.get_nid(ctx_ptr)
      id = Registry.get_id(ctx_ptr)
      scheme = Registry.get_scheme(id)
      unless Registry.nids.include?(nid)
        hint = _get_hint(Registry.nids, nid)
        help = _get_help(Registry.nids, 'nids', nid)
        raise "! Unrecognized namespace ID \"#{nid}\" (#{ctx_ptr_type} - \"#{ctx_ptr_key}\")#{hint}#{help}"
      end
      unless Registry.has_scheme?(nid, scheme)
        registry_schemes = Registry.send("#{nid}_schemes".intern)
        hint = _get_hint(registry_schemes, scheme)
        help = _get_help(registry_schemes, 'schemes', scheme)
        raise "! Unrecognized scheme \"#{scheme}\" (#{ctx_ptr_type} - \"#{ctx_ptr_key}\")#{hint}#{help}"
      end
      hash = Registry.get_context(ctx_ptr)
      if hash
        @hArgs.update(hash)
        @context = nil
        @context = self.get_context
      else
        err = ""
        err << "! Could not retrive context-object from \""
        err << Registry.get_id(ctx_ptr)
        err << "\""
        raise "#{err}"
      end
    end

    # Check that we have a referent entity
    unless @context.get_referent()
      raise "! No referent entity declared"
    end

    # Now run through decsriptors in entity order
    Entity.entity_types().each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e     # why do we need this?
      Descriptor.descriptor_types().each do |dsc_type|
        ent_dsc_type = "#{ent_type}, #{dsc_type}"
        ent_dsc_key = "#{Registry.get_entity_key_type(ent_type)}"
        ent_dsc_key += "_#{Registry.get_descriptor_key_type(dsc_type)}"
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              nid = Registry.get_nid(d.value)
              id = Registry.get_id(d.value)
              scheme = Registry.get_scheme(id)
              unless Registry.nids.include?(nid)
                hint = _get_hint(Registry.nids, nid)
                help = _get_help(Registry.nids, 'nids', nid)
                raise "! Unrecognized namespace ID \"#{nid}\" (#{ent_dsc_type} - \"#{ent_dsc_key}\")#{hint}#{help}"
              end
              unless Registry.has_scheme?(nid, scheme)
                registry_schemes = Registry.send("#{nid}_schemes".intern)
                hint = _get_hint(registry_schemes, scheme)
                help = _get_help(registry_schemes, 'schemes', scheme)
                raise "! Unrecognized scheme \"#{scheme}\" (#{ent_dsc_type} - \"#{ent_dsc_key}\")#{hint}#{help}"
              end
              id = Utils.entify(Registry.get_id(d.value))
            when Descriptor::METADATA
              # fmt = Registry.get_id(d.format)
              fmt = d.format
              unless Registry.schemas.include?(fmt)
                hint = _get_hint(Registry.schemas, fmt)
                help = _get_help(Registry.schemas, 'schemas', fmt)
                raise "! Unrecognized schema \"#{fmt}\" (#{ent_dsc_type} - \"#{ent_dsc_key}\")#{hint}#{help}"
              end
              d.value.each do |value|
                key, val = value.split(/=/)
                val = Utils.entify(val)
              end
            when Descriptor::METADATA_PTR
              nid = Registry.get_nid(d.format)
              unless Registry.nids.include?(nid)
                hint = _get_hint(Registry.nids, nid)
                help = _get_help(Registry.nids, 'nids', nid)
                raise "! Unrecognized namespace ID \"#{nid}\" (#{ent_dsc_type} - \"#{ent_dsc_key}\")#{hint}#{help}"
              end
              fmt = Registry.get_id(d.format)
              val = Utils.entify(d.value[0])
            when Descriptor::PRIVATE_DATA
          end
        end
      end
    end

=begin
  def get_referrer()
  def get_referring_entity()
  def get_requester()
  def get_resolver()
  def get_service_type()
=end

  end

  def _get_hint(registry, item)
    hint = ""; a = []
    registry.sort.each do |_item|
      a << "\"#{_item}\"" if _item =~ /#{item}/
      a << "\"#{_item}\"" if item =~ /#{_item}/
    end
    if a.length > 0 
      hint << "<p>\nDid you mean "; hint << a.join(', ')
      hint << "?"
    end
    return hint
  end

  def _get_help(registry, items, item)
    help = "<p>\nRegistered #{items}:\n"; a = []
    registry.sort.each do |_item|
      a << "\"#{_item}\""
    end
    help << a.join(', ')
    return help
  end

  def upgrade_version

    nKeys = 0; byVal = false
    @hArgs.each do |key, vals|
      if Registry.has_key_01?(key)
        nKeys += 1
        # byVal = true if @@hKeys_01[key] > 0 
      end
    end
    if nKeys > 0
      @version = "0.1"
      @admin['version'] = "Z39.00-00"
      @hArgs.each do |key, vals|
        _vals = []
        if key == 'id'
          vals.each do |val|
            nam = "#{val}"
            nam.sub!(/(\w+):(.*)/, '\1')
            val.sub!(/(\w+):(.*)/, '\2')
            if Registry.has_nid_01?(nam)
              _vals.push("ori:#{nam}:#{val}")
            end
          end
          @hArgs.delete(key); @hArgs['ref_id'] = _vals
        end
        if key == 'sid'
          vals.each do |val|
            _vals.push("ori:dbid:#{val}")
          end
          @hArgs.delete(key); @hArgs['rfr_id'] = _vals
        end
        if key == 'pid'
          @hArgs.delete(key); @hArgs['ref_pid'] = vals
        end
      end
      # If "genre" is sepcified then we need to map that to the
      # by-val format type - otherwise we'll need to infer it
      # from the best match of meta-tags to format type
      @hArgs['ref_valfmt'] = 'jarticle' if byVal
    else
      # exit
    end

    return self

  end

########################################################################

  def to_s

    s = ""
    s << "#  OpenURL v.1.0 Parameters"
    s << " (converted from OpenURL v.0.1)" if @version == '0.1'
    s << ":\n\n"
    @hArgs.sort.each do |key, vals|
      next if key.empty?
      vals.each do |val|
        # s << "*   #{key} = #{val}\n" if Registry.has_key?(key)
        # s << "+   #{key} = #{val}\n" if Registry.has_fmt_key?(key)
        s << "   #{key} = #{val}\n" if Registry.has_key?(key)
        s << "   #{key} = #{val}\n" if Registry.has_fmt_key?(key)
      end
    end
    return s

  end

  alias_method :to_key, :to_s

########################################################################

  @@registry = 'http://lib-www.lanl.gov/~herbertv/niso'
  @@xsi = 'http://www.w3.org/2001/XMLSchema-instance'

  @@xml_decl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  @@xml_head =<<-EOT
<!--
  Oboe/Ruby - OpenURL Based Open Environment

  Author: tony_hammond@harcourt.com
  Date:   June 22, 2002
-->
EOT

  @@ctxc_head =<<-EOT
<context-container xmlns="http://www.niso.org/context-object" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xsi:schemaLocation="http://www.niso.org/context-object
  http://lib-www.lanl.gov/~herbertv/niso/context-container.xsd" 
  version="">
  EOT

  @@ctxc_tail = "</context-container>"

  @@ctx_head = "<context-object>"
  @@ctx_tail = "</context-object>"

  def to_xml

    s = ""

    if @admin.has_key?('timestamp')
      @@ctxc_head.sub!(/\>\Z/, " timestamp=\"#{@admin['timestamp']}\"\>")
      @@ctx_head.sub! (/\>\Z/, " timestamp=\"#{@admin['timestamp']}\"\>")
    end
    @@ctxc_head.sub!(/(version="")/, "version=\"#{@version}\"")
 
    s << "#{@@xml_decl}\n"
    s << "#{@@xml_head}\n"
    s << "#{@@ctxc_head}\n"
    s << "  #{@@ctx_head}\n"
    s << "  <!--\n"
    s << self.to_s
    s << "-->\n"

    Entity.entity_types().each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e	# why do we need this?
      s << "    <#{ent_type}>\n"
      Descriptor.descriptor_types().each do |dsc_type|
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              nid = Registry.get_nid(d.value) 
              id = Utils.entify(Registry.get_id(d.value))
              s << "      <#{dsc_type} type=\"#{nid}\">"
              s << "#{id}</#{dsc_type}>\n"
            when Descriptor::METADATA
              # fmt = Registry.get_id(d.format)
              fmt = d.format
              s << "      <#{dsc_type}>\n"
              s << "        <m:#{fmt} xmlns:m=\"#{@@registry}/#{fmt}\"\n"
              s << "          xmlns:xsi=\"#{@@xsi}\"\n"
              s << "          xsi:schemaLocation=\"#{@@registry}/#{fmt}\">\n"
              d.value.each do |value|
                key, val = value.split(/=/)
                val = Utils.entify(val)
                s << "        <m:#{key}>#{val}</m:#{key}>\n"
              end
              s << "        </m:#{fmt}>\n"
              s << "      </#{dsc_type}>\n"
            when Descriptor::METADATA_PTR
              nid = Registry.get_nid(d.format) 
              fmt = Registry.get_id(d.format)
              val = Utils.entify(d.value[0])
              s << "      <#{dsc_type} type=\"#{fmt}\">"
              s << "#{val}</#{dsc_type}>\n"
            when Descriptor::PRIVATE_DATA
              id = Utils.entify(d.value)
              s << "      <#{dsc_type} type=\"#{nid}\">"
              s << "#{id}</#{dsc_type}>\n"
          end
        end
      end
      s << "    </#{ent_type}>\n"
    end

    s << "  #{@@ctx_tail}\n"
    s << "#{@@ctxc_tail}\n"

    return s

  end

########################################################################

=begin
  @@registry = 'http://lib-www.lanl.gov/~herbertv/niso'
  @@xsi = 'http://www.w3.org/2001/XMLSchema-instance'
=end

  def to_yads

    s = ""

    s << "#{@@xml_decl}\n"
    s << "#{@@xml_head}\n"
    s << "<yads>\n"
    s << "<!--\n"
    s << self.to_s
    s << "-->\n"
    s << "  <nest>\n"
    s << "    <!-- OpenURL -->\n"
    s << "    <property type=\"type\">oboe:openurl</property>\n"
    s << "    <resource/>\n"
    s << "    <collection>\n"
    s << "      <item>\n"
    s << "        <!-- Administration -->\n"
    s << "        <property type=\"type\">oboe:administration</property>\n"
    s << "        <collection>\n"
    @admin.each do |key, val|
      s << "          <item>\n"
      s << "            <!-- #{key.capitalize} -->\n"
      s << "            <property type=\"type\">oboe:#{key}</property>\n"
      s << "            <data>#{val}</data>\n"
      s << "          </item>\n"
    end
    s << "        </collection>\n"
    s << "      </item>\n"
    s << "      <item>\n"
    s << "        <!-- ContextObject -->\n"
    s << "        <property type=\"type\">oboe:context-object</property>\n"
    s << "        <collection>\n"

    Entity.entity_types().each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e	# why do we need this?
      s << "          <item>\n"
      s << "            <!-- #{ent_type.capitalize} -->\n"
      s << "            <property type=\"type\">oboe:#{ent_type}</property>\n"
      s << "            <collection>\n"
      Descriptor.descriptor_types().each do |dsc_type|
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              nid = Registry.get_nid(d.value) 
              id = Utils.entify(Registry.get_id(d.value))
              s << "              <item>\n"
              s << "                <!-- #{dsc_type.capitalize} -->\n"
              s << "                <property type=\"type\">oboe:#{dsc_type}</property>\n"
              s << "                <data>#{d.value}</data>\n"
              s << "              </item>\n"
            when Descriptor::METADATA
              # fmt = Registry.get_id(d.format)
              fmt = d.format
              s << "              <item>\n"
              s << "                <!-- #{dsc_type.capitalize} -->\n"
              s << "                <property type=\"type\">oboe:#{dsc_type}</property>\n"
              s << "                <property type=\"directive\">oboe:#{fmt}</property>\n"
              s << "                <collection>\n"
              d.value.each do |value|
                key, val = value.split(/=/)
                val = Utils.entify(val)
                s << "                  <item>\n"
                s << "                    <property type=\"type\">oboe:#{key}</property>\n"
                s << "                    <data>#{val}</data>\n"
                s << "                  </item>\n"
              end
              s << "                </collection>\n"
              s << "              </item>\n"
            when Descriptor::METADATA_PTR
              nid = Registry.get_nid(d.format) 
              fmt = Registry.get_id(d.format)
              val = Utils.entify(d.value[0])
              s << "              <item>\n"
              s << "                <!-- #{dsc_type.capitalize} -->\n"
              s << "                <property type=\"type\">oboe:#{dsc_type}</property>\n"
              s << "                <property type=\"directive\">oboe:#{fmt}</property>\n"
              s << "                <data>#{d.value}</data>\n"
              s << "              </item>\n"
            when Descriptor::PRIVATE_DATA
              id = Utils.entify(d.value)
              s << "              <item>\n"
              s << "                <!-- #{dsc_type.capitalize} -->\n"
              s << "                <property type=\"type\">oboe:#{dsc_type}</property>\n"
              s << "                <data>#{d.value}</data>\n"
              s << "              </item>\n"
          end
        end
      end
      s << "            </collection>\n"
      s << "          </item>\n"
    end

    s << "        </collection>\n"
    s << "      </item>\n"
    s << "    </collection>\n"
    s << "  </nest>\n"
    s << "</yads>\n"

    return s

  end

########################################################################

=begin
  @@registry = 'http://lib-www.lanl.gov/~herbertv/niso'
  @@xsi = 'http://www.w3.org/2001/XMLSchema-instance'
=end

  SCHEMA_YADS = "doi:1014/yads-schema-2002-04-03#"
  SCHEMA_RDF  = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

  def to_rdf

    s = ""

    s << "#{@@xml_decl}\n"
    s << "#{@@xml_head}\n"
    s << "<rdf:RDF xmlns:isa=\"#{SCHEMA_YADS}\" xmlns:has=\"#{SCHEMA_YADS}\""
    s << " xmlns:rdf=\"#{SCHEMA_RDF}\">\n"
    s << "  <rdf:Description rdf:about=\"\">\n"
    s << "    <!--\n"
    s << self.to_s
    s << "-->\n"
    s << "    <rdf:type>isa:Nest</rdf:type>\n"
    s << "    <!-- OpenURL -->\n"
    s << "    <has:type>oboe:openurl</has:type>\n"
    s << "    <has:resource/>\n"
    s << "    <has:collection>\n"
    s << "      <rdf:Bag>\n"
    s << "        <rdf:li parseType=\"Resource\">\n"
    s << "          <rdf:type>isa:Item</rdf:type>\n"
    s << "          <!-- Administration -->\n"
    s << "          <has:type>oboe:administration</has:type>\n"
    s << "          <has:collection>\n"
    s << "            <rdf:Bag>\n"
    @admin.each do |key, val|
      s << "              <rdf:li parseType=\"Resource\">\n"
      s << "                <rdf:type>isa:Item</rdf:type>\n"
      s << "                <!-- #{key.capitalize} -->\n"
      s << "                <has:type>oboe:#{key}</has:type>\n"
      s << "                <has:resource>data:,#{val}</has:resource>\n"
      s << "              </rdf:li>\n"
    end
    s << "            </rdf:Bag>\n"
    s << "          </has:collection>\n"
    s << "        </rdf:li>\n"
    s << "        <rdf:li parseType=\"Resource\">\n"
    s << "          <rdf:type>isa:Item</rdf:type>\n"
    s << "          <!-- ContextObject -->\n"
    s << "          <has:type>oboe:context-object</has:type>\n"
    s << "          <has:collection>\n"
    s << "            <rdf:Bag>\n"

    Entity.entity_types().each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e	# why do we need this?
      s << "              <rdf:li parseType=\"Resource\">\n"
      s << "                <rdf:type>isa:Item</rdf:type>\n"
      s << "                <!-- #{ent_type.capitalize} -->\n"
      s << "                <has:type>oboe:#{ent_type}</has:type>\n"
      s << "                <has:collection>\n"
      s << "                  <rdf:Bag>\n"
      Descriptor.descriptor_types().each do |dsc_type|
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              nid = Registry.get_nid(d.value) 
              id = Utils.entify(Registry.get_id(d.value))
              s << "                    <rdf:li parseType=\"Resource\">\n"
              s << "                      <rdf:type>isa:Item</rdf:type>\n"
              s << "                      <!-- #{dsc_type.capitalize} -->\n"
              s << "                      <has:type>oboe:#{dsc_type}</has:type>\n"
              s << "                      <has:resource>data:,#{d.value}</has:resource>\n"
              s << "                    </rdf:li>\n"
            when Descriptor::METADATA
              # fmt = Registry.get_id(d.format)
              fmt = d.format
              s << "                    <rdf:li parseType=\"Resource\">\n"
              s << "                      <rdf:type>isa:Item</rdf:type>\n"
              s << "                      <!-- #{dsc_type.capitalize} -->\n"
              s << "                      <has:type>oboe:#{dsc_type}</has:type>\n"
              s << "                      <has:directive>oboe:#{fmt}</has:directive>\n"
              s << "                      <has:collection>\n"
              s << "                        <rdf:Bag>\n"
              d.value.each do |value|
                key, val = value.split(/=/)
                val = Utils.entify(val)
                s << "                          <rdf:li parseType=\"Resource\">\n"
                s << "                            <rdf:type>isa:Item</rdf:type>\n"
                s << "                            <has:type>oboe:#{key}</has:type>\n"
                s << "                            <has:resource>data:,#{val}</has:resource>\n"
                s << "                          </rdf:li>\n"
              end
              s << "                        </rdf:Bag>\n"
              s << "                      </has:collection>\n"
              s << "                    </rdf:li>\n"
            when Descriptor::METADATA_PTR
              nid = Registry.get_nid(d.format) 
              fmt = Registry.get_id(d.format)
              val = Utils.entify(d.value[0])
              s << "                    <rdf:li parseType=\"Resource\">\n"
              s << "                      <rdf:type>isa:Item</rdf:type>\n"
              s << "                      <!-- #{dsc_type.capitalize} -->\n"
              s << "                      <has:type>oboe:#{dsc_type}</has:type>\n"
              s << "                      <has:directive>oboe:#{fmt}</has:directive>\n"
              s << "                      <has:resource>data:,#{d.value}</has:resource>\n"
              s << "                    </rdf:li>\n"
            when Descriptor::PRIVATE_DATA
              id = Utils.entify(d.value)
              s << "                    <rdf:li parseType=\"Resource\">\n"
              s << "                      <rdf:type>isa:Item</rdf:type>\n"
              s << "                    <!-- #{dsc_type.capitalize} -->\n"
              s << "                      <has:type>oboe:#{dsc_type}</has:type>\n"
              s << "                      <has:resource>data:,#{d.value}</has:resource>\n"
              s << "                    </rdf:li>\n"
          end
        end
      end
      s << "                  </rdf:Bag>\n"
      s << "                </has:collection>\n"
      s << "              </rdf:li>\n"
    end

    s << "            </rdf:Bag>\n"
    s << "          </has:collection>\n"
    s << "        </rdf:li>\n"
    s << "      </rdf:Bag>\n"
    s << "    </has:collection>\n"
    s << "  </rdf:Description>\n"
    s << "</rdf:RDF>\n"

    return s

  end

########################################################################
end

end

########################################################################
__END__
=begin
a. read those tags that are explicitly defined in the EBNF
b. pick ref_valftm (if exists)
c. read all tags that conform to the format defined by the value of ref_valfmt
d. ignore the remaining tags (from OpenURL perspective)

1. check existence of adm_ver and value thereof in HTTP GET/POST URL
=> if adm_ver exists AND value is one of the 2 legitimate ones (there is one
value for name=value encoding -- say z39.00-1 -- and one for XML encoding -- say
z39.00-2 -- of context-object) then go to 2
=> if adm_ver does not exists OR value is not one of the 2 legitimate ones  then
STOP: this is not an (embedded) OpenURL

2. check existence ctx_ptr in HTTP GET/POST URL
=> if ctx_ptr does not exists AND  if adm_ver=z39.00-1 go to 3
=> if ctx_ptr does exists AND  if adm_ver=z39.00-1 go to 4
=> if ctx_ptr does not exists AND  if adm_ver=z39.00-2 go to 6
=> if ctx_ptr does exists AND  if adm_ver=z39.00-2 go to 5

3. this is name=value encoding of context-object by-value
3.a. read those tags from in HTTP GET/POST URL that are explicitly defined in
Part 2 of the EBNF
3.b. pick ref_valftm (if exists)
3.c. read all tags that conform to the format defined by the value of ref_valfmt

3.d. ignore the remaining tags on HTTP GET/POST URL (from OpenURL perspective)
3.e. STOP. all OpenURL-info is now available.

4. this is name=value encoding of context-object by-reference
4.a. resolve value of ctx_ptr (i.e. fetch name=value encoding)
4.b. read those tags from fetched encoding that are explicitly defined in Part 2
of the EBNF
4.c. pick ref_valftm (if exists)
4.d. read all tags from fetched encoding that conform to the format defined by
the value of ref_valfmt
4.e. ignore the remaining tags from fetched encoding (from OpenURL perspective)
4.f. STOP.  all OpenURL-info is now available.

5. this is XML encoding of context-object by-ref
5.a. ignore all remaining tags on HTTP GET/POST URL  (from OpenURL perspective)
5.b. resolve value of ctx_ptr (i.e. fetch XML encoding)
5.c. STOP.  all OpenURL-info is now available.

6.  this is XML encoding of context-object by-value => IMO this is not a valid
OpenURL, but we have not discussed this yet. => STOP
=end=
