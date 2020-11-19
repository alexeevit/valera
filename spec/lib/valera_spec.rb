require 'valera'

describe Valera do
  describe '.logger' do
    it 'returns a Logger instance' do
      expect(described_class.logger).to be_instance_of(Valera::Logger)
    end
  end
end
