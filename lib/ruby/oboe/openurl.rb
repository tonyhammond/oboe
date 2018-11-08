#
require 'uri'

class String
  def capitalize_each
    a = []
    self.split(/-/).each{|w| a << w.capitalize}
    return a.join('-')
  end
  def squash
    return self.gsub(/^\s*\n/m, "")
  end

  @@indent = 0
  @@spaces = "  "
  def zero
    @@indent = 0 
    self
  end
  def hold
    # self.concat("#{@@spaces * @@indent}")
    self
  end
  def more
    @@indent += 1; self.hold
  end
  def less
    @@indent -= 1; self.hold
  end
end

module Oboe

  class OpenURL

  @@registry = 'http://lib-www.lanl.gov/~herbertv/niso'
  @@xsi = 'http://www.w3.org/2001/XMLSchema-instance'

  SCHEMA_YADS = "doi:1014/yads-schema-2002-04-03#"
  SCHEMA_RDF  = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  SCHEMA_OBOE = "http://www2.elsevier.co.uk/~tony/oboe/oboe.rdf"

  def initialize(*args)

    @hArgs = {}
    @hArgs = args[0]

    @admin = Hash.new(nil)
    @context = nil
    @resolver = nil

    @services = {}

    self._check_services

    if @hArgs.has_key?(Registry.key_format_by_val)
      Registry.set_format(@hArgs[Registry.key_format_by_val][0])
    end

    # Is this in OpenURL v1.0 format?
    if @hArgs.has_key?(Registry.key_admin_version)
      @version = "1.0"
      @admin['version'] = @hArgs[Registry.key_admin_version][0]
    elsif @services.has_key?('no_strict')
      if Registry.has_legacy_keys?(@hArgs.each_key{ |key| key})
        self.upgrade_version
      else 
        @version = "1.0"
        @admin['version'] = "Z39.00-00"
        @hArgs[Registry.key_admin_version] = "Z39.00-00"
      end
    else
      # Assume this is in OpenURL 0.1 format
      # and convert to OpenURL 1.0 format
      self.upgrade_version
    end

    if @hArgs.has_key?(Registry.key_admin_timestamp)
      @admin['timestamp'] = @hArgs[Registry.key_admin_timestamp][0]
    end

    if @hArgs.has_key?(Registry.key_admin_char_set)
      @admin['char_set'] = @hArgs[Registry.key_admin_char_set][0]
    end

    @context = self.set_context

    return self

  end

  def _check_services
    if @hArgs.has_key?(Registry.key_service_id)
      Registry.set_service(@hArgs[Registry.key_service_id])
      # Need to push this back to the Registry
      if @hArgs[Registry.key_service_id].include?('_ri:oboe:keep_context')
        @services['keep_context'] = 1
      end
      if @hArgs[Registry.key_service_id].include?('_ri:oboe:trace')
        @services['trace'] = 1
      end
      if @hArgs[Registry.key_service_id].include?('_ri:oboe:no_strict')
        @services['no_strict'] = 1
      end
      if @hArgs[Registry.key_service_id].include?('_ri:oboe:strict')
        @services['strict'] = 1
        if @services.has_key?('no_strict')
          @services.delete('no_strict')
        end
      end
      if @hArgs[Registry.key_service_id].include?('_ri:oboe:no_parse_uris')
        @services['no_parse_uris'] = 1
      else
        load 'uri.rb'
      end
    end
  end

  def get_context
    return @context
  end

  def add_context(ctx)
    @context = ctx
    return @context
  end

  def set_context

    trace = false
    if @services.has_key?('trace') then trace = true end

    hEntities = Hash.new(0)

    ctx = ContextObject.new

    if @hArgs.has_key?(Registry.key_context_pointer)
      ctx.add_pointer(@hArgs[Registry.key_context_pointer][0])
    end

    if @hArgs.has_key?(Registry.key_context_data)
      data = ""
      data = @hArgs[Registry.key_context_data]
      # ctx.add_data(_encode_querystring(data.join("")))
      ctx.add_data(data.join(""))
    end

    # Run though keys and get descriptor counts for each entity
    Entity.entity_types.each do |ent_type|
      @hArgs.each_key do |key|
        if Registry.keys.include?(key)
          ent, dsc = key.split(/_/)
          next unless Registry.get_entity_type(ent) == ent_type
          hEntities[ent_type] += 1
        end
      end
    end

    Entity.entity_types.each do |ent_type|
      next unless hEntities[ent_type] > 0
      e = Entity.new(ent_type)
      Descriptor.descriptor_types.each do |dsc_type|
        print "\n? #{ent_type}, #{dsc_type}\n" if trace
        @hArgs.each do |key, vals|
          print "  #{key} => #{vals.join(', ')}\n" if trace
          if Registry.has_key?(key)
            # ent, dsc = key.split(/_/)
            ent = key.split(/_/).first
            dsc = key.split(/_/).last
            next unless Registry.get_entity_type(ent) == ent_type \
                        and Registry.get_descriptor_type(dsc) == dsc_type
            vals.each do |val|
              print "* #{val}\n" if trace
              case dsc_type
                when Descriptor::ID
                  if @services['no_strict']
                    val = _add_missing_nid(val)
                  end
                  d = Descriptor.new(dsc_type, nil, val)
                when Descriptor::METADATA
                  aFmts = []
                  Registry.fmt_keys.each do |fmt_key|
                    print "  ? #{fmt_key}\n" if trace
                    if @hArgs.has_key?(fmt_key)
                      print "  * #{fmt_key}\n" if trace
                      fmt_vals = @hArgs[fmt_key]
                      fmt_vals.each do |fmt_val|
                        aFmts << "#{fmt_key}=#{fmt_val}"
                      end
                    end 
                  end 
                  if @hArgs.has_key?(Registry.key_format_by_val)
                    fmt = @hArgs[Registry.key_format_by_val][0]
                    if @services['no_strict']
                      fmt = _add_missing_nid(fmt)
                    end
                    d = Descriptor.new(dsc_type, fmt, aFmts)
                  else
                    d = Descriptor.new(dsc_type, nil, aFmts)
                  end
                when Descriptor::METADATA_PTR
                  if @hArgs.has_key?(Registry.key_format_by_ref)
                    fmt = @hArgs[Registry.key_format_by_ref][0]
                    if @services['no_strict']
                      fmt = _add_missing_nid(fmt)
                      val = _add_missing_nid(val)
                    end
                    d = Descriptor.new(dsc_type, fmt, val)
                  else
                    d = Descriptor.new(dsc_type, nil, val)
                  end
                when Descriptor::PRIVATE_DATA
                  val = _encode_querystring(val)
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

  # Check an identifier for its nid - if found return else
  # assume the leading namespace is a scheme and match that
  # to a registered nid or assume it's a private nid
  def _add_missing_nid(id)
    return unless id.length > 0
    nid = Registry.get_nid(id)
    return id if Registry.nids.include?(nid)
    scheme = Registry.get_scheme(id)
    Registry.nids.each do |nid|
      if Registry.has_scheme?(nid, scheme)
        return "#{nid}:#{id}"
      end
    end
    # return "#{Registry.foreign_nid}:id"
    return id
  end

  def is_valid?

    begin
      self.validate
      return true
    rescue
      return false
    end

  end

  def _decode_querystring(val)
    if _is_encoded_querystring?(val)
      val = CGI.unescape(val).gsub!(/=/, " = ").gsub!(/&/, " & ")
    end
    return val
  end

  def _encode_querystring(val)
    if _is_querystring?(val)
      val = CGI.escape(val.gsub!(/\s*=\s*/, "=").gsub!(/\s*&\s*/, "&"))
    end
    return val
  end

  def _is_querystring?(val)
    na = 0; ne = 0
    # sense querystring pattern - could use directives to control
    na = val.split(/\s*&\s*/).length; ne = val.split(/\s*=\s*/).length
    if na == ne or na + 1 == ne and na > 0
      return true
    else
      return false
    end
  end

  def _is_encoded_querystring?(val)
    na = 0; ne = 0
    # sense querystring pattern - could use directives to control
    na = val.split(/%26/).length; ne = val.split(/%3D/i).length
    if na == ne or na + 1 == ne and na > 0
      return true
    else
      return false
    end
  end

  def validate

    # Check on the admin version first
    unless @admin['version']
      raise "! No admin version declared"
    end
    unless @admin['version'] =~ /^Z39.\d\d-\d\d$/
      raise "! Unrecognized admin version: \"#{@admin['version']}\""
    end
    if @admin.has_key?('char_set')
      unless Registry.char_sets.include?(@admin['char_set'])
        raise "! Unrecognized admin char_set: \"#{@admin['char_set']}\""
      end 
    end

    # May need to allow for recursion
    if @hArgs.has_key?(Registry.key_context_pointer)
      self.resolve_context
    end

    # Check that we have a referent entity
    unless @context.get_referent()
      raise "! No referent entity declared"
    end

    # Now run through decsriptors in entity order
    Entity.entity_types.each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e
      Descriptor.descriptor_types.each do |dsc_type|
        ent_dsc_type = "#{ent_type}, #{dsc_type}"
        ent_dsc_key = "#{Registry.get_entity_key_type(ent_type)}"
        ent_dsc_key += "_#{Registry.get_descriptor_key_type(dsc_type)}"
        where = "#{ent_dsc_type}: \"#{ent_dsc_key}\""
        where_fmt = "#{ent_dsc_type}, format: \"#{ent_dsc_key}_fmt\""
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              _check_val(d.value, where)
              nid = Registry.get_nid(d.value)
              _check_nid(nid, where)
              id = Registry.get_id(d.value)
              scheme = Registry.get_scheme(id)
              _check_scheme(nid, scheme, where)
              _check_uri(id, where) if nid == 'uri'
            when Descriptor::METADATA
              unless ent_type == Registry.referent
                raise "! Descriptor type \"#{dsc_type}\"" \
                      " only allowed for a \"#{Registry.referent}\" entity"
              end
              if e.get_descriptors_of_type(dsc_type).length > 1
                raise "! Only one descriptor type \"#{dsc_type}\"" \
                      " allowed for a \"#{ent_type}\" entity"
              end
              nid = Registry.get_nid(d.format)
              _check_nid(nid, where)
              id = Registry.get_id(d.format)
              scheme = Registry.get_scheme(id)
              _check_scheme(nid, scheme, where)
              _check_uri(id, where) if nid == 'uri'
              schema = d.format
              if Registry.get_schemes_schema.include?(schema)
                _check_schema(nid, schema, where)
              end
              d.value.each do |value|
                key, val = value.split(/=/)
                _check_val(val, where)
              end
            when Descriptor::METADATA_PTR
              if e.get_descriptors_of_type(dsc_type).length > 1
                raise "! Only one descriptor type \"#{dsc_type}\"" \
                      " allowed for a \"#{ent_type}\" entity"
              end
              _check_val(d.value, where)
              nid = Registry.get_nid(d.value)
              _check_nid(nid, where)
              id = Registry.get_id(d.value)
              scheme = Registry.get_scheme(id)
              _check_scheme(nid, scheme, where)
              _check_uri(id, where) if nid == 'uri'
              nid = Registry.get_nid(d.format)
              _check_nid(nid, where)
              id = Registry.get_id(d.format)
              scheme = Registry.get_scheme(id)
              _check_scheme(nid, scheme, where)
              _check_uri(id, where) if nid == 'uri'
              schema = d.format
              if Registry.get_schemes_schema.include?(schema)
                _check_schema(nid, schema, where)
              end
            when Descriptor::PRIVATE_DATA
              if e.get_descriptors_of_type(dsc_type).length > 1
                raise "! Only one descriptor type \"#{dsc_type}\"" \
                      " allowed for a \"#{ent_type}\" entity"
              end
          end
        end
      end
    end

  end

  def resolve_context
    ctx_ptr = @hArgs[Registry.key_context_pointer][0]
    ctx_ptr_type = "context-pointer, identifier"
    ctx_ptr_key = Registry.key_context_pointer
    where = "#{ctx_ptr_type} - \"#{ctx_ptr_key}\""

    nid = Registry.get_nid(ctx_ptr)
    _check_nid(nid, where)
    id = Registry.get_id(ctx_ptr)
    scheme = Registry.get_scheme(id)
    _check_scheme(nid, scheme, where)

    hash = Registry.get_context(ctx_ptr)
    if hash
      @hArgs.delete(Registry.key_context_pointer)
      @hArgs.update(hash)
      if @hArgs.has_key?(Registry.key_format_by_val)
        Registry.set_format(@hArgs[Registry.key_format_by_val][0])
      end
      self._check_services
      @context = self.set_context
    else
      err = ""
      err << "! Could not retrieve context-object from \""
      err << Registry.get_id(ctx_ptr)
      err << "\""
      raise "#{err}"
    end
  end

  def _check_val(val, where)
    unless val
      raise "! No value found (#{where})"
    end
  end

  def _check_nid(nid, where)
    unless Registry.nids.include?(nid)
      hint = _get_hint(Registry.nids, nid)
      help = _get_help(Registry.nids, 'nids')
      raise "! Unrecognized namespace ID \"#{nid}\" (#{where})#{hint}#{help}"
    end
    return if where =~ /service/
    if nid == Registry.foreign_nid
      unless @context.get_referrer()
        raise "! Namespace ID \"#{nid}\" found and no referrer entity declared (#{where})"
      end
    end
  end

  def _check_scheme(nid, scheme, where)
    return if nid == Registry.foreign_nid
    unless Registry.has_scheme?(nid, scheme)
      registry_schemes = Registry.get_schemes(nid)
      hint = _get_hint(registry_schemes, scheme)
      help = _get_help(registry_schemes, 'schemes')
      raise "! Unrecognized scheme \"#{scheme}\" (#{where})#{hint}#{help}"
    end
  end

  def _check_schema(nid, schema, where)
    return if nid == Registry.foreign_nid
    unless Registry.schemas.include?(schema)
      hint = _get_hint(Registry.schemas, schema)
      help = _get_help(Registry.schemas, 'schemas in "ori:schema:"')
      raise "! Unrecognized schema \"#{schema}\" (#{where})#{hint}#{help}"
    end
  end

  def _check_uri(id, where)
    return if @services['no_parse_uris']
    begin
      URI.parse(id)
    rescue
      raise "! Malformed URI \"#{id}\" (#{where})"
    end
  end

  def _get_hint(registry, item)
    hint = ""; a = []
    registry.sort.each do |_item|
      item_ = "#{item}"
      item_.sub!(/^\w+:\w+:/, "") if item =~ /schema/
      _item.sub!(/^\w+:\w+:/, "") if item =~ /schema/
      item_initial = nil
      item_initial = $1 if item =~ /^(\w)/
      a << "\"#{_item}\"" if _item =~ /^#{item_initial}/
      a << "\"#{_item}\"" if _item =~ /#{item_}/
      a << "\"#{_item}\"" if item_ =~ /#{_item}/
    end
    if a.length > 0 
      hint << "\n\nDid you mean "; hint << a.uniq.join(', ')
      hint << "?"
    end
    return hint
  end

  def _get_help(registry, items)
    help = "\n\nRegistered #{items}:\n"; a = []
    registry.sort.each do |_item|
      _item.sub!(/^\w+:\w+:/, "") if items =~ /schemas/
      a << "\"#{_item}\""
    end
    help << a.join(', ')
    return help
  end

  def upgrade_version

    trace = false
    if @services.has_key?('trace') then trace = true end

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
      if @hArgs.has_key?('genre')
        @hArgs.delete(key); @hArgs['ref_valfmt'] = vals
      else
        genre_counts = {}; genre_matches = 0; genre_match = []
        Registry.genres.each do |genre|
          genre_counts[genre] = 0
          @hArgs.each do |key, vals|
            print "\n? genre: #{genre} (#{genre_counts[genre]})\n\n" if trace
            genre_keys = Registry.get_genre_keys(genre)
            genre_keys.each do |genre_key|
              genre_counts[genre] += 1 if key == genre_key
              if trace 
                print "* " if key == genre_key
                print "  " if key != genre_key
                print "\"#{key}\" =? \"#{genre_key}\""
                print " (#{genre_counts[genre]})\n"
              end 
            end 
          end
        end
        p genre_counts if trace
        Registry.genres.each do |genre|
          if genre_counts[genre] > genre_matches
            genre_matches = genre_counts[genre]
            genre_match << genre
          end 
        end
        print "\n> #{genre_match}\n\n" if trace
        @hArgs['ref_valfmt'] = []
        Registry.genres.each do |genre|
          if genre_counts[genre] == genre_matches
            print "\"#{genre}\" (#{genre_counts[genre]})\n" if trace
            @hArgs['ref_valfmt'] << genre if genre_counts[genre] > 0
          end
        end
      end
    else
      # exit
    end

    return self

  end

