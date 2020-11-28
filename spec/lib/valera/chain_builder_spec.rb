require 'valera/chain_builder'
require 'valera/chain'
require 'valera/parser'
require 'valera/adapters/memory'

describe Valera::ChainBuilder do
  subject { described_class.new(chain) }
  let(:chain) { Valera::Chain.new(adapter) }
  let(:adapter) { Valera::Adapters::Memory.new }

  describe '#initialize' do
    it 'saves chain and parser' do
      expect(subject.send(:chain)).to be_kind_of(Valera::Chain)
      expect(subject.send(:parser)).to be_kind_of(Valera::Parser)
    end
  end

  describe '#add' do
    it 'adds each word to the chain' do
      expect(chain).to receive(:add).exactly(11).and_call_original
      subject.add('Hello world! My name is Valera! And you')
      expect(chain.get_all).to eq({
        '^' => {
          'hello' => { 'transitions' => 1, 'frequency' => 33 },
          'my' => { 'transitions' => 1, 'frequency' => 33 },
          'and' => { 'transitions' => 1, 'frequency' => 34 },
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

  describe '#stats' do
    before { subject.add('Hello world! My name is Valera! And you') }
    it 'returns hash with proper data' do
      expect(subject.stats).to eq({
        pairs_count: 11,
        transitions_count: 11,
      })
    end
  end
end
