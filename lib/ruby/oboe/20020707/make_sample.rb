require 'registry'
require 'context'; include Oboe

=begin
  # Example 1
  @@qs0 =<<-EOT
    & ref_id = ori:doi:10.1045%2Fjuly99-caplan
    & ref_valfmt = jarticle
    & aulast = caplan
    & aufirst = priscilla
    & issn = 10829873
    & volume = 5
    & issue = 7%2F8
    & atitle = Reference%20Linking%20for%20Journal%20Articles
    & rfr_id = ori:dbid:dlib.org:D-Lib Magazine
    & rfe_id = ori:doi:10.1045/march2001-vandesompel
    & adm_ver = Z39.00-00
  EOT
=end

ctx = ContextObject.new

metadata = [ "aulast=caplan", "aufirst=priscilla" ]
metadata_doc = "uri:http://www.somwhere.com/path"

ref = Entity.referent \
        .add_id("ori:doi:10.1045%2Fjuly99-caplan") \
        .add_private_data("jungle harry") \
	.add_metadata(Registry::OPENURL_JARTICLE) \
	.add_metadata_ptr(Registry::OPENURL_JARTICLE)
	#.add_metadata(Registry::OPENURL_JARTICLE, metadata) \
	#.add_metadata_ptr(Registry::OPENURL_JARTICLE, metadata_doc)

rfr = Entity.referrer \
        .add_id("ori:dbid:dlib.org:D-Lib Magazine")

rfe = Entity.referring_entity \
        .add_id("ori:doi:10.1045/march2001-vandesompel")

ctx.add_entity(ref) \
   .add_entity(rfr) \
   .add_entity(rfe)

print ctx.inspect