########################################################################

  def post(resolver=nil)

    a = []; uri = ""

    if resolver
      Utils.post_html(resolver, self.to_query)
    else
      a = self.get_context.get_resolver.get_descriptors_id
      if a.length > 0 
        uri = Registry.get_id(a[0].value)
        Utils.post_html(uri, self.to_query)
      end
    end
 
  end

########################################################################

  def to_query

    other_directives = false

    s = ""; a = []

    if @admin.has_key?('char_set')
      a << "#{Registry.key_admin_char_set}=#{CGI.escape(@admin['char_set'])}"
    end
    if @admin.has_key?('timestamp')
      a << "#{Registry.key_admin_timestamp}=#{CGI.escape(@admin['timestamp'])}"
    end
    if @admin.has_key?('version')
      a << "#{Registry.key_admin_version}=#{CGI.escape(@admin['version'])}"
    end

    if @context.data
      a << "#{Registry.key_context_data}=#{CGI.escape(@context.data)}"
    end
    if @context.pointer
      a << "#{Registry.key_context_pointer}=#{CGI.escape(@context.pointer)}"
    end

    Entity.entity_types.each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e
      if ent_type == Registry.service_type
        e.get_descriptors_id.each do |d|
         other_directives = true if d.value !~ 'oboe'
        end
      else
      end
      Descriptor.descriptor_types.each do |dsc_type|
        ent_dsc_key = "#{Registry.get_entity_key_type(ent_type)}"
        ent_dsc_key += "_#{Registry.get_descriptor_key_type(dsc_type)}"
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              unless ent_type == Registry.service_type and d.value =~ 'oboe' and not @services.has_key?('keep_context')
                a << "#{ent_dsc_key}=#{CGI.escape(d.value)}"
              end
            when Descriptor::METADATA
              fmt = d.format
	      a << "#{ent_dsc_key}=#{CGI.escape('*')}"
	      a << "#{ent_dsc_key}_fmt=#{CGI.escape(d.format)}"
              d.value.each do |value|
                key, val = value.split(/=/)
                a << "#{key}=#{CGI.escape(val)}"
              end
            when Descriptor::METADATA_PTR
              a << "#{ent_dsc_key}=#{CGI.escape(d.value)}"
              a << "#{ent_dsc_key}_fmt=#{CGI.escape(d.format)}"
            when Descriptor::PRIVATE_DATA
              a << "#{ent_dsc_key}=#{CGI.escape(d.value)}"
          end
        end
      end
    end

    s = a.join("&")

    return s

  end

