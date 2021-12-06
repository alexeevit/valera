require_relative 'valera'
require 'telegram/bot'

class TelegramHandler
  attr_reader :options, :redis_adapter

  def initialize(options = {})
    @options = options
    @redis_adapter = Valera::Adapters::Redis.new(url: options[:redis_url])
  end

  def run!
    Telegram::Bot::Client.run(options[:token]) do |bot|
      bot.listen do |message|
        next unless message
        chain = Valera::Chain.new(redis_adapter, "telegram:#{message.chat.id}")
        builder = Valera::ChainBuilder.new(chain)

        begin
          case message.text
          when /хуйня/i
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: 'А может это ты хуйня?')
          when '/generate'
            generator = Valera::Generator.new(chain)
            sentence_size = rand(30) + 10
            generated_text = generator.get(sentence_size)
            bot.api.send_message(chat_id: message.chat.id, text: generated_text)
          when '/stats'
            stats = builder.stats
            stats_text = "Количество пар: #{stats[:pairs_count]}\nКоличество переходов: #{stats[:transitions_count]}"
            bot.api.send_message(chat_id: message.chat.id, text: stats_text)
          when '/purge'
            if chain.purge
              bot.api.send_message(chat_id: message.chat.id, text: 'Done')
            else
              bot.api.send_message(chat_id: message.chat.id, text: 'Something went wrong')
            end
          when '/dump'
            bot.api.send_message(chat_id: message.chat.id, text: chain.get_all.to_json.slice(0, 4096))
          when nil
          else
            builder.add(message.text)
          end
        rescue => e
          bot.api.send_message(chat_id: message.chat.id, text: "Something wrong happened: #{e.class}: #{e.message}")
        end
      end
    end
  end
end
