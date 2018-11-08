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
#   ref_val = 
#   ref_val_fmt = ori:schema:jarticle
#   date = 2002-02
#   stitle = Appl Environ Microbiol
#   issue = 2
#   volume = 68
#   aulast = Sturino
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
                (:
                  #  Metadata-By-Val 
                  type => "oboe:descriptor:metadata-by-val"
                  resource => <data:,ori:schema:jarticle>
                  {
                    (
                      type => "date"
                      resource => <data:,2002-02>
                    )
                    (
                      type => "stitle"
                      resource => <data:,Appl%20Environ%20Microbiol>
                    )
                    (
                      type => "issue"
                      resource => <data:,2>
                    )
                    (
                      type => "volume"
                      resource => <data:,68>
                    )
                    (
                      type => "aulast"
                      resource => <data:,Sturino>
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
