########################################################################

require 'net/http'

LOGS = "c:/cygwin/tmp"

module Oboe

  class Utils

    # Entify an XML string
    def Utils.entify(string)
      string.gsub!(/&/, '&amp;')
      string.gsub!(/"/, '&quot;')
      string.gsub!(/'/, '&apos;')
      return string
    end
  
    def Utils.get_html(uri)

      uri =~ /^http:\/\/(.*?)(:\d+)*(\/.*)*$/
      server, port, path = $1, $2, $3

      s = Net::HTTP.new(server, port)
      begin
        resp, data = s.get(path, nil)
        if resp.message == "OK"
          return data
        else
          return nil
        end
      rescue
        return nil
      end
    end

    def Utils.post_html(uri, post)

      uri =~ /^http:\/\/(.*?)(:\d+)*(\/.*)*$/
      server, port, path = $1, $2, $3
      s = Net::HTTP.new(server, port)
      begin
        resp, data = s.post(path, post)
        if resp.message == "OK"
          return data
        else
          return nil
        end
      rescue
        return nil
      end
    end

  end

  def Utils.time() Time.now.gmtime.strftime("%Y-%m-%dT%H:%M:%SZ") end
  def Utils.date() Time.now.gmtime.strftime("%Y-%m-%d") end
  
  def write_log(query, valid=nil, output=nil, origin=nil)
  
    log_file = "#{LOGS}/#{Utils.date}.xml"

    unless FileTest.exists?(log_file)
  
=begin
      a = []; last_log_file = ""
      Dir.foreach(LOGS) do |file|
        a << file if file =~ /^\d{4}-\d{2}-\d{2}$/
        last_log_file = a.pop
      end
  
      if FileTest.exists?("#{LOGS}/#{last_log_file}")
        l = File.open("#{LOGS}/#{last_log_file}", "a")
        l.print "</log>\n"
        l.close
      end
=end
      l = File.open(log_file, "w")
      l.print "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n"
  
      l.print "<log date=\"#{Utils.date}\">\n"
    else
      l = File.open(log_file, "a")
    end
  
    
    File.truncate(log_file, File.size(log_file) - "</log>\n".length)
    l.print "<oboe at=\"#{Utils.time}\""
    l.print " ip=\"#{ENV['REMOTE_ADDR']}\""
    l.print " origin=\"#{origin}\"" if origin
    l.print " output=\"#{output}\"" if output
    l.print " valid=\"#{valid}\"" if valid
    l.print " query=\"#{query}\" />\n"
    l.print "</log>\n"
  
    l.close
  end

end

########################################################################
__END__
