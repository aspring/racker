# encoding: utf-8
require 'racker/builders/builder'

module Racker
  module Builders
    # This is the Virtualbox builder
    class Virtualbox < Racker::Builders::Builder
      def to_packer(name, config)
        logger.debug("Entering #{self.class}.#{__method__}")
        config = super(name, config)

        %w(boot_command export_opts floppy_files import_flags iso_urls vboxmanage vboxmanage_post).each do |key|
          if config.key? key
            logger.info("Converting #{key} to packer value...")
            config[key] = convert_hash_to_packer_value(config[key])
          end
        end

        logger.debug("Leaving #{self.class}.#{__method__}")
        config
      end
    end
  end
end
