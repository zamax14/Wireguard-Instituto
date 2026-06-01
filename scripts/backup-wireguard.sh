#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${1:-/root/wireguard-backups}"
TS="$(date +%Y%m%d-%H%M%S)"
OUT="${BACKUP_DIR}/wireguard-${TS}.tar.gz"

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Ejecuta este script con sudo/root."
  exit 1
fi

mkdir -p "${BACKUP_DIR}"
chmod 700 "${BACKUP_DIR}"

tar -czf "${OUT}" /etc/wireguard
chmod 600 "${OUT}"

echo "Backup creado: ${OUT}"
