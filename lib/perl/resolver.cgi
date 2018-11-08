#!c:/cygwin/bin/perl

  use CGI;
  use Oboe;

  $cgi =  new CGI; @nams = $cgi->param;

  $output = 'xml';

  if ($cgi->param('OpenURL')) {
    $output = "$cgi->param('Parse')";
    $_cgi =  new CGI($cgi->param('OpenURL'));
    @nams = $_cgi->param;
  }

  # # If no querystring present select a random sample
  # if args.empty?
  #   args = CGI::parse(Samples.new.querystring)
  # end

  for (@nams) {
    @vals = $cgi->param($_);
    $args{$_} = [ @vals ];
  }

  # $o = new Oboe::OpenURL(\%args);
  
  $output = 'txt';
  if ($output eq 'txt') {
      print "content-type: text/html\n\n";
      print "<body>\n<pre>\n";

      for (@nams) {
        $vals = join ", ", $cgi->param($_);
        print "$_ => $vals\n";
      }
      # print $o->to_s;

      print "</pre>\n</body>\n";
  }
  elsif ($output eq 'xml') {
      print "content-type: text/xml\n\n";
      print $o->to_xml;
  }

__END__