########################################################################

  def to_s

    other_directives = false

    s = ""
    s << "# OpenURL v.1.0 Parameters"
    s << " (converted from OpenURL v.0.1)" if @version == '0.1'
    s << ":\n\n"

    s << "# Administration\n\n" 
    if @admin.has_key?('char_set')
      s << "  #{Registry.key_admin_char_set} = #{@admin['char_set']}\n"
    end
    if @admin.has_key?('timestamp')
      s << "  #{Registry.key_admin_timestamp} = #{@admin['timestamp']}\n"
    end
    if @admin.has_key?('version')
      s << "  #{Registry.key_admin_version} = #{@admin['version']}\n"
    end

    s << "\n" 
    s << "# Context-Object\n" 
    if @context.data
      data = @context.data
      if _is_encoded_querystring?(data)
        data = _decode_querystring(data)
        data.gsub!(/&/, "\\\n              &")
      end
      s << "\n  #{Registry.key_context_data} = #{data}\n"
    end
    if @context.pointer
      s << "\n  #{Registry.key_context_pointer} = #{@context.pointer}\n"
    end

    Entity.entity_types.each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e
      if ent_type == Registry.service_type
        e.get_descriptors_id.each do |d|
         other_directives = true if d.value !~ 'oboe'
        end
        s << "\n  # #{ent_type.capitalize_each}\n" if other_directives or @services.has_key?('keep_context')
      else
        s << "\n  # #{ent_type.capitalize_each}\n"
      end
      Descriptor.descriptor_types.each do |dsc_type|
        ent_dsc_key = "#{Registry.get_entity_key_type(ent_type)}"
        ent_dsc_key += "_#{Registry.get_descriptor_key_type(dsc_type)}"
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              unless ent_type == Registry.service_type and d.value =~ 'oboe' and not @services.has_key?('keep_context')
                s << "  #{ent_dsc_key} = #{d.value}\n"
              end
            when Descriptor::METADATA
              schema = Registry.get_id(d.format)
	      s << "  #{ent_dsc_key} = *\n"
	      s << "  #{ent_dsc_key}_fmt = #{d.format}\n"
	      s << "\n"
	      s << "    # Metadata-By-Val (\"#{schema}\")\n"
              d.value.sort.each do |value|
                key, val = value.split(/=/)
                s << "    #{key} = #{val}\n"
              end
	      s << "\n"
            when Descriptor::METADATA_PTR
              s << "  #{ent_dsc_key} = #{d.value}\n"
              s << "  #{ent_dsc_key}_fmt = #{d.format}\n"
            when Descriptor::PRIVATE_DATA
              data = d.value
              if _is_encoded_querystring?(data)
                data = _decode_querystring(data)
                data.gsub!(/&/, "\\\n              &")
              end
              s << "  #{ent_dsc_key} = #{data}\n"
          end
        end
      end
    end

    s.gsub!(/\n\n\n/m, "\n\n")

    return s

  end

