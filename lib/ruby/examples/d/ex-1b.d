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
#   # Referent
#   ref_id = ori:doi:10.1045/july99-caplan
#   ref_val = 
#   ref_val_fmt = ori:schema:jarticle
#   issn = 10829873
#   issue = 7/8
#   volume = 5
#   aulast = caplan
#   aufirst = priscilla
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
              #  Referent 
              type => "oboe:entity:referent"
              {
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,ori:doi:10.1045/july99-caplan>
                )
                (:
                  #  Metadata-By-Val 
                  type => "oboe:descriptor:metadata-by-val"
                  resource => <data:,ori:schema:jarticle>
                  {
                    (
                      type => "issn"
                      resource => <data:,10829873>
                    )
                    (
                      type => "issue"
                      resource => <data:,7/8>
                    )
                    (
                      type => "volume"
                      resource => <data:,5>
                    )
                    (
                      type => "aulast"
                      resource => <data:,caplan>
                    )
                    (
                      type => "aufirst"
                      resource => <data:,priscilla>
                    )
                  }
                :)
              }
            )
          }
        )
      }
    :)
  }
:)
