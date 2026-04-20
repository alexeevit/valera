require_relative 'valera/adapters/redis'
require_relative 'valera/chain'
require_relative 'valera/parser'
require_relative 'valera/chain_builder'
require_relative 'valera/generator'
require_relative 'valera/logger'
require_relative 'valera/bigram/training/normalizator'
require_relative 'valera/bigram/training/tokenizer'
require_relative 'valera/bigram/generation/sampler'
require_relative 'valera/bigram/generation/formatter'
require_relative 'valera/bigram/model'
require_relative 'valera/bigram/trainer'
require_relative 'valera/bigram/generator'

module Valera
  LOG_LEVEL = (ENV['LOG_LEVEL'] || :info).freeze

  def self.logger
    @logger ||= Logger.new($stdout, LOG_LEVEL)
  end
end
