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

      private

      attr_reader :data
    end
  end
end
