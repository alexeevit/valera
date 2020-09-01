module Valera
  class Generator
    def initialize(chain)
      @chain = chain
    end

    def get(words_count, first_word = nil)
      sentence = []

      first_word = chain.random unless first_word && chain.has?(first_word)
      sentence << first_word
      next_word = first_word

      (words_count - 1).times do |i|
        next_word = chain.random unless chain.has?(next_word)
        next_node = chain.get(next_word)
        rand_index = rand(100)
        progressive_frequency = 0
        next_word, _ = next_node.find do |word, node|
          progressive_frequency += node['frequency'].to_i
          progressive_frequency >= rand_index
        end
        sentence << next_word
      end

      sentence.join(' ')
    end

    private

    attr_reader :chain
  end
end
