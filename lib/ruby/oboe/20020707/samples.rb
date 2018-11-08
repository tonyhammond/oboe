#

module Oboe

  class Samples

  attr_reader :querystring

  def initialize

    sample_file = 'samples/ex-' + rand(5).to_s + '.txt'
    @querystring = ""
    Registry.read_property_file(sample_file).each do |key, val|
      @querystring << "#{key}=#{val}&"
    end
    @querystring.gsub!(/\s+/, "")

  end

  end

end

########################################################################
