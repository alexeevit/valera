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
        chain.add(word, previous) if previous
        previous = word
      end
    end

    private

    attr_reader :chain, :parser
  end
end
