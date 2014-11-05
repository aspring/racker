# encoding: utf-8
require 'optparse'
require 'racker/processor'
require 'racker/version'

module Racker
  # The CLI is a class responsible for handling the command line interface
  # logic.
  class CLI
    include Racker::LogSupport

    STDOUT_TOKEN = '-'

    attr_reader :options

    def initialize(argv)
      @argv = argv
    end

    def execute!
      # Parse our arguments
      option_parser.parse!(@argv)

      # Set the logging level specified by the command line
      Racker::LogSupport.level = options[:log_level]

      # Display the options if a minimum of 1 template and an output file is not provided
      if @argv.length < 2
        puts option_parser
        Kernel.exit!(1)
      end

      # Set the output file to the last arg. A single dash can be supplied to
      # indicate that the compiled template should be written to STDOUT. Output
      # to STDOUT assumes the quiet option.
      options[:output] = output = @argv.pop
      logger.debug("Output file set to: #{output}")

      # Output to STDOUT assumes quiet mode
      @options[:quiet] = true if output == STDOUT_TOKEN

      # Set the input files to the remaining args
      options[:templates] = @argv

      # Run through Racker
      logger.debug('Executing the Racker Processor...')
      template = Processor.new(options).execute!

      write(output, template)

      # Thats all folks!
      logger.debug('Processing complete.')
      puts "Processing complete!" unless options[:quiet]
      puts "Packer file generated: #{options[:output]}" unless options[:quiet]

      return 0
    end

    private

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

    private

    def write(output_path, template)
      if output_path == STDOUT_TOKEN
        write_to_stdout(template)
      else
        write_to_file(template, output_path)
      end
      true
    end

    def write_to_file(template, path)
      path = File.expand_path(path)
      output_dir = File.dirname(path)

      # Create output directory if it does not exist
      unless File.directory?(output_dir)
        logger.info(%Q[Creating output directory "#{output_dir}"])
        FileUtils.mkdir_p(output_dir)
      end

      File.open(path, 'w') { |file| write_to_stream(template, file, path) }
    end

    def write_to_stdout(template)
      write_to_stream(template, $stdout, :STDOUT)
    end

    def write_to_stream(template, stream, stream_name)
      logger.info("Writing packer template to #{stream_name}")
      stream.write(template)
      stream.flush if stream.respond_to?(:flush)
      logger.info("Writing packer template to #{stream_name} complete.")
    end

  end
end
