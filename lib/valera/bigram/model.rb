module Valera
  module Bigram
    class Model
      KEY_PREFIX = 'bigram'

      def initialize(redis, chat_id)
        @redis = redis
        @chat_id = chat_id
      end

      def transitions(word1, word2)
        redis.hgetall(key(word1, word2)).transform_values(&:to_i)
      end

      def add_transition(word1, word2, next_word)
        redis.hincrby(key(word1, word2), next_word, 1)
      end

      def start_bigrams
        prefix = "#{KEY_PREFIX}:#{chat_id}:<s>:"
        redis.keys("#{prefix}*").map { |k| ['<s>', k[prefix.length..]] }
      end

      def insert(data)
        redis.multi do |tx|
          data.each do |(word1, word2), transitions|
            transitions.each do |next_word, count|
              tx.hincrby(key(word1, word2), next_word, count)
            end
          end
        end
      end

      private

      attr_reader :redis, :chat_id

      def key(word1, word2)
        "#{KEY_PREFIX}:#{chat_id}:#{word1}:#{word2}"
      end
    end
  end
end
