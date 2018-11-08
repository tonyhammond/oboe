#!c:/cygwin/usr/local/bin/ruby

  require 'cgi'
  require 'oboe'; include Oboe

  cgi = CGI.new; args = cgi.params; params = {}

  print "content-type: text/html\n\n"
  print "<head>\n"
  print "<link href=\"css/oboe.css\" type=text/css rel=stylesheet>\n"
  print "</head>\n"
  print "<body>\n"
  print "<h2>CrossRef Agent</h2>\n"
  print "The following CrossRef parameters were found in the OpenURL.\n"
  print "<p>\n"

  o = OpenURL.new(args)

  if o.is_valid?
    data = o.get_context.get_data  # CrossRef paramter set
    print "<table width=100% cellpadding=3>\n"
    params = CGI.parse(CGI.unescape(data))
    print "<tr><th align=left>Parameter</th><th align=left>Value</th></tr>\n"      
    params.sort.each do |key, vals|
      print "<tr><td>&nbsp;&nbsp;#{key}</td>"
      print "<td>&nbsp;&nbsp;#{vals.join(', ')}</td></tr>\n"      
    end
    print "</table>\n"
    print "<p>\n"
    unless params.has_key?('cr_setVer')
      print "<b>! Invalid parameter set: no version number \"cr_setVer\"</b>\n"
    end
    unless params.has_key?('cr_src')
      print "<b>! Invalid parameter set: no source \"cr_src\"</b>\n"
    end
  else
    print "! Error in fetching parameter set\n"
  end
  print "</body>\n"

__END__
