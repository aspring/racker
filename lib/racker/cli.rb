# encoding: utf-8
require 'optparse'
require 'racker/processor'
require 'racker/version'
require 'log4r'

module Racker
  # The CLI is a class responsible for handling the command line interface
  # logic.
  class CLI
    attr_reader :options

    def initialize(argv)
      @argv = argv
    end

    def execute!
      # Get the global logger
      log = Log4r::Logger['racker']

      # Parse our arguments
      option_parser.parse!(@argv)

      # Set the logging level specified by the command line
      log.level = get_log4r_level(options[:log_level])
      log.info("Log level set to: #{options[:log_level]}")

      # Display the options if a minimum of 1 template and an output file is not provided
      if @argv.length < 2
        puts option_parser 
        Kernel.exit!(1)
      end

      # Set the output file to the last arg
      options[:output] = @argv.pop
      log.debug("Output file set to: #{options[:output]}")

      # Set the input files to the remaining args
      options[:templates] = @argv

      # Run through Racker
      log.debug('Executing the Racker Processor...')
      Processor.new(options).execute!
      log.debug('Processing complete.')

      # Thats all folks!
      puts "Processing complete!" unless options[:quiet]
      puts "Packer file generated: #{options[:output]}" unless options[:quiet]

      return 0
    end
   
    private

    def get_log4r_level(level)
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

    def options
      @options ||= {
        log_level:     :warn,
        knockout:      '~~', 
        output:        '',
        templates:     [],
        quiet:         false, 
      }
    end

    def option_parser
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{opts.program_name} [options] [TEMPLATE1, TEMPLATE2, ...] OUTPUT"
        
        opts.on('-l', '--log-level [LEVEL]', [:fatal, :error, :warn, :info, :debug], 'Set log level') do |v|
          options[:log_level] = v
        end

        opts.on('-k', '--knockout PREFIX', 'Set the knockout prefix (Default: ~~)') do |v|
          options[:knockout] = v || '~~'
        end

        opts.on('-q', '--quiet', 'Disable unnecessary output') do |v|
          options[:quiet] = true
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts option_parser
          Kernel.exit!(0)
        end

        opts.on_tail('-v', '--version', "Show #{opts.program_name} version") do
          puts Racker::Version.version
          Kernel.exit!(0)
        end
      end
    end
  end
end
