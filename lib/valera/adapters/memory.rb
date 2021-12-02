module Valera
  module Adapters
    class Memory
      def initialize
        @data = {}
      end

      def get_all(chat_id)
        data[chat_id]
      end

      def get(chat_id, prev_word)
        data.dig(chat_id, prev_word)
      end

      def save(chat_id, prev_word, matrix)
        data[chat_id] ||= {}
        data[chat_id][prev_word] = matrix
      end

      def get_random_key(chat_id)
        data[chat_id].keys.sample
      end

      def purge(chat_id)
        data[chat_id] = {}
        true
      end

      private

      attr_reader :data
    end
  end
end
