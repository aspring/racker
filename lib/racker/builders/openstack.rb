# encoding: utf-8
require 'racker/builders/builder'

module Racker
  module Builders
    # This is the OpenStack builder
    class OpenStack < Racker::Builders::Builder
      def to_packer(name, config)
        log = Log4r::Logger['racker']
        log.debug("Entering #{self.class}.#{__method__}")
        config = super(name, config)

        %w(security_groups).each do |key|
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
