require 'racker'

class RSpec::Core::ExampleGroup
  FIXTURE_DIR = File.expand_path('../fixtures', __FILE__)

  def fixture_path(filename)
    File.join(FIXTURE_DIR, filename.to_s)
  end
end
