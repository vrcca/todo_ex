# -------------- builder phase ------------ #
FROM arm32v7/elixir:1.9-alpine AS builder

ENV MIX_ENV=prod \
    LANG=C.UTF-8

RUN ["mkdir", "-p", "/app"]

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY rel ./rel
COPY ["mix.exs", "mix.lock", "./"]

RUN mix deps.get --only=prod
RUN mix deps.compile
RUN mix release

# -------------- app phase -------------- #
FROM arm32v7/alpine:3.10 AS app

ENV LANG=C.UTF-8

RUN apk add --no-cache openssl ncurses

RUN addgroup -S app && adduser -S app -G app
WORKDIR /home/app

COPY --from=builder --chown=app:app /app/_build .

USER app

CMD ["./prod/rel/todo_ex/bin/todo_ex", "start"]
