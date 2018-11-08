#!c:/cygwin/usr/local/bin/ruby

  require 'cgi'
  require 'oboe'; require 'oboe/samples'

  include Oboe

  cgi = CGI.new; args = cgi.params

  no_validate_directive = false
  no_follow_ref_directive = false
  output = 'to_key'

  if args.has_key?('OpenURL')
    output = "#{args['srv_id']}".sub(/:oboe:/, "")
    args = CGI::parse(args['OpenURL'][0])
  end

  # If no querystring present select a random sample
  if args.empty?
    args = CGI::parse(Samples.new.querystring)
  end

  o = OpenURL.new(args)
  # Process any service directives
  if o.get_context.get_directives('oboe')
    o.get_context.get_directives('oboe').each do |directive|
      case directive
        when /oboe:to_key/ then output = 'to_key'
        when /oboe:to_xml/ then output = 'to_xml'
        when /oboe:to_rdf/ then output = 'to_rdf'
        when /oboe:no_val/ then no_validate_directive = true
        when /oboe:no_ref/ then no_follow_ref_directive = true
      end
    end
  end

  begin
    o.validate unless no_validate_directive

    if output == 'to_key'
      print "content-type: text/html\n\n"
      print <<-EOT
<html>
<head>
<link href="css/parser.css" type=text/css rel=stylesheet>
<title>Oboe: Parser Result</title>
</head>
<body>
<h1>
Oboe/Ruby - <i>OpenURL Parser Result</i></h1>
<hr>
<br>
<pre>
#{o.to_key}
</pre>
</body>
</html>
EOT
    elsif output == 'to_xml'
      print "content-type: text/xml\n\n"
      print o.to_xml
    elsif output == 'to_rdf'
      print "content-type: text/xml\n\n"
      print o.to_rdf
    end
  rescue
      param = o.to_key; a = []
      error = $!.to_s
      if error =~ /- \"([a-z]+_[a-z]+)\"\)/
        key = $1
        param.split(/\n/).each do |line|
          if line =~ /#{key}/
            line = "<b>#{line}</b>"
          end
          a << line
        end
        param = a.join("\n")
      end
      print "content-type: text/html\n\n"
      print <<-"EOT"
<html>
<head>
<link href="css/parser.css" type=text/css rel=stylesheet>
<title>Oboe: Parser Error</title>
</head>
<body>
<h1>
Oboe/Ruby - <i>OpenURL Parser Error</i></h1>
<hr>
<br>
<b>#{$!}</b>
<pre>
#{param}
</pre>
</body>
</html>
EOT
     
  end

