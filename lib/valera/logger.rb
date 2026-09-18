require 'json'
require 'time'

module Valera
  # Writes one JSON object per line, so log collectors (e.g. Loki) can parse it.
  #
  #   logger.info('reply_sent', duration_ms: 12)
  #   # {"time":"2026-09-18T10:00:00.000Z","level":"info","event":"reply_sent","duration_ms":12}
  #
  #   logger.error('handler_failed', error: e)
  #   # {..., "error_class":"RuntimeError","error_message":"boom","backtrace":"..."}
  class Logger
    LEVELS = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3,
      fatal: 4,
    }.freeze
    DEFAULT_LEVEL = :info
    BACKTRACE_LIMIT = 20

    def initialize(io, level = DEFAULT_LEVEL)
      @io = io
      @level = LEVELS.fetch(level.to_s.downcase.to_sym) { LEVELS.fetch(DEFAULT_LEVEL) }
    end

    LEVELS.each do |name, severity|
      define_method name do |event, error: nil, **fields|
        write(name, event, error, fields) if severity >= level
      end
    end

    private

    attr_reader :io, :level

    def write(severity, event, error, fields)
      entry = { time: Time.now.utc.iso8601(3), level: severity, event: event }
      entry.merge!(fields)
      entry.merge!(error_fields(error)) if error
      io.puts(JSON.generate(entry))
    rescue StandardError
      # logging must never take the bot down
    end

    def error_fields(error)
      {
        error_class: error.class.name,
        error_message: error.message,
        backtrace: Array(error.backtrace).first(BACKTRACE_LIMIT).join("\n"),
      }
    end
  end
end
