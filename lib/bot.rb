require 'fileutils'
require_relative 'valera'
require 'telegram/bot'

class Bot
  attr_reader :options, :redis_adapter

  def initialize(options)
    @options = options

    options[:logfile] = File.expand_path(logfile) if logfile?
    options[:pidfile] = File.expand_path(pidfile) if pidfile?

    @redis_adapter = Valera::Adapters::Redis.new(url: options[:redis_url])
  end

  def run!
    check_pid
    daemonize if daemonize?
    write_pid

    if logfile?
      redirect_output
    elsif daemonize?
      suppress_output
    end

    run_telegram_bot
  end

  private

  def daemonize?
    options[:daemonize]
  end

  def logfile
    options[:logfile]
  end

  def pidfile
    options[:pidfile]
  end

  def logfile?
    !logfile.nil?
  end

  def pidfile?
    !pidfile.nil?
  end

  def write_pid
    if pidfile?
      begin
        FileUtils.mkdir_p(File.dirname(pidfile), :mode => 0755)
        File.open(pidfile, ::File::CREAT | ::File::EXCL | ::File::WRONLY){|f| f.write("#{Process.pid}") }
        at_exit { File.delete(pidfile) if File.exists?(pidfile) }
      rescue Errno::EEXIST
        check_pid
        retry
      end
    end
  end

  def check_pid
    if pidfile?
      case pid_status(pidfile)
      when :running, :not_owned
        puts "A server is already running. Check #{pidfile}"
        exit(1)
      when :dead
        File.delete(pidfile)
      end
    end
  end

  def pid_status(pidfile)
    return :exited unless File.exists?(pidfile)
    pid = ::File.read(pidfile).to_i
    return :dead if pid == 0
    Process.kill(0, pid) # check process status
    :running
  rescue Errno::ESRCH
    :dead
  rescue Errno::EPERM
    :not_owned
  end

  def daemonize
    exit if fork
    Process.setsid
    exit if fork
    Dir.chdir "/"
  end

  def redirect_output
    FileUtils.mkdir_p(File.dirname(logfile), :mode => 0755)
    FileUtils.touch logfile
    File.chmod(0644, logfile)
    $stderr.reopen(logfile, 'a')
    $stdout.reopen($stderr)
    $stdout.sync = $stderr.sync = true
  end

  def suppress_output
    $stderr.reopen('/dev/null', 'a')
    $stdout.reopen($stderr)
  end

  def run_telegram_bot
    Telegram::Bot::Client.run(options[:telegram_token]) do |bot|
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
