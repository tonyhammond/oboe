#

module Oboe

  class Samples

  # Example 1
  @@qs0 =<<-EOT
    & ref_id = openurl:doi:10.1045%2Fjuly99-caplan
    & ref_valfmt = article
    & aulast = caplan
    & aufirst = priscilla
    & issn = 10829873
    & volume = 5
    & issue = 7%2F8
    & atitle = Reference%20Linking%20for%20Journal%20Articles
    & rfr_id = openurl:dbid:dlib.org:D-Lib Magazine
    & rfe_id = openurl:doi:10.1045/march2001-vandesompel
    & adm_ver = Z39.00-00
  EOT

  # Example 2
  @@qs1 =<<-EOT
    & ref_valfmt = book
    & aulast = Dodds
    & aufirst = David
    & title = Professional%20XML%20Meta%20Data
    & date = 2001
    & ref_id = openurl:isbn:1861004516
    & req_id = local:104-0011434-4639158
    & rfr_id = openurl:dns:amazon.com
    & rfe_id = uri:http%3A%2F%2Fwww.amazon.com%2Fexec%2Fobidos%2FASIN%2F1861004516
    & srv_id = local:addToCart
    & adm_tim = 2002-03-20T13%3A05%3A54Z
    & adm_ver = Z39.00-00
  EOT

  # Example 3
  @@qs2 =<<-EOT
    & ref_valfmt = jarticle
    & aulast = Sturino
    & auinit = JM
    & stitle = Appl%20Environ%20Microbiol
    & volume = 68
    & issue = 2
    & date = 2002-02
    & adm_ver = Z39.00-00
    & ref_ptr = uri:http%3A%2F%2Fwww.ncbi.nlm.nih.gov%2Fentrez%2Futils%2Fpmfetch.fcgi?db=PubMed%26id=11823195%26report=xml%26mode=text
    & rfr_id = openurl:dbid:ncbi.nlm.nih.gov:pubmed
    & req_id = uri:mailto:joe.doe@greatjob.org
    & rfe_id = openurl:pmid:11823195
  EOT

  # Example 4
  @@qs3 =<<-EOT
    & ref_id  = openurl:doi%3A10.1126%2Fscience.275.5304.1320
    & ref_id  = openurl:pmid%3A9036860
    & rfr_id  = openurl:dbid%3Acrossref.org%3Aidealibrary.com
    & rfe_id  = openurl:doi%3A10.1006%2Fmthe.2000.0239
    & rfe_id  = openurl:issn%3A1525-0016
    & adm_ver = Z39.00-00
    & adm_tim = 2002-02-20T14%3A20%3A03Z
    & ctx_pid = cr_setVer ~ 01 !
                cr_key ~ cx1Dk0f1ud58jlKfdsAifhe23swkHG^s !
                cr_keyVer ~ 01 !
                cr_datTim ~ 20020220142003 !
                cr_src ~ idealibrary.com !
                cr_srcDOI ~ 10.1006%2Fmthe.2000.0239 !
                cr_rtnURL ~ http%3A%2F%2Fwww.idealibrary.com%2Flinks%2Fdoi%2F10.1006%2Fmthe.2000.0239%2Fref !
                cr_rtnTxt ~ Click%20Here !
                cr_srvTyp ~ html !
                cr_workId ~ Molecular%20Therapy !
                cr_pub ~ Academic%20Press !
  EOT

  attr_reader :querystring

  def initialize

    @querystring = eval eval "'@@qs' + rand(4).to_s"
    @querystring.gsub!(/\s+/, "")

  end

  end

end

########################################################################
