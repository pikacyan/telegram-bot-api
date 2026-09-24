FROM debian:bookworm-slim AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        g++ \
        git \
        gperf \
        libssl-dev \
        make \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
# Keep this commit in sync with the td submodule.
RUN git init td \
    && git -C td fetch --depth 1 https://github.com/tdlib/td.git bc9c263e2bfee06aaab41e82db51a103376030bc \
    && git -C td checkout --detach FETCH_HEAD
COPY CMakeLists.txt ./
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
