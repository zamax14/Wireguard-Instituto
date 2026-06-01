#!/usr/bin/env bash
set -euo pipefail

CLIENT_NAME="${1:-}"
CLIENT_IP="${2:-}"
RUNTIME_ENV="/etc/wireguard/wg-institute.env"

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Ejecuta este script con sudo/root."
  exit 1
fi

if [[ -z "${CLIENT_NAME}" || -z "${CLIENT_IP}" ]]; then
  echo "Uso: sudo $0 nombre_cliente ip_vpn"
  echo "Ejemplo: sudo $0 juan.laptop 172.27.240.10"
  exit 1
fi

if [[ ! -f "${RUNTIME_ENV}" ]]; then
  echo "ERROR: No existe ${RUNTIME_ENV}. Ejecuta primero install-wireguard-server.sh"
  exit 1
fi

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"

WG_CONF="/etc/wireguard/${WG_INTERFACE}.conf"
CLIENT_DIR="/etc/wireguard/clients/${CLIENT_NAME}"
CLIENT_CONF="${CLIENT_DIR}/${CLIENT_NAME}.conf"

if [[ -d "${CLIENT_DIR}" ]]; then
  echo "ERROR: El cliente ya existe: ${CLIENT_NAME}"
  exit 1
fi

if grep -q "AllowedIPs = ${CLIENT_IP}/32" "${WG_CONF}"; then
  echo "ERROR: La IP VPN ya está asignada: ${CLIENT_IP}"
  exit 1
fi

mkdir -p "${CLIENT_DIR}"
chmod 700 "${CLIENT_DIR}"

umask 077
wg genkey > "${CLIENT_DIR}/private.key"
wg pubkey < "${CLIENT_DIR}/private.key" > "${CLIENT_DIR}/public.key"

CLIENT_PRIVATE_KEY="$(cat "${CLIENT_DIR}/private.key")"
CLIENT_PUBLIC_KEY="$(cat "${CLIENT_DIR}/public.key")"
SERVER_PUBLIC_KEY="$(cat /etc/wireguard/keys/server_public.key)"

cat > "${CLIENT_CONF}" <<CLIENTCONF
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/32
DNS = ${CLIENT_DNS}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_ENDPOINT}
AllowedIPs = ${CLIENT_ALLOWED_IPS}
PersistentKeepalive = 25
CLIENTCONF

chmod 600 "${CLIENT_CONF}"

cat >> "${WG_CONF}" <<PEERCONF

[Peer]
# ${CLIENT_NAME}
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_IP}/32
PEERCONF

systemctl restart "wg-quick@${WG_INTERFACE}"

echo "Cliente creado: ${CLIENT_NAME}"
echo "IP VPN: ${CLIENT_IP}"
echo "Archivo cliente: ${CLIENT_CONF}"
echo
echo "Para ver QR:"
echo "sudo ./scripts/show-client-qr.sh ${CLIENT_NAME}"
