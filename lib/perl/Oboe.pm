########################################################################
#
# Package Oboe
#
########################################################################

package Oboe::OpenURL;


########################################################################

  $registry = 'http://lib-www.lanl.gov/~herbertv/niso';
  $xsi = 'http://www.w3.org/2001/XMLSchema-instance';

########################################################################

  $ctxc_head =<<"EOT";
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Oboe/Perl - OpenURL Based Open Environment

  This OpenURL parser translates a name/value encoding into
  an equivalent XML encoding. Note that name/value encodings
  may be both unordered and fragmented within their carrier
  URLs as regards the canonical XML representation.

  Author: tony_hammond\@harcourt.com
  Date:   June 22, 2002
-->
<context-container xmlns="http://www.niso.org/context-object"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.niso.org/context-object
    http://lib-www.lanl.gov/~herbertv/niso/context-container.xsd"
    version="">
EOT

  $ctxc_tail = "</context-container>";

  $ctx_head = "<context-object>";
  $ctx_tail = "</context-object>";

########################################################################

  # Entity name prefix to XML element name table
  $hEnts = {
    "ctx" => "context-object",
    "ref" => "referent",
    "req" => "requester",
    "res" => "resolver",
    "rfe" => "referring-entity",
    "rfr" => "referrer",
    "srv" => "service-type",
  };

  # Entity name prefix counts
  $hEntN = {
    "ctx" => 0,
    "ref" => 0, "req" => 0, "res" => 0,
    "rfe" => 0, "rfr" => 0, "srv" => 0,
  };

  # Processing order for entities
  $aEnts = [ 'ref', 'rfr', 'rfe', 'req', 'res', 'srv', 'ctx' ];

  # Descriptor name suffix to XML element name table
  $hDesc = {
    "id" => "identifier",
    "valfmt" => "metadata",
    "reffmt" => "metadata-by-ref",
    "ptr" => "metadata-by-ref",
    "pid" => "private-data",
  };

  # Processing order for descriptors
  $aDesc = [ 'id', 'valfmt', 'reffmt', 'ptr', 'pid' ];

  # Namespace identifiers
  $hNIDs = {
    "local" => 1,
    "openurl" => 1,
    "uri" => 1,
  };

  # Recognized OpenURL 1.0 keywords
  $hKeys = {
    # Admin
    "adm_set" => 1,	# character set
    "adm_tim" => 1,	# timestamp
    "adm_ver" => 1,	# version
    # ContextObject
    "ctx_ptr" => 1,	# by-reference network location
    "ctx_pid" => 1,	# private data descriptor
    # Referent
    "ref_id" => 1,	# identifier descriptor
    "ref_valfmt" => 1,	# by-value metadata descriptor
    "ref_reffmt" => 1,	# by-reference metadata descriptor
    "ref_ptr" => 1,	# by-reference network location
    "ref_pid" => 1,	# private data descriptor
    # Requester
    "req_id" => 1,	# identifier descriptor
    "req_reffmt" => 1,	# by-reference metadata descriptor
    "req_ptr" => 1,	# by-reference network location
    "req_pid" => 1,	# private data descriptor
    # Resolver
    "res_id" => 1,	# identifier descriptor
    "res_reffmt" => 1,	# by-reference metadata descriptor
    "res_ptr" => 1,	# by-reference network location
    "res_pid" => 1,	# private data descriptor
    # Referring-Entity
    "rfe_id" => 1,	# identifier descriptor
    "rfe_reffmt" => 1,	# by-reference metadata descriptor
    "rfe_ptr" => 1,	# by-reference network location
    "rfe_pid" => 1,	# private data descriptor
    # Referrer
    "rfr_id" => 1,	# identifier descriptor
    "rfr_reffmt" => 1,	# by-reference metadata descriptor
    "rfr_ptr" => 1,	# by-reference network location
    "rfr_pid" => 1,	# private data descriptor
    # Service-Type
    "srv_id" => 1,	# identifier descriptor
    "srv_reffmt" => 1,	# by-reference metadata descriptor
    "srv_ptr" => 1,	# by-reference network location
    "srv_pid" => 1,	# private data descriptor
  };

########################################################################

  # Namespace identifiers fior OpenURL 0.1
  $hNIDs0_1 = {
    "bibcode" => 1,
    "doi" => 1,
    "oai" => 1,
    "pmid" => 1,
  };

  # Recognized OpenURL 0.1 keywords
  # We set a positive value on the by-value metadata meta-tags only
  # to allow a simple means of detection
  $hKeys0_1 = {
    # Origin-Description
    "sid" => 0,
    # Global-Identifer-Zone
    "id" => 0,
    # Local-Identifer-Zone
    "pid" => 0,
    # Object-Metadata-Zone Meta-Tags
    "genre" => 1,
    "aulast" => 1,
    "aufirst" => 1,
    "auinit" => 1,
    "auinit1" => 1,
    "auinitm" => 1,
    "coden" => 1,
    "issn" => 1,
    "eissn" => 1,
    "isbn" => 1,
    "title" => 1,
    "stitle" => 1,
    "atitle" => 1,
    "volume" => 1,
    "part" => 1,
    "issue" => 1,
    "spage" => 1,
    "epage" => 1,
    "pages" => 1,
    "artnum" => 1,
    "sici" => 1,
    "bici" => 1,
    "ssn" => 1,
    "quarter" => 1,
    "date" => 1,
  };

