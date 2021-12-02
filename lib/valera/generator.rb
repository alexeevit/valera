module Valera
  class Generator
    def initialize(chain)
      @chain = chain
    end

    def get(words_count)
      phrase = []

      # start the phrase with a new sentence
      first_word = get_to_start_sentence
      return unless first_word
      phrase << first_word

      # continue the phrase
      loop do
        break if phrase.size >= words_count

        # if a sentence is ended, start a new one
        prev_word = phrase[-1]
        if word_is_ending?(prev_word)
          phrase << get_to_start_sentence
          next
        end

        # just next word
        phrase << get_to_continue(prev_word)
      end

      phrase.compact.join(' ').gsub(/\s*(#{Parser.all_punctuation_regex})/, '\1').gsub('$', '')
    end

    private

    attr_reader :chain

    def get_to_start_sentence
      select_next(chain.get('^'))
    end

    def get_to_continue(word)
      safe_word = word.downcase
      paths = chain.get(safe_word)
      return if paths.empty?

      continuing_paths = paths.select { |word, _| chain.get(word).any? { |w, _| !w.match?(Parser.sentence_ending_regex) } }
      if continuing_paths.any?
        paths = calculate_frequencies(continuing_paths)
      end

      select_next(paths)
    end

    def calculate_frequencies(transitions)
      transitions_sum = transitions.values.sum { |data| data['transitions'] }
      transitions.each { |_, data| data['frequency'] = data['transitions'] * 100 / transitions_sum  }
      transitions[transitions.keys.last]['frequency'] += 100 - transitions.values.sum { |data| data['frequency'] } if transitions.any?
      transitions
    end

    def select_next(transitions, probability = rand(100))
      return if transitions.empty?

      progressive_frequency = 0
      word, _ = transitions.find do |word, data|
        progressive_frequency += data['frequency'].to_i
        progressive_frequency >= probability
      end

      word
    end

    def word_is_ending?(word)
      word.match?(Parser.sentence_ending_regex)
    end
  end
end
