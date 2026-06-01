#!/usr/bin/env bash
set -euo pipefail

RUNTIME_ENV="/etc/wireguard/wg-institute.env"

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Ejecuta este script con sudo/root."
  exit 1
fi

if [[ ! -f "${RUNTIME_ENV}" ]]; then
  echo "ERROR: No existe ${RUNTIME_ENV}."
  exit 1
fi

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"

WG_CONF="/etc/wireguard/${WG_INTERFACE}.conf"

if [[ ! -f "${WG_CONF}" ]]; then
  echo "ERROR: No existe ${WG_CONF}"
  exit 1
fi

printf "%-30s %-18s %-10s\n" "CLIENTE" "IP_VPN" "ESTADO"
printf "%-30s %-18s %-10s\n" "-------" "------" "------"

awk '
  /^# / { client=substr($0, 3) }
  /^AllowedIPs = / {
    ip=$3
    if (client != "") {
      printf "%-30s %-18s %-10s\n", client, ip, "config"
      client=""
    }
  }
' "${WG_CONF}"

echo
echo "Estado runtime:"
wg show "${WG_INTERFACE}" || true
