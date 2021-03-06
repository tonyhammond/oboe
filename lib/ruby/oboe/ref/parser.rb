#

module Oboe

  class OpenURL

########################################################################

  @@registry = 'http://lib-www.lanl.gov/~herbertv/niso'
  @@xsi = 'http://www.w3.org/2001/XMLSchema-instance'

########################################################################

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

########################################################################

  # Entity name prefix to XML element name table
  @@hEnts = {
    "ctx" => "context-object",
    "ref" => "referent",
    "req" => "requester",
    "res" => "resolver",
    "rfe" => "referring-entity",
    "rfr" => "referrer",
    "srv" => "service-type",
  }

  # Entity name prefix counts
  @@hEntN = {
    "ctx" => 0,
    "ref" => 0, "req" => 0, "res" => 0,
    "rfe" => 0, "rfr" => 0, "srv" => 0,
  }

  # Processing order for entities
  @@aEnts = [ 'ref', 'rfr', 'rfe', 'req', 'res', 'srv', 'ctx' ]

  # Descriptor name suffix to XML element name table
  @@hDesc = {
    "id" => "identifier",
    "valfmt" => "metadata",
    "reffmt" => "metadata-by-ref",
    "ptr" => "metadata-by-ref",
    "pid" => "private-data",
  }

  # Processing order for descriptors
  @@aDesc = [ 'id', 'valfmt', 'reffmt', 'ptr', 'pid' ]

  # Namespace identifiers
  @@hNIDs = {
    "_ri" => 1,
    "ori" => 1,
    "uri" => 1,
  }

  # Recognized OpenURL 1.0 keywords
  @@hKeys = {
    # Admin
    "adm_set" => 1,	# character set
    "adm_tim" => 1,	# timestamp
    "adm_ver" => 1,	# version
    # ContextObject
    "ctx_ptr" => 1,	# by-reference network location
    "ctx_pid" => 1,	# private data descriptor
    # Referent
    "ref_id" => 1,	# identifier descriptor
    "ref_valfmt" => 1,	# by-value metadata descriptor
    "ref_reffmt" => 1,	# by-reference metadata descriptor
    "ref_ptr" => 1,	# by-reference network location
    "ref_pid" => 1,	# private data descriptor
    # Requester
    "req_id" => 1,	# identifier descriptor
    "req_reffmt" => 1,	# by-reference metadata descriptor
    "req_ptr" => 1,	# by-reference network location
    "req_pid" => 1,	# private data descriptor
    # Resolver
    "res_id" => 1,	# identifier descriptor
    "res_reffmt" => 1,	# by-reference metadata descriptor
    "res_ptr" => 1,	# by-reference network location
    "res_pid" => 1,	# private data descriptor
    # Referring-Entity
    "rfe_id" => 1,	# identifier descriptor
    "rfe_reffmt" => 1,	# by-reference metadata descriptor
    "rfe_ptr" => 1,	# by-reference network location
    "rfe_pid" => 1,	# private data descriptor
    # Referrer
    "rfr_id" => 1,	# identifier descriptor
    "rfr_reffmt" => 1,	# by-reference metadata descriptor
    "rfr_ptr" => 1,	# by-reference network location
    "rfr_pid" => 1,	# private data descriptor
    # Service-Type
    "srv_id" => 1,	# identifier descriptor
    "srv_reffmt" => 1,	# by-reference metadata descriptor
    "srv_ptr" => 1,	# by-reference network location
    "srv_pid" => 1,	# private data descriptor
  }

########################################################################

  # Namespace identifiers fior OpenURL 0.1
  @@hNIDs0_1 = {
    "bibcode" => 1,
    "doi" => 1,
    "oai" => 1,
    "pmid" => 1,
  }

  # Recognized OpenURL 0.1 keywords
  # We set a positive value on the by-value metadata meta-tags only
  # to allow a simple means of detection
  @@hKeys0_1 = {
    # Origin-Description
    "sid" => 0,
    # Global-Identifer-Zone
    "id" => 0,
    # Local-Identifer-Zone
    "pid" => 0,
    # Object-Metadata-Zone Meta-Tags
    "genre" => 1,
    "aulast" => 1,
    "aufirst" => 1,
    "auinit" => 1,
    "auinit1" => 1,
    "auinitm" => 1,
    "coden" => 1,
    "issn" => 1,
    "eissn" => 1,
    "isbn" => 1,
    "title" => 1,
    "stitle" => 1,
    "atitle" => 1,
    "volume" => 1,
    "part" => 1,
    "issue" => 1,
    "spage" => 1,
    "epage" => 1,
    "pages" => 1,
    "artnum" => 1,
    "sici" => 1,
    "bici" => 1,
    "ssn" => 1,
    "quarter" => 1,
    "date" => 1,
  }
 
########################################################################

  # Test format - "jarticle"
  @@hType = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  }

  # Type format - "book"
  @@hType_book = {
    "au" => 1, "aufirst" => 1, "aulast" => 1,
    "btitle" => 1, "date" => 1, "isbn" => 1,
    "org" => 1, "place" => 1, "pub" => 1, "tpages" => 1,
  }

  # Type format - "book_component"
  @@hType_book_component = {
    "atitle" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "btitle" => 1, "bici" => 1, "date" => 1, "isbn" => 1,
    "org" => 1, "pages" => 1, "spage" => 1, "title" => 1,
  }

  # Type format - "conf_proc"
  @@hType_conf_proc = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  }

  # Type format - "conf_paper"
  @@hType_conf_paper = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  }

  # Type format - "dissertation"
  @@hType_dissertation = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  }

  # Type format - "journal"
  @@hType_journal = {
    "coden" => 1, "eissn" => 1, "issn" => 1, "jtitle" => 1,
    "stitle" => 1, "title" => 1,
  }

  # Type format - "jissue"
  @@hType_jissue = {
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "issn" => 1, "issue" => 1, "jtitle" => 1, "part" => 1,
    "sici" => 1, "stitle" => 1, "title" => 1, "volume" => 1,
  }

  # Type format - "jarticle"
  @@hType_jarticle = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  }

  # Type format - "patent"
  @@hType_patent = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  }

  # Type format - "tech_report"
  @@hType_tech_report = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  }

