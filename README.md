# WireGuard VPN Institucional

Plantilla para desplegar una VPN con **WireGuard** en un instituto, permitiendo que usuarios remotos se conecten desde casa a recursos internos de forma controlada.

El diseño recomendado es **split tunnel**: solo el tráfico hacia la red institucional pasa por la VPN; el internet normal del usuario sigue saliendo por su conexión doméstica.

## Arquitectura

```text
Casa del usuario
Windows / Linux / macOS / móvil
   |
Internet
   |
Router / firewall institucional
UDP 51820 publicado
   |
Servidor VPN WireGuard
Ubuntu Server
   |
Red interna institucional
```

Ejemplo de direccionamiento:

```text
Red interna instituto: 192.168.10.0/24
Servidor WireGuard LAN: 192.168.10.20
Red VPN WireGuard: 172.27.240.0/24
Servidor VPN wg0: 172.27.240.1
Puerto VPN: UDP 51820
```

## Contenido del repo

```text
.
├── config/
│   └── wg-server.example.env
├── docs/
│   ├── 01-arquitectura.md
│   ├── 02-instalacion-servidor.md
│   ├── 03-clientes-windows.md
│   ├── 04-operacion-usuarios.md
│   ├── 05-seguridad.md
│   └── 06-troubleshooting.md
├── examples/
│   ├── cliente-windows.conf.example
│   └── route-core-router.example.txt
├── scripts/
│   ├── install-wireguard-server.sh
│   ├── create-client.sh
│   ├── revoke-client.sh
│   ├── list-clients.sh
│   ├── show-client-qr.sh
│   ├── backup-wireguard.sh
│   └── publish-to-github.sh
└── README.md
```

## Inicio rápido

### 1. Copiar configuración base

```bash
cp config/wg-server.example.env config/wg-server.env
nano config/wg-server.env
```

Edita al menos:

```bash
SERVER_ENDPOINT="vpn.instituto.gob.mx:51820"
LAN_CIDR="192.168.10.0/24"
LAN_INTERFACE="ens18"
```

Puedes detectar la interfaz LAN con:

```bash
ip route | grep default
```

### 2. Instalar servidor

```bash
sudo ./scripts/install-wireguard-server.sh config/wg-server.env
```

### 3. Crear cliente

```bash
sudo ./scripts/create-client.sh juan 172.27.240.10
```

Esto genera:

```text
/etc/wireguard/clients/juan/juan.conf
```

Ese archivo se entrega al usuario Windows para importarlo en WireGuard.

### 4. Ver clientes

```bash
sudo ./scripts/list-clients.sh
```

### 5. Revocar cliente

```bash
sudo ./scripts/revoke-client.sh juan
```

## Router/firewall institucional

Debes publicar el puerto UDP hacia el servidor VPN:

```text
WAN UDP 51820 -> IP_LAN_SERVIDOR_VPN UDP 51820
```

Ejemplo:

```text
WAN UDP 51820 -> 192.168.10.20 UDP 51820
```

## Modos de red

### NAT mode

Más fácil para piloto:

```bash
NAT_MODE="true"
```

Los servidores internos verán las conexiones como si vinieran del servidor VPN.

### Routing mode

Más limpio para producción:

```bash
NAT_MODE="false"
```

En el router/core interno agrega una ruta:

```text
172.27.240.0/24 via 192.168.10.20
```

Así los servidores internos ven la IP VPN real de cada usuario.

## Cliente Windows

El usuario instala WireGuard para Windows, importa su `.conf` y activa el túnel.

Ver guía completa: [`docs/03-clientes-windows.md`](docs/03-clientes-windows.md)

## Recomendaciones institucionales

- Un peer por usuario y por dispositivo.
- No compartir archivos `.conf` entre usuarios.
- Usar split tunnel.
- Revocar acceso eliminando el peer correspondiente.
- Mantener inventario de usuario, dispositivo e IP VPN.
- Limitar acceso a servidores/puertos necesarios.
- Preferir routing mode si el equipo de redes puede agregar rutas en el core.
