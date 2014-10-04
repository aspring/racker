# encoding: utf-8

require 'fileutils'
require 'json'
require 'racker/template'
require 'pp'

module Racker
  # This class handles command line options.
  class Processor
    include Racker::LogSupport

    CONFIGURE_MUTEX = Mutex.new

    def initialize(options)
      @options = options
    end

    def execute!
      # Verify that the templates exist
      @options[:templates].each do |template|
        raise "File does not exist!  (#{template})" unless ::File.exists?(template)
      end

      # Check that the output directory exists
      output_dir = File.dirname(File.expand_path(@options[:output]))

      # If the output directory doesnt exist
      logger.info('Creating the output directory if it does not exist...')
      FileUtils.mkdir_p output_dir unless File.exists? output_dir

      # Load the templates
      templates = []

      # Load the template procs
      logger.info('Loading racker templates...')
      template_procs = load(@options[:templates])

      # Load the actual templates
      logger.info('Processing racker templates...')
      template_procs.each do |version,proc|
        # Create the new template
        template = Racker::Template.new

        # Run the block with the template
        proc.call(template)

        # Store the template
        templates << template
      end
      logger.info('Racker template processing complete.')

      # Get the first template and merge each subsequent one on the latest
      logger.info('Merging racker templates...')
      current_template = templates.shift

      # Overlay the templates
      templates.each do |template|
        current_template = current_template.deep_merge!(template, {:knockout_prefix => @options[:knockout]})
      end

      # Compact the residual template to remove nils
      logger.info('Compacting racker template...')
      compact_template = current_template.compact(:recurse => true)

      # Write the compact template out to file
      File.open(@options[:output], 'w') do |file|
        logger.info('Writing packer template...')
        file.write(JSON.pretty_generate(compact_template.to_packer))
        logger.info('Writing packer template complete.')
      end
    end

    def load(templates)
      return capture_templates do
        templates.each do |template|
          puts "Loading template file: #{template}" unless @options[:quiet]
          Kernel.load template
        end
      end
    end

    # This is a class method so the templates can load it
    def self.register_template(version='1',&block)
      @@last_procs ||= []
      @@last_procs << [version, block]
    end

    def capture_templates
      CONFIGURE_MUTEX.synchronize do
        @@last_procs = []

        yield

        return @@last_procs
      end
    end
  end
end
