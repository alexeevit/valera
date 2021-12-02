require 'securerandom'

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
        phrase_words = phrase.reject { |word| word.match?(Parser.all_punctuation_regex) }
        break if phrase_words.size >= words_count

        # if a sentence is ended, start a new one
        prev_word = phrase[-1]
        if word_is_ending?(prev_word)
          phrase << get_to_start_sentence
          next
        end

        # just next word
        phrase << get_next(prev_word)
      end

      phrase.compact.join(' ').gsub(/\s*(#{Parser.punctuation_marks_without_leading_space})/, '\1').gsub('$', '')
    end

    private

    attr_reader :chain

    def get_to_start_sentence
      select_next(chain.get('^'))
    end

    def get_next(word)
      safe_word = word.downcase
      paths = chain.get(safe_word)
      return if paths.empty?

      select_next(paths)
    end

    def select_next(transitions, probability = BigDecimal(String(SecureRandom.random_number)))
      return if transitions.empty?

      progressive_frequency = 0

      sorted = transitions.sort_by { |word, data| data['frequency'] }
      sorted.find do |word, data|
        (progressive_frequency += data['frequency']) >= probability
      end.shift
    end

    def word_is_ending?(word)
      word.match?(Parser.sentence_ending_regex)
    end
  end
end
