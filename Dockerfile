FROM debian:bullseye-slim AS builder

RUN apt-get update && apt-get install -y curl build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    curl https://sh.rustup.rs/ -sSf | sh -s -- -y --default-toolchain nightly 

ENV PATH="/root/.cargo/bin:${PATH}"

ADD . ./

RUN cargo build --release

FROM debian:bullseye-slim

COPY --from=builder \
  /target/release/poc-rust \
  /usr/local/bin/

WORKDIR /root
CMD ROCKET_PORT=$PORT /usr/local/bin/poc-rust