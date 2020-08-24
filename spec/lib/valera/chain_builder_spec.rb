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
      expect(chain).to receive(:add).exactly(5).and_call_original
      subject.add('Hello world! My name is Valera!')
      expect(chain.get_all).to eq({
        'Hello' => { 'world' => { 'transitions' => 1, 'frequency' => 100 } },
        'world' => { 'My' => { 'transitions' => 1, 'frequency' => 100 } },
        'My' => { 'name' => { 'transitions' => 1, 'frequency' => 100 } },
        'name' => { 'is' => { 'transitions' => 1, 'frequency' => 100 } },
        'is' => { 'Valera' => { 'transitions' => 1, 'frequency' => 100 } },
      })
    end
  end
end
