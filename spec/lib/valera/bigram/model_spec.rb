describe Valera::Bigram::Model do
  subject { described_class.new(redis, chat_id) }

  let(:redis) { Redis.new }
  let(:chat_id) { '123' }

  describe '#transitions' do
    context 'when no transitions exist' do
      it 'returns an empty hash' do
        expect(subject.transitions('hello', 'world')).to eq({})
      end
    end

    context 'when transitions exist' do
      before do
        subject.add_transition('hello', 'world', 'foo')
        subject.add_transition('hello', 'world', 'foo')
        subject.add_transition('hello', 'world', 'bar')
      end

      it 'returns next words with counts' do
        expect(subject.transitions('hello', 'world')).to eq({ 'foo' => 2, 'bar' => 1 })
      end
    end
  end

  describe '#add_transition' do
    it 'creates a transition with count 1' do
      subject.add_transition('hello', 'world', 'foo')
      expect(subject.transitions('hello', 'world')).to eq({ 'foo' => 1 })
    end

    it 'increments the count on repeated calls' do
      subject.add_transition('hello', 'world', 'foo')
      subject.add_transition('hello', 'world', 'foo')
      expect(subject.transitions('hello', 'world')).to eq({ 'foo' => 2 })
    end

    it 'tracks multiple next words independently' do
      subject.add_transition('hello', 'world', 'foo')
      subject.add_transition('hello', 'world', 'bar')
      expect(subject.transitions('hello', 'world')).to eq({ 'foo' => 1, 'bar' => 1 })
    end

    it 'isolates transitions by chat_id' do
      other = described_class.new(redis, 'other_chat')
      subject.add_transition('hello', 'world', 'foo')
      expect(other.transitions('hello', 'world')).to eq({})
    end

    it 'isolates transitions by bigram' do
      subject.add_transition('hello', 'world', 'foo')
      expect(subject.transitions('hello', 'other')).to eq({})
    end
  end

  describe '#insert' do
    let(:data) do
      {
        ['<s>', 'hello'] => { 'world' => 3, 'there' => 1 },
        ['hello', 'world'] => { '</s>' => 2 },
      }
    end

    it 'loads all bigram transitions into the model' do
      subject.insert(data)

      expect(subject.transitions('<s>', 'hello')).to eq({ 'world' => 3, 'there' => 1 })
      expect(subject.transitions('hello', 'world')).to eq({ '</s>' => 2 })
    end

    it 'increments existing counts' do
      subject.add_transition('<s>', 'hello', 'world')
      subject.insert(data)

      expect(subject.transitions('<s>', 'hello')).to eq({ 'world' => 4, 'there' => 1 })
    end
  end
end
