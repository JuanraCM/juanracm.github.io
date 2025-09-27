# frozen_string_literal: true

require_relative 'config'
require_relative 'event_logger'

require 'webrick'

module SSG
  class Server
    def initialize(port)
      @port = port
      @server = WEBrick::HTTPServer.new(Port: @port, DocumentRoot: BUILD_DIR)
    end

    def start
      trap('INT') { @server.shutdown }

      logger.info "Serving #{BUILD_DIR} at http://localhost:#{@port}"
      @server.start
    end

    private

    def logger
      @logger ||= SSG::EventLogger.new('Server')
    end
  end
end
