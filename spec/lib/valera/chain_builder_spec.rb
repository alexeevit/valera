require 'valera/chain_builder'
require 'valera/chain'
require 'valera/parser'
require 'valera/adapters/memory'

describe Valera::ChainBuilder do
  subject(:builder) { described_class.new(chain) }
  let(:chat_id) { '123456' }
  let(:chain) { Valera::Chain.new(adapter, chat_id) }
  let(:adapter) { Valera::Adapters::Memory.new }

  describe '#initialize' do
    it 'saves chain and parser' do
      expect(builder.send(:chain)).to be_kind_of(Valera::Chain)
      expect(builder.send(:parser)).to be_kind_of(Valera::Parser)
    end
  end

  describe '#add' do
    context 'when the chain is empty' do
      it 'adds each word to the chain' do
        expect(chain).to receive(:add).exactly(11).and_call_original
        builder.add('Hello world! My name is Valera! And you')
        expect(chain.get_all).to eq({
          '^' => {
            'hello' => { 'transitions' => 1, 'frequency' => 33 },
            'my' => { 'transitions' => 1, 'frequency' => 33 },
            'and' => { 'transitions' => 1, 'frequency' => 33 },
          },
          'hello' => { 'world' => { 'transitions' => 1, 'frequency' => 100 } },
          'world' => { '!' => { 'transitions' => 1, 'frequency' => 100 } },
          'my' => { 'name' => { 'transitions' => 1, 'frequency' => 100 } },
          'name' => { 'is' => { 'transitions' => 1, 'frequency' => 100 } },
          'is' => { 'valera' => { 'transitions' => 1, 'frequency' => 100 } },
          'valera' => { '!' => { 'transitions' => 1, 'frequency' => 100 } },
          'and' => { 'you' => { 'transitions' => 1, 'frequency' => 100 } },
          'you' => { '$' => { 'transitions' => 1, 'frequency' => 100 } },
        })
      end
    end

    context 'when the chain is not empty' do
      before do
        builder.add('Hello world! My name is Valera! And you')
      end

      it 'adds all words to existing words' do
        builder.add('Hello Valera, how are you?')

        expect(chain.get_all).to match(
          '^' => {
            'hello' => { 'transitions' => 2, 'frequency' => 50 },
            'my' => { 'transitions' => 1, 'frequency' => 25 },
            'and' => { 'transitions' => 1, 'frequency' => 25 },
          },
          'hello' => {
            'world' => { 'transitions' => 1, 'frequency' => 50 },
            'valera' => { 'transitions' => 1, 'frequency' => 50 },
          },
          'world' => { '!' => { 'transitions' => 1, 'frequency' => 100 } },
          'my' => { 'name' => { 'transitions' => 1, 'frequency' => 100 } },
          'name' => { 'is' => { 'transitions' => 1, 'frequency' => 100 } },
          'is' => { 'valera' => { 'transitions' => 1, 'frequency' => 100 } },
          'valera' => {
            '!' => { 'transitions' => 1, 'frequency' => 50 },
            ',' => { 'transitions' => 1, 'frequency' => 50 },
          },
          'and' => { 'you' => { 'transitions' => 1, 'frequency' => 100 } },
          'you' => {
            '$' => { 'transitions' => 1, 'frequency' => 50 },
            '?' => { 'transitions' => 1, 'frequency' => 50 },
          },
          ',' => { 'how' => { 'transitions' => 1, 'frequency' => 100 } },
          'how' => { 'are' => { 'transitions' => 1, 'frequency' => 100 } },
          'are' => { 'you' => { 'transitions' => 1, 'frequency' => 100 } },
        )
      end
    end
  end

  describe '#stats' do
    before { builder.add('Hello world! My name is Valera! And you') }
    it 'returns hash with proper data' do
      expect(builder.stats).to eq({
        pairs_count: 11,
        transitions_count: 11,
      })
    end
  end
end
