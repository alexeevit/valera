require 'pathname'
lib_path ||= File.expand_path("../lib", Pathname.new(__FILE__).realpath)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", Pathname.new(__FILE__).realpath)

ENV["APP_ENV"] ||= "development"

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

if %w(development test).include?(ENV["APP_ENV"])
  require "dotenv/load"
end