########################################################################

  # Test format - "jarticle"
  $hType = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  };

  # Type format - "book"
  $hType_book = {
    "au" => 1, "aufirst" => 1, "aulast" => 1,
    "btitle" => 1, "date" => 1, "isbn" => 1,
    "org" => 1, "place" => 1, "pub" => 1, "tpages" => 1,
  };

  # Type format - "book_component"
  $hType_book_component = {
    "atitle" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "btitle" => 1, "bici" => 1, "date" => 1, "isbn" => 1,
    "org" => 1, "pages" => 1, "spage" => 1, "title" => 1,
  };

  # Type format - "conf_proc"
  $hType_conf_proc = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  };

  # Type format - "conf_paper"
  $hType_conf_paper = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  };

  # Type format - "dissertation"
  $hType_dissertation = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  };

  # Type format - "journal"
  $hType_journal = {
    "coden" => 1, "eissn" => 1, "issn" => 1, "jtitle" => 1,
    "stitle" => 1, "title" => 1,
  };

  # Type format - "jissue"
  $hType_jissue = {
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "issn" => 1, "issue" => 1, "jtitle" => 1, "part" => 1,
    "sici" => 1, "stitle" => 1, "title" => 1, "volume" => 1,
  };

  # Type format - "jarticle"
  $hType_jarticle = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  };

  # Type format - "patent"
  $hType_patent = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  };

  # Type format - "tech_report"
  $hType_tech_report = {
    "artnum" => 1, "au" => 1, "aufirst" => 1, "aulast" => 1,
    "chron" => 1, "coden" => 1, "date" => 1, "eissn" => 1,
    "epage" => 1, "issn" => 1, "issue" => 1, "jtitle" => 1,
    "org" => 1, "pages" => 1, "part" => 1, "sici" => 1, "spage" => 1,
    "stitle" => 1, "title" => 1, "volume" => 1,
  };

