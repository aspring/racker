require 'racker'

def initialize_logger
  return if Log4r::Logger['racker']

  log = Log4r::Logger.new('racker')
  log.outputters = Log4r::Outputter.stdout
  log.level = Log4r::ERROR
  nil
end
initialize_logger

class RSpec::Core::ExampleGroup
  FIXTURE_DIR = File.expand_path('../fixtures', __FILE__)

  def fixture_path(filename)
    File.join(FIXTURE_DIR, filename.to_s)
  end
end
