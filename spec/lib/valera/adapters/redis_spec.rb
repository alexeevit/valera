require 'valera/adapters/redis'

describe Valera::Adapters::Redis do
  subject(:adapter) { described_class.new }

  let(:raw_redis) { Redis.new }
  let(:chat_id) { '123456' }
  let(:matrix) do
    {
      'hello' => {
        'transitions' => 1,
        'frequency' => 45.5,
      },
      'world' => {
        'transitions' => 1,
        'frequency' => 50.5,
      },
    }
  end

  describe '#initialize' do
    it 'creates a Redis client with passed params' do
      adapter = described_class.new(role: :master)
      expect(adapter.send(:client)).to be_a(Redis)
    end
  end

  describe '#save' do
    it 'stores the matrix into the hash' do
      adapter.save(chat_id, '^', matrix)
      expect(raw_redis.hget("markov_chain:#{chat_id}", '^')).to eq(matrix.to_json)
    end

    it 'stores fractional numbers' do
      adapter.save(chat_id, '^', matrix)
      data = JSON.parse(raw_redis.hget("markov_chain:#{chat_id}", '^'))
      expect(data.dig('hello', 'frequency')).to eq(45.5)
    end
  end

  describe '#get_all' do
    context 'when db is not empty' do
      before do
        adapter.save(chat_id, 'first', matrix)
        adapter.save(chat_id, 'second', matrix)
      end

      it 'returns all keys with matrices' do
        expect(adapter.get_all(chat_id)).to match('first' => matrix, 'second' => matrix)
      end

      it 'returns matrix frequency as BigDecimal' do
        frequency = adapter.get_all(chat_id).dig('first', 'hello', 'frequency')
        expect(frequency).to be_an_instance_of(BigDecimal)
        expect(frequency).to eq(BigDecimal('45.5'))
      end
    end

    context 'when db is empty' do
      it 'returns empty hash' do
        expect(adapter.get_all(chat_id)).to eq({})
      end
    end
  end

  describe '#get' do
    context 'when the initial word exists' do
      before { adapter.save(chat_id, '^', matrix) }

      it 'returns the matrix' do
        expect(adapter.get(chat_id, '^')).to eq(matrix)
      end

      it 'returns hash with frequency as BigDecimal' do
        frequency = adapter.get(chat_id, '^').dig('hello', 'frequency')
        expect(frequency).to be_an_instance_of(BigDecimal)
        expect(frequency).to eq(BigDecimal('45.5'))
      end
    end

    context 'when the initial word does not exist' do
      it 'returns empty hash' do
        expect(adapter.get(chat_id, '^')).to eq({})
      end
    end
  end

  describe '#get_random_key' do
    context 'when the db is not empty' do
      before do
        adapter.save(chat_id, 'first', matrix)
        adapter.save(chat_id, 'second', matrix)
      end

      it 'returns a random key' do
        expect(%w(first second)).to include(adapter.get_random_key(chat_id))
      end
    end

    context 'when the db is empty' do
      it 'returns nil' do
        expect(adapter.get_random_key(chat_id)).to be_nil
      end
    end
  end

  describe '#purge' do
    it 'flushes the database' do
      adapter.save(chat_id, '^', matrix)

      expect { adapter.purge(chat_id) }.to(
        change { raw_redis.hget("markov_chain:#{chat_id}", '^') }.from(matrix.to_json).to(nil)
      )
    end
  end
end