########################################################################

  @@xml_decl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  @@xml_head =<<-"EOT"
<!--
  Oboe: OpenURL Based Open Environment

  Mail: Tony Hammond <t.hammond@elsevier.com>
  Time: #{Utils.time}
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

    other_directives = false

    s = ""

    if @admin.has_key?('char_set')
      @@xml_decl = "<?xml version=\"1.0\" encoding=\"#{@admin['char_set']}\"?>"
    end

    if @admin.has_key?('timestamp')
      @@ctxc_head.sub!(/\>\Z/, " timestamp=\"#{@admin['timestamp']}\"\>")
      @@ctx_head.sub!(/\>\Z/, " timestamp=\"#{@admin['timestamp']}\"\>")
    end
    @@ctxc_head.sub!(/(version="")/, "version=\"#{@admin['version']}\"")
 
    s << "#{@@xml_decl}\n"
    s << "#{@@xml_head}\n"
    s << "#{@@ctxc_head}\n"
    s << "  #{@@ctx_head}\n"
    s << "  <!--\n#{self.to_s.squash}-->\n"

    Entity.entity_types.each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e
=begin
      if ent_type == Registry.service_type
        e.get_descriptors_id.each do |d|
         other_directives = true if d.value !~ 'oboe'
        end
        s << "\n  # #{ent_type.capitalize_each}\n" if other_directives
      else
        s << "\n  # #{ent_type.capitalize_each}\n"
      end
