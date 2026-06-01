# Seguridad

## Principios

- Un peer por usuario y dispositivo.
- No compartir archivos `.conf`.
- No mandar llaves privadas sueltas.
- Mantener inventario de accesos.
- Revocar accesos que ya no se usen.
- Separar usuarios internos de proveedores.
- Dar acceso solo a recursos necesarios.

## Split tunnel

Recomendado:

```ini
AllowedIPs = 172.27.240.0/24, 192.168.10.0/24
```

Evitar full tunnel salvo que sea una política explícita.

## Proveedores externos

Para proveedores se recomienda:

- IP VPN dedicada.
- Vigencia temporal.
- Reglas de firewall más estrictas.
- Acceso solo a servidores y puertos necesarios.

## Revocación

Revocar con:

```bash
sudo ./scripts/revoke-client.sh nombre.dispositivo
```

Después verificar:

```bash
sudo wg
sudo ./scripts/list-clients.sh
```

## Backups

Antes de cambios grandes:

```bash
sudo ./scripts/backup-wireguard.sh
```

El backup contiene `/etc/wireguard`, por lo que debe tratarse como material sensible.
