describe Valera::Bigram::Generator do
  let(:model) { Valera::Bigram::Model.new(Redis.new, '123') }

  before do
    model.insert(
      ['<s>', 'hello']   => { 'world' => 5 },
      ['hello', 'world'] => { '.' => 5 },
      ['world', '.']     => { '</s>' => 5 },
      ['<s>', 'bye']     => { '!' => 5 },
      ['bye', '!']       => { '</s>' => 5 },
    )
  end

  describe '#call' do
    it 'generates a formatted message for seed 42' do
      generator = described_class.new(model, mention: '@valera', seed: 42)
      expect(generator.call).to eq('Bye! Bye!')
    end

    it 'generates a formatted message for seed 5' do
      generator = described_class.new(model, mention: '@valera', seed: 5)
      expect(generator.call).to eq('Hello world. Hello world. Bye!')
    end
  end
end
