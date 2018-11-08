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
#   ref_id = _ri:ASIN-1861004516
# 
#   # Referrer
#   rfr_id = _ri:booksales
# 
#   # Requester
#   req_id = _ri:104-0011434-4639158
# 
#   # Service-Type
#   srv_id = _ri:addToCart
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
                  resource => <data:,_ri:ASIN-1861004516>
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
                  resource => <data:,_ri:booksales>
                )
              }
            )
            (
              #  Requester 
              type => "oboe:entity:requester"
              {
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,_ri:104-0011434-4639158>
                )
              }
            )
            (
              #  Service-Type 
              type => "oboe:entity:service-type"
              {
                (
                  #  Identifier 
                  type => "oboe:descriptor:identifier"
                  resource => <data:,_ri:addToCart>
                )
              }
            )
          }
        )
      }
    :)
  }
:)
