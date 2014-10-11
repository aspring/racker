require 'spec_helper'
require 'fileutils'
require 'securerandom'

RSpec.describe Racker::Processor do
  DUMMY_TEMPLATE_PROC = proc { |t| nil }

  context '::register_template' do
    before(:all) do
      @instance = described_class.new({})
    end

    it 'takes a block and an optional version argument' do
      the_version = 'my_version'
      the_block = DUMMY_TEMPLATE_PROC

      captured_templates = @instance.capture_templates do
        described_class.register_template(the_version, &the_block)
      end
      version, captured_template = captured_templates.first
      expect(version).to eq(the_version)
      expect(captured_template).to eq(the_block)
    end

    it 'uses a default value of "1" for version if none is provided' do
      default_version = '1'
      captured_templates = @instance.capture_templates do
        described_class.register_template(&DUMMY_TEMPLATE_PROC)
      end
      version = captured_templates.first.first
      expect(version).to eq(default_version)
    end
  end

  context '#capture_templates' do
    before(:all) do
      @instance = described_class.new(:quiet => true)
    end

    it 'captures [version, template_proc] pairs for each call to ::register_template' do
      template_count = 5
      dummy_templates = Hash.new do |hash, key|
        hash[key] = DUMMY_TEMPLATE_PROC.dup
      end

      captured_templates = @instance.capture_templates do
        template_count.times do |version|
          described_class.register_template(version, &dummy_templates[version])
        end
      end

      expect(captured_templates.length).to eq(template_count)
      expect(captured_templates.flatten).to eq(dummy_templates.to_a.flatten)
    end
  end

  context '#execute!' do
    before(:all) do
      @options = {
        :output => "/tmp/#{SecureRandom.uuid}/this_directory_should_not_exist/template.json",
        :knockout => '~~',
        :quiet => true,
      }
      @output_path = @options[:output]
      @instance = described_class.new(@options)
    end

    it 'raises a RuntimeError if any of the provided templates do not exist' do
      @options[:templates] = [ '/tmp/this_template_should_not_exists.json' ]
      expect { @instance.execute! }.to raise_error(RuntimeError)
    end

    it 'merges the templates with a knockout_prefix matching the provided knockout option' do
      @options[:templates] = [
        fixture_path('low_priority_template.rb'),
        fixture_path('high_priority_template.rb'),
      ]
      @instance.execute!

      result = JSON.parse(File.read(@output_path))
      expect(result['variables']['password']).to eq(nil)
    end

    it 'merges the templates such that each template takes presedence over its predecessors' do
      @options[:templates] = [
        fixture_path('low_priority_template.rb'),
        fixture_path('high_priority_template.rb'),
      ]
      @instance.execute!

      result = JSON.parse(File.read(@output_path))
      expect(result['variables']['iso_url']).to eq('priority.img')
    end

    it 'removes nil values from the generated template' do
      @options[:templates] = [
        fixture_path('low_priority_template.rb'),
        fixture_path('high_priority_template.rb'),
      ]
      @instance.execute!

      result = JSON.parse(File.read(@output_path))
      expect(result['variables'].key?('nil')).to eq(false)
    end

    it 'outputs the computed template in JSON format' do
      @options[:templates] = [
        fixture_path('low_priority_template.rb'),
      ]
      @instance.execute!

      expected = {
        'variables' => {
          'iso_url' => 'os.img',
          'password' => 'password',
        },
      }
      expect(JSON.parse(File.read(@output_path))).to eq(expected)
    end

    it 'writes the computed template to a given path' do
      output_dir = File.dirname(@output_path)
      FileUtils.rm_rf(output_dir) if Dir.exists?(output_dir)

      @options.replace({
        :output => @output_path,
        :quiet => true,
        :templates => [
          fixture_path('low_priority_template.rb'),
        ],
      })

      @instance.execute!
      expect(File.exists?(@output_path)).to eq(true)
    end

  end

  context '#initialize' do
    it 'sets the options instance variable to the given argument' do
      opts = {}
      instance = described_class.new(opts)
      expect(instance.instance_variable_get(:@options).object_id).to eq(opts.object_id)
    end
  end

  context '#load' do
    before(:all) do
      @fixture = fixture_path('low_priority_template.rb')
      @options = {}
      @instance = described_class.new(@options)
    end

    it 'puts the template file if a falsy :quiet option was provided' do
      expect(@instance).to receive(:puts).exactly(3).times

      @options.delete(:quiet)
      @instance.load([@fixture])
      @options[:quiet] = nil
      @instance.load([@fixture])
      @options[:quiet] = false
      @instance.load([@fixture])
    end

    it 'puts no output if a truthy :quiet option was provided' do
      expect(@instance).to_not receive(:puts)

      @options[:quiet] = true
      @instance.load([@fixture])
      @options[:quiet] = Object.new
      @instance.load([@fixture])
    end

    it 'loads each given template path' do
      expect(Kernel).to receive(:load).with(@fixture).exactly(3).times

      @options[:quiet] = true
      @instance.load([
        @fixture,
        @fixture,
        @fixture,
      ])
    end
  end
end
