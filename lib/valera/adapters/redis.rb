require 'json'
require 'redis'

module Valera
  module Adapters
    class Redis
      def initialize(connection_params = {})
        @client = build_client(connection_params)
      end

      def get_all
        keys = client.keys
        values = keys.any? ? client.mget(keys) : {}
        result = {}
        keys.each.with_index do |key, i|
          result[key] = JSON.parse(values[i])
        end
        result
      end

      def get(prev_word)
        str = client.get(prev_word)
        return {} if str.nil? || str.empty?
        JSON.parse(str)
      end

      def save(prev_word, matrix)
        client.set(prev_word, matrix.to_json)
      end

      def purge
        client.flushall == "OK"
      end

      def get_random_key
        client.randomkey
      end

      private

      attr_reader :client

      def build_client(params)
        ::Redis.new(params)
      end
    end
  end
end
