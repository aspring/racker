# encoding: utf-8
require 'racker/builders/builder'

module Racker
  module Builders
    # This is the QEMU builder
    class QEMU < Racker::Builders::Builder
      def to_packer(name, config)
        log = Log4r::Logger['racker']
        log.debug("Entering #{self.class}.#{__method__}")
        config = super(name, config)

        %w(boot_command floppy_files iso_urls qemuargs).each do |key|
          if config.key? key
            log.info("Converting #{key} to packer value...")
            config[key] = convert_hash_to_packer_value(config[key])
          end
        end

        log.debug("Leaving #{self.class}.#{__method__}")
        config
      end
    end
  end
end
