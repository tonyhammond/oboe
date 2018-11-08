#!c:/cygwin/usr/local/bin/ruby

  require 'cgi'
  require '_oboe'

  include Oboe

ctx = ContextObject.new
# ctx.add_referrer.add_id("http://www.this.com/1234")
# ctx.add_entity(Entity.new(Entity::REFERENT).add_id("http://www.this.com/1234"))

ref = Entity.new(Entity::REFERENT).add_id("http://www.this.com/1234")
# ref = Entity.referent.add_id("http://www.this.com/1234")
#ctx.add_entity(Entity::REFERENT, ref)
ctx.add_referent(ref)
ctx.get_entity(Entity::REFERENT)

p ctx
