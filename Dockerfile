# Use the full Ruby 3.4.2 image
FROM ruby:3.4.2

# Set environment variables
ENV RACK_ENV=production 
# Or development if preferred for local server logs
ENV LANG=en_US.UTF-8

# Install OS dependencies (PostgreSQL client libs, build tools)
RUN apt update && apt install -y \
  build-essential libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Update RubyGems & Install/Update Bundler
# Using latest Bundler 2.x series
RUN gem update --system && gem install bundler -v '~> 2.5'

# Set working directory inside the container
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gem dependencies using Bundler
RUN bundle install --jobs $(nproc) --retry 3 
# Added common optimizations

# Copy the rest of the application code into the container
COPY . .

# Command to run the application server (uses Bundler)
CMD bundle exec puma -p ${PORT:-3000} -e ${RACK_ENV:-development}