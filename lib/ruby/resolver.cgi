#!c:/cygwin/usr/local/bin/ruby

  require 'cgi'
  require 'oboe'; require 'oboe/samples'

  include Oboe

  cgi = CGI.new; args = cgi.params

  # Service directive flags
  no_validate_directive = false
  no_refs_directive = false
  no_strict_directive = false
  trace = false
  forward = false

  # print "content-type: text/html\n\n"

  # Default output method is to a property list
  output = 'to_s'
  origin = 'batch'

  def print_form
  
    print <<-"EOT"
content-type: text/html

<html>
<head>
<link href="css/oboe.css" type=text/css rel=stylesheet>
<title>Oboe: Resolver</title>
<div id="topdeck" class="popper">&nbsp;</div>
<script type="text/javascript">

<!-- Original:  Mike McGrath   (mike_mcgrath@lineone.net) -->
<!-- Web Site:  http://website.lineone.net/~mike_mcgrath/ -->
<!--

var nav = (document.layers); 
var iex = (document.all);
var skn = (nav) ? document.topdeck : topdeck.style;
if (nav) document.captureEvents(Event.MOUSEMOVE);
document.onmousemove = get_mouse;

function pop(msg,bak) 
{

var content ="<table width=240 border=1 cellpadding=2 cellspacing=0 bgcolor="+bak+"><tr><td>"+msg+"</td></tr></table>";

  if (nav) 
  { 
    skn.document.write(content); 
          skn.document.close();
          skn.visibility = "visible";
  }
    else if (iex) 
  {
          document.all("topdeck").innerHTML = content;
          skn.visibility = "visible";  
  }
}

function get_mouse(e) 
{
        var x = (nav) ? e.pageX : event.x+document.body.scrollLeft; 
        var y = (nav) ? e.pageY : event.y+document.body.scrollTop;
        skn.left = x - 60;
  skn.top  = y+20;
}

function unpop() 
{
  skn.visibility = "hidden";
}

//-->

</script>
<style type="text/css">
<!--
.popper
{ position : absolute;
  visibility : hidden;
  z-index:200;}
//-->
</style>
</head>
<body>
<h1><i>Oboe</i> ~ An OpenURL Validating Resolver</h1>
<hr>
<b>&gt;&gt;</b>
<a href="about.html" onmouseover="pop('This resolver parses, validates and services an OpenURL.','silver')"; onmouseout="unpop()"><b>About</b></a> |
<a href="tutorial.html" onmouseover="pop('A one-page tutorial describing the resolver action, key names, etc.','silver')"; onmouseout="unpop()"><b>Tutorial</b></a> |
<a href="examples.html" onmouseover="pop('EBNF example contexts and sample service contexts.','silver')"; onmouseout="unpop()"><b>Examples</b></a> |
<a href="directives.html" onmouseover="pop('Listing of Oboe service directives.','silver')"; onmouseout="unpop()"><b>Directives</b></a> |
<a href="features.html" onmouseover="pop('Resolver feature set listing.','silver')"; onmouseout="unpop()"><b>Features</b></a> |
<a href="issues.html" onmouseover="pop('Stances taken on non-closed Committee issues.','silver')"; onmouseout="unpop()"><b>Open Issues</b></a>
&nbsp;&nbsp;&nbsp;&nbsp;
<b>&gt;&gt;</b>
<a href="http://library.caltech.edu/openurl/" onmouseover="pop('NISO Committee AX web page.','silver')"; onmouseout="unpop()"><b>NISO AX</b></a> |
<a href="mailto:t.hammond@elsevier.com" onmouseover="pop('Mail comments and feedback.','silver')"; onmouseout="unpop()"><b>Email</b></a>
<hr>
<p>
Enter an OpenURL <a href="properties.html"><b>Property List</b></a> to resolve
or just refresh the page for a new random example:<p>
<form name="form" action="resolver.cgi" method="POST">
<textarea name="oboe_form" rows=15 cols=80>
#{Samples.new.querystring}
</textarea>
<p>
<input name="resolve" type="submit" value="Resolve">
&nbsp;&nbsp;&nbsp;&nbsp;
<input name="clear" type="button" value="Clear Text" onclick="window.document.form.oboe_form.value=''">
&nbsp;&nbsp;&nbsp;&nbsp;
<input type="radio" name="srv_id" value=":oboe:to_s" checked>Property List
&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
<input type="radio" name="srv_id" value=":oboe:to_excel">Excel
&nbsp;&nbsp;&nbsp;&nbsp;
<input type="radio" name="srv_id" value=":oboe:to_query">Query
&nbsp;&nbsp;&nbsp;&nbsp;
<input type="radio" name="srv_id" value=":oboe:to_rdf">RDF
&nbsp;&nbsp;&nbsp;&nbsp;
<input type="radio" name="srv_id" value=":oboe:to_xml">XML
</form>
<hr>
<p>
Comments and feedback welcome at <a href="mailto:t.hammond@elsevier.com"><b>Feedback</b></a>.
</body>
</html>
EOT

  end

  # If form requested then print one with a random sample
  if args.has_key?('print_form')
    print_form(); exit
  end

  if args.has_key?('oboe_form')
    origin = 'form'
    output = 'to_s'
    output = "#{args['srv_id']}".sub(/:oboe:/, "")
    form_args = args['oboe_form'].join("\n")
    form_args += "\n"
    form_args += "srv_id=_ri:oboe:no_strict\n"
