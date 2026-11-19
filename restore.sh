#!/bin/bash
# ==========================================
# ILUMY Server Auto-Restore on Container Boot
# ==========================================

mkdir -p /tmp/pumpkin/world

if [ -n "$GITHUB_TOKEN" ]; then
  WORLD_COUNT=$(find /tmp/pumpkin/world -mindepth 1 2>/dev/null | wc -l)
  if [ "$WORLD_COUNT" -eq 0 ]; then
    echo "[Restore] Folder /tmp/pumpkin/world kosong."
    echo "[Restore] Mencoba restore save data world dari ILUMY-BACKUP..."

    GITHUB_USER="${GITHUB_USERNAME:-mueligo}"
    REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/ILUMY-BACKUP.git"

    rm -rf /tmp/backup_restore
    if git clone --depth 1 "$REPO_URL" /tmp/backup_restore 2>/dev/null; then
      if [ -d "/tmp/backup_restore/world" ]; then
        RESTORE_COUNT=$(find /tmp/backup_restore/world -mindepth 1 2>/dev/null | wc -l)
        if [ "$RESTORE_COUNT" -gt 0 ]; then
          echo "[Restore] Ditemukan backup world di repo. Menyalin ke /tmp/pumpkin/world..."
          cp -r /tmp/backup_restore/world/* /tmp/pumpkin/world/
          echo "[Restore] Sukses me-restore data world!"
        fi
      fi
      rm -rf /tmp/backup_restore
    else
      echo "[Restore Warning] Belum ada backup atau gagal meng-clone ILUMY-BACKUP. Server mulai dari awal."
    fi
  else
    echo "[Restore] Folder world lokal sudah ada data. Melewati proses restore."
  fi
else
  echo "[Restore] GITHUB_TOKEN tidak diset. Melewati proses restore."
fi
