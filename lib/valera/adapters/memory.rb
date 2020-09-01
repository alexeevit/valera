module Valera
  module Adapters
    class Memory
      def initialize
        @data = {}
      end

      def get_all
        data
      end

      def get(prev_word)
        data[prev_word]
      end

      def save(prev_word, matrix)
        data[prev_word] = matrix
      end

      def get_random_key
        data.keys.sample
      end

      def purge
        @data = {}
        true
      end

      private

      attr_reader :data
    end
  end
end
