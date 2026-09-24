# Initialize dependencies before building: git submodule update --init --recursive
FROM debian:bookworm-slim AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        cmake \
        g++ \
        gperf \
        libssl-dev \
        make \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY CMakeLists.txt ./
COPY td/ td/
COPY telegram-bot-api/ telegram-bot-api/
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --target install --parallel 2

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libssl3 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
WORKDIR /var/lib/telegram-bot-api
EXPOSE 8081
ENTRYPOINT ["telegram-bot-api"]
