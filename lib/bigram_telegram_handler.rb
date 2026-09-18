require 'telegram/bot'

class BigramTelegramHandler
  def initialize(options = {})
    @options = options
    @redis = Redis.new(url: options[:redis_url])
    @logger = options.fetch(:logger) { Valera.logger }
  end

  def run!
    Telegram::Bot::Client.run(options[:token]) do |bot|
      @me = bot.api.get_me['result']
      logger.info('bot_started', bot_username: me['username'])

      bot.listen do |message|
        handle(bot, message)
      end
    end
  end

  private

  attr_reader :options, :redis, :me, :logger

  def handle(bot, message)
    return unless message

    unless message.is_a?(Telegram::Bot::Types::Message)
      logger.info('update_ignored', update_type: message.class.name.split('::').last)
      return
    end

    logger.info('message_received', chat_type: message.chat.type, has_text: !message.text.nil?)
    log_membership_change(message)

    model = Valera::Bigram::Model.new(redis, "telegram:#{message.chat.id}")

    if message.text
      started_at = monotonic_now
      Valera::Bigram::Trainer.new(model).call(message.text)
      logger.debug('message_trained', duration_ms: elapsed_ms(started_at))
    end

    trigger = reply_trigger(message)
    return unless trigger

    logger.info('reply_triggered', trigger: trigger)
    started_at = monotonic_now

    if trigger == :keyword
      text = 'А может это ты хуйня?'
    else
      mention = "@#{message.from.username}"
      text = Valera::Bigram::Generator.new(model, mention: mention).call
      empty = text.empty?
      text = 'Мне нечего вам сказать' if empty
    end

    bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: text)
    logger.info('reply_sent', trigger: trigger, empty_generation: empty || false, duration_ms: elapsed_ms(started_at))
  rescue => e
    logger.error('message_handling_failed', error: e)
    notify_error(bot, message, e)
  end

  def reply_trigger(message)
    if message.text&.match?(/хуйня/i)
      :keyword
    elsif message.reply_to_message&.from&.username == me['username']
      :reply
    elsif message.text&.match?(me['username'])
      :mention
    end
  end

  def log_membership_change(message)
    if message.new_chat_members&.any? { |user| user.id == me['id'] }
      logger.info('bot_added_to_chat', chat_type: message.chat.type)
    elsif message.left_chat_member&.id == me['id']
      logger.info('bot_removed_from_chat', chat_type: message.chat.type)
    end
  end

  # Reporting the error to the chat can fail too (bot kicked, rate limited),
  # and an exception here would escape `listen` and crash the bot.
  def notify_error(bot, message, error)
    bot.api.send_message(chat_id: message.chat.id, text: "Something wrong happened: #{error.class}: #{error.message}")
  rescue => e
    logger.error('error_notification_failed', error: e)
  end

  def monotonic_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def elapsed_ms(started_at)
    ((monotonic_now - started_at) * 1000).round
  end
end
