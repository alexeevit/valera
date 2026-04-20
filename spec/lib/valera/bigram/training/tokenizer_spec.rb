describe Valera::Bigram::Training::Tokenizer do
  subject(:tokenizer) { described_class }

  describe '.call' do
    it 'returns empty array for empty text' do
      expect(tokenizer.call('')).to eq([])
    end

    it 'wraps multiple words in sentence markers' do
      expect(tokenizer.call('hello world')).to eq(['<s>', 'hello', 'world', '</s>'])
    end

    it 'emits punctuation as separate tokens' do
      expect(tokenizer.call('hello, world')).to eq(['<s>', 'hello', ',', 'world', '</s>'])
    end

    it 'closes and opens sentence on .' do
      expect(tokenizer.call('hello. world')).to eq(['<s>', 'hello', '.', '</s>', '<s>', 'world', '</s>'])
    end

    it 'closes and opens sentence on newline' do
      expect(tokenizer.call("hello\nworld")).to eq(['<s>', 'hello', '</s>', '<s>', 'world', '</s>'])
    end

    it 'does not emit newline as a token' do
      expect(tokenizer.call("hello\nworld")).not_to include("\n")
    end

    it 'keeps special tokens intact' do
      expect(tokenizer.call('see <url> and <mention>')).to eq(['<s>', 'see', '<url>', 'and', '<mention>', '</s>'])
    end

    it 'handles text ending with sentence-ending punctuation' do
      expect(tokenizer.call('hello!')).to eq(['<s>', 'hello', '!', '</s>'])
    end

    it 'keeps hyphenated words as a single token' do
      expect(tokenizer.call('back-end development')).to eq(['<s>', 'back-end', 'development', '</s>'])
    end

    it 'handles multiple sentences' do
      expect(tokenizer.call('hi! bye')).to eq(['<s>', 'hi', '!', '</s>', '<s>', 'bye', '</s>'])
    end
  end
end
