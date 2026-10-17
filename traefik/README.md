# Traefik para Patito public deploy

Este folder contiene archivos de Traefik usados por `../docker-compose.traefik.yml`.

## Archivos

- `dynamic/middlewares.yml`: compresion y eliminacion de los prefijos que los backends no conocen.
- `letsencrypt/`: storage ACME (`acme.json`) para certificados automaticos.
- `certs/`: reservado para certificados manuales si se decide no usar ACME.
- `logs/access.json`: registro de peticiones en JSON. La API lo lee (solo lectura) para la página
  **Bloqueos** del panel de administración.

## Rotar el registro de peticiones

Traefik no rota `logs/access.json` por su cuenta. En el servidor, `/etc/logrotate.d/patito-traefik`:

```
/ruta/a/patito-public-deploy/traefik/logs/access.json {
  daily
  rotate 7
  compress
  delaycompress
  missingok
  notifempty
  postrotate
    docker kill --signal=USR1 $(docker ps -qf name=traefik) >/dev/null 2>&1 || true
  endscript
}
```

`USR1` hace que Traefik vuelva a abrir el archivo después de rotarlo.

## Rutas en un solo host

Todas las rutas usan `PATITO_HOST`:

- `/` y `/oj/`: web legacy.
- `/api/`: Admin API.
- `/admin/`: Admin UI, quitando `/admin` antes de llegar a Nginx.
- `/ide/`: Vibe IDE, que conoce su propio base path.
- `/lsp/`: servidor LSP/WebSocket, quitando `/lsp` antes de llegar al servidor.
- `/pma/`: phpMyAdmin opcional, quitando `/pma` antes de llegar a Apache.

El dashboard de Traefik permanece sin router publico.

El overlay publica `80` y `443`: HTTP redirige a HTTPS y Let's Encrypt usa HTTP-01 para emitir certificados.

Antes de produccion:

1. Cambia `TRAEFIK_ACME_EMAIL` en `.env`.
2. Configura `PATITO_HOST` con el unico dominio publico.
3. Apunta ese DNS al servidor.
4. Abre puertos `80` y `443`.
5. Valida la configuracion combinada antes de desplegar:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.traefik.yml --profile tools config --quiet
   ```
