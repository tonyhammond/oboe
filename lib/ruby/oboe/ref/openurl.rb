#

module Oboe

  class OpenURL

  def initialize(*args)

    @hArgs = {}
    @hArgs = args[0]

    @admin = nil
    @context = nil
    @resolver = nil

    # Is this in OpenURL v1.0 format?
    if @hArgs.has_key?(Registry.key_version)
      @version = "1.0"
    else
      # Assume this is in OpenURL 0.1 format
      # and convert to OpenURL 1.0 format
      self.upgrade_version
    end

    if @hArgs.has_key?(Registry.key_context_pointer)
      Registry.get_context
    end

    if @hArgs.has_key?(Registry.key_format)
      Registry.set_format(@hArgs[Registry.key_format])
    end

    # if not self.is_valid?
    # end

    @context = self.get_context

    return self

  end

  def get_context

    hEntities = Hash.new(0)

    # Run though keys and get descriptor counts for each entity
    Entity.entity_types().each do |ent_type|
      @hArgs.each_key do |key|
        if Registry.keys().include?(key)
          ent, dsc = key.split(/_/)
          next unless Registry.get_entity_type(ent) == ent_type
          hEntities[ent_type] += 1
        end
      end
    end

    ctx = ContextObject.new
    Entity.entity_types().each do |ent_type|
      next unless hEntities[ent_type] > 0
      e = Entity.new(ent_type)
      Descriptor.descriptor_types().each do |dsc_type|
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
                  Registry.fmt_keys().each do |fmt_key|
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

    if not @hArgs.has_key?(Registry.key_version)
      return false
    end

    return true

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
      @hArgs[Registry.key_version] = "Z39.00-00"
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
    @hArgs.sort.each do |key, vals|
      vals.each { |val|
      s << "*" if Registry.has_key?(key)
      s << "+" if Registry.has_fmt_key?(key)
      s << "  #{key} = #{val}\n" unless key.empty? }
    end
    return s

  end

  alias_method :to_xml, :to_s

########################################################################

  @@registry = 'http://lib-www.lanl.gov/~herbertv/niso'
  @@xsi = 'http://www.w3.org/2001/XMLSchema-instance'

  @@xml_decl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

  @@ctxc_head =<<-EOT
<!--
  Oboe/Ruby - OpenURL Based Open Environment

  Author: tony_hammond@harcourt.com
  Date:   June 22, 2002
-->
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

=begin
    if @hArgs.has_key?('adm_tim')
      @@ctxc_head.sub!(/\>\Z/, " timestamp=\"#{@hArgs['adm_tim']}\"\>")
      @@ctx_head.sub! (/\>\Z/, " timestamp=\"#{@hArgs['adm_tim']}\"\>")
    end
    @@ctxc_head.sub!(/(version="")/, "version=\"#{@hArgs['adm_ver']}\"")
=end
 
    s << "#{@@xml_decl}\n"
    s << "#{@@ctxc_head}\n"
    s << "  #{@@ctx_head}\n"
    s << "  <!--\n  OpenURL v.1.0 Parameters"
    s << " (converted from OpenURL v.0.1)" if @version == '0.1'
    s << ":\n\n"
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
