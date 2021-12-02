require 'valera/generator'
require 'valera/chain'
require 'valera/parser'
require 'valera/chain_builder'
require 'valera/adapters/memory'

describe Valera::Generator do
  subject(:generator) { described_class.new(chain) }
  let(:chain) { Valera::Chain.new(adapter, chat_id) }
  let(:chat_id) { '123456' }
  let(:adapter) { Valera::Adapters::Memory.new }
  let(:builder) { Valera::ChainBuilder.new(chain) }

  describe '#get' do
    context 'when chain is empty' do
      it 'returns nil' do
        expect(generator.get(5)).to be_nil
      end
    end

    context 'when chain has the single word' do
      before do
        builder.add('hi')
      end

      it 'returns the word n times' do
        expect(generator.get(5)).to eq('hi hi hi hi hi')
      end
    end

    context 'when chain is not empty' do
      before do
        builder.add('It is a first sentence!')
      end

      subject(:sentence) { generator.get(5) }
      let(:words) { sentence.split(' ') }

      it 'still generates a string of n words with an initial word' do
        expect(words.first).to eq('it')
        expect(sentence).to eq('it is a first sentence')
      end
    end

    context 'when chain includes punctuation marks' do
      before do
        builder.add('Hey, is front-end - ok?')
      end

      subject(:sentence) { generator.get(6) }

      it 'removes spaces before punctuation marks' do
        expect(sentence).to eq('hey, is front-end - ok? hey')
      end
    end
  end

  describe '#get_to_start_sentence' do
    before { builder.add('It is a first sentence! And a horse!') }

    it 'returns some word to start the sentence' do
      expect(%w(it and)).to include(generator.send(:get_to_start_sentence))
    end
  end

  describe '#get_next' do
    before { builder.add('It is a first sentence! And a horse!') }

    context 'when the word has continuing next words' do
      let(:prev_word) { 'a' }

      it 'returns a continuing word' do
        expect(%w(first horse)).to include(generator.send(:get_next, prev_word))
      end
    end

    context 'when the word does not have continuing next words' do
      let(:prev_word) { 'first' }

      it 'returns an ending word' do
        expect(generator.send(:get_next, prev_word)).to eq('sentence')
      end
    end

    context 'when the word does not have next words' do
      let(:prev_word) { '!' }

      it 'returns nil' do
        expect(generator.send(:get_next, prev_word)).to be_nil
      end
    end
  end

  describe '#select_next' do
    let(:transitions) {
      {
        'b' => {
          'transitions' => 4,
          'frequency' => BigDecimal('0.4'),
        },

        'c' => {
          'transitions' => 5,
          'frequency' => BigDecimal('0.5'),
        },

        'a' => {
          'transitions' => 1,
          'frequency' => BigDecimal('0.1'),
        },
      }
    }

    it 'selects correct word' do
      expect(generator.send(:select_next, transitions, BigDecimal('0.1'))).to eq('a')
      expect(generator.send(:select_next, transitions, BigDecimal('0.5'))).to eq('b')
      expect(generator.send(:select_next, transitions, BigDecimal('0.51'))).to eq('c')
    end

    context 'when there are no transitions' do
      it 'returns nil' do
        expect(generator.send(:select_next, {})).to be_nil
      end
    end
  end
end
