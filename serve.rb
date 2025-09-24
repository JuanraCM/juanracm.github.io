# frozen_string_literal: true

require_relative 'lib/ssg'

require 'listen'
require 'webrick'

listener = Listen.to('assets', 'layouts', 'pages') do |_modified, _added, _removed|
  puts 'Changes detected. Rebuilding site...'

  SSG.prepare_output_dir
  SSG.build

  puts 'Site rebuilt.'
end

puts 'Starting file listener...'
listener.start

port = 8000
build_dir = File.expand_path('build')

server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: build_dir)

trap('INT') { server.shutdown }

puts "Serving #{build_dir} at http://localhost:#{port}"
server.start
