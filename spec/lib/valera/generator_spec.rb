require 'valera/generator'
require 'valera/chain'
require 'valera/parser'
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

    context 'when the initial word is specified' do
      it 'starts with the specified word' do
        expect(subject.get(5, 'first')).to start_with('first')
      end

      it 'gets next word from the chain and finishes the sentence' do
        expect(subject.get(2, 'a')).to eq('a first sentence!')
      end
    end

    context 'when the initial word is not present' do
      it 'starts with a random initial word' do
        expect(subject.get(5, 'wrong')).to be_kind_of(String)
      end
    end

    context 'when the initial word is not specified' do
      let(:words) { subject.get(5).split(' ') }

      it 'still generates a string of n words with a random initial word' do
        expect(words.first).to eq('it')
        expect(%w(it is a first sentence)).to include(words.first.downcase)
        expect(words.size).to be >= 5
      end
    end
  end

  describe '#get_to_start' do
    before { builder.add('It is a first sentence! And a horse!') }

    it 'returns some word to start the sentence' do
      expect(%w(it and)).to include(subject.send(:get_to_start))
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

  describe '#get_with_ending' do
    before { builder.add('It is a first sentence! And the first try was ok') }

    context 'when the word has ending next words' do
      let(:prev_word) { 'a' }

      it 'returns ending word' do
        expect(subject.send(:get_with_ending, 'first')).to eq(['sentence', '!'])
        expect(subject.send(:get_with_ending, 'was')).to eq(['ok'])
      end
    end

    context 'when the words does not have ending next words' do
      let(:prev_word) { 'and' }

      it 'returns nil' do
        expect(subject.send(:get_with_ending, prev_word)).to be_nil
      end
    end

    context 'when the word does not have next words' do
      let(:prev_word) { 'ok' }

      it 'returns nil' do
        expect(subject.send(:get_with_ending, prev_word)).to be_nil
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
