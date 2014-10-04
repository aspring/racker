require 'spec_helper'

RSpec.describe Racker::CLI do

  context '#execute!' do
    it 'exits with a status of 1 if fewer than 2 arguments were received' do
      allow(Kernel).to receive(:exit!)

      instance = Racker::CLI.new(['template.rb'])
      allow(instance).to receive(:puts)

      # This next call is going to break somewhere because we stubbed the exit!
      # call, so catch any error that occurs.
      instance.execute! rescue nil

      # set expextation on puts to silence output
      expect(instance).to have_received(:puts)
      expect(Kernel).to have_received(:exit!).with(1)
    end

    context 'with valid options' do
      before(:each) do
        @immutable_argv = ['template.rb', 'environment.rb', 'template.json'].freeze
        @argv = @immutable_argv.dup
        @instance = Racker::CLI.new(@argv)
        @options = @instance.send(:options)
        @options[:quiet] = true
        # Prevent fake file from being written
        allow(File).to receive(:open)
      end

      it 'uses the last argument for the value of the output option' do
        allow_any_instance_of(Racker::Processor).to receive(:execute!)
        @instance.execute!
        expect(@options[:output]).to eq(@immutable_argv.last)
      end

      it 'uses all arguments except the last for the value of the templates option' do
        allow_any_instance_of(Racker::Processor).to receive(:execute!)
        @instance.execute!
        expect(@options[:templates]).to eq(@immutable_argv[0..-2])
      end

      it 'initializes and executes a new Racker::Processor with the given options' do
        processor_instance = Racker::Processor.new(@options)
        expect(Racker::Processor).to receive(:new) { processor_instance }.with(@options)
        expect(processor_instance).to receive(:execute!)
        @instance.execute!
      end

      it 'outputs no message when quieted' do
        @options[:quiet] = true
        allow_any_instance_of(Racker::Processor).to receive(:execute!)
        expect(@instance).not_to receive(:puts)
        @instance.execute!
      end

      it 'outputs a message upon success when not quieted' do
        @options[:quiet] = false
        allow_any_instance_of(Racker::Processor).to receive(:execute!)
        expect(@instance).to receive(:puts).at_least(1)
        @instance.execute!
      end

      it 'returns 0 on success' do
        allow_any_instance_of(Racker::Processor).to receive(:execute!)
        expect(@instance.execute!).to eq(0)
      end
    end
  end

  context '#initialize' do
    it 'sets the @argv instance variable to the provided argument' do
      instance = described_class.new(argv = [])
      expect(instance.instance_variable_get(:@argv).object_id).to eq(argv.object_id)
    end
  end

  context '#option_parser' do
    before(:each) { @instance = described_class.new([]) }

    it 'returns a new default OptionParser if none exists' do
      expect(@instance.instance_variable_get(:@option_parser)).to eq(nil)
      expect(@instance.send(:option_parser)).to be_an(OptionParser)
    end

    it 'returns the same OptionParser on subsequent calls' do
      first_option_parser = @instance.send(:option_parser)
      second_option_parser = @instance.send(:option_parser)
      expect(second_option_parser).to be(first_option_parser)
    end
  end

  context '#options' do
    before(:each) { @instance = described_class.new([]) }

    it 'returns a Hash of default options if none exists' do
      expect(@instance.instance_variable_get(:@options)).to eq(nil)
      options = @instance.send(:options)
      expect(options).to eq({
        log_level:     :warn,
        knockout:      '~~',
        output:        '',
        templates:     [],
        quiet:         false,
      })
    end

    it 'returns the same Hash on subsequent calls' do
      first_options = @instance.send(:options)
      second_options = @instance.send(:options)
      expect(second_options).to be(first_options)
    end
  end

  context 'option parser' do
    before(:all) { @instance = described_class.new([]) }
    before(:each) do
      @instance.instance_variable_set(:@option_parser, nil)
      @instance.instance_variable_set(:@options, nil)
      @parser = @instance.send(:option_parser)
      @options = @instance.send(:options)
    end

    context 'log_level' do
      %w[-l --log-level].each do |format|
        it "is triggered by the #{format} arg" do
          @options.delete(:log_level)
          @parser.parse!(%W[#{format} fatal])
          expect(@options[:log_level]).to be(:fatal)
        end
      end

      %w[debug error fatal info warn].each do |log_level|
        it "supports a log level of #{log_level}" do
          @options.delete(:log_level)
          @parser.parse!(%W[-l #{log_level}])
          expect(@options[:log_level]).to be(log_level.to_sym)
        end
      end

      it 'defaults invalid log levels to nil' do
        @options.delete(:log_level)
        @parser.parse!(%W[-l foo])
        expect(@options[:log_level]).to be(nil)
      end
    end

    context 'knockout' do
      %w[-k --knockout].each do |format|
        it "is triggered by the #{format} arg" do
          @options.delete(:knockout)
          @parser.parse!(%W[#{format} xxx])
          expect(@options[:knockout]).to eq('xxx')
        end
      end
    end

    context 'quiet' do
      %w[-q --quiet].each do |format|
        it "is triggered by the #{format} arg" do
          @options.delete(:quiet)
          @parser.parse!([format])
          expect(@options[:quiet]).to eq(true)
        end
      end
    end

    context 'help' do
      %w[-h --help].each do |format|
        it "is triggered by the #{format} arg" do
          expect(@instance).to receive(:puts)
          expect(Kernel).to receive(:exit!)
          @parser.parse!([format])
        end
      end

      it 'outputs help then exits with a status of 0' do
        expect(@instance).to receive(:puts)
        expect(Kernel).to receive(:exit!).with(0)
        @parser.parse!(['--help'])
      end
    end

    context 'version' do
      %w[-v --version].each do |format|
        it "is triggered by the #{format} arg" do
          expect(@instance).to receive(:puts)
          expect(Kernel).to receive(:exit!)
          @parser.parse!([format])
        end
      end

      it 'outputs the version then exits with a status of 0' do
        expect(@instance).to receive(:puts)
        expect(Kernel).to receive(:exit!).with(0)
        @parser.parse!(['--version'])
      end
    end
  end
end
