# frozen_string_literal: true

require_relative 'config'

require 'webrick'

module SSG
  class Server
    def initialize(port)
      @port = port
      @server = WEBrick::HTTPServer.new(Port: @port, DocumentRoot: BUILD_DIR)
    end

    def start
      trap('INT') { @server.shutdown }

      puts "Serving #{BUILD_DIR} at http://localhost:#{@port}"
      @server.start
    end
  end
end
