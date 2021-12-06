source 'https://rubygems.org'

gem 'telegram-bot-ruby'
gem 'redis'

group :development do
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano-bundler', '~> 2.0', require: false
  gem 'capistrano-rvm', require: false
  gem 'pry', '~> 0.12.2'
  gem 'dotenv'

  # https://github.com/net-ssh/net-ssh/issues/565
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

group :test do
  gem 'fakeredis'
  gem 'rspec'
end
