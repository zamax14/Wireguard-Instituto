# Instalación del servidor

## Requisitos

- Ubuntu Server 22.04/24.04.
- IP fija dentro de la red institucional.
- Puerto UDP publicado hacia el servidor.
- Dominio público o IP pública.
- Acceso root o sudo.

## 1. Preparar configuración

```bash
cp config/wg-server.example.env config/wg-server.env
nano config/wg-server.env
```

Ajusta:

```bash
SERVER_ENDPOINT="vpn.instituto.gob.mx:51820"
LAN_CIDR="192.168.10.0/24"
LAN_INTERFACE="ens18"
CLIENT_DNS="192.168.10.1"
```

Detecta la interfaz LAN con:

```bash
ip route | grep default
```

## 2. Instalar

```bash
sudo ./scripts/install-wireguard-server.sh config/wg-server.env
```

El script instala WireGuard, genera llaves, activa forwarding, crea `/etc/wireguard/wg0.conf`, guarda variables en `/etc/wireguard/wg-institute.env` y levanta `wg-quick@wg0`.

## 3. Verificar

```bash
sudo systemctl status wg-quick@wg0
sudo wg
ip addr show wg0
```

## 4. Publicar puerto

En el firewall institucional:

```text
WAN UDP 51820 -> IP_LAN_SERVIDOR_VPN UDP 51820
```

## 5. Crear cliente

```bash
sudo ./scripts/create-client.sh juan.laptop 172.27.240.10
```

El archivo generado queda en:

```text
/etc/wireguard/clients/juan.laptop/juan.laptop.conf
```
