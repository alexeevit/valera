require 'valera/chain'
require 'valera/adapters/memory'

describe Valera::Chain do
  subject { described_class.new(adapter, chat_id) }
  let(:chat_id) { '123456' }
  let(:adapter) { Valera::Adapters::Memory.new }

  describe '#get' do
    before { subject.add(prev_word, next_word) }

    let(:prev_word) { 'a' }
    let(:next_word) { 'b' }

    it 'returns all transitions for the word' do
      expect(subject.get(prev_word)).to eq({
        next_word => {
          'transitions' => 1,
          'frequency' => 1,
        }
      })
    end

    context 'when the word does not present' do
      it 'returns empty hash' do
        expect(subject.get('c')).to eq({})
      end
    end
  end

  describe '#add' do
    let(:prev_word) { 'a' }
    let(:next_word) { 'b' }

    context 'when prev_word not present' do
      it 'returns new transition' do
        expect(subject.add(prev_word, next_word)).to eq({
          'transitions' => 1,
          'frequency' => 1,
        })
      end

      it 'adds new word to the hash' do
        subject.add(prev_word, next_word)
        expect(subject.get(prev_word)).to eq({
          next_word => {
            'transitions' => 1,
            'frequency' => 1,
          }
        })
      end
    end

    context 'when prev_word present' do
      before { subject.add(prev_word, 'c') }

      it 'recalculates transitions' do
        expect(subject.get(prev_word)).to eq({
          'c' => {
            'transitions' => 1,
            'frequency' => 1,
          }
        })

        subject.add(prev_word, next_word)

        expect(subject.get(prev_word)).to eq({
          'c' => {
            'transitions' => 1,
            'frequency' => BigDecimal('0.5'),
          },
          next_word => {
            'transitions' => 1,
            'frequency' => BigDecimal('0.5'),
          }
        })
      end
    end

    context 'when transition presents' do
      before { subject.add(prev_word, next_word) }

      it 'increments transition' do
        expect(subject.get(prev_word).dig(next_word, 'transitions')).to eq(1)
        subject.add(prev_word, next_word)
        expect(subject.get(prev_word).dig(next_word, 'transitions')).to eq(2)
      end
    end

    context 'when transitions count passed' do
      it 'increments transition by n' do
        expect(subject.get(prev_word).dig(next_word, 'transitions')).to be_nil
        subject.add(prev_word, next_word, 2)
        expect(subject.get(prev_word).dig(next_word, 'transitions')).to eq(2)
      end
    end
  end

  describe '#purge' do
    it 'invokes adapters purge' do
      expect(adapter).to receive(:purge).and_call_original
      subject.purge
    end
  end

  describe '#has?' do
    before { subject.add(prev_word, next_word) }

    let(:prev_word) { 'a' }
    let(:next_word) { 'b' }

    it 'returns true if the chain has the word' do
      expect(subject.has?(prev_word)).to be_truthy
    end

    it 'returns false if the chain does not have the word' do
      expect(subject.has?('c')).to be_falsey
    end
  end

  describe '#random' do
    it 'calls adapters get_random_key' do
      expect(adapter).to receive(:get_random_key)
      subject.random
    end
  end
end
