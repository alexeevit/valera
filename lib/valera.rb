require_relative 'valera/adapters/redis'
require_relative 'valera/chain'
require_relative 'valera/parser'
require_relative 'valera/chain_builder'
require_relative 'valera/generator'
require_relative 'valera/logger'

module Valera
  LOG_LEVEL = (ENV['LOG_LEVEL'] || :info).freeze

  def self.logger
    @logger ||= Logger.new($stdout, LOG_LEVEL)
  end
end
