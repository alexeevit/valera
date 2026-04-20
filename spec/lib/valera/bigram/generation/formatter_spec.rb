describe Valera::Bigram::Generation::Formatter do
  subject(:formatter) { described_class.new(mention: '@valera') }

  describe '#call' do
    it 'capitalizes the first word of each sentence' do
      expect(formatter.call(['<s>', 'hello', '</s>'])).to eq('Hello')
    end

    it 'handles multiple sentences' do
      tokens = ['<s>', 'hello', '</s>', '<s>', 'bye', '</s>']
      expect(formatter.call(tokens)).to eq("Hello\nBye")
    end

    it 'attaches punctuation to the preceding word' do
      tokens = ['<s>', 'hello', ',', 'world', '.', '</s>']
      expect(formatter.call(tokens)).to eq('Hello, world.')
    end

    it 'removes <s> and </s> markers' do
      result = formatter.call(['<s>', 'hello', '</s>'])
      expect(result).not_to include('<s>', '</s>')
    end

    it 'replaces <mention> with the given mention' do
      tokens = ['<s>', 'hi', '<mention>', '</s>']
      expect(formatter.call(tokens)).to eq('Hi @valera')
    end

    it 'replaces <num> with a number' do
      allow(formatter).to receive(:rand).with(1..9999).and_return(42)
      tokens = ['<s>', 'i', 'have', '<num>', 'cats', '</s>']
      expect(formatter.call(tokens)).to eq('I have 42 cats')
    end

    it 'replaces <url> with a fake url' do
      allow(Faker::Internet).to receive(:url).and_return('http://example.com')
      tokens = ['<s>', 'see', '<url>', '</s>']
      expect(formatter.call(tokens)).to eq('See http://example.com')
    end
  end
end
