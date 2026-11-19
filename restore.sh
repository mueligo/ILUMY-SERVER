#!/bin/bash
# ==========================================
# ILUMY Server Auto-Restore on Container Boot
# ==========================================

if [ -n "$GITHUB_TOKEN" ]; then
  if [ ! -d "/pumpkin/world" ] || [ -z "$(ls -A /pumpkin/world 2>/dev/null)" ]; then
    echo "[Restore] Folder /pumpkin/world kosong atau belum ada."
    echo "[Restore] Mencoba restore save data dari ILUMY-BACKUP..."

    GITHUB_USER="${GITHUB_USERNAME:-mueligo}"
    REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/ILUMY-BACKUP.git"

    rm -rf /tmp/backup_restore
    if git clone --depth 1 "$REPO_URL" /tmp/backup_restore 2>/dev/null; then
      if [ -d "/tmp/backup_restore/world" ] && [ -n "$(ls -A /tmp/backup_restore/world 2>/dev/null)" ]; then
        echo "[Restore] Ditemukan backup world di repo. Menyalin ke /pumpkin/world..."
        mkdir -p /pumpkin/world
        cp -r /tmp/backup_restore/world/* /pumpkin/world/
        echo "[Restore] Sukses me-restore data world!"
      else
        echo "[Restore] Belum ada backup world di repo (server baru pertama kali jalan)."
      fi

      if [ -f "/tmp/backup_restore/pumpkin.toml" ]; then
        echo "[Restore] Memperbarui pumpkin.toml dari backup..."
        cp /tmp/backup_restore/pumpkin.toml /pumpkin/pumpkin.toml
      fi

      rm -rf /tmp/backup_restore
    else
      echo "[Restore Warning] Gagal meng-clone ILUMY-BACKUP. Server akan mulai dari awal."
    fi
  else
    echo "[Restore] Folder world lokal sudah ada data. Melewati proses restore."
  fi
else
  echo "[Restore] GITHUB_TOKEN tidak diset. Melewati proses restore."
fi
