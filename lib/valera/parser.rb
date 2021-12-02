module Valera
  class Parser
    def self.all_punctuation_regex
      /#{sentence_ending_regex}|#{other_punctuation_regex}/
    end

    def self.punctuation_marks_without_leading_space
      /[\,\;\:]|#{sentence_ending_regex}/
    end

    def self.sentence_ending_regex
      /[\.\?\!\$]/
    end

    def self.other_punctuation_regex
      /[,;:\-\-\–]/
    end

    def parse(text)
      split_into_sentences(text).map { |sentence| split_into_words(sentence) }
    end

    private

    def split_into_words(text)
      words = []
      text.split(' ').each do |word|
        loop do
          break if word.nil? || word.empty?

          punct_index = word.index(all_punctuation_regex)
          unless punct_index
            words << word
            break
          end

          words << word[0..punct_index - 1] unless punct_index == 0
          words << word[punct_index]

          word = word[punct_index + 1..-1]
        end
      end

      words
    end

    def split_into_sentences(text)
      sentences = []
      loop do
        end_index = text.index(sentence_ending_regex) || text.length - 1
        sentences << text[0..end_index]

        break if end_index == text.length - 1
        text = text[end_index + 1..-1].strip
      end

      sentences
    end

    def is_word?(word)
      word.match?(/[a-zA-Zа-яА-Я0-9\-%]/)
    end

    def is_ending?(word)
      word.match?(sentence_ending_regex)
    end

    def all_punctuation_regex
      self.class.all_punctuation_regex
    end

    def other_punctuation_regex
      self.class.other_punctuation_regex
    end

    def sentence_ending_regex
      self.class.sentence_ending_regex
    end

    def other_symbols_regex
      /['"*]/
    end
  end
end
