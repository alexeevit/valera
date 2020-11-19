require 'valera/logger'

describe Valera::Logger do
  let(:stdout) { StringIO.new }

  subject { described_class.new(stdout, level) }

  describe '#error' do
    before { subject.error('hello') }

    context 'log_level is info' do
      let(:level) { :info }

      it 'does not write log' do
        expect(stdout.string).to be_empty
      end
    end

    context 'log_level is debug' do
      let(:level) { :debug }

      it 'does not write log' do
        expect(stdout.string).to be_empty
      end
    end

    context 'log_level is error' do
      let(:level) { :error }

      it 'writes log' do
        expect(stdout.string).to match(/hello/)
      end
    end
  end

  describe '#debug' do
    before { subject.debug('hello') }

    context 'log_level is info' do
      let(:level) { :info }

      it 'does not write log' do
        expect(stdout.string).to be_empty
      end
    end

    context 'log_level is debug' do
      let(:level) { :debug }

      it 'writes log' do
        expect(stdout.string).to match(/hello/)
      end
    end

    context 'log_level is error' do
      let(:level) { :error }

      it 'writes log' do
        expect(stdout.string).to match(/hello/)
      end
    end
  end

  describe '#info' do
    before { subject.info('hello') }

    context 'log_level is info' do
      let(:level) { :info }

      it 'writes log' do
        expect(stdout.string).to match(/hello/)
      end
    end

    context 'log_level is debug' do
      let(:level) { :debug }

      it 'writes log' do
        expect(stdout.string).to match(/hello/)
      end
    end

    context 'log_level is error' do
      let(:level) { :error }

      it 'writes log' do
        expect(stdout.string).to match(/hello/)
      end
    end
  end
end
