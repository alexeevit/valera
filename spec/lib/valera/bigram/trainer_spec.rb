describe Valera::Bigram::Trainer do
  subject(:trainer) { described_class.new(model) }

  let(:model) { Valera::Bigram::Model.new(Redis.new, '123') }

  describe '#call' do
    it 'saves bigram transitions to the model' do
      trainer.call('hello world')

      expect(model.transitions('<s>', 'hello')).to eq('world' => 1)
      expect(model.transitions('hello', 'world')).to eq('</s>' => 1)
    end

    it 'normalizes the message before training' do
      trainer.call('Hello World')

      expect(model.transitions('<s>', 'hello')).to eq('world' => 1)
    end

    it 'increments counts on repeated training' do
      trainer.call('hello world')
      trainer.call('hello world')

      expect(model.transitions('<s>', 'hello')).to eq('world' => 2)
    end

    it 'handles multiple sentences' do
      trainer.call('hi. bye')

      expect(model.transitions('<s>', 'hi')).to eq('.' => 1)
      expect(model.transitions('</s>', '<s>')).to eq('bye' => 1)
    end
  end
end
