# Troubleshooting

## Ver estado del servidor

```bash
sudo systemctl status wg-quick@wg0
sudo wg
ip addr show wg0
```

## No hay handshake

Revisar:

- Puerto UDP publicado en el firewall institucional.
- Endpoint correcto en el cliente.
- Llave pública del peer en el servidor.
- Hora del sistema correcta.
- Servicio activo.

Comando:

```bash
sudo wg
```

Debe aparecer `latest handshake`.

## Hay handshake pero no llega a la LAN

Revisar forwarding:

```bash
cat /proc/sys/net/ipv4/ip_forward
```

Debe responder `1`.

Revisar reglas:

```bash
sudo iptables -S
sudo iptables -t nat -S
```

## Problemas con Windows

- Verificar que el túnel esté activo.
- Probar primero `ping 172.27.240.1`.
- Luego probar un recurso interno por IP.
- Revisar si la red de casa choca con la red institucional.

## DNS interno no resuelve

Probar por IP. Si por IP funciona pero por nombre no, revisar `CLIENT_DNS` en `config/wg-server.env`.

## Ver logs

```bash
journalctl -u wg-quick@wg0 -n 100 --no-pager
```

## Reiniciar servicio

```bash
sudo systemctl restart wg-quick@wg0
```
