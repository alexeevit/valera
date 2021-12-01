require 'valera/adapters/redis'

describe Valera::Adapters::Redis do
  subject(:adapter) { described_class.new }

  let(:raw_redis) { Redis.new }
  let(:chat_id) { '123456' }
  let(:matrix) do
    {
      'hello' => {
        'transitions' => 1,
        'frequency' => 50,
      },
      'world' => {
        'transitions' => 1,
        'frequency' => 50,
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
      adapter.save('^', matrix)
      expect(raw_redis.get('^')).to eq(matrix.to_json)
    end
  end

  describe '#get' do
    context 'when the initial word exists' do
      before { adapter.save('^', matrix) }

      it 'returns the matrix' do
        expect(adapter.get('^')).to eq(matrix)
      end
    end

    context 'when the initial word does not exist' do
      it 'returns empty hash' do
        expect(adapter.get('^')).to eq({})
      end
    end
  end

  describe '#get_random_key' do
    context 'when the db is not empty' do
      before do
        adapter.save('first', matrix)
        adapter.save('second', matrix)
      end

      it 'returns a random key' do
        expect(%w(first second)).to include(adapter.get_random_key)
      end
    end

    context 'when the db is empty' do
      it 'returns nil' do
        expect(adapter.get_random_key).to be_nil
      end
    end
  end

  describe '#purge' do
    it 'flushes the database' do
      adapter.save('^', matrix)

      expect { adapter.purge }.to(
        change { raw_redis.get('^') }.from(matrix.to_json).to(nil)
      )
    end
  end
end
