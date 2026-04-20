FROM ruby:2.7.8-alpine AS base

RUN adduser -D app
WORKDIR /app

RUN gem install bundler -v 1.17.3
CMD ["ruby", "bin/anobot"]

FROM base AS development
RUN apk add --no-cache build-base

FROM base AS production

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

USER app
