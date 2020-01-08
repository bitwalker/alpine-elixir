# Elixir for running releases on Alpine Linux

This Dockerfile provides a full installation of Erlang and Elixir on Alpine, intended for running releases,
so it has no build tools installed. The Erlang installation is provided so one can avoid cross-compiling
releases. The caveat, of course, is if one has NIFs which require a native compilation toolchain, but that is
left as an exercise for the reader.

## Usage

NOTE: This image sets up a `default` user, with home set to `/opt/app` and owned by that user. The working directory
is also set to `$HOME`. It is highly recommended that you add a `USER default` instruction to the end of your
Dockerfile so that your app runs in a non-elevated context.

To boot straight to a prompt in the image:

```
$ docker run --rm -it --user=root bitwalker/alpine-elixir iex
Erlang/OTP 22 [erts-10.3] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false]

Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

Extending for your own application:

```dockerfile
#https://github.com/bitwalker/alpine-elixir/issues/51
FROM bitwalker/alpine-elixir:latest

ENV APP_NAME="my_app" \
    PORT=4000 \
    MIX_ENV=prod

# Set exposed ports
EXPOSE 4000

COPY my_app ./

RUN chown -R default ${APP_NAME}

USER default

CMD ./${APP_NAME}/bin/${APP_NAME} start
```

Where is `my_app` in `COPY` commando above is the folder created by `mix release` command (E.g. `_build/prod/rel/my_app`)


## Extras

If you want an extended Dockerfile to build and run your project, feel free to use this:
```dockerfile
#===========
#Build Stage
#===========
FROM elixir:1.9-alpine as build

ENV MIX_ENV="prod" \
    APP_NAME="my_app"

RUN apk add --no-cache bash
RUN apk add --update \
  build-base

RUN yes | mix local.hex
RUN yes | mix local.rebar --force

COPY . .
RUN mix deps.get && \
    mix deps.compile && \
    mix release && \
    mkdir /latest_release && \
    cp -R "_build/prod/rel/${APP_NAME}" /latest_release/

#================
#Deployment Stage
#================

#https://github.com/bitwalker/alpine-elixir/issues/51
FROM bitwalker/alpine-elixir:latest

ENV APP_NAME="my_app" \
    PORT=4000 \
    MIX_ENV=prod

EXPOSE 4000

COPY --from=build /latest_release/ .

RUN chown -R default ${APP_NAME}

#https://github.com/bitwalker/alpine-elixir#usage
USER default

CMD ./${APP_NAME}/bin/${APP_NAME} start

```
This dockerfile is handy for CI deploy pipelines. E.g. you can define a Gitlab CI job (.gitlab-ci.yml) like that

````
stages:
  - deploy

deploy:
  image: docker:stable
  variables:
    DOCKER_DRIVER: overlay2
    DOCKER_HOST: "tcp://docker:2375/"
  services:
    - docker:18.09.7-dind
  stage: build
  script:
    - docker build -t ${IMAGE_NAME}:${CI_COMMIT_REF_NAME} -f Dockerfile .
    - docker run --name my-service -d ${IMAGE_NAME}:${CI_COMMIT_REF_NAME}
  only:
    - master
````
## License

MIT
