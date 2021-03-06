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
# 
#   # Referrer
#   rfr_id = ori:dbid:dlib.org:D-Lib Magazine
# 
#   # Referring-Entity
#   rfe_id = ori:doi:10.1045/march2001-vandesompel
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
              }
            )
            (
              #  Referrer 
              type => "oboe:entity:referrer"
              {
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,ori:dbid:dlib.org:D-Lib%20Magazine>
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
                  resource => <data:,ori:doi:10.1045/march2001-vandesompel>
                )
              }
            )
          }
        )
      }
    :)
  }
:)
