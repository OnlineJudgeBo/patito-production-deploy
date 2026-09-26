FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Code only. keys/, data/ and config/groups.json are mounted at runtime (see docker-compose.yml).
COPY server.py index.html icpc-bolivia-logo.svg icpc-bolivia-wallpaper.svg command.schema.json ./

EXPOSE 8090

CMD ["python3", "server.py"]
