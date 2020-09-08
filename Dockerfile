# Compile
FROM    alpine:3.10 AS compiler

RUN     apk update --quiet
RUN     apk add curl
RUN     apk add build-base

RUN     curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

WORKDIR /meilisearch

COPY    . .

ENV     RUSTFLAGS="-C target-feature=-crt-static"

RUN     $HOME/.cargo/bin/cargo build --release

# Run
FROM    alpine:3.10

RUN     apk add -q --no-cache libgcc tini

COPY    --from=compiler /meilisearch/target/release/meilisearch .

ENV     MEILI_HTTP_ADDR 0.0.0.0:8080
EXPOSE  8080/tcp

ENTRYPOINT ["tini", "--"]
CMD     ./meilisearch --master-key="8e4213e3-a3bd-4d86-89ce-7466843b13d7"
