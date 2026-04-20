module Valera
  module Bigram
    module Training
      module Normalizator
        URL_REGEX     = /https?:\/\/[^\s,!?;:)>\]]+/.freeze
        MENTION_REGEX = /@\w+/.freeze
        NUMBER_REGEX  = /\d+/.freeze

        module_function

        def call(text)
          text
            .downcase
            .gsub(URL_REGEX, '<url>')
            .gsub(MENTION_REGEX, '<mention>')
            .gsub(NUMBER_REGEX, '<num>')
        end
      end
    end
  end
end
