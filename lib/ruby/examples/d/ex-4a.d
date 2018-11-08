# 
#   Oboe/Ruby - OpenURL Based Open Environment
# 
#   Author: Tony Hammond <t.hammond@elsevier.com>
#   Date:   June 22, 2002
# 
# 
# # OpenURL v.1.0 Parameters:
# 
# # Administration
# 
#   adm_ver = Z39.00-00
# 
# # Context-Object
# 
#   ctx_dat = cr_setVer = 01 & cr_key = cx1Dk0f1ud58jlKfdsAifhe23swkHG^s & cr_keyVer = 01 & cr_datTim = 20020220142003 & cr_src = idealibrary.com & cr_srcDOI = 10.1006/mthe.2000.0239 & cr_rtnURL = http://www.idealibrary.com/links/doi/10.1006/mthe.2000.0239/ref & cr_rtnTxt = Click Here & cr_srvTyp = html & cr_workId = Molecular Therapy & cr_pub = Academic Press
# 
#   # Referent
#   ref_id = ori:doi:10.1126/science.275.5304.1320
#   ref_id = ori:pmid:9036860
# 
#   # Referrer
#   rfr_id = ori:dbid:elsevier.com:ScienceDirect
# 
#   # Referring-Entity
#   rfe_id = ori:doi:10.1006/mthe.2000.0239
#   rfe_id = uri:urn:ISSN:1525-0016
# 
(:
  #  OpenURL 
  resource => <>
  {
    (:
      #  Profile 
      directive => "oboe:"
      resource => <http://www2.elsevier.co.uk/~tony/oboe/oboe.rdf>
      {
        (
          #  Administration 
          type => "oboe:administration"
          {
            (
              #  Version 
              type => "oboe:administration:version"
              resource => <data:,Z39.00-00>
            )
          }
        )
        (
          #  Context-Object 
          type => "oboe:context"
          {
            (
              #  Context-Object Private Data 
              type => "oboe:private-data"
              resource => <cr_setVer = 01 & cr_key = cx1Dk0f1ud58jlKfdsAifhe23swkHG^s & cr_keyVer = 01 & cr_datTim = 20020220142003 & cr_src = idealibrary.com & cr_srcDOI = 10.1006/mthe.2000.0239 & cr_rtnURL = http://www.idealibrary.com/links/doi/10.1006/mthe.2000.0239/ref & cr_rtnTxt = Click Here & cr_srvTyp = html & cr_workId = Molecular Therapy & cr_pub = Academic Press>
            )
            (
              #  Referent 
              type => "oboe:entity:referent"
              {
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,ori:doi:10.1126/science.275.5304.1320>
                )
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,ori:pmid:9036860>
                )
              }
            )
            (
              #  Referrer 
              type => "oboe:entity:referrer"
              {
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,ori:dbid:elsevier.com:ScienceDirect>
                )
              }
            )
            (
              #  Referring-Entity 
              type => "oboe:entity:referring-entity"
              {
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,ori:doi:10.1006/mthe.2000.0239>
                )
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,uri:urn:ISSN:1525-0016>
                )
              }
            )
          }
        )
      }
    :)
  }
:)
