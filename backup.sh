#!/bin/bash
# ==========================================
# ILUMY Server 30-Minute Backup Daemon
# ==========================================

# Tunggu 60 detik setelah server start agar world awal sudah ter-generate
sleep 60

BACKUP_REPO_DIR="/pumpkin_backup_git"

if [ -z "$GITHUB_TOKEN" ]; then
  echo "[Backup Warning] GITHUB_TOKEN belum diset di environment variables."
  echo "[Backup Warning] Fitur auto backup 30 menit ke GitHub dinonaktifkan."
  exit 0
fi

GITHUB_USER="${GITHUB_USERNAME:-mueligo}"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/ILUMY-BACKUP.git"

# Clone repo backup jika belum ada
if [ ! -d "$BACKUP_REPO_DIR/.git" ]; then
  echo "[Backup] Meng-clone repository ILUMY-BACKUP..."
  git clone "$REPO_URL" "$BACKUP_REPO_DIR" || {
    echo "[Backup Error] Gagal meng-clone repo ILUMY-BACKUP. Cek kembali token Anda."
    exit 1
  }
fi

cd "$BACKUP_REPO_DIR"
git config user.name "ILUMY Backup Bot"
git config user.email "bot@ilumy.local"

echo "[Backup Daemon] Aktif! Backup akan dijalankan otomatis setiap 30 menit..."

while true; do
  echo "[Backup] Memulai proses sinkronisasi data: $(date -u +'%Y-%m-%d %H:%M:%S UTC')..."

  # Sinkronisasi folder world
  if [ -d "/pumpkin/world" ]; then
    mkdir -p "$BACKUP_REPO_DIR/world"
    rsync -av --delete --exclude='*.lock' --exclude='*.tmp' /pumpkin/world/ "$BACKUP_REPO_DIR/world/"
  fi

  # Salin file konfigurasi
  if [ -f "/pumpkin/pumpkin.toml" ]; then
    cp /pumpkin/pumpkin.toml "$BACKUP_REPO_DIR/pumpkin.toml"
  fi
  if [ -f "/pumpkin/features.toml" ]; then
    cp /pumpkin/features.toml "$BACKUP_REPO_DIR/features.toml"
  fi

  cd "$BACKUP_REPO_DIR"
  git add -A

  if git diff --cached --quiet; then
    echo "[Backup] Tidak ada perubahan data di world/config. Skip commit."
  else
    TIMESTAMP=$(date -u +'%Y-%m-%d %H:%M:%S UTC')
    git commit -m "Auto backup: ${TIMESTAMP}"
    if git push origin main; then
      echo "[Backup Success] Berhasil backup ke GitHub ILUMY-BACKUP pada ${TIMESTAMP}!"
    else
      echo "[Backup Warning] Push gagal, mencoba pull --rebase..."
      git pull --rebase origin main && git push origin main && echo "[Backup Success] Berhasil backup setelah rebase!"
    fi
  fi

  # Istirahat 30 menit (1800 detik)
  sleep 1800
done
