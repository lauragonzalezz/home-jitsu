# syntax=docker/dockerfile:1
# Development image for Home-Jitsu.
# Ships Ruby, Node and Yarn in one image so bin/dev can run the Rails server
# and the webpack watcher side by side. This is the DEV box only; the Rails 8
# production Dockerfile (multi-stage, Thruster) comes later in the upgrade.
ARG RUBY_VERSION=3.1.2
FROM ruby:${RUBY_VERSION}-slim

# Debian 11 (bullseye) is end-of-life and no longer on the standard mirrors,
# so repoint apt at the archive before installing anything. (This image is
# pinned to the app's current Ruby 3.1.2; it goes away when we bump Ruby.)
RUN printf '%s\n' \
      'deb http://archive.debian.org/debian bullseye main' \
      'deb http://archive.debian.org/debian-security bullseye-security main' \
      > /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid

# OS packages: build tools for native gems (pg), the Postgres client lib,
# libvips for Active Storage variants, plus git/curl for tooling and Node setup.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      libvips \
      git \
      curl \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Node + Yarn (classic) for jsbundling/webpack.
ARG NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install --no-install-recommends -y nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

# foreman drives Procfile.dev via bin/dev. It stays out of the Gemfile by
# Rails convention, so install it globally here.
RUN gem install foreman

WORKDIR /rails

# Install dependencies and prepare the DB on first boot (see the script).
ENTRYPOINT ["bin/docker-entrypoint"]

# Default command for `docker compose up`. The dev container overrides this
# (see devcontainer.json) so the container stays idle for interactive work.
CMD ["bin/dev"]
