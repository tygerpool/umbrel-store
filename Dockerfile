# Tyger DATUM gateway image — innerhat-dev/datum_gateway pinned to the payout-fix build.
# Mirrors retropex/datum-docker's layout (binary /app/datum_gateway, user datum, CMD)
# so the Umbrel compose + hooks work unchanged. Thank you, Retropex.
FROM debian:bookworm-slim AS build
RUN apt update && apt install -y libmicrohttpd12 libjansson4 libsodium23 build-essential cmake curl \
    libmicrohttpd-dev libjansson-dev libcurl4-openssl-dev libsodium-dev pkg-config git
WORKDIR /app
RUN git clone https://github.com/innerhat-dev/datum_gateway.git . \
 && git checkout 4cd17a062d53285c5b48ce87e10f2d85930154e5
RUN cmake -DCMAKE_C_FLAGS=-DDATUM_API_FOR_UMBREL . && make

FROM debian:bookworm-slim AS base
RUN apt update && apt install -y libmicrohttpd12 libjansson4 libsodium23 curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/datum_gateway /app/datum_gateway
RUN adduser --disabled-password --no-create-home --gecos "" datum
USER datum
LABEL org.opencontainers.image.source=https://github.com/tygerpool/umbrel-store
LABEL org.opencontainers.image.description="Tyger DATUM gateway (innerhat 4cd17a0 payout-fix build)"
LABEL org.opencontainers.image.revision=4cd17a062d53285c5b48ce87e10f2d85930154e5
CMD ["./datum_gateway"]
