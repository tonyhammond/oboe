#!c:/cygwin/usr/local/bin/ruby

  require 'cgi'
  require 'context'

  include Oboe

ctx = ContextObject.new
# ctx.add_referrer.add_id("http://www.this.com/1234")
# ctx.add_entity(Entity.new(Entity::REFERENT).add_id("http://www.this.com/1234"))

d = Descriptor.new(Descriptor::ID, "http://www.this.com/1234")
#ref = Entity.new(Entity::REFERENT).add_id("http://www.this.com/1234")
ref = Entity.new(Entity::REFERENT, d)
# ref = Entity.referent.add_id("http://www.this.com/1234")
ctx.add_entity(ref)
#ctx.add_referent(ref)
#ctx.get_entity(Entity::REFERENT)

p ctx
#print d.value, "\n"
#print d.type, "\n"
