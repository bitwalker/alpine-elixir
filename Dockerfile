FROM bitwalker/alpine-erlang:22.2.6

MAINTAINER Paul Schoenfelder <paulschoenfelder@gmail.com>

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2020-01-22 \
    ELIXIR_VERSION=v1.10.0 \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex

WORKDIR /tmp/elixir-build

RUN \
    apk --no-cache --update upgrade && \
    apk add --no-cache --update --virtual .elixir-build \
      make && \
    apk add --no-cache --update \
      git && \
    git clone https://github.com/elixir-lang/elixir --depth 1 --branch $ELIXIR_VERSION && \
    cd elixir && \
    make && make install && \
    mix local.hex --force && \
    mix local.rebar --force && \
    cd $HOME && \
    rm -rf /tmp/elixir-build && \
    apk del --no-cache .elixir-build

WORKDIR ${HOME}

# Always install latest versions of Hex and Rebar
ONBUILD RUN mix do local.hex --force, local.rebar --force

CMD ["/bin/sh"]
