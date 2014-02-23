require 'racker/smash/mash'
require 'racker/smash/deep_merge_modified'

# This class wraps mash and adds extended smart functionality
class Smash < Mash

  def [](key)
    if !key?(key)
      self[key] = self.class.new
    else
      super
    end
  end

  def compact(opts={})
    inject(self.class.new) do |new_hash, (k,v)|
      unless v.nil?
        new_hash[k] = opts[:recurse] && v.class == self.class ? v.compact(opts) : v
      end
      new_hash
    end
  end

  def convert_value(value)
    case value
    when Smash
      value
    when Mash
      self.class.new(value)
    when Hash
      self.class.new(value)
    else
      value
    end
  end

  def deep_merge!(source, options = {})
    default_opts = {:preserve_unmergeables => false}
    DeepMergeModified::deep_merge!(source, self, default_opts.merge(options))
  end

  def dup
    self.class.new(self)
  end

  def method_missing(symbol, *args)
    if symbol == :to_ary
      super
    elsif args.empty?
      self[symbol]
    elsif symbol.to_s =~ /=$/
      key_to_set = symbol.to_s[/^(.+)=$/, 1]
      self[key_to_set] = (args.length == 1 ? args[0] : args)
    else
      raise NoMethodError, "Undefined key or method `#{symbol}' on `Smash`."
    end
  end
end
