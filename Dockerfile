FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies yang dibutuhkan
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    rsync \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Download binary resmi Pumpkin MC (Linux x86_64)
RUN curl -fsSL "https://github.com/Pumpkin-MC/Pumpkin/releases/latest/download/pumpkin-X64-Linux" \
    -o /usr/local/bin/pumpkin && \
    chmod +x /usr/local/bin/pumpkin

# Download binary resmi Playit.gg agent (Linux x86_64)
RUN curl -fsSL "https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64" \
    -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

WORKDIR /pumpkin

# Salin script dan konfigurasi
COPY pumpkin.toml /pumpkin/pumpkin.toml
COPY restore.sh /pumpkin/restore.sh
COPY backup.sh /pumpkin/backup.sh
COPY entrypoint.sh /pumpkin/entrypoint.sh

# Beri izin eksekusi
RUN chmod +x /pumpkin/*.sh

EXPOSE 25565

CMD ["/pumpkin/entrypoint.sh"]
