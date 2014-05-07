# encoding: utf-8

module Racker
  # This defines the version of the gem
  module Version
    MAJOR = 0
    MINOR = 1
    PATCH = 4
    BUILD = 'dev'

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')

    BANNER = 'Racker v%s'

    module_function

    def version
      sprintf(BANNER, STRING)
    end
  end
end
