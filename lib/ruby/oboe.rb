#

module Oboe
  VERSION_CODE = '0.2.1'.freeze
  VERSION = VERSION_CODE.scan(/../).collect{|n| n.to_i}.join('.').freeze
end

=begin

== Components

  * ((<Oboe>)) Module
  * ((<Oboe::Context>)) Class
  * ((<Oboe::OpenURL>)) Class

=end

require 'oboe/registry'
require 'oboe/utils'
require 'oboe/context'
require 'oboe/openurl'
