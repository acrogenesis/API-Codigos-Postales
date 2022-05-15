FROM ruby:3.1-slim

ENV RACK_ENV=production
ENV LANG=en_US.UTF-8

RUN apt update && apt install -y \
  build-essential libpq-dev  \
  && rm -rf /var/lib/apt/lists/*

# Install deps
ADD Gemfile Gemfile.lock ./

RUN bundle install

ADD . .

# run server
CMD bundle exec puma -p ${PORT:-3000} -e ${RACK_ENV:-development}
