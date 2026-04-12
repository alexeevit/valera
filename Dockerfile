FROM ruby:2.7.8-alpine

RUN adduser -D app
WORKDIR /app

RUN gem install bundler -v 1.17.3

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

USER app
CMD ["ruby", "bin/anobot"]
