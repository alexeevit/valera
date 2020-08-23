require 'valera/chain'

describe Valera::Chain do
  subject { described_class.new }

  describe '#get' do
    before { subject.add(prev_word, next_word) }

    let(:prev_word) { 'a' }
    let(:next_word) { 'b' }

    it 'returns all transitions for the word' do
      expect(subject.get(prev_word)).to eq({
        next_word => {
          transitions: 1,
          frequency: 100,
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
          transitions: 1,
          frequency: 100,
        })
      end

      it 'adds new word to the hash' do
        subject.add(prev_word, next_word)
        expect(subject.get(prev_word)).to eq({
          next_word => {
            transitions: 1,
            frequency: 100,
          }
        })
      end
    end

    context 'when prev_word present' do
      before { subject.add(prev_word, 'c') }

      it 'recalculates transitions' do
        expect(subject.get(prev_word)).to eq({
          'c' => {
            transitions: 1,
            frequency: 100,
          }
        })

        subject.add(prev_word, next_word)

        expect(subject.get(prev_word)).to eq({
          'c' => {
            transitions: 1,
            frequency: 50,
          },
          next_word => {
            transitions: 1,
            frequency: 50,
          }
        })
      end
    end

    context 'when transition presents' do
      before { subject.add(prev_word, next_word) }

      it 'increments transition' do
        expect(subject.get(prev_word).dig(next_word, :transitions)).to eq(1)
        subject.add(prev_word, next_word)
        expect(subject.get(prev_word).dig(next_word, :transitions)).to eq(2)
      end
    end

    context 'when transitions count passed' do
      it 'increments transition by n' do
        expect(subject.get(prev_word).dig(next_word, :transitions)).to be_nil
        subject.add(prev_word, next_word, 2)
        expect(subject.get(prev_word).dig(next_word, :transitions)).to eq(2)
      end
    end
  end
end
