require_relative 'valera'
require 'telegram/bot'

class Bot
  attr_reader :options
  attr_reader :chain
  attr_reader :builder

  def initialize(options)
    @options = options
    redis_adapter = Valera::Adapters::Redis.new(url: options[:redis_url])
    @chain = Valera::Chain.new(redis_adapter)
    @builder = Valera::ChainBuilder.new(chain)
  end

  def run!
    run_telegram_bot
  end

  private

  def run_telegram_bot
    Telegram::Bot::Client.run(options[:telegram_token]) do |bot|
      bot.listen do |message|
        case message.text
        when '/dump'
          bot.api.send_message(chat_id: message.chat.id, text: chain.get_all.to_json)
        else
          builder.add(message.text)
        end
      end
    end
  end
end
