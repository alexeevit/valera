module Valera
  module Bigram
    module Training
      module Tokenizer
        TOKEN_REGEX        = /<\w+>|[a-zA-Zа-яА-ЯёЁ0-9]+|\n|[^\s]/.freeze
        SENTENCE_END_REGEX = /\A[.!?\n]\z/.freeze

        module_function

        def call(text)
          tokens = text.scan(TOKEN_REGEX)
          return [] if tokens.empty?

          insert_sentence_markers(tokens)
        end

        def insert_sentence_markers(tokens)
          result = ['<s>']
          tokens.each do |token|
            if token == "\n"
              result << '</s>'
              result << '<s>'
              next
            end
            result << token
            if sentence_end?(token)
              result << '</s>'
              result << '<s>'
            end
          end
          result.pop if result.last == '<s>'
          result << '</s>' unless result.last == '</s>'
          result
        end

        def sentence_end?(token)
          token.match?(SENTENCE_END_REGEX)
        end
      end
    end
  end
end
