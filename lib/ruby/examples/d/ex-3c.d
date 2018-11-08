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
#   ref_id = ori:pmid:11823195
# 
#   # Referrer
#   rfr_id = ori:dbid:ncbi.nlm.nih.gov:pubmed
# 
#   # Referring-Entity
#   rfe_id = ori:pmid:11823195
# 
#   # Requester
#   req_id = uri:mailto:joe.doe@greatjob.org
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
                  resource => <data:,ori:pmid:11823195>
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
                  resource => <data:,ori:dbid:ncbi.nlm.nih.gov:pubmed>
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
                  resource => <data:,ori:pmid:11823195>
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
                  resource => <data:,uri:mailto:joe.doe@greatjob.org>
                )
              }
            )
          }
        )
      }
    :)
  }
:)
