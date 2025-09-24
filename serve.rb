# frozen_string_literal: true

require 'webrick'

port = 8000
build_dir = File.expand_path('build')

server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: build_dir)

trap('INT') { server.shutdown }

puts "Serving #{build_dir} at http://localhost:#{port}"
server.start
