module Valera
  class Chain
    def initialize(adapter)
      @adapter = adapter
    end

    def get_all
      adapter.get_all
    end

    def get(prev_word)
      return unless prev_word
      prev_word = String(prev_word)
      adapter.get(prev_word) || {}
    end

    def add(prev_word, next_word, count = 1)
      return unless prev_word && next_word
      prev_word = String(prev_word)
      next_word = String(next_word)
      count = Integer(count)

      old_data = adapter.get(prev_word)
      new_data = new_transitions(old_data, next_word, count)
      adapter.save(prev_word, new_data)
      new_data[next_word]
    end

    def purge
      adapter.purge
    end

    private

    attr_reader :hash, :adapter

    def new_transitions(transitions, next_word, count)
      transitions ||= {}
      transitions[next_word] ||= { 'transitions' => 0 }
      transitions[next_word]['transitions'] += count

      transitions_sum = transitions.values.sum { |data| data['transitions'] }
      transitions.each { |_, data| data['frequency'] = data['transitions'] * 100 / transitions_sum  }
    end
  end
end
