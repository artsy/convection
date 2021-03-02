FROM ruby:2.7.2-alpine

ENV LANG C.UTF-8
ARG BUNDLE_GITHUB__COM
WORKDIR /app

RUN apk update && apk --no-cache --quiet add \
  bash \
  build-base \
  chromium \
  chromium-chromedriver \
  dumb-init \
  git \
  nodejs \
  postgresql-dev \
  postgresql-client \
  yarn \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && adduser -D -g '' deploy

ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver

RUN gem install bundler && \
  bundle config --global frozen 1

COPY Gemfile Gemfile.lock .ruby-version  ./
RUN bundle install -j4 && \
  mkdir -p /shared/pids && \
  mkdir /shared/sockets && \
  chown -R deploy:deploy /shared

COPY package.json yarn.lock ./
RUN yarn install

COPY . ./

RUN bundle exec rake assets:precompile && \
  chown -R deploy:deploy ./

USER deploy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.config"]
