FROM rust:slim AS builder

COPY . .

RUN cargo build --release

FROM debian:bullseye-slim

COPY --from=builder \
  /target/release/poc-rust \
  /usr/local/bin/

WORKDIR /root
CMD ROCKET_PORT=$PORT /usr/local/bin/poc-rust