$LOAD_PATH << '.'
require 'Bot'

exec "ruby pushServer.rb" if fork.nil? 

server = LCBot::Server.new(:Port => 1234)
server.start

