# encoding: utf-8

module Racker

  module Builders
    # This is the Builder base class
    class Builder
      include Racker::LogSupport

      def to_packer(name, config)
        logger.debug("Entering #{self.class}.#{__method__}")

        # Set the name of the builder
        logger.info("Setting config name to #{name}")
        config['name'] = name

        logger.debug("Leaving #{self.class}.#{__method__}")
        config
      end

      def convert_hash_to_packer_value(config)
        config.kind_of?(Hash) ? config.values : config
      end
    end
  end
end
