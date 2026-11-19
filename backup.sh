#!/bin/bash
# ==========================================
# ILUMY Server 30-Minute Backup Daemon
# ==========================================

sleep 60
BACKUP_REPO_DIR="/tmp/pumpkin_backup_git"

if [ -z "$GITHUB_TOKEN" ]; then
  echo "[Backup Warning] GITHUB_TOKEN belum diset."
  exit 0
fi

GITHUB_USER="${GITHUB_USERNAME:-mueligo}"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/ILUMY-BACKUP.git"

if [ ! -d "$BACKUP_REPO_DIR/.git" ]; then
  echo "[Backup] Meng-clone repository ILUMY-BACKUP..."
  git clone "$REPO_URL" "$BACKUP_REPO_DIR" || {
    echo "[Backup Error] Gagal meng-clone repo ILUMY-BACKUP."
    exit 1
  }
fi

cd "$BACKUP_REPO_DIR"
git config user.name "ILUMY Backup Bot"
git config user.email "bot@ilumy.local"

echo "[Backup Daemon] Aktif! Backup akan dijalankan otomatis setiap 30 menit..."

while true; do
  MODE="${GAME_MODE:-minecraft}"
  MODE=$(echo "$MODE" | tr '[:upper:]' '[:lower:]')
  echo "[Backup] Memulai proses sinkronisasi data (${MODE}): $(date -u +'%Y-%m-%d %H:%M:%S UTC')..."

  if [ "$MODE" = "terraria" ]; then
    if [ -d "/tmp/terraria/Worlds" ]; then
      mkdir -p "$BACKUP_REPO_DIR/terraria"
      rsync -av --delete /tmp/terraria/Worlds/ "$BACKUP_REPO_DIR/terraria/" 2>/dev/null || true
    fi
  elif [ "$MODE" = "minecraft" ]; then
    if [ -d "/tmp/pumpkin/world" ]; then
      mkdir -p "$BACKUP_REPO_DIR/world"
      rsync -av --delete --exclude='*.lock' --exclude='*.tmp' /tmp/pumpkin/world/ "$BACKUP_REPO_DIR/world/" 2>/dev/null || true
    fi
    if [ -f "/tmp/pumpkin/ops.json" ]; then
      cp -f /tmp/pumpkin/ops.json "$BACKUP_REPO_DIR/ops.json"
    fi
  fi

  cd "$BACKUP_REPO_DIR"
  git add -A

  if git diff --cached --quiet; then
    echo "[Backup] Tidak ada perubahan data. Skip commit."
  else
    TIMESTAMP=$(date -u +'%Y-%m-%d %H:%M:%S UTC')
    git commit -m "Auto backup (${MODE}): ${TIMESTAMP}"
    if git push origin main; then
      echo "[Backup Success] Berhasil backup ${MODE} ke GitHub!"
    else
      echo "[Backup Warning] Push gagal, mencoba pull --rebase..."
      git pull --rebase origin main && git push origin main && echo "[Backup Success] Berhasil backup setelah rebase!"
    fi
  fi

  sleep 1800
done
