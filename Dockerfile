FROM ruby:2.5.3

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app
COPY Gemfile ./
# COPY Gemfile.lock ./

RUN bundle install
COPY ./ ./

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["puma -t 1:2 -p ${PORT:-3000} -e ${RACK_ENV:-development}"]
