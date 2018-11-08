
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
      s << "    <#{ent_type}>\n"
      Descriptor.descriptor_types().each do |dsc_type|
        e.get_descriptors_of_type(dsc_type).each do |d|
          case dsc_type
            when Descriptor::ID
              nid = Registry.get_nid(d.val) 
              id = Utils.entify(Registry.get_id(d.val))
              s << "      <#{dsc_type} type=\"#{nid}\">"
              s << "#{id}</#{dsc_type}>\n"
            when Descriptor::METADATA
            when Descriptor::METADATA_PTR
            when Descriptor::PRIVATE_DATA
          end
        end
      end
      s << "    <#{ent_type}>\n"
    end
    s << "  #{@@ctx_tail}\n"
    s << "#{@@ctxc_tail}\n"

    return s

  end

########################################################################
