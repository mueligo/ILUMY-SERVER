FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependensi sistem yang dibutuhkan
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    rsync \
    procps \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Ambil binary resmi playitd dari image resmi ghcr.io/playit-cloud/playit-agent:1.0
COPY --from=ghcr.io/playit-cloud/playit-agent:1.0 /usr/local/bin/playitd /usr/local/bin/playitd
RUN chmod +x /usr/local/bin/playitd

# Download binary resmi Pumpkin MC (Linux x86_64) - latest release 0.2.2+26.3-26.60
RUN curl -fsSL "https://github.com/Pumpkin-MC/Pumpkin/releases/download/0.2.2%2B26.3-26.60/pumpkin-X64-Linux" \
    -o /usr/local/bin/pumpkin && \
    chmod +x /usr/local/bin/pumpkin

# Download Terraria 1.4.5.8 Dedicated Server (Linux x86_64)
RUN curl -fsSL "https://terraria.org/api/download/pc-dedicated-server/terraria-server-1458.zip" -o /tmp/terraria.zip && \
    unzip -q /tmp/terraria.zip "1458/Linux/*" -d /tmp/terraria_extracted && \
    mkdir -p /terraria && \
    mv /tmp/terraria_extracted/1458/Linux/* /terraria/ && \
    chmod +x /terraria/TerrariaServer.bin.x86_64 /terraria/TerrariaServer && \
    rm -rf /tmp/terraria.zip /tmp/terraria_extracted

WORKDIR /pumpkin

# Salin script dan konfigurasi
COPY pumpkin.toml /pumpkin/pumpkin.toml
COPY ops.json /pumpkin/ops.json
COPY terraria-serverconfig.txt /pumpkin/terraria-serverconfig.txt
COPY restore.sh /pumpkin/restore.sh
COPY backup.sh /pumpkin/backup.sh
COPY entrypoint.sh /pumpkin/entrypoint.sh

RUN chmod +x /pumpkin/*.sh

EXPOSE 25565 7777

CMD ["/pumpkin/entrypoint.sh"]
