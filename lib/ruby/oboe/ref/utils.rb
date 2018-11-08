########################################################################
module Oboe

  class Utils

    # Entify an XML string
    def Utils.entify(string)
      string.gsub!(/&/, '&amp;')
      string.gsub!(/"/, '&quot;')
      string.gsub!(/'/, '&apos;')
      return string
    end
  
  end

end

########################################################################
__END__
