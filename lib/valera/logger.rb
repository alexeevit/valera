module Valera
  class Logger
    LEVELS = {
      error: 0,
      debug: 1,
      info: 2,
    }.freeze

    def initialize(stdout, log_level)
      @stdout = stdout
      @log_level = LEVELS[log_level.to_sym]
    end

    LEVELS.each do |level, level_num|
      define_method level do |str|
        stdout.puts str if log_level <= level_num
      end
    end

    private

    attr_reader :stdout, :log_level
  end
end
