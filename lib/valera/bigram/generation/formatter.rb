module Valera
  module Bigram
    module Generation
      class Formatter
        PUNCTUATION_REGEX = /\A[^\p{L}\p{N}<>]\z/.freeze

        def initialize(mention:)
          @mention = mention
        end

        def call(tokens)
          words = []
          capitalize_next = false

          tokens.each do |token|
            case token
            when '<s>'
              capitalize_next = true
            when '</s>'
              next
            when '<num>'
              capitalize_next = false
              words << rand(1..9999).to_s
            when '<url>'
              capitalize_next = false
              words << Faker::Internet.url
            when '<mention>'
              capitalize_next = false
              words << mention
            else
              if token.match?(PUNCTUATION_REGEX)
                words[-1] = "#{words[-1]}#{token}" unless words.empty?
              else
                words << (capitalize_next ? token.capitalize : token)
                capitalize_next = false
              end
            end
          end

          words.join(' ')
        end

        private

        attr_reader :mention
      end
    end
  end
end
