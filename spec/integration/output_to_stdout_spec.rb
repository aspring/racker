require 'spec_helper'

RSpec.describe :output_to_stdout do
  before(:all) do
    @instance = Racker::CLI.new([fixture_path('low_priority_template.rb'), '-'])
  end

  context 'when successful' do
    it 'writes the computed template to $stdout' do
      pretty_output = JSON.pretty_generate(parsed_low_priority_template)
      expect(@instance).to receive(:puts).never
      expect($stdout).to receive(:write).with(pretty_output)
      @instance.execute!
    end
  end
end
