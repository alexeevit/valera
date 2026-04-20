module Valera
  module Bigram
    module Generation
      class Formatter
        PUNCTUATION_REGEX = /\A[^\p{L}\p{N}<>]\z/.freeze

        def initialize(mention:)
          @mention = mention
        end

        def call(tokens)
          parts = []
          capitalize_next = false
          next_sep = ' '

          tokens.each do |token|
            case token
            when '<s>'
              capitalize_next = true
            when '</s>'
              next_sep = "\n" if parts.last && !parts.last[-1].match?(/[[:punct:]]/)
            when '<num>'
              parts << (parts.empty? ? '' : next_sep) + rand(1..9999).to_s
              capitalize_next = false
              next_sep = ' '
            when '<url>'
              parts << (parts.empty? ? '' : next_sep) + Faker::Internet.url
              capitalize_next = false
              next_sep = ' '
            when '<mention>'
              parts << (parts.empty? ? '' : next_sep) + mention
              capitalize_next = false
              next_sep = ' '
            else
              if token.match?(PUNCTUATION_REGEX)
                if !parts.empty? && (token == '-' || token == '—')
                  parts[-1] = "#{parts[-1]} #{token}"
                elsif !parts.empty?
                  parts[-1] = "#{parts[-1]}#{token}"
                end
              else
                word = capitalize_next ? token.capitalize : token
                parts << (parts.empty? ? word : "#{next_sep}#{word}")
                capitalize_next = false
                next_sep = ' '
              end
            end
          end

          parts.join
        end

        private

        attr_reader :mention
      end
    end
  end
end
