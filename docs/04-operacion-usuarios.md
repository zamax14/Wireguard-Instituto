# Operación de usuarios

## Crear cliente

```bash
sudo ./scripts/create-client.sh juan.laptop 172.27.240.10
```

Esto genera:

```text
/etc/wireguard/clients/juan.laptop/private.key
/etc/wireguard/clients/juan.laptop/public.key
/etc/wireguard/clients/juan.laptop/juan.laptop.conf
```

Y agrega un bloque `[Peer]` en `/etc/wireguard/wg0.conf`.

## Mostrar QR

```bash
sudo ./scripts/show-client-qr.sh juan.laptop
```

Útil para celulares.

## Listar clientes

```bash
sudo ./scripts/list-clients.sh
```

## Revocar cliente

```bash
sudo ./scripts/revoke-client.sh juan.laptop
```

El script elimina el peer del servidor, reinicia WireGuard y mueve el directorio del cliente a `/etc/wireguard/revoked/`.

## Inventario recomendado

| Usuario | Dispositivo | IP VPN | Estado |
|---|---|---:|---|
| Juan Pérez | Laptop | `172.27.240.10` | Activo |
| Ana López | Laptop | `172.27.240.11` | Activo |
| Proveedor X | Laptop | `172.27.240.50` | Temporal |

## Nomenclatura

```text
nombre.dispositivo
```

Ejemplos:

```text
juan.laptop
juan.desktop
ana.laptop
proveedorx.laptop
```
