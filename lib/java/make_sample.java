import java.io.*;
import java.lang.*;
import oboe.lib.*;

/*
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
*/

ContextObject ctx = new ContextObject();

// metadata = [ "aulast=caplan", "aufirst=priscilla" ]
// metadata_doc = "uri:http://www.somwhere.com/path"

Entity ref = Entity.referent()
             .addId("ori:doi:10.1045%2Fjuly99-caplan")
             .addPrivateData("jungle harry")
	     .addMetadata(Registry::OPENURL_JARTICLE)
	     .addMetadataPtr(Registry::OPENURL_JARTICLE);
	     // .add_metadata(Registry::OPENURL_JARTICLE, metadata)
	     // .add_metadata_ptr(Registry::OPENURL_JARTICLE, metadata_doc)

Entity rfr = Entity.referrer()
             .add_id("ori:dbid:dlib.org:D-Lib Magazine");

Entity rfe = Entity.referring_entity()
             .add_id("ori:doi:10.1045/march2001-vandesompel");

ctx.add_entity(ref)
   .add_entity(rfr)
   .add_entity(rfe);

// print ctx.inspect
