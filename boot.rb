require 'pathname'
lib_path ||= File.expand_path("../lib", Pathname.new(__FILE__).realpath)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", Pathname.new(__FILE__).realpath)

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)
