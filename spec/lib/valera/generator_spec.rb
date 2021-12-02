require 'valera/generator'
require 'valera/chain'
require 'valera/parser'
require 'valera/chain_builder'
require 'valera/adapters/memory'

describe Valera::Generator do
  subject { described_class.new(chain) }
  let(:chain) { Valera::Chain.new(adapter, chat_id) }
  let(:chat_id) { '123456' }
  let(:adapter) { Valera::Adapters::Memory.new }
  let(:builder) { Valera::ChainBuilder.new(chain) }

  describe '#get' do
    context 'when chain is empty' do
      it 'returns nil' do
        expect(subject.get(5)).to be_nil
      end
    end

    context 'when chain has the single word' do
      before do
        builder.add('hi')
      end

      it 'returns the word n times' do
        expect(subject.get(5)).to eq('hi hi hi')
      end
    end

    context 'when chain is not empty' do
      before do
        builder.add('It is a first sentence!')
      end

      let(:words) { subject.get(5).split(' ') }

      it 'still generates a string of n words with a random initial word' do
        expect(words.first).to eq('it')
        expect(%w(it is a first sentence)).to include(words.first.downcase)
        expect(words.size).to be >= 5
      end
    end
  end

  describe '#get_to_start_sentence' do
    before { builder.add('It is a first sentence! And a horse!') }

    it 'returns some word to start the sentence' do
      expect(%w(it and)).to include(subject.send(:get_to_start_sentence))
    end
  end

  describe '#get_to_continue' do
    before { builder.add('It is a first sentence! And a horse!') }

    context 'when the word has continuing next words' do
      let(:prev_word) { 'a' }

      it 'returns a continuing word' do
        expect(subject.send(:get_to_continue, prev_word)).to eq('first')
      end
    end

    context 'when the word does not have continuing next words' do
      let(:prev_word) { 'first' }

      it 'returns an ending word' do
        expect(subject.send(:get_to_continue, prev_word)).to eq('sentence')
      end
    end

    context 'when the word does not have next words' do
      let(:prev_word) { '!' }

      it 'returns nil' do
        expect(subject.send(:get_to_continue, prev_word)).to be_nil
      end
    end
  end

  describe '#select_next' do
    let(:transitions) {
      {
        'a' => {
          'transitions' => 4,
          'frequency' => 40,
        },

        'b' => {
          'transitions' => 5,
          'frequency' => 50,
        },

        'c' => {
          'transitions' => 1,
          'frequency' => 10,
        },
      }
    }

    it 'selects correct word' do
      expect(subject.send(:select_next, transitions, 20)).to eq('a')
      expect(subject.send(:select_next, transitions, 90)).to eq('b')
      expect(subject.send(:select_next, transitions, 91)).to eq('c')
    end

    context 'when there are no transitions' do
      it 'returns nil' do
        expect(subject.send(:select_next, {})).to be_nil
      end
    end
  end

  describe '#calculate_frequencies' do
    let(:original) {
      {
        'a' => {
          'transitions' => 4,
          'frequency' => 40,
        },

        'b' => {
          'transitions' => 5,
          'frequency' => 50,
        },
      }
    }

    let(:expected) {
      {
        'a' => {
          'transitions' => 4,
          'frequency' => 44,
        },

        'b' => {
          'transitions' => 5,
          'frequency' => 56,
        },
      }
    }

    it 'returns a new hash with new frequencies' do
      expect(subject.send(:calculate_frequencies, original)).to eq(expected)
    end
  end
end
