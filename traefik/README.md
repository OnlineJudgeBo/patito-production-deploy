# Traefik para Patito public deploy

Este folder contiene archivos de Traefik usados por `../docker-compose.traefik.yml`.

## Archivos

- `dynamic/middlewares.yml`: middlewares compartidos (`compress` y auth basica para el dashboard).
- `letsencrypt/`: storage ACME (`acme.json`) para certificados automaticos.
- `certs/`: reservado para certificados manuales si se decide no usar ACME.

## Hosts por defecto

- `patito.localhost`: Web legacy, API (`/api`) e IDE (`/ide`).
- `admin.patito.localhost`: Admin UI.
- `pma.patito.localhost`: phpMyAdmin cuando se levanta con profile `tools`.
- `traefik.patito.localhost`: dashboard Traefik.

El overlay publica `80` y `443`: HTTP redirige a HTTPS y Let's Encrypt usa HTTP-01 para emitir certificados.

Antes de produccion:

1. Cambia `TRAEFIK_ACME_EMAIL` en `.env`.
2. Cambia los hosts `PATITO_HOST`, `ADMIN_HOST`, `PHPMYADMIN_HOST`, `TRAEFIK_DASHBOARD_HOST` a dominios reales.
3. Apunta esos DNS al servidor.
4. Abre puertos `80` y `443`.
5. Cambia las credenciales del dashboard.

Credenciales por defecto del dashboard: `admin` / `admin`. Cambialas antes de exponerlo fuera de local.
