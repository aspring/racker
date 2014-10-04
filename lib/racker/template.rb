# encoding: utf-8
require 'racker/smash/smash'
require 'racker/builders/amazon'
require 'racker/builders/builder'
require 'racker/builders/digitalocean'
require 'racker/builders/docker'
require 'racker/builders/google'
require 'racker/builders/null'
require 'racker/builders/openstack'
require 'racker/builders/qemu'
require 'racker/builders/virtualbox'
require 'racker/builders/vmware'

module Racker
  # This class handles the bulk of the legwork working with Racker templates
  class Template < Smash
    include Racker::LogSupport

    # This formats the template into packer format hash
    def to_packer
      # Create the new smash
      packer = Smash.new

      # Variables
      packer['variables'] = self['variables'].dup unless self['variables'].nil? || self['variables'].empty?

      # Builders
      packer['builders'] = [] unless self['builders'].nil? || self['builders'].empty?
      logger.info("Processing builders...")
      self['builders'].each do |name,config|
        logger.info("Processing builder: #{name} with type: #{config['type']}")

        # Get the builder for this config
        builder = get_builder(config['type'])

        # Have the builder convert the config to packer format
        packer['builders'] << builder.to_packer(name, config.dup)
      end

      # Provisioners
      packer['provisioners'] = [] unless self['provisioners'].nil? || self['provisioners'].empty?
      logger.info("Processing provisioners...")
      self['provisioners'].sort.map do |index, provisioners|
        provisioners.each do |name,config|
          logger.debug("Processing provisioner: #{name}")
         packer['provisioners'] << config.dup
        end
      end

      # Post-Processors
      packer['post-processors'] = [] unless self['postprocessors'].nil? || self['postprocessors'].empty?
      logger.info("Processing post-processors...")
      self['postprocessors'].each do |name,config|
        logger.debug("Processing post-processor: #{name}")
        packer['post-processors'] << config.dup unless config.nil?
      end

      packer
    end

    def get_builder(type)
      case type
      when /amazon/
        Racker::Builders::Amazon.new
      when /digitalocean/
        Racker::Builders::DigitalOcean.new
      when /docker/
        Racker::Builders::Docker.new
      when /googlecompute/
        Racker::Builders::Google.new
      when /null/
        Racker::Builders::Null.new
      when /openstack/
        Racker::Builders::OpenStack.new
      when /parallels/
        Racker::Builders::Parallels.new
      when /qemu/
        Racker::Builders::QEMU.new
      when /virtualbox/
        Racker::Builders::Virtualbox.new
      when /vmware/
        Racker::Builders::VMware.new
      else
        Racker::Builders::Builder.new
      end
    end
  end
end
