module Valera
  module Bigram
    class Generator
      def initialize(model, mention:, seed: Random.new_seed)
        @model   = model
        @mention = mention
        @seed    = seed
      end

      def call
        tokens = Generation::Sampler.new(model, seed: seed).call
        Generation::Formatter.new(mention: mention).call(tokens)
      end

      private

      attr_reader :model, :mention, :seed
    end
  end
end
