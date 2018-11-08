#

module Oboe

  class Samples

  attr_reader :querystring

  def initialize

    a = []
    Dir.foreach('examples/q') do |file|
      a << file if file =~ /^ex-\d\D.q$/
    end
    sample_file = 'examples/q/' + a[rand(a.length - 1)]

    # sample_file = 'samples/ex-' + rand(5).to_s + '.txt'
    # sample_file = 'samples/ex-4.txt'

    # sample_file = 'examples/q/ex-4a.q'
    @querystring = File.new(sample_file).readlines
  end

  end

end

########################################################################
