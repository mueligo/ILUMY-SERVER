#!/bin/bash
# ==========================================
# ILUMY Server Auto-Restore on Container Boot
# ==========================================

TARGET_GAME="${1:-${GAME_MODE:-minecraft}}"
TARGET_GAME=$(echo "$TARGET_GAME" | tr '[:upper:]' '[:lower:]')

if [ -z "$GITHUB_TOKEN" ]; then
  echo "[Restore] GITHUB_TOKEN tidak diset. Melewati proses restore."
  exit 0
fi

GITHUB_USER="${GITHUB_USERNAME:-mueligo}"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/ILUMY-BACKUP.git"
BACKUP_RESTORE_DIR="/tmp/backup_restore"

rm -rf "$BACKUP_RESTORE_DIR"
if ! git clone --depth 1 "$REPO_URL" "$BACKUP_RESTORE_DIR" 2>/dev/null; then
  echo "[Restore Warning] Belum ada backup atau gagal clone ILUMY-BACKUP."
  exit 0
fi

if [ "$TARGET_GAME" = "terraria" ]; then
  echo "[Restore] Memeriksa data world Terraria..."
  mkdir -p /tmp/terraria/Worlds
  if [ -d "$BACKUP_RESTORE_DIR/terraria" ]; then
    cp -rf "$BACKUP_RESTORE_DIR/terraria/"* /tmp/terraria/Worlds/ 2>/dev/null || true
    echo "[Restore] Sukses me-restore save data Terraria!"
  else
    echo "[Restore] Belum ada save data Terraria di repo. Server akan generate world baru."
  fi
else
  echo "[Restore] Memeriksa data world Minecraft..."
  mkdir -p /tmp/pumpkin/world
  WORLD_COUNT=$(find /tmp/pumpkin/world -mindepth 1 2>/dev/null | wc -l)
  if [ "$WORLD_COUNT" -eq 0 ]; then
    if [ -d "$BACKUP_RESTORE_DIR/world" ]; then
      cp -rf "$BACKUP_RESTORE_DIR/world/"* /tmp/pumpkin/world/ 2>/dev/null || true
      echo "[Restore] Sukses me-restore data world Minecraft!"
    fi
  fi
  if [ -f "$BACKUP_RESTORE_DIR/ops.json" ]; then
    echo "[Restore] Ditemukan ops.json di backup. Menyalin ke /tmp/pumpkin/ops.json..."
    cp -f "$BACKUP_RESTORE_DIR/ops.json" /tmp/pumpkin/ops.json 2>/dev/null || true
  fi
fi

rm -rf "$BACKUP_RESTORE_DIR"
