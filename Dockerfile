# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production and development, choose it using the ARG_RAILS_ENV
# docker build arg parameter (if no arg is provided, production will be the default).
# Use with Kamal or build'n'run by hand:
# docker build -t buses_monitor:production --target production .
# docker run -d -p 80:80 \
#   -e RAILS_MASTER_KEY=<value from config/master.key> \
#   -e REQUEST_BRT_BUSES_INTERVAL_SECONDS=20 \
#   --name buses_monitor_prod \
#   buses_monitor:production

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.4.7

# ----------------------- Base -----------------------
FROM registry.docker.com/library/ruby:$RUBY_VERSION-alpine AS base

ARG ARG_RAILS_ENV=production
ARG ARG_BUNDLE_WITHOUT="development"

ENV APP_HOME_PATH="/buses_monitor" \
  RAILS_ENV=${ARG_RAILS_ENV} \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_WITHOUT=${ARG_BUNDLE_WITHOUT} \
  BUNDLE_PATH="/usr/local/bundle"

WORKDIR ${APP_HOME_PATH}

# ----------------------- Build -----------------------
FROM base AS build

# Install packages needed to build gems
# Use virtual build-dependency tag so we can remove these packages after bundle install
RUN apk add --update --no-cache --virtual build-dependency make gcc g++ musl-dev yaml-dev

# Install application gems
COPY Gemfile Gemfile.lock vendor ${APP_HOME_PATH}/
RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") \
  && bundle install --no-cache --jobs 2 --retry 5 \
  && bundle clean --force \
  && rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git \
  # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
  && bundle exec bootsnap precompile -j 1 --gemfile

# Remove build dependencies
RUN apk del build-dependency

# ----------------------- After Build -----------------------
FROM base AS after_build

# Copy built artifacts: gems, application
COPY --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}

# Install runtime dependencies
RUN apk add --update --no-cache tzdata

# ----------------------- Development -----------------------
FROM after_build AS development

EXPOSE 3000

ENTRYPOINT ["./docker/entrypoint-development.sh"]

CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]

# ----------------------- Production Precompile -----------------------
FROM after_build AS production_precompile

COPY . .

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 REQUEST_BRT_BUSES_INTERVAL_SECONDS=20 ./bin/rails assets:precompile

# ----------------------- Production -----------------------
FROM after_build AS production

# Run and own only the runtime files as a non-root user for security
# RUN addgroup -S -g 1000 rails && \
#   adduser -S -u 1000 -G rails -h /home/rails -s /bin/sh rails
# USER 1000:1000

# Copy built artifacts: application
COPY --from=production_precompile ${APP_HOME_PATH} ${APP_HOME_PATH}

# Entrypoint prepares the database.
ENTRYPOINT ["/buses_monitor/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
# CMD ["./bin/thrust", "./bin/rails", "server"]
CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile"]