########################################################################

  sub new {

    my $class = shift;
    my $args = shift;

    my $self = {};

    $$self{'hArgs'} = {};
    $$self{'hArgs'} = $args;
    # %args = ( "id" => [ "doi:1234" ], );
    # $$self{'hArgs'} = { %args };
      for my $key (keys %{$$self{'hArgs'}}) {
#print "$key\n";
}

    # Is this in OpenURL v1.0 format?
    if (exists $$self{'hArgs'}{'adm_ver'}) {
      $ver = "1.0";
    }
    else {
      # assume this is in OpenURL 0.1 format
      # and convert to OpenURL 1.0 format
      $nKeys = 0; $byVal = 0;
      for my $key (keys %{$$self{'hArgs'}}) {
        if (exists $$hKeys0_1{$key}) {
          $nKeys += 1;
          $byVal = 1 if $$hKeys0_1{$key} > 0 ;
        }
      }
      if ($nKeys > 0) {
        $ver = "0.1";
        $$self{'hArgs'}{'adm_ver'} = [ "Z39.00-00" ];
        for my $key (keys %{$$self{'hArgs'}}) {
          $vals = $$self{'hArgs'}{$key};
          $_vals = [];
          if ($key eq 'id') {
            for my $val (@$vals) {
              $nam = "$val";
              $nam =~ s/(\w+):(.*)/$1/;
              $val =~ s/(\w+):(.*)/$2/;
              if (exists $$hNIDs0_1{$nam}) {
                push(@$_vals, "openurl:$nam:$val");
              }
            }
            delete $$self{'hArgs'}{$key}; $$self{'hArgs'}{'ref_id'} = $_vals;
          }
          if ($key eq 'sid') {
            for my $val (@$vals) {
              push(@$_vals, "openurl:dbid:$val");
            }
            delete $$self{'hArgs'}{$key}; $$self{'hArgs'}{'rfr_id'} = $_vals;
          }
          if ($key eq 'pid') {
            delete $$self{'hArgs'}{$key}; $$self{'hArgs'}{'ref_pid'} = $vals;
          }
        }
        # If "genre" is sepcified then we need to map that to the
        # by-val format type - otherwise we'll need to infer it
        # from the best match of meta-tags to format type
        $$self{'hArgs'}{'ref_valfmt'} = 'jarticle' if $byVal;
      }
      else {
        # exit
      }
    }

    bless $self, ref $class || $class;

    return $self;

  }

  sub to_s {

    my $self = shift;
    my $s = "";

    for my $key (sort %{$$self{'hArgs'}}) {
      for my $val (@{$$self{'hArgs'}{$key}}) {
        $s .= "  $key = $val\n" if $key;
      }
    }

    return $s;

  }

  sub to_xml {

    my $self = shift;
    my $s = "";

    # Run though keys and get descriptor counts for each entity
    for my $_ent (@$aEnts) {
      for my $key (%{$$self{'hArgs'}}) {
        if (exists $$self{'hKeys'}{$key}) {
          ($ent, $desc) = split /_/, $key;
          next unless $ent eq $_ent;
          $$hEntN{$ent} += 1;
        }
      }
    }

    if (exists $$self{'hArgs'}{'adm_tim'}) {
      $ctxc_head =~ s/\>\Z/ timestamp=\"$$self{'hArgs'}{'adm_tim'}\"\>/m;
      $ctx_head =~  s/\>\Z/ timestamp=\"$$self{'hArgs'}{'adm_tim'}\"\>/m;
    }
    $ctxc_head =~ s/(version="")/version=\"$$self{'hArgs'}{'adm_ver'}\"/;

    $s .= "$ctxc_head\n";
    $s .= "  $ctx_head\n";
    $s .= "  <!--\n  OpenURL v.1.0 Parameters";
    $s .= " (converted from OpenURL v.0.1)" if $ver eq '0.1';
    $s .= ":\n\n";
    for my $key (sort %{$$self{'hArgs'}}) {
      for my $val (@{$$self{'hArgs'}{$key}}) {
        $s .= "  $key = $val\n" if $key;
      }
    }
    $s .= "-->\n";
    # Output entities in XML schema sequence order
    for my $_ent (@$aEnts) {
      $_ent_new = 1;
      # Output descriptors in XML schema sequence order
      for my $_desc (@$aDesc) {
        # Now run though the arguments
        for my $key (sort %{$$self{'hArgs'}}) {
          # And output only recognized OpenURL keywords
          if (exists $$hKeys{$key}) {
            ($ent, $desc) = split /_/, $key;
            next unless ($ent eq $_ent) and ($desc eq $_desc);
            if ($_ent_new) {
              $s .= "    <$$hEnts{$ent}>\n" unless $ent eq 'ctx';
            }
            $_ent_new = 0; $hEntN{$ent} -= 1;
            for my $val (@{$$self{'hArgs'}{$key}}) {
              $val =~ s/&/&amp;/g;
              $val =~ s/"/&quot;/g;
              $val =~ s/'/&apos;/g;
              if (($desc eq 'id') or ($desc eq 'reffmt')
                  or ($desc eq 'ptr')) {
                $nam = "$val";
                $nam =~ s/(\w+):(.*)/$1/;
                $val =~ s/(\w+):(.*)/$2/;
                if (exists $$hNIDs{$nam}) {
                  $s .= "      <$$hDesc{$desc} type=\"$nam\">";
                  $s .= "$val</$$hDesc{$desc}>\n";
                }
              }
              elsif ($desc eq 'valfmt') {
                $s .= "      <$$hDesc{$desc}>\n";
                $s .= "        <ref:$val ";
                $s .= "xmlns:ref=\"$registry/$val\"\n";
                $s .= "            xmlns:xsi=\"$xsi\"\n";
                $s .= "            xsi:schemaLocation=\"";
                $s .= "$registry/$val\">\n";
                for my $key_fmt (@$self{'hArgs'}) {
                  if (exists $$hType{$key_fmt}) {
                    $s .= "          <ref:$key_fmt>";
                    $s .= "$$self{'hArgs'}{$key_fmt}</ref:$key_fmt>\n";
                  }
                }
                $s .= "        </ref:$val>\n";
                $s .= "      </$$hDesc{$desc}>\n";
              }
              else {
                $s .= "      <$$hDesc{$desc}>$val</$$hDesc{$desc}>\n"
              }
            }
            if ($$hEntN{$ent} eq 0) {
              $s .= "    </$$hEnts{$ent}\n" unless $ent eq 'ctx';
            }
          }
        }
      }
    }
    $s .= "  $ctx_tail\n";
    $s .= "$ctxc_tail\n";

    return $s;

  }


1;
__END__

########################################################################

=pod

=head1 NAME

Oboe::OpenURL.pm - provides methods to manipulate OpenURL strings.

=head1 SYNOPSIS

  use CGI;
  use Oboe;

  $cgi = CGI.new; @nams = $cgi->parse;

  for (@nams) {
    @vals = $cgi->param($_);
    $args{$_} = [ @vals ];
  }
  print "content-type: text/html\n\n<body>";
  print Oboe::OpenURL->new(\%args)->to_s;

=head1 DESCRIPTION

The Oboe::OpenURL module is a Perl package for managing OpenURL objects.

=head1 CLASS METHODS

=over 4

=item Oboe::OpenURL->new( \%args )

Constructs a new OpenURL object with from the name/values in the hash %args.

=item Oboe::OpenURL->methods

Prints list of OpenURL class and instance methods.

=back

=head1 INSTANCE METHODS

=over 4

=item $o->to_s

Prints this OpenURL instance as a list of name/value pairs.

=item $o->to_xml

Prints this OpenURL instance as an XML document.

=back

=head1 AUTHOR

Tony Hammond <F<tony_hammond@harcourt.com>>

=cut
