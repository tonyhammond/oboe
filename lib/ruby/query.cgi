#!c:/cygwin/usr/local/bin/ruby

  require 'cgi'

  cgi = CGI.new; args = cgi.params

  print "content-type: text/html\n\n"

  a = []; a = IO.readlines(args['file'][0])

  print <<-"EOT"
<html>
<head>
<link href="css/oboe.css" type=text/css rel=stylesheet>
<title>Oboe: Resolver Query</title>
</head>
<body>
<h1><i>Oboe</i> ~ Resolver Query</h1>
<hr>
Send <a href="resolver.cgi?oboe_example&adm_ver=Z39.00-00&ctx_ptr=uri:http://#{cgi.server_name}#{cgi.script_name.sub(/query.cgi/, "")}#{args['file']}"><b>#{a[0].sub(/# /, "").strip}</b></a> to 
the Oboe Resolver.
<hr>
<br>
<pre>
#{a.join("")}
</pre>
</body>
</html>
  EOT
