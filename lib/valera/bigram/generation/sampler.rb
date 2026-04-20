module Valera
  module Bigram
    module Generation
      class Sampler
        def initialize(model, seed: Random.new_seed)
          @model = model
          @rng   = Random.new(seed)
        end

        def call
          @rng.rand(2..3).times.flat_map { generate_sentence }
        end

        private

        attr_reader :model, :rng

        def generate_sentence
          w1, w2 = random_start
          return [] unless w1

          result = ['<s>', w2]

          loop do
            transitions = model.transitions(w1, w2)
            break if transitions.empty?

            next_word = weighted_sample(transitions)
            break unless next_word

            result << next_word
            break if next_word == '</s>'

            w1, w2 = w2, next_word
          end

          result << '</s>' unless result.last == '</s>'
          result
        end

        def random_start
          starts = model.start_bigrams
          return if starts.empty?

          starts.sample(random: rng)
        end

        def weighted_sample(transitions)
          total = transitions.values.sum
          threshold = rng.rand(total) + 1
          cumulative = 0
          transitions.each do |word, count|
            cumulative += count
            return word if cumulative >= threshold
          end
        end
      end
    end
  end
end
