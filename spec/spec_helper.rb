require 'racker'

class RSpec::Core::ExampleGroup
  FIXTURE_DIR = File.expand_path('../fixtures', __FILE__)
  PARSED_LOW_PRIORITY_TEMPLATE = {
    'variables' => {
      'iso_url' => 'os.img',
      'password' => 'password',
    },
  }.freeze

  def fixture_path(filename)
    File.join(FIXTURE_DIR, filename.to_s)
  end

  def parsed_low_priority_template
    PARSED_LOW_PRIORITY_TEMPLATE
  end
end
