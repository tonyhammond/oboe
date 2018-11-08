#!c:/cygwin/usr/local/bin/ruby

  require 'cgi'
  require 'oboe'; include Oboe

  cgi = CGI.new; args = cgi.params

  # print "content-type: application/xml\n\n"
  # print OpenURL.new(args).to_xml

  o = OpenURL.new(args)
  begin
    o.validate
    print "content-type: application/xml\n\n"
    print o.to_xml
  rescue
    print "content_type: text/html\n\n"
    print "<body><pre>\n"
    print "! Not valid OpenURL:\n\n#{$!.to_s}\n"
    print "</pre></body>\n"
  end

__END__
