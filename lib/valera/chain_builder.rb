module Valera
  class ChainBuilder
    def initialize(chain)
      @chain = chain
      @parser = Parser.new
    end

    def add(text)
      sentences = parser.parse(text)
      sentences.each do |words|
        return if words.empty?

        previous = '^'
        words.each do |word|
          safe_word = word.downcase
          chain.add(previous, safe_word) if previous
          previous = safe_word
        end
        chain.add(previous, '$') unless previous.match?(Parser.sentence_ending_regex)
      end
    end

    def stats
      words = chain.get_all
      {
        pairs_count: words.values.sum { |transitions| transitions.keys.count },
        transitions_count: words.values.sum { |transitions| transitions.values.sum { |transition| transition['transitions'] } },
      }
    end

    private

    attr_reader :chain, :parser
  end
end
