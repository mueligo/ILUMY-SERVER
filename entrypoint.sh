#!/bin/bash
set -e

echo "================================================="
echo "  ILUMY Multi-Game Server (Minecraft & Terraria)"
echo "  Powered by Hostless Cloud & Playit.gg"
echo "  Active Mode: ${GAME_MODE:-minecraft}"
echo "================================================="

mkdir -p /tmp/playit
rm -f /tmp/playit/playit.sock

# 1. Jalankan Playit tunnel agent di background
if [ -n "$SECRET_KEY" ]; then
  echo "[Playit] Menjalankan playitd daemon..."
  playitd --secret "$SECRET_KEY" --socket-path /tmp/playit/playit.sock > /tmp/playit/playit.log 2>&1 &
  PLAYIT_PID=$!
  sleep 3
  if kill -0 $PLAYIT_PID 2>/dev/null; then
    echo "[Playit] Playit daemon sukses berjalan (PID: $PLAYIT_PID)."
  else
    echo "[Playit Warning] Playit daemon gagal start."
  fi
else
  echo "[Playit Warning] SECRET_KEY tidak diset!"
fi

# 2. Jalankan background backup daemon
if [ -n "$GITHUB_TOKEN" ]; then
  /pumpkin/backup.sh &
  echo "[Backup] Auto-backup daemon aktif di latar belakang."
fi

# 3. Jalankan Game Server berdasarkan GAME_MODE
MODE="${GAME_MODE:-minecraft}"
MODE=$(echo "$MODE" | tr '[:upper:]' '[:lower:]')

case "$MODE" in
  "terraria")
    echo "[Server] Memulai mode TERRARIA SERVER..."
    mkdir -p /tmp/terraria/Worlds
    cp -f /pumpkin/terraria-serverconfig.txt /tmp/terraria/serverconfig.txt 2>/dev/null || true
    
    # Jalankan restore Terraria jika ada backup
    /pumpkin/restore.sh terraria
    
    cd /terraria
    echo "[Server] Menjalankan TerrariaServer.bin.x86_64 pada port 7777..."
    exec ./TerrariaServer.bin.x86_64 -config /tmp/terraria/serverconfig.txt
    ;;

  "stopped"|"idle"|"pause")
    echo "[Server] Mode STOPPED / IDLE diaktifkan. Server tertidur (hemat resource)."
    while true; do
      sleep 3600
    done
    ;;

  *) # Default: Minecraft
    echo "[Server] Memulai mode MINECRAFT (Pumpkin MC)..."
    mkdir -p /tmp/pumpkin/world
    cp -f /pumpkin/pumpkin.toml /tmp/pumpkin/pumpkin.toml
    cp -f /pumpkin/ops.json /tmp/pumpkin/ops.json 2>/dev/null || true
    
    # Jalankan restore Minecraft
    /pumpkin/restore.sh minecraft
    
    cd /tmp/pumpkin
    echo "[Server] Menjalankan Pumpkin MC..."
    exec /usr/local/bin/pumpkin
    ;;
esac
