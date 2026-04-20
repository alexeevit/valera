module Valera
  module Bigram
    class Trainer
      def initialize(model)
        @model = model
      end

      def call(message)
        tokens = Training::Tokenizer.call(Training::Normalizator.call(message))
        tokens.each_cons(3) do |w1, w2, next_word|
          model.add_transition(w1, w2, next_word)
        end
      end

      private

      attr_reader :model
    end
  end
end
