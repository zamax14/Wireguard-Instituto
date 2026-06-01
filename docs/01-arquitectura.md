# Arquitectura

Objetivo: permitir acceso remoto seguro a recursos internos del instituto usando WireGuard.

## Diseño

```text
Cliente remoto -> Internet -> Firewall institucional UDP 51820 -> Servidor WireGuard Ubuntu -> Red interna
```

## Rangos sugeridos

| Uso | Ejemplo |
|---|---|
| Red interna | `192.168.10.0/24` |
| Red VPN | `172.27.240.0/24` |
| Servidor VPN | `172.27.240.1` |
| Cliente | `172.27.240.10` |

Se recomienda usar una red VPN poco común para evitar choques con redes domésticas.

## Split tunnel

Recomendado:

```ini
AllowedIPs = 172.27.240.0/24, 192.168.10.0/24
```

Solo el tráfico hacia la VPN y la LAN institucional pasa por WireGuard.

## NAT mode

Ideal para piloto rápido. El servidor VPN hace NAT hacia la LAN. No requiere rutas internas adicionales, pero los servidores internos ven el tráfico como si viniera del servidor VPN.

## Routing mode

Más adecuado para producción. En el router/core interno se agrega:

```text
172.27.240.0/24 via 192.168.10.20
```

Con esto los servidores internos pueden ver la IP VPN real de cada usuario.
