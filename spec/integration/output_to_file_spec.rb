require 'spec_helper'

RSpec.describe :output_to_file do
  before(:all) do
    @output_path = "/tmp/#{SecureRandom.uuid}/this_directory_should_not_exist/template.json"
    @instance = Racker::CLI.new(['-q', fixture_path('low_priority_template.rb'), @output_path])
  end

  context 'when successful' do
    it 'writes the computed template to the given path' do
      output_dir = File.dirname(@output_path)
      FileUtils.rm_rf(output_dir) if Dir.exists?(output_dir)

      @instance.execute!
      expect(File.exists?(@output_path)).to eq(true)

      result = JSON.parse(File.read(@output_path))
      expect(result).to eq(parsed_low_priority_template)
    end
  end
end