=end
      s.more << "<#{ent_type}>\n"
      Descriptor.descriptor_types.each do |dsc_type|
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              unless ent_type == Registry.service_type and d.value =~ 'oboe' and not @services.has_key?('keep_context')
                nid = Registry.get_nid(d.value) 
                id = Utils.entify(Registry.get_id(d.value))
                s.more << "<#{dsc_type} namespace-id=\"#{nid}\">"
                s << "#{id}</#{dsc_type}>\n"
#                s.less
              end
            when Descriptor::METADATA
              nid = Registry.get_nid(d.format)
              id = Registry.get_id(d.format)
              scheme = Registry.get_scheme(id)
              fmt = scheme ? id.sub(/#{scheme}:/, "") : id
              s.more << "<#{dsc_type}>\n"
              s.more << "<format namespace-id=\"#{nid}\">#{id}</format>\n"
              s.hold << "<#{fmt} xmlns=\"#{@@registry}/#{fmt}\"\n"
              s << "xmlns:xsi=\"#{@@xsi}\"\n"
              s << "xsi:schemaLocation=\"#{@@registry}/#{fmt}\">\n"
              d.value.each do |value|
                key, val = value.split(/=/)
                val = Utils.entify(val)
                s.hold << "<#{key}>#{val}</#{key}>\n"
              end
              s.less << "</#{fmt}>\n"
              s.less << "</#{dsc_type}>\n"
#              s.less
            when Descriptor::METADATA_PTR
              nid = Registry.get_nid(d.format)
              id = Registry.get_id(d.format)
              scheme = Registry.get_scheme(id)
              fmt = scheme ? id.sub(/#{scheme}:/, "") : id
              s.more << "<#{dsc_type}>\n"
              s.more << "<format namespace-id=\"#{nid}\">#{id}</format>\n"
              pointer = Utils.entify(d.value)
              nid = Registry.get_nid(pointer)
              id = Registry.get_id(pointer)
              s.more << "<location namespace-id=\"#{nid}\">"
              s << "#{id}</location>\n"
              s.more << "</#{dsc_type}>\n"
#              s.less
            when Descriptor::PRIVATE_DATA
              s.more << "<#{dsc_type}\">"
              s.less << "#{d.value[0]}</#{dsc_type}>\n"
#              s.less
          end
        end
      end
      s.less << "</#{ent_type}>\n"
    end

    if @context.get_data
      s.hold << "<#{Registry.context_data}>\n"
      s.more << "#{Utils.entify(@context.get_data)}\n"
      s.less << "</#{Registry.context_data}>\n"
    end

    s.less << "#{@@ctx_tail}\n"
    s.less << "#{@@ctxc_tail}\n"

    return s

  end

########################################################################

  def to_excel

    s = ""; metadata_s = ""
    tab = "\t"; repeat = 0; a = []

    s << "#\n"
    s << "# Oboe:#{tab}OpenURL\n"
    s << "# #{tab}Based Open Environment\n"
    s << "#\n"
    s << "# Mail:#{tab}<t.hammond@elsevier.com>\n"
    s << "# Time:#{tab}#{Utils.time}\n"
    s << "#\n"
    s << "\n"
    s << "Administration\n"
    s << "#{tab}Version#{tab}Timestamp#{tab}Char-Set\n"
    s << "#{tab}"
    s << "#{@admin['version']}" if @admin.has_key?('version')
    s << "#{tab}"
    s << "#{@admin['timestamp']}" if @admin.has_key?('timestamp')
    s << "#{tab}"
    s << "#{@admin['char_set']}" if @admin.has_key?('char_set')
    s << "\n\n"
    s << "Context-Object\n"
    # s << "#{tab}Data#{@context.data}" if @context.has_key?('data')
    # s << "#{tab}Pointer#{@context.pointer}" if @context.has_key?('pointer')
    s << "#{tab}#{tab}"
    Descriptor.descriptor_types.each do |dsc_type|
      s << "#{dsc_type}".capitalize_each
      s << "#{tab}"
    end
    s << "\n"
    Entity.entity_types.each do |ent_type|
      e = @context.get_entity_of_type(ent_type)
      next unless e
      repeat = 0
      Descriptor.descriptor_types.each do |dsc_type|
        if e.get_descriptors_of_type(dsc_type).length > repeat
          repeat = e.get_descriptors_of_type(dsc_type).length
        end
      end
      (0..repeat-1).each do |i|
        s << "#{tab}" << "#{ent_type}".capitalize_each << "#{tab}"
        Descriptor.descriptor_types.each do |dsc_type|
          a = e.get_descriptors_of_type(dsc_type)
          d = a[i]
          unless d
            s << "#{tab}"  
          else
            case dsc_type
              when Descriptor::ID
                s << "#{Registry.get_id(d.value)}#{tab}"
              when Descriptor::METADATA
                s << "#{Registry.get_id(d.format)}#{tab}"
                if d.value.length > 0
                  metadata_s << "Metadata-By-Val#{tab}Term#{tab}Value\n"
                end
                d.value.each do |value|
                  key, val = value.split(/=/)
                  metadata_s << "#{tab}#{tab}#{key}#{tab}\"#{val}\"\n"
                end
              when Descriptor::METADATA_PTR
                s << "#{Registry.get_id(d.format)}#{tab}"
              when Descriptor::PRIVATE_DATA
                s << "#{d.value}#{tab}"
            end
          end
        end
      s << "\n"
      end
    end

    s << "\n\n#{tab}#{metadata_s}"

    return s

  end

########################################################################

  def to_yads

    other_directives = false

    s = ""; s.zero

    if @admin.has_key?('char_set')
      @@xml_decl = "<?xml version=\"1.0\" encoding=\"#{@admin['char_set']}\"?>"
    end

    s.hold << "#{@@xml_decl}\n"
    s.hold << "#{@@xml_head}\n"
    s.hold << "<yads>\n"
    s.hold << "<!--\n#{self.to_s.squash}-->\n"
    s.more << "<nest>\n"
    s.more << "<!-- OpenURL -->\n"
    s.hold << "<resource/>\n"
    s.hold << "<collection>\n"
    s.more << "<nest>\n"
    s.more << "<!-- Profile -->\n"
    s.hold << "<property type=\"directive\">oboe:</property>\n"
    s.hold << "<resource>#{SCHEMA_OBOE}</resource>\n"
    s.hold << "<collection>\n"
    s.more << "<item>\n"
    s.more << "<!-- Administration -->\n"
    s.hold << "<property type=\"type\">oboe:administration</property>\n"
    s.hold << "<collection>\n"
    @admin.each do |key, val|
      s.more << "<item>\n"
      s.more << "<!-- #{key.capitalize_each} -->\n"
      s.hold << "<property type=\"type\">oboe:administration:#{key}</property>\n"
      s.hold << "<data>#{val}</data>\n"
      s.less << "</item>\n"
      s.less << ""
    end
    s.less << "</collection>\n"
    s.less << "</item>\n"
    s.hold << "<item>\n"
    s.more << "<!-- Context-Object -->\n"
    s.hold << "<property type=\"type\">oboe:context</property>\n"
    s.hold << "<collection>\n"

    if @context.pointer
      s.more << "<item>\n"
      s.more << "<!-- Context-Object Pointer -->\n"
      s.hold << "<property type=\"type\">oboe:#{Registry.context_pointer}</property>\n"
      s.hold << "<resource>#{Utils.entify(@context.pointer)}</resource>\n"
      s.less << "</item>\n"
    end

    if @context.data
      s.more << "<item>\n"
      s.more << "<!-- Context-Object Private Data -->\n"
      s.hold << "<property type=\"type\">oboe:#{Registry.context_data}</property>\n"
      s.hold << "<resource>#{Utils.entify(@context.data)}</resource>\n"
      s.less << "</item>\n"
    end

    Entity.entity_types.each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e
      if ent_type == Registry.service_type
        e.get_descriptors_id.each do |d|
         other_directives = true if d.value !~ 'oboe'
        end
        next unless other_directives
      end
      s.hold << "<item>\n"
      s.more << "<!-- #{ent_type.capitalize_each} -->\n"
      s.hold << "<property type=\"type\">oboe:entity:#{ent_type}</property>\n"
      s.hold << "<collection>\n"
      Descriptor.descriptor_types.each do |dsc_type|
       #dsc_type.split(/-/).each{|w| w.capitalize_each}.join('-')
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              unless ent_type == Registry.service_type and d.value =~ 'oboe' and not @services.has_key?('keep_context')
                nid = Registry.get_nid(d.value) 
                id = Utils.entify(Registry.get_id(d.value))
                s.more << "<item>\n"
                s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
                s.hold << "<property type=\"type\">oboe:descriptor:#{dsc_type}</property>\n"
                s.hold << "<data>#{d.value}</data>\n"
                s.less << "</item>\n"
                #s.less << ""
              end
            when Descriptor::METADATA
              fmt = d.format
              s.more << "<nest>\n"
              s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
              s.hold << "<property type=\"type\">oboe:descriptor:#{dsc_type}</property>\n"
              s.hold << "<data>#{fmt}</data>\n"
              s.hold << "<collection>\n"
              d.value.each do |value|
                key, val = value.split(/=/)
                val = Utils.entify(val)
                s.more << "<item>\n"
                s.more << "<property type=\"type\">#{key}</property>\n"
                s.hold << "<data>#{val}</data>\n"
                s.less << "</item>\n"
              end
              s.less << "</collection>\n"
              s.less << "</nest>\n"
              #s.less
            when Descriptor::METADATA_PTR
              nid = Registry.get_nid(d.format) 
              fmt = Registry.get_id(d.format)
              val = Utils.entify(d.value)
              s.more << "<item>\n"
              s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
              s.hold << "<property type=\"type\">oboe:descriptor:#{dsc_type}</property>\n"
              s.hold << "<property type=\"directive\">#{fmt}</property>\n"
              s.hold << "<data>#{d.value}</data>\n"
              s.less << "</item>\n"
              #s.less
            when Descriptor::PRIVATE_DATA
              id = Utils.entify(d.value)
              s.more << "<item>\n"
              s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
              s.hold << "<property type=\"type\">oboe:descriptor:#{dsc_type}</property>\n"
              s.hold << "<data>#{d.value}</data>\n"
              s.less << "</item>\n"
              #s.less
          end
        end
      end
      s.less << "</collection>\n"
      s.less << "</item>\n"
    end

    s.less << "</collection>\n"
    s.less << "</item>\n"
    s.less << "</collection>\n"
    s.less << "</nest>\n"
    s << "</collection>\n"
    s << "</nest>\n"
    s << "</yads>\n"

    return s

  end

########################################################################

  def to_rdf

    other_directives = false

    s = ""

    if @admin.has_key?('char_set')
      @@xml_decl = "<?xml version=\"1.0\" encoding=\"#{@admin['char_set']}\"?>"
    end

    s.hold << "#{@@xml_decl}\n"
    s.hold << "#{@@xml_head}\n"
    s.hold << "<rdf:RDF xmlns:isa=\"#{SCHEMA_YADS}\""
    s << " xmlns:has=\"#{SCHEMA_YADS}\" xmlns:rdf=\"#{SCHEMA_RDF}\">\n"
    s.more << "<rdf:Description rdf:about=\"\">\n"
    s.hold << "<!--\n#{self.to_s.squash}-->\n"
    s.more << "<rdf:type>isa:Nest</rdf:type>\n"
    s.more << "<!-- OpenURL -->\n"
    s.hold << "<has:resource/>\n"
    s.hold << "<has:collection>\n"
    s.more << "<rdf:Bag>\n"
    s.more << "<rdf:li parseType=\"Resource\">\n"
    s.more << "<rdf:type>isa:Nest</rdf:type>\n"
    s.hold << "<!-- Profile -->\n"
    s.hold << "<has:directive>oboe:</has:directive>\n"
    s.hold << "<has:resource>#{SCHEMA_OBOE}</has:resource>\n"
    s.hold << "<has:collection>\n"
    s.more << "<rdf:Bag>\n"
    s.more << "<rdf:li parseType=\"Resource\">\n"
    s.more << "<rdf:type>isa:Item</rdf:type>\n"
    s.more << "<!-- Administration -->\n"
    s.hold << "<has:type>oboe:administration</has:type>\n"
    s.hold << "<has:collection>\n"
    s.more << "<rdf:Bag>\n"
    @admin.each do |key, val|
      s.more << "<rdf:li parseType=\"Resource\">\n"
      s.more << "<rdf:type>isa:Item</rdf:type>\n"
      s.hold << "<!-- #{key.capitalize_each} -->\n"
      s.hold << "<has:type>oboe:administration:#{key}</has:type>\n"
      s.hold << "<has:resource>data:,#{val}</has:resource>\n"
      s.less << "</rdf:li>\n"
      s.less
    end
    s.less << "</rdf:Bag>\n"
    s.less << "</has:collection>\n"
    s.less << "</rdf:li>\n"
    s.more << "<rdf:li parseType=\"Resource\">\n"
    s.more << "<rdf:type>isa:Item</rdf:type>\n"
    s.more << "<!-- Context-Object -->\n"
    s.hold << "<has:type>oboe:context</has:type>\n"
    s.hold << "<has:collection>\n"
    s.hold << "<rdf:Bag>\n"

    if @context.pointer
      s.more << "<rdf:li parseType=\"Resource\">\n"
      s.more << "<rdf:type>isa:Item</rdf:type>\n"
      s.more << "<!-- Context-Object Pointer -->\n"
      s.hold << "<has:type>oboe:#{Registry.context_pointer}</has:type>\n"
      s.hold << "<has:resource>#{Utils.entify(@context.ptr)}</has:resource>\n"
      s.less << "</rdf:li>\n"
      s.less
    end

    if @context.data
      s.more << "<rdf:li parseType=\"Resource\">\n"
      s.more << "<rdf:type>isa:Item</rdf:type>\n"
      s.more << "<!-- Context-Object Data -->\n"
      s.hold << "<has:type>oboe:#{Registry.context_data}</has:type>\n"
      s.hold << "<has:resource>#{Utils.entify(@context.data)}</has:resource>\n"
      s.less << "</rdf:li>\n"
      s.less
    end

    Entity.entity_types.each do |ent_type|
      next unless @context.entity_type?(ent_type)
      e = @context.get_entity_of_type(ent_type)
      next unless e
      if ent_type == Registry.service_type
        e.get_descriptors_id.each do |d|
         other_directives = true if d.value !~ 'oboe'
        end
        next unless other_directives
      end
      s.more << "<rdf:li parseType=\"Resource\">\n"
      s.more << "<rdf:type>isa:Item</rdf:type>\n"
      s.hold << "<!-- #{ent_type.capitalize_each} -->\n"
      s.hold << "<has:type>oboe:entity:#{ent_type}</has:type>\n"
      s.hold << "<has:collection>\n"
      s.hold << "<rdf:Bag>\n"
      Descriptor.descriptor_types.each do |dsc_type|
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              unless ent_type == Registry.service_type and d.value =~ 'oboe' and not @services.has_key?('keep_context')
              nid = Registry.get_nid(d.value) 
              id = Utils.entify(Registry.get_id(d.value))
                s.more << "<rdf:li parseType=\"Resource\">\n"
                s.more << "<rdf:type>isa:Item</rdf:type>\n"
                s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
                s.hold << "<has:type>oboe:descriptor:#{dsc_type}</has:type>\n"
                s.hold << "<has:resource>data:,#{d.value}</has:resource>\n"
                s.less << "</rdf:li>\n"
                s.less
              end
            when Descriptor::METADATA
              fmt = d.format
              s.more << "<rdf:li parseType=\"Resource\">\n"
              s.more << "<rdf:type>isa:Item</rdf:type>\n"
              s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
              s.hold << "<has:type>oboe:descriptor:#{dsc_type}</has:type>\n"
              s.hold << "<has:directive>#{fmt}</has:directive>\n"
              s.hold << "<has:collection>\n"
              s << "<rdf:Bag>\n"
              d.value.each do |value|
                key, val = value.split(/=/)
                val = Utils.entify(val)
                s.more << "<rdf:li parseType=\"Resource\">\n"
                s.more << "<rdf:type>isa:Item</rdf:type>\n"
                s.hold << "<has:type>#{key}</has:type>\n"
                s.hold << "<has:resource>data:,#{val}</has:resource>\n"
                s << "</rdf:li>\n"
                s.less
              end
              s.less << "</rdf:Bag>\n"
              s.less << "</has:collection>\n"
              s.less << "</rdf:li>\n"
              s.less
            when Descriptor::METADATA_PTR
              nid = Registry.get_nid(d.format) 
              fmt = Registry.get_id(d.format)
              val = Utils.entify(d.value[0])
              s.more << "<rdf:li parseType=\"Resource\">\n"
              s.more << "<rdf:type>isa:Item</rdf:type>\n"
              s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
              s.hold << "<has:type>oboe:descriptor:#{dsc_type}</has:type>\n"
              s.hold << "<has:directive>#{fmt}</has:directive>\n"
              s.hold << "<has:resource>data:,#{d.value}</has:resource>\n"
              s.less << "</rdf:li>\n"
              s.less
            when Descriptor::PRIVATE_DATA
              id = Utils.entify(d.value)
              s.more << "<rdf:li parseType=\"Resource\">\n"
              s.more << "<rdf:type>isa:Item</rdf:type>\n"
              s.more << "<!-- #{dsc_type.capitalize_each} -->\n"
              s.hold << "<has:type>oboe:descriptor:#{dsc_type}</has:type>\n"
              s.hold << "<has:resource>data:,#{d.value}</has:resource>\n"
              s.less << "</rdf:li>\n"
              s.less
          end
        end
      end
      s.less << "</rdf:Bag>\n"
      s.less << "</has:collection>\n"
      s.less << "</rdf:li>\n"
    end

    s.less << "</rdf:Bag>\n"
    s.less << "</has:collection>\n"
    s.less << "</rdf:li>\n"
    s.less << "</rdf:Bag>\n"
    s.less << "</has:collection>\n"
    s.less << "</rdf:li>\n"
    s.less << "</rdf:Bag>\n"
    s.less << "</has:collection>\n"
    s.less << "</rdf:Description>\n"
    s.less << "</rdf:RDF>\n"

    return s

  end

########################################################################
end

end

########################################################################
__END__
