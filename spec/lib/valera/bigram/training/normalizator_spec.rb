describe Valera::Bigram::Training::Normalizator do
  subject(:normalizator) { described_class }

  describe '.call' do
    it 'downcases text' do
      expect(normalizator.call('Hello World')).to eq('hello world')
    end

    it 'replaces urls' do
      expect(normalizator.call('check https://example.com out')).to eq('check <url> out')
    end

    it 'replaces telegram mentions' do
      expect(normalizator.call('hello @valera!')).to eq('hello <mention>!')
    end

    it 'replaces numbers' do
      expect(normalizator.call('i have 42 cats')).to eq('i have <num> cats')
    end

    it 'applies all replacements together' do
      expect(normalizator.call('Hi @user, see https://example.com, 99 times'))
        .to eq('hi <mention>, see <url>, <num> times')
    end
  end
end
