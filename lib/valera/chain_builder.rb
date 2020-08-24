module Valera
  class ChainBuilder
    def initialize(chain)
      @chain = chain
      @parser = Parser.new
    end

    def add(text)
      words = parser.parse(text)
      previous = nil
      words.each do |word|
        chain.add(previous, word) if previous
        previous = word
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
