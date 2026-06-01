#!/usr/bin/env bash
set -euo pipefail

CLIENT_NAME="${1:-}"
CLIENT_CONF="/etc/wireguard/clients/${CLIENT_NAME}/${CLIENT_NAME}.conf"

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Ejecuta este script con sudo/root."
  exit 1
fi

if [[ -z "${CLIENT_NAME}" ]]; then
  echo "Uso: sudo $0 nombre_cliente"
  echo "Ejemplo: sudo $0 juan.laptop"
  exit 1
fi

if [[ ! -f "${CLIENT_CONF}" ]]; then
  echo "ERROR: No existe ${CLIENT_CONF}"
  exit 1
fi

if ! command -v qrencode >/dev/null 2>&1; then
  echo "ERROR: qrencode no está instalado."
  echo "Instala con: sudo apt install -y qrencode"
  exit 1
fi

qrencode -t ansiutf8 < "${CLIENT_CONF}"
