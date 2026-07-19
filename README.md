# Patito public deploy

Este folder levanta Patito Online Judge usando imagenes Docker.

## Imagenes usadas

| Servicio | Imagen |
| --- | --- |
| Web client | `ghcr.io/onlinejudgebo/patito-web:patito2-0` |
| Judge kernel | `ghcr.io/onlinejudgebo/patito-judge-kernel:master` |
| Admin API | `ghcr.io/onlinejudgebo/patito-admin-api:develop` |
| Admin UI | `ghcr.io/onlinejudgebo/patito-admin-ui:main` |
| Vibe LSP server | `ghcr.io/samuelloza/vibe-ide-lsp-server:main` |
| Vibe IDE | `ghcr.io/samuelloza/vibe-ide:main` |
| DB | `mariadb:11.3` |
| phpMyAdmin opcional | `phpmyadmin:5.2-apache` |

## Requisitos

- Docker
- Docker Compose v2
- Acceso para descargar imagenes desde GHCR/Docker Hub

## Variables de entorno

Todas las variables del despliegue estan en `.env` dentro de este folder.
Docker Compose lo carga automaticamente al ejecutar comandos desde `patito-public-deploy`.

Para credenciales de aplicacion usa:

```env
MARIADB_USER=...
MARIADB_PASSWORD=...
```

Los servicios de aplicacion usan `MARIADB_USER`/`MARIADB_PASSWORD`, no `root`. `MARIADB_ROOT_PASSWORD` queda reservado para inicializacion/admin de MariaDB y phpMyAdmin.

El contenedor `patito-web` monta `config/patito-web.env` como
`/var/www/html/client-web/.env` porque la imagen PHP actual exige que ese
archivo exista al iniciar. Los valores reales de runtime se inyectan desde el
bloque `environment:` de `docker-compose.yml`, evitando duplicar secretos en
ese archivo montado.


## Estructura

```txt
patito-public-deploy/
├── .env.example                  # variables del despliegue
├── docker-compose.yml            # servicios Docker base
├── docker-compose.traefik.yml    # overlay para reverse proxy Traefik
├── config/patito-web.env         # .env minimo montado en patito-web
├── traefik/                      # configuracion dinamica de Traefik
├── db/init/                      # SQL inicial de MariaDB
└── data/                         # datos montados en contenedores
    ├── judge/            # home del juez (/home/judge)
    │   ├── data/         # problemas/archivos del juez
    │   └── etc/          # judge.conf generado al arrancar
    └── vibe-lsp/         # workspace/storage del LSP
```

`data/judge/etc/judge.conf` se regenera al iniciar `patito-judge-kernel` mediante `scripts/write-judge-conf.sh` usando los valores de `.env`, por eso la clave de base de datos se cambia en un solo lugar.

### Variables usadas por `judge.conf`

El kernel usa el usuario MariaDB de aplicacion (`MARIADB_USER`/`MARIADB_PASSWORD`) por defecto. No debe usar `root` para conectarse a MySQL; el `user: root` del servicio Docker es solo el usuario Linux dentro del contenedor.


El kernel actual solo lee estas claves:

- `judged`: `OJ_HOST_NAME`, `OJ_USER_NAME`, `OJ_PASSWORD`, `OJ_DB_NAME`, `OJ_PORT_NUMBER`, `OJ_RUNNING`, `OJ_SLEEP_TIME`, `OJ_LANG_SET`.
- `judge_client`: `OJ_HOST_NAME`, `OJ_USER_NAME`, `OJ_PASSWORD`, `OJ_DB_NAME`, `OJ_PORT_NUMBER`, `OJ_JAVA_TIME_BONUS`, `OJ_JAVA_MEMORY_BONUS`, `OJ_SIM_ENABLE`, `OJ_JAVA_XMS`, `OJ_JAVA_XMX`, `OJ_OI_MODE`, `OJ_SHM_RUN`, `OJ_USE_MAX_TIME`.

Se quitaron del deploy publico porque no aparecen como claves leidas en el codigo actual: `OJ_TOTAL`, `OJ_MOD`, `OJ_HTTP_JUDGE`, `OJ_HTTP_BASEURL`, `OJ_HTTP_USERNAME`, `OJ_HTTP_PASSWORD`.

## Inicio rapido

```bash
cd patito-public-deploy
cp .env.example .env
# Edita .env antes de usar fuera de local.
docker compose up -d
```

Con phpMyAdmin:

