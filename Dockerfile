FROM ruby:3.4.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev cron

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY update_sepomex.sh /app/update_sepomex.sh
COPY cron/sepomex_update_cron /etc/cron.d/sepomex_update_cron
RUN chmod +x /app/update_sepomex.sh
RUN chmod 0644 /etc/cron.d/sepomex_update_cron

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-p", "3000", "-e", "development"]