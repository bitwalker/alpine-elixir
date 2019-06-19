# Elixir on Alpine Linux

This Dockerfile provides a full installation of Erlang and Elixir on Alpine, intended for running releases,
so it has no build tools installed. The Erlang installation is provided so one can avoid cross-compiling
releases. The caveat of course is if one has NIFs which require a native compilation toolchain, but that is
left as an exercise for the reader.

## Usage

NOTE: This image sets up a `default` user, with home set to `/opt/app` and owned by that user. The working directory
is also set to `$HOME`. It is highly recommended that you add a `USER default` instruction to the end of your
Dockerfile so that your app runs in a non-elevated context.

To boot straight to a prompt in the image:

```
docker run --rm -it --user=root bitwalker/alpine-elixir iex
```

Extending for your own application:

```dockerfile
FROM bitwalker/alpine-elixir:1.8.2

# Set exposed ports
EXPOSE 5000
ENV PORT=5000

ENV MIX_ENV=prod

COPY yourapp.tar.gz ./
RUN tar -xzvf yourapp.tar.gz

USER default

CMD ./bin/yourapp foreground
```

## License

MIT