```bash
docker compose --profile tools up -d
```

## Inicio con Traefik

El despliegue base sigue funcionando con puertos directos. Para agregar Traefik como reverse proxy usa el overlay:

```bash
cd patito-public-deploy
cp .env.example .env
# Edita hosts, claves y puertos si corresponde.
docker compose -f docker-compose.yml -f docker-compose.traefik.yml up -d
```

Con phpMyAdmin detras de Traefik:

```bash
docker compose -f docker-compose.yml -f docker-compose.traefik.yml --profile tools up -d
```

Hosts por defecto del overlay HTTPS:

- Web legacy/API/IDE: <https://patito.localhost/>
- Admin API: <https://patito.localhost/api>
- Vibe IDE: <https://patito.localhost/ide/>
- Admin UI: <https://admin.patito.localhost/>
- phpMyAdmin opcional: <https://pma.patito.localhost/>
- Dashboard Traefik: <https://traefik.patito.localhost/> (`admin` / `admin` por defecto)

El puerto `80` queda abierto solo para redirigir a `443` y para el challenge HTTP-01 de Let's Encrypt.
El overlay de produccion tambien cierra los puertos directos heredados del compose base (`3307`, `8082`, `8088`, `8083`, `3000`, `3001`, `8081`); publicamente solo quedan `80` y `443`.

Si usas un dominio real, cambia en `.env` estas variables despues de copiar `.env.example`:

```env
PATITO_HOST=patito.tu-dominio.com
ADMIN_HOST=admin.tu-dominio.com
PHPMYADMIN_HOST=pma.tu-dominio.com
TRAEFIK_DASHBOARD_HOST=traefik.tu-dominio.com
TRAEFIK_ACME_EMAIL=admin@tu-dominio.com
PATITO_WEB_PUBLIC_URL=https://patito.tu-dominio.com
ADMIN_API_PUBLIC_URL=https://patito.tu-dominio.com/api
ADMIN_API_PUBLIC_WS_URL=wss://patito.tu-dominio.com/api
VIBE_IDE_PUBLIC_URL=https://patito.tu-dominio.com/ide/
VIBE_IDE_CONTEXT_URL=https://patito.tu-dominio.com/api/vibe/context
PHPMYADMIN_PUBLIC_URL=https://pma.tu-dominio.com/
```

Nota: el dashboard de Traefik queda protegido por auth basica definida en `traefik/dynamic/middlewares.yml`; cambia esas credenciales antes de exponerlo publicamente.

Para certificados automaticos, Traefik usa Let's Encrypt HTTP-01. En produccion, los DNS de `PATITO_HOST`, `ADMIN_HOST`, `PHPMYADMIN_HOST` y `TRAEFIK_DASHBOARD_HOST` deben apuntar al servidor, y los puertos `80` y `443` deben estar abiertos hacia este compose.

## URLs configuradas en `.env.example`

`.env.example` esta orientado al despliegue con Traefik/HTTPS:

- Web legacy/API/IDE: <https://patito.localhost/>
- Admin UI: <https://admin.patito.localhost/>
- phpMyAdmin opcional: <https://pma.patito.localhost/>
- Dashboard Traefik: <https://traefik.patito.localhost/>

Si levantas solo `docker-compose.yml` sin Traefik, ajusta en `.env` las URLs publicas a los puertos directos correspondientes.

## Datos persistentes

- MariaDB: volumen Docker `patito_mysql_data`
- Archivos/problemas del juez: `./data/judge/data`
- Config del judge: `./data/judge/etc/judge.conf`
- Workspace del LSP: `./data/vibe-lsp/workspace`

## Inicializacion de base de datos

Los scripts en `db/init/` se ejecutan solo la primera vez que el volumen de MariaDB esta vacio:

- `01-jol.sql`
- `02-schedule-management.sql`
- `03-grant-app-user.sh`: garantiza permisos de `MARIADB_USER` sobre `${MARIADB_DATABASE}` y `schedule_management`.

Si cambias esos SQL y quieres reinicializar desde cero:

```bash
docker compose down -v
docker compose up -d
```

Cuidado: `down -v` borra el volumen de base de datos.

Si ya tienes un volumen MariaDB existente y cambiaste de `root` a `MARIADB_USER`, aplica los permisos una vez:

```bash
./scripts/apply-db-grants.sh
```

## Verificacion

```bash
docker compose ps
docker compose logs -f patito-db admin-api patito-web
```
