# frozen_string_literal: true

require 'logger'

module SSG
  class EventLogger
    LOG_OUTPUT = $stdout

    GREEN = "\e[32m"
    YELLOW = "\e[33m"
    RED = "\e[31m"
    RESET = "\e[0m"

    COLOR_BY_SEVERITY = {
      'INFO' => GREEN,
      'DEBUG' => YELLOW,
      'ERROR' => RED
    }.freeze

    def initialize(identifier)
      @logger = ::Logger.new(LOG_OUTPUT)
      @logger.progname = identifier
      @logger.formatter = proc do |severity, datetime, progname, msg|
        color = COLOR_BY_SEVERITY[severity] || RESET
        time  = datetime.strftime('%Y-%m-%d %H:%M:%S')

        "#{color}[#{time}] #{progname} - #{severity}: #{msg}#{RESET}\n"
      end
    end

    def info(message)
      @logger.info(message)
    end

    def debug(message)
      @logger.debug(message)
    end

    def error(message)
      @logger.error(message)
    end
  end
end
