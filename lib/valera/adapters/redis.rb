require 'json'
require 'redis'

module Valera
  module Adapters
    class Redis
      def initialize(connection_params = {})
        @client = build_client(connection_params)
      end

      def get_all(chat_id)
        client.hgetall("markov_chain:#{chat_id}").tap do |data|
          data.each do |k, v|
            data[k] = JSON.parse(v)
          end
        end
      end

      def get(chat_id, prev_word)
        str = client.hget("markov_chain:#{chat_id}", prev_word)
        return {} if str.nil? || str.empty?
        JSON.parse(str)
      end

      def save(chat_id, prev_word, matrix)
        client.hset("markov_chain:#{chat_id}", prev_word, matrix.to_json)
      end

      def purge(chat_id)
        client.del("markov_chain:#{chat_id}")
      end

      def get_random_key(chat_id)
        client.hkeys("markov_chain:#{chat_id}").sample
      end

      private

      attr_reader :client

      def build_client(params)
        ::Redis.new(params)
      end
    end
  end
end
