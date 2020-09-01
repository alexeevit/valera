require 'valera/generator'
require 'valera/chain'
require 'valera/chain_builder'
require 'valera/adapters/memory'

describe Valera::Generator do
  subject { described_class.new(chain) }
  let(:chain) { Valera::Chain.new(adapter) }
  let(:adapter) { Valera::Adapters::Memory.new }
  let(:builder) { Valera::ChainBuilder.new(chain) }

  describe '#get' do
    before do
      builder.add('It is a first sentence!')
    end

    it 'generates a sentence with a length of n words' do
      expect(subject.get(5).split(' ').size).to eq(5)
    end

    it 'starts with the specified word' do
      expect(subject.get(5, 'first')).to start_with('first')
    end

    it 'starts with random word if the specified word does not present' do
      expect(subject.get(5, 'wrong')).to be_kind_of(String)
    end

    it 'gets next word from the chain' do
      expect(subject.get(2, 'first')).to eq('first sentence')
    end
  end
end
