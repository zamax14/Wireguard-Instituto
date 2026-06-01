#!/usr/bin/env bash
set -euo pipefail

CLIENT_NAME="${1:-}"
RUNTIME_ENV="/etc/wireguard/wg-institute.env"

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Ejecuta este script con sudo/root."
  exit 1
fi

if [[ -z "${CLIENT_NAME}" ]]; then
  echo "Uso: sudo $0 nombre_cliente"
  echo "Ejemplo: sudo $0 juan.laptop"
  exit 1
fi

if [[ ! -f "${RUNTIME_ENV}" ]]; then
  echo "ERROR: No existe ${RUNTIME_ENV}."
  exit 1
fi

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"

WG_CONF="/etc/wireguard/${WG_INTERFACE}.conf"
CLIENT_DIR="/etc/wireguard/clients/${CLIENT_NAME}"
REVOKED_DIR="/etc/wireguard/revoked/${CLIENT_NAME}-$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "${WG_CONF}" ]]; then
  echo "ERROR: No existe ${WG_CONF}"
  exit 1
fi

TMP_FILE="$(mktemp)"

awk -v name="${CLIENT_NAME}" '
  BEGIN { skip=0; buf="" }
  /^\[Peer\]/ {
    buf=$0 "\n"
    if ((getline line) > 0) {
      buf=buf line "\n"
      if (line == "# " name) {
        skip=1
        next
      }
      printf "%s", buf
      skip=0
      next
    }
  }
  skip == 1 {
    if ($0 ~ /^\[Peer\]/) {
      skip=0
      print $0
    }
    next
  }
  { print }
' "${WG_CONF}" > "${TMP_FILE}"

cp "${WG_CONF}" "${WG_CONF}.$(date +%Y%m%d-%H%M%S).bak"
cat "${TMP_FILE}" > "${WG_CONF}"
rm -f "${TMP_FILE}"
chmod 600 "${WG_CONF}"

if [[ -d "${CLIENT_DIR}" ]]; then
  mkdir -p /etc/wireguard/revoked
  mv "${CLIENT_DIR}" "${REVOKED_DIR}"
  echo "Cliente movido a: ${REVOKED_DIR}"
fi

systemctl restart "wg-quick@${WG_INTERFACE}"

echo "Cliente revocado: ${CLIENT_NAME}"
