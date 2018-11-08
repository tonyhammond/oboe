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
#   adm_ver = 1
# 
# # Context-Object
# 
#   # Referent
#   ref_val = 
#   ref_val_fmt = ori:schema:book
# 
#   # Referring-entity
#   rfe_id = uri:urn:ISBN:0262531283
# 
(:
  #  OpenURL 
  resource => <>
  {
    (:
      #  Profile 
      directive => "oboe:"
      resource => <http://www2.elsevier.co.uk/~tony/oboe.rdf>
      {
        (
          #  Administration 
          type => "oboe:administration"
          {
            (
              #  Version 
              type => "oboe:version"
              resource => <data:,1>
            )
          }
        )
        (
          #  Context-Object 
          type => "oboe:context-object"
          {
            (
              #  Referent 
              type => "oboe:referent"
              {
                (
                  #  Metadata-by-val 
                  type => "oboe:metadata-by-val"
                  {
                  }
                )
              }
            )
            (
              #  Referring-entity 
              type => "oboe:referring-entity"
              {
                (
                  #  Identifier 
                  type => "oboe:identifier"
                  resource => <data:,uri:urn:ISBN:0262531283>
                )
              }
            )
          }
        )
      }
    :)
  }
:)
