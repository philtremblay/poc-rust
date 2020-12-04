FROM debian:bullseye-slim AS builder

RUN apt-get update && apt-get install -y curl libpq-dev build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    curl https://sh.rustup.rs/ -sSf | sh -s -- -y --default-toolchain nightly 

ENV PATH="/root/.cargo/bin:${PATH}"

ADD . ./

RUN cargo build --release

FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder \
  /target/release/poc-rust \
  /usr/local/bin/

WORKDIR /root
CMD ROCKET_PORT=$PORT /usr/local/bin/poc-rust