########################################################################

require 'net/http'

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

  end

end

########################################################################
__END__
