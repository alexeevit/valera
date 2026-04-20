require 'telegram/bot'

class BigramTelegramHandler
  def initialize(options = {})
    @options = options
    @redis = Redis.new(url: options[:redis_url])
  end

  def run!
    Telegram::Bot::Client.run(options[:token]) do |bot|
      @me = bot.api.get_me['result']

      bot.listen do |message|
        next unless message

        begin
          model = Valera::Bigram::Model.new(redis, "telegram:#{message.chat.id}")

          Valera::Bigram::Trainer.new(model).call(message.text) if message.text

          if mentioned?(message)
            mention = "@#{message.from.username}"
            text = Valera::Bigram::Generator.new(model, mention: mention).call
            text = 'Мне нечего вам сказать' if text.empty?
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: text)
          end
        rescue => e
          bot.api.send_message(chat_id: message.chat.id, text: "Something wrong happened: #{e.class}: #{e.message}")
        end
      end
    end
  end

  private

  attr_reader :options, :redis, :me

  def mentioned?(message)
    message.reply_to_message&.from&.username == me['username'] ||
      message.text&.match?(me['username'])
  end
end
