#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-config/wg-server.env}"
RUNTIME_ENV="/etc/wireguard/wg-institute.env"

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Ejecuta este script con sudo/root."
  exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "ERROR: No existe el archivo de configuración: ${CONFIG_FILE}"
  echo "Copia config/wg-server.example.env a config/wg-server.env y edítalo."
  exit 1
fi

# shellcheck disable=SC1090
source "${CONFIG_FILE}"

: "${WG_INTERFACE:?Falta WG_INTERFACE}"
: "${WG_PORT:?Falta WG_PORT}"
: "${SERVER_WG_IPV4:?Falta SERVER_WG_IPV4}"
: "${VPN_CIDR:?Falta VPN_CIDR}"
: "${LAN_CIDR:?Falta LAN_CIDR}"
: "${LAN_INTERFACE:?Falta LAN_INTERFACE}"
: "${SERVER_ENDPOINT:?Falta SERVER_ENDPOINT}"
: "${CLIENT_DNS:?Falta CLIENT_DNS}"
: "${CLIENT_ALLOWED_IPS:?Falta CLIENT_ALLOWED_IPS}"
: "${NAT_MODE:?Falta NAT_MODE}"
: "${MANAGE_UFW:?Falta MANAGE_UFW}"

apt-get update
apt-get install -y wireguard qrencode iptables

mkdir -p /etc/wireguard/keys /etc/wireguard/clients /etc/wireguard/revoked
chmod 700 /etc/wireguard /etc/wireguard/keys /etc/wireguard/clients /etc/wireguard/revoked

if [[ ! -f /etc/wireguard/keys/server_private.key ]]; then
  umask 077
  wg genkey > /etc/wireguard/keys/server_private.key
  wg pubkey < /etc/wireguard/keys/server_private.key > /etc/wireguard/keys/server_public.key
fi

SERVER_PRIVATE_KEY="$(cat /etc/wireguard/keys/server_private.key)"

cat > /etc/sysctl.d/99-wireguard-ip-forward.conf <<SYSCTL
net.ipv4.ip_forward=1
SYSCTL
sysctl --system >/dev/null

if [[ -f "/etc/wireguard/${WG_INTERFACE}.conf" ]]; then
  BACKUP="/etc/wireguard/${WG_INTERFACE}.conf.$(date +%Y%m%d-%H%M%S).bak"
  cp "/etc/wireguard/${WG_INTERFACE}.conf" "${BACKUP}"
  echo "Backup creado: ${BACKUP}"
fi

POST_UP="iptables -A INPUT -p udp --dport ${WG_PORT} -j ACCEPT; iptables -A FORWARD -i %i -s ${VPN_CIDR} -d ${LAN_CIDR} -j ACCEPT; iptables -A FORWARD -o %i -s ${LAN_CIDR} -d ${VPN_CIDR} -j ACCEPT"
POST_DOWN="iptables -D INPUT -p udp --dport ${WG_PORT} -j ACCEPT; iptables -D FORWARD -i %i -s ${VPN_CIDR} -d ${LAN_CIDR} -j ACCEPT; iptables -D FORWARD -o %i -s ${LAN_CIDR} -d ${VPN_CIDR} -j ACCEPT"

if [[ "${NAT_MODE}" == "true" ]]; then
  POST_UP="${POST_UP}; iptables -t nat -A POSTROUTING -s ${VPN_CIDR} -d ${LAN_CIDR} -o ${LAN_INTERFACE} -j MASQUERADE"
  POST_DOWN="${POST_DOWN}; iptables -t nat -D POSTROUTING -s ${VPN_CIDR} -d ${LAN_CIDR} -o ${LAN_INTERFACE} -j MASQUERADE"
fi

cat > "/etc/wireguard/${WG_INTERFACE}.conf" <<WGCONF
[Interface]
Address = ${SERVER_WG_IPV4}
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIVATE_KEY}
PostUp = ${POST_UP}
PostDown = ${POST_DOWN}
WGCONF

chmod 600 "/etc/wireguard/${WG_INTERFACE}.conf"
cp "${CONFIG_FILE}" "${RUNTIME_ENV}"
chmod 600 "${RUNTIME_ENV}"

if command -v ufw >/dev/null 2>&1 && [[ "${MANAGE_UFW}" == "true" ]]; then
  if ufw status | grep -qi "Status: active"; then
    ufw allow "${WG_PORT}/udp"
  fi
fi

systemctl enable "wg-quick@${WG_INTERFACE}"
systemctl restart "wg-quick@${WG_INTERFACE}"

echo "Servidor WireGuard instalado."
echo "Interfaz: ${WG_INTERFACE}"
echo "Puerto: ${WG_PORT}/udp"
echo "VPN: ${VPN_CIDR}"
echo "LAN: ${LAN_CIDR}"
echo "NAT_MODE: ${NAT_MODE}"
echo "Llave pública del servidor:"
cat /etc/wireguard/keys/server_public.key
