guard :rspec, all_after_pass: true, all_on_start: true, keep_failed: true do
  watch(%r{^lib/(.+)\.rb$})        { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')     { "spec" }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/support/.+\.rb$}) { "spec" }
end

guard :rubocop do
  watch(%r{.+\.rb$})
  watch(%r{bin/.*$})
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

guard :bundler do
  watch('Gemfile')
  watch('racker.gemspec')
end

notification :gntp, :sticky => false, :host => '127.0.0.1'
