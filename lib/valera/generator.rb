module Valera
  class Generator
    def initialize(chain)
      @chain = chain
    end

    def get(words_count, first_word = nil)
      sentence = []

      if !first_word || !chain.has?(first_word)
        first_word = select_next(chain.get('^'))
      end

      sentence << first_word

      loop do
        prev_word = sentence[-1]

        if prev_word.match?(Parser.sentence_ending_regex)
          sentence << select_next(chain.get('^'))
          next
        end

        if sentence.size >= words_count - 1
          ending = get_with_ending(prev_word)

          if ending
            sentence << ending
            break
          end
        end

        sentence << get_to_continue(prev_word)
      end

      sentence.compact.join(' ').gsub(/\s(#{Parser.sentence_ending_regex})/, '\1')
    end

    private

    attr_reader :chain

    def get_to_start
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

    def get_with_ending(word)
      safe_word = word.downcase

      paths = chain.get(safe_word)
      paths = paths.select { |word, _| chain.get(word).any? { |w, _| w.match?(Parser.sentence_ending_regex) } }
      paths = calculate_frequencies(paths)
      return if paths.empty?

      word = select_next(paths)

      endings = chain.get(word)
      endings = endings.select { |v, _| v.match?(Parser.sentence_ending_regex) }
      endings = calculate_frequencies(endings)

      ending = select_next(endings)
      return [word] if ending == '$'
      [word, ending]
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
  end
end
