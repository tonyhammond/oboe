require Date

LOGS = "/tmp"

def write_log(log)

  date = Date.today

  unless File.stat("#{LOGS}/#{date}").exists?

    a = []
    Dir.foreach(LOGS) do |file|
      a << file if file =~ /^\d{4}-\d{2}-\d{2}$/
      last_log_file = a.pop
    end

    if File.stat("#{LOGS}/#{last_log_file}").exists?
      l = File.open("#{LOGS}/#{last_log_file}", "w+")
      l.print "</log>\n"
      l.close
    end
    l = File.open("#{LOGS}/#{date}.xml", "w")
    l.print "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n"

    l.print "<log date=\"#{date}\">\n"
  }
  else {
    l = File.open("#{LOGS}/#{date}.xml", "w")
  }

  l.print "<oboe at=\"", Get_TimeStamp(), "\" "
  l.print "ip=\"#{ENV['REMOTE_ADDR']}\" #{log} />\n"

  l.close
end

###########################################################################

