# -------------- builder ------------ #
FROM elixir:1.9-alpine AS builder

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
COPY mix.exs .
COPY mix.lock .

RUN mix deps.get
RUN mix deps.compile
RUN mix release

# -------------- app -------------- #
FROM alpine:3.10 AS app

ENV LANG=C.UTF-8
RUN apk add --no-cache openssl ncurses

RUN adduser -S app
WORKDIR /home/app

COPY --from=builder /app/_build .
RUN chown -R app: ./prod
USER app

CMD ["./prod/rel/todo_ex/bin/todo_ex", "start"]