########################################################################

  def initialize(*args)

    @hArgs = {}
    @hArgs = args[0]

    # Is this in OpenURL v1.0 format?
    if @hArgs.has_key?('adm_ver')
      @ver = "1.0"
    else
      # assume this is in OpenURL 0.1 format
      # and convert to OpenURL 1.0 format
      nKeys = 0; byVal = false
      @hArgs.each do |key, vals|
        if @@hKeys0_1.has_key?(key)
          nKeys += 1
          byVal = true if @@hKeys0_1[key] > 0 
        end
      end
      if nKeys > 0
        @ver = "0.1"
        @hArgs['adm_ver'] = "Z39.00-00"
        @hArgs.each do |key, vals|
          _vals = []
          if key == 'id'
            vals.each do |val|
              nam = "#{val}"
              nam.sub!(/(\w+):(.*)/, '\1')
              val.sub!(/(\w+):(.*)/, '\2')
              if @@hNIDs0_1.has_key?(nam)
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
    end

    return self

  end

  def to_s

    s = ""

    @hArgs.sort.each do |key, vals|
      vals.each { |val| s << "  #{key} = #{val}\n" unless key.empty? }
    end

    return s

  end

  def to_xml

    s = ""

    # Run though keys and get descriptor counts for each entity
    @@aEnts.each do |_ent|
      @hArgs.each_key do |key|
        if @@hKeys.has_key?(key)
          ent, desc = key.split(/_/)
          next unless ent == _ent;
          @@hEntN[ent] += 1
        end
      end
    end

    if @hArgs.has_key?('adm_tim')
      @@ctxc_head.sub!(/\>\Z/, " timestamp=\"#{@hArgs['adm_tim']}\"\>")
      @@ctx_head.sub! (/\>\Z/, " timestamp=\"#{@hArgs['adm_tim']}\"\>")
    end
    @@ctxc_head.sub!(/(version="")/, "version=\"#{@hArgs['adm_ver']}\"")
  
    s << "#{@@xml_decl}\n"
    s << "#{@@ctxc_head}\n"
    s << "  #{@@ctx_head}\n"
    s << "  <!--\n  OpenURL v.1.0 Parameters"
    s << " (converted from OpenURL v.0.1)" if @ver == '0.1'
    s << ":\n\n"
    @hArgs.sort.each { |key, vals|
      vals.each { |val| s << "  #{key} = #{val}\n" unless key.empty? } }
    s << "-->\n"
    # Output entities in XML schema sequence order
    @@aEnts.each do |_ent|
      _ent_new = true
      # Output descriptors in XML schema sequence order
      @@aDesc.each do |_desc|
        # Now run though the arguments
        @hArgs.each do |key, vals|
          # And output only recognized OpenURL keywords
          if @@hKeys.has_key?(key)
            ent, desc = key.split(/_/)
            next unless ent == _ent and desc == _desc
            if _ent_new
              s << "    <#{@@hEnts[ent]}>\n" unless ent == 'ctx'
            end
            _ent_new = false; @@hEntN[ent] -= 1
            vals.each do |val|
              val.gsub!(/&/, '&amp;')
              val.gsub!(/"/, '&quot;')
              val.gsub!(/'/, '&apos;')
              if desc == 'id' or desc == 'reffmt' or desc == 'ptr'
                nam = "#{val}"
                nam.sub!(/(\w+):(.*)/, '\1')
                val.sub!(/(\w+):(.*)/, '\2')
                if @@hNIDs.has_key?(nam)
                  s << "      <#{@@hDesc[desc]} type=\"#{nam}\">"
                  s << "#{val}</#{@@hDesc[desc]}>\n"
                end
              elsif desc == 'valfmt'
                s << "      <#{@@hDesc[desc]}>\n"
                s << "        <ref:#{val} "
                s << "xmlns:ref=\"#{@@registry}/#{val}\"\n"
                s << "            xmlns:xsi=\"#{@@xsi}\"\n"
                s << "            xsi:schemaLocation=\""
                s << "#{@@registry}/#{val}\">\n"
                @hArgs.each_key do |key_fmt|
                  if @@hType.has_key?(key_fmt)
                    s << "          <ref:#{key_fmt}>"
                    s << "#{@hArgs[key_fmt]}</ref:#{key_fmt}>\n"
                  end
                end
                s << "        </ref:#{val}>\n"
                s << "      </#{@@hDesc[desc]}>\n"
              else
                s << "      <#{@@hDesc[desc]}>#{val}</#{@@hDesc[desc]}>\n"
              end
            end
            if @@hEntN[ent] == 0
              s << "    </#{@@hEnts[ent]}>\n" unless ent == 'ctx'
            end
          end
        end
      end
    end
    s << "  #{@@ctx_tail}\n"
    s << "#{@@ctxc_tail}\n"

    return s

  end

  end

########################################################################

  def _get_html(uri)

    uri =~ /^http:\/\/(.*?)(:\d+)*(\/.*)*$/
    server, port, path = $1, $2, $3

    s = Net::HTTP.new(server, port)
    resp, data = s.get(path, nil)
    return data if resp.message == "OK"
    
  end

end

########################################################################
