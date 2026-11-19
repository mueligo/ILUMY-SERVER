#!/bin/bash
set -e

echo "================================================="
echo "  Starting ILUMY Pumpkin Minecraft Server        "
echo "  Powered by Pumpkin MC (Rust) & Playit.gg       "
echo "================================================="

cd /pumpkin

# 1. Jalankan pengecekan restore backup dari GitHub
if [ -f "/pumpkin/restore.sh" ]; then
  bash /pumpkin/restore.sh
fi

# 2. Jalankan Playit.gg tunnel di background
echo "[Playit] Menyalakan Playit.gg tunnel agent..."
if [ -n "$SECRET_KEY" ]; then
  echo "[Playit] Menjalankan Playit dengan SECRET_KEY dari Environment Variable..."
  playitd --secret "$SECRET_KEY" &
elif [ -n "$PLAYIT_SECRET_KEY" ]; then
  echo "[Playit] Menjalankan Playit dengan PLAYIT_SECRET_KEY dari Environment Variable..."
  playitd --secret "$PLAYIT_SECRET_KEY" &
else
  echo "[Playit] SECRET_KEY belum diset. Menjalankan playitd mode klaim..."
  playitd &
fi

# 3. Jalankan daemon auto backup 30 menit di background
if [ -f "/pumpkin/backup.sh" ]; then
  echo "[Backup] Menjalankan daemon auto-backup 30 menit..."
  bash /pumpkin/backup.sh &
fi

# 4. Jalankan Pumpkin MC Server (Foreground)
echo "[Pumpkin] Menjalankan Pumpkin Minecraft Server di port 25565..."
exec /usr/local/bin/pumpkin
