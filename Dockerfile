FROM ruby:2.6.2-alpine
ENV LANG C.UTF-8
ARG BUNDLE_GITHUB__COM

# Set up nodejs and dumb-init
RUN apk update && apk --no-cache --quiet add \
  bash \
  build-base \
  dumb-init \
  git \
  nodejs \
  postgresql-dev \
  postgresql-client \
  tzdata \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install bundler

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# Set up working directory
RUN mkdir /app

# Set up gems
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD .ruby-version .ruby-version
RUN bundle install -j4

# Finally, add the rest of our app's code
# (this is done at the end so that changes to our app's code
# don't bust Docker's cache)
ADD . /app
WORKDIR /app

# Setup Rails shared folders for Puma
RUN mkdir /shared
RUN mkdir /shared/pids
RUN mkdir /shared/sockets

# Precompile Rails assets
RUN bundle exec rake assets:precompile

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.config"]