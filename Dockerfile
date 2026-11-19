FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependensi sistem yang dibutuhkan
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    rsync \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Ambil binary resmi playitd dari image resmi ghcr.io/playit-cloud/playit-agent:1.0
COPY --from=ghcr.io/playit-cloud/playit-agent:1.0 /usr/local/bin/playitd /usr/local/bin/playitd
RUN chmod +x /usr/local/bin/playitd

# Download binary resmi Pumpkin MC (Linux x86_64)
RUN curl -fsSL "https://github.com/Pumpkin-MC/Pumpkin/releases/latest/download/pumpkin-X64-Linux" \
    -o /usr/local/bin/pumpkin && \
    chmod +x /usr/local/bin/pumpkin

WORKDIR /pumpkin

# Salin script dan konfigurasi
COPY pumpkin.toml /pumpkin/pumpkin.toml
COPY ops.json /pumpkin/ops.json
COPY restore.sh /pumpkin/restore.sh
COPY backup.sh /pumpkin/backup.sh
COPY entrypoint.sh /pumpkin/entrypoint.sh

RUN chmod +x /pumpkin/*.sh

EXPOSE 25565

CMD ["/pumpkin/entrypoint.sh"]