#    form_args += "srv_id=_ri:oboe:trace\n"
    args = Registry.read_properties(form_args)
  end

  if args.has_key?('oboe_example')
    origin = 'example'
    form_args = args['ctx_ptr'][0]
    args = Registry.read_properties(Utils.get_html(form_args.sub(/uri:/, "")))
  end

# print "<pre>\n"
  o = OpenURL.new(args)
# print "</pre>\n"
  # Process any service directives
  if o.get_context.get_directives('oboe')
    o.get_context.get_directives('oboe').each do |directive|
      case directive
        when /oboe:to_s/ then output = 'to_s'
        when /oboe:to_xml/ then output = 'to_xml'
        when /oboe:to_rdf/ then output = 'to_rdf'
        when /oboe:to_yads/ then output = 'to_yads'
        when /oboe:to_query/ then output = 'to_query'
        when /oboe:to_excel/ then output = 'to_excel'
        when /oboe:no_validate/ then no_validate_directive = true
        when /oboe:no_refs/ then no_refs_directive = true
        when /oboe:no_strict/ then no_strict_directive = true
        when /oboe:trace/ then trace = true
        when /oboe:forward/ then forward = true
      end
    end
  end

  # print "content-type: text/plain\n\n" if trace

  begin

    # We validate twice - first time silently for a test to write
    # result to the log file
    if no_validate_directive
      valid = "null"  
    else 
      valid = o.is_valid? ? "true" : "false"
    end

    a = []
    args.each do |key, vals|
      vals.each do |val|
        a << "#{key}=#{val}"
      end
    end
    Utils.write_log(Utils.entify(a.join('&').gsub(/"/, '\"')), valid, output, origin)

    # Now we validate for real
    o.validate unless no_validate_directive

    if forward
      print "content-type: text/html\n\n"
      print <<-EOT
<html>
<head>
<link href="css/oboe.css" type=text/css rel=stylesheet>
<title>Oboe: Resolver Result</title>
</head>
<body>
<h1><i>Oboe</i> ~ Resolver Result</h1>
<hr>
EOT
      print <<-EOT unless no_validate_directive
<b>Success. OpenURL validated OK.</b>
<hr>
EOT
      print <<-EOT
Forwarding to ...
<br>
#{o.post}
</body>
</html>
EOT
    elsif output == 'to_s' or output == 'to_query'

      body = ""
      body = o.to_s if output == 'to_s'
      body = o.to_query if output == 'to_query'

      print "content-type: text/html\n\n"
      print <<-EOT
<html>
<head>
<link href="css/oboe.css" type=text/css rel=stylesheet>
<title>Oboe: Resolver Result</title>
</head>
<body>
<h1><i>Oboe</i> ~ Resolver Result</h1>
<hr>
EOT
      print <<-EOT unless no_validate_directive
<b>Success. OpenURL validated OK.</b>
<hr>
EOT
      print <<-EOT
<br>
<pre>
#{body}
</pre>
</body>
</html>
EOT
    elsif output == 'to_excel'
      print "content-type: application/vnd.ms-excel\n\n"
      print o.to_excel
    elsif output == 'to_xml'
      print "content-type: application/xml\n\n"
      print o.to_xml
    elsif output == 'to_yads'
      print "content-type: application/xml\n\n"
      print o.to_yads
    elsif output == 'to_rdf'
      print "content-type: application/xml\n\n"
      print o.to_rdf
    elsif output == 'to_svg'
      print "content-type: application/xml\n\n"
      # tmp_file = "/tmp/oboe.xml"
      # tmp = File.open(tmp_file "w")
      print o.to_yads
      # system("xalan -xsl ../../../../xsl/yads2dot.xsl -in #{tmp_file} | dot -Tsvg"
    end
  rescue
      param = o.to_s; a = []
      error = $!.to_s.gsub!(/\n\n/m, "<p>")
      if error =~ /: \"([a-z]+_\w+)\"\)/
        key = $1
        if error =~ /\"(\w+)\" \(/
          err = $1
        end
        param.split(/\n/).each do |line|
          if line =~ /#{key}/ and line =~ /#{err}/
            line = "<b>&gt; #{line.strip}</b>"
          end
          a << line
        end
        param = a.join("\n")
      end
      print "content-type: text/html\n\n"
      print <<-"EOT"
<html>
<head>
<link href="css/oboe.css" type=text/css rel=stylesheet>
<title>Oboe: Resolver Error</title>
</head>
<body>
<h1><i>Oboe</i> ~ Resolver Error</h1>
<hr>
<b>#{$!}</b>
<hr>
<br>
<pre>
#{param}
</pre>
</body>
</html>
EOT
     
  end

__END__
