# Start from the official Elixir image. See
# https://hub.docker.com/_/elixir
FROM elixir:1.9.4

# Install needed Debian packages
RUN \
    apt-get update \
    && apt-get install --yes build-essential inotify-tools postgresql-client

# Install Phoenix. See
# https://hexdocs.pm/phoenix/installation.html#content
RUN \
    mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install hex phx_new 1.4.12 --force

# RUN cd assets && npm install

# Install node. Phoenix will use webpack to bundle
# static assets.
RUN \
    curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh \
    && bash ./nodesource_setup.sh \
    && apt-get install -y nodejs \
    # Using yarn because it is much faster than
    # npm in my empirical tests.
    && npm install -g yarn

WORKDIR /app