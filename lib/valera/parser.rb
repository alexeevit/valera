module Valera
  class Parser
    def parse(text)
      text.split(' ').select { |w| is_word?(w) }.map { |w| prepare_word(w) }
    end

    private

    def is_word?(word)
      word.match?(/[a-zA-Zа-яА-Я0-9-%]/)
    end

    def prepare_word(word)
      word.strip.gsub(/[\.,'"\?\!;:*]/,'')
    end
  end
end
