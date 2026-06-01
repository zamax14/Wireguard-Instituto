# Clientes Windows

## Instalación

1. Instalar WireGuard para Windows.
2. Abrir WireGuard.
3. Clic en **Import tunnel(s) from file**.
4. Seleccionar el archivo `.conf` entregado por TI.
5. Clic en **Activate**.

## Configuración típica

```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 172.27.240.10/32
DNS = 192.168.10.1

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = vpn.instituto.gob.mx:51820
AllowedIPs = 172.27.240.0/24, 192.168.10.0/24
PersistentKeepalive = 25
```

## Instructivo corto para usuarios

```text
1. Abre WireGuard.
2. Selecciona tu túnel.
3. Presiona Activate.
4. Para desconectarte, presiona Deactivate.
```

## Notas

Normalmente se requieren permisos de administrador para instalar WireGuard.

Usa un archivo por usuario y por dispositivo:

```text
juan.laptop.conf
juan.desktop.conf
ana.laptop.conf
```

Si un equipo se pierde, se revoca solo ese peer.

## Choque de redes

Si la casa del usuario usa la misma red que el instituto, por ejemplo `192.168.1.0/24`, Windows puede enrutar mal. Por eso conviene que la VPN use un rango poco común como `172.27.240.0/24`.
