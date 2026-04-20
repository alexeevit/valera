describe Valera::Bigram::Generation::Sampler do
  let(:model) { Valera::Bigram::Model.new(Redis.new, '123') }

  describe '#call' do
    context 'when model has data' do
      subject(:sampler) { described_class.new(model, seed: 42) }

      before do
        model.insert(
          ['<s>', 'hello']   => { 'world' => 5 },
          ['hello', 'world'] => { '.' => 5 },
          ['world', '.']     => { '</s>' => 5 },
          ['<s>', 'bye']     => { '!' => 5 },
          ['bye', '!']       => { '</s>' => 5 },
        )
      end

      it 'generates 2 sentences for seed 42' do
        expect(sampler.call).to eq(['<s>', 'bye', '!', '</s>', '<s>', 'bye', '!', '</s>'])
      end

      it 'generates 3 sentences for seed 5' do
        expect(described_class.new(model, seed: 5).call).to eq([
          '<s>', 'hello', 'world', '.', '</s>',
          '<s>', 'hello', 'world', '.', '</s>',
          '<s>', 'bye', '!', '</s>',
        ])
      end
    end

    context 'when model is empty' do
      subject(:sampler) { described_class.new(model, seed: 42) }

      it 'returns an empty array' do
        expect(sampler.call).to eq([])
      end
    end
  end
end
