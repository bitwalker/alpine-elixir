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
$ docker run --rm -it --user=root bitwalker/alpine-elixir iex
Erlang/OTP 20 [erts-9.1.5] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false]

Interactive Elixir (1.6.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

Extending for your own application:

```dockerfile
FROM bitwalker/alpine-elixir:1.6.3

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
