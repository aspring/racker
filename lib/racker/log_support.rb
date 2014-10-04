require 'log4r'

module Racker
  module LogSupport
    unless Log4r::Logger['racker']
      # Create the initial logger
      logger = Log4r::Logger.new('racker')

      # Set the output to STDOUT
      logger.outputters = Log4r::Outputter.stdout

      # We set the initial log level to ERROR
      logger.level = Log4r::ERROR
    end

    def self.level=(level)
      log_level = log4r_level_for(level)
      logger.level = log_level
      logger.info("Log level set to: #{log_level}")
    end

    def self.log4r_level_for(level)
      case level
      when /fatal/
        Log4r::FATAL
      when /error/
        Log4r::ERROR
      when /warn/
        Log4r::WARN
      when /info/
        Log4r::INFO
      when /debug/
        Log4r::DEBUG
      else
        Log4r::INFO
      end
    end

    def self.logger
      Log4r::Logger['racker']
    end

    def logger
      Racker::LogSupport.logger
    end
  end
end
