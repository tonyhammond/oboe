# 
#   Oboe/Ruby - OpenURL Based Open Environment
# 
#   Author: Tony Hammond <t.hammond@elsevier.com>
#   Date:   June 22, 2002
# 
# 
# #  OpenURL v.1.0 Parameters:
# 
# # Administration
# 
#   adm_ver = Z39.00-00
# 
# # ContextObject
# 
#   ref_valfmt = jarticle
#   date = 2002-02
#   stitle = Appl Environ Microbiol
#   issue = 2
#   volume = 68
#   aulast = Sturino
#   rfr_id = ori:dbid:ncbi.nlm.nih.gov:pubmed
#   rfe_id = ori:pmid:11823195
#   req_id = uri:mailto:joe.doe@greatjob.org
# 
(:
  #  OpenURL 
  resource => <>
  {
    (:
      #  Profile 
      directive => "oboe:"
      {
        (
          #  Administration 
          type => "oboe:administration"
          {
            (
              #  Version 
              type => "oboe:version"
              resource => <data:,Z39.00-00>
            )
          }
        )
        (
          #  ContextObject 
          type => "oboe:context-object"
          {
            (
              #  Referent 
              type => "oboe:referent"
              {
                (
                  #  Metadata 
                  type => "oboe:metadata"
                  {
                    (
                      type => "oboe:schema:jarticle:date"
                      resource => <data:,2002-02>
                    )
                    (
                      type => "oboe:schema:jarticle:stitle"
                      resource => <data:,Appl%20Environ%20Microbiol>
                    )
                    (
                      type => "oboe:schema:jarticle:issue"
                      resource => <data:,2>
                    )
                    (
                      type => "oboe:schema:jarticle:volume"
                      resource => <data:,68>
                    )
                    (
                      type => "oboe:schema:jarticle:aulast"
                      resource => <data:,Sturino>
                    )
                  }
                )
              }
            )
            (
              #  Referrer 
              type => "oboe:referrer"
              {
                (
                  #  Identifier 
                  type => "oboe:identifier"
                  resource => <data:,ori:dbid:ncbi.nlm.nih.gov:pubmed>
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
                  resource => <data:,ori:pmid:11823195>
                )
              }
            )
            (
              #  Requester 
              type => "oboe:requester"
              {
                (
                  #  Identifier 
                  type => "oboe:identifier"
                  resource => <data:,uri:mailto:joe.doe@greatjob.org>
                )
              }
            )
            (
              #  Service-type 
              type => "oboe:service-type"
              {
                (
                  #  Identifier 
                  type => "oboe:identifier"
                  resource => <data:,_ri:oboe:no_strict>
                )
              }
            )
          }
        )
      }
      resource => <http://www2.elsevier.co.uk/~tony/oboe.rdf>
    :)
  }
:)
