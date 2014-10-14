require 'spec_helper'

RSpec.describe Racker::LogSupport do
  before(:all) do
    # Must call described_class outside of Class.new block so method lookup
    # resolves against test scope rather than block scope
    klass = described_class
    DummyClass = Class.new { include klass }
    @instance = DummyClass.new
  end

  context '::logger' do
    it 'returns the global Log4r logger for racker' do
      expect(described_class.logger).to eq(Log4r::Logger['racker'])
    end
  end

  context '::level=' do
    it 'sets the logger level based on the provided level string' do
      described_class.level = 'error'
      expect(described_class.logger.level).to eq(Log4r::ERROR)
    end
  end

  context '::log4r_log_level_for' do
    it 'returns Log4r::DEBUG for values matching debug' do
      expect(described_class.log4r_level_for('debug')).to eq(Log4r::DEBUG)
      expect(described_class.log4r_level_for(:debug)).to eq(Log4r::DEBUG)
    end

    it 'returns Log4r::ERROR for values matching error' do
      expect(described_class.log4r_level_for('error')).to eq(Log4r::ERROR)
      expect(described_class.log4r_level_for(:error)).to eq(Log4r::ERROR)
    end

    it 'returns Log4r::FATAL for values matching fatal' do
      expect(described_class.log4r_level_for('fatal')).to eq(Log4r::FATAL)
      expect(described_class.log4r_level_for(:fatal)).to eq(Log4r::FATAL)
    end

    it 'returns Log4r::INFO for values matching info' do
      expect(described_class.log4r_level_for('info')).to eq(Log4r::INFO)
      expect(described_class.log4r_level_for(:info)).to eq(Log4r::INFO)
    end

    it 'returns Log4r::WARN for values matching warn' do
      expect(described_class.log4r_level_for('warn')).to eq(Log4r::WARN)
      expect(described_class.log4r_level_for(:warn)).to eq(Log4r::WARN)
    end

    it 'returns Log4r::INFO otherwise' do
      expect(described_class.log4r_level_for('emergency')).to eq(Log4r::INFO)
      expect(described_class.log4r_level_for(:emergency)).to eq(Log4r::INFO)
    end
  end

  context '#logger' do
    it 'returns the global Log4r logger for racker' do
      expect(@instance.logger).to eq(Log4r::Logger['racker'])
    end
  end
end
