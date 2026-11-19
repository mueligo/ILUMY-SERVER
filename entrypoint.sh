#!/bin/bash

echo "================================================="
echo "  Starting ILUMY Pumpkin Minecraft Server        "
echo "  Powered by Pumpkin MC (Rust) & Playit.gg       "
echo "================================================="

# Buat direktori kerja di /tmp yang 100% writable (Read-Write)
mkdir -p /tmp/pumpkin/world /tmp/playit
cp /pumpkin/pumpkin.toml /tmp/pumpkin/pumpkin.toml 2>/dev/null || true
cd /tmp/pumpkin

# 1. Jalankan pengecekan restore backup dari GitHub
if [ -f "/pumpkin/restore.sh" ]; then
  bash /pumpkin/restore.sh || true
fi

# 2. Jalankan Playit.gg tunnel di background
echo "[Playit] Menyalakan Playit.gg tunnel agent..."
if [ -n "$SECRET_KEY" ]; then
  echo "[Playit] Menjalankan Playit dengan SECRET_KEY..."
  playitd --secret "$SECRET_KEY" --socket-path /tmp/playit/playit.sock --platform-docker &
elif [ -n "$PLAYIT_SECRET_KEY" ]; then
  echo "[Playit] Menjalankan Playit dengan PLAYIT_SECRET_KEY..."
  playitd --secret "$PLAYIT_SECRET_KEY" --socket-path /tmp/playit/playit.sock --platform-docker &
else
  echo "[Playit] Menjalankan playitd tanpa secret (mode klaim)..."
  playitd --socket-path /tmp/playit/playit.sock --platform-docker &
fi

# 3. Jalankan daemon auto backup 30 menit di background
if [ -f "/pumpkin/backup.sh" ]; then
  echo "[Backup] Menjalankan daemon auto-backup 30 menit..."
  bash /pumpkin/backup.sh &
fi

# 4. Jalankan Pumpkin MC Server (Foreground)
echo "[Pumpkin] Menjalankan Pumpkin Minecraft Server di port 25565..."
exec /usr/local/bin/pumpkin
