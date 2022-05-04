ARG ERLANG_VERSION
FROM bitwalker/alpine-erlang:${ERLANG_VERSION}
ARG ELIXIR_VERSION

MAINTAINER Paul Schoenfelder <paulschoenfelder@gmail.com>

ENV ELIXIR_VERSION=v${ELIXIR_VERSION} \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex

WORKDIR /tmp/elixir-build

RUN \
    apk add --no-cache --update-cache \
      git \
      make && \
    git clone https://github.com/elixir-lang/elixir --depth 1 --branch $ELIXIR_VERSION && \
    cd elixir && \
    if [ ! -d /usr/local/sbin ]; then ln -s /usr/local/bin /usr/local/sbin; fi && \
    make && make install && \
    mkdir -p ${HEX_HOME} && \
    mix local.hex --force && \
    mix local.rebar --force && \
    cd $HOME && \
    rm -rf /tmp/elixir-build

WORKDIR ${HOME}

# Always install latest versions of Hex and Rebar
ONBUILD RUN mix do local.hex --force, local.rebar --force

CMD ["bash"]
