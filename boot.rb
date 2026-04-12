# frozen_string_literal: true

require 'pathname'

lib_path ||= File.expand_path('../lib', Pathname.new(__FILE__).realpath)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', Pathname.new(__FILE__).realpath)

ENV['APP_ENV'] ||= 'production'

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, ENV.fetch('APP_ENV'))
