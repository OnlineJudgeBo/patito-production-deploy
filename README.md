# Despliegue público de Patito

Docker Compose para levantar el stack completo: MariaDB, web, kernel, API, panel administrativo, IDE y servidor LSP.

- `docker-compose.yml` publica los servicios por puertos.
- `docker-compose.traefik.yml` agrega Traefik, HTTPS y un solo dominio.

## Configuración

Hace falta Docker Compose v2 y acceso a las imágenes de GHCR.

Prepara el archivo local:

```bash
cp .env.example .env
```

Antes de levantar el stack, revisa `.env` y cambia:

- usuarios y contraseñas de MariaDB;
- `VIBE_IDE_TOKEN_SECRET` y `LSP_AUTH_TOKEN`;
- `JWT_ISS` y `JWT_AUD`;
- puertos y URLs públicas;
- `PATITO_HOST` y el correo de Let's Encrypt si usarás Traefik.

No dejes claves de desarrollo en un servidor público.

Las variables están separadas por grupo en `.env.example`:

| Grupo | Variables principales |
| --- | --- |
| MariaDB | `MARIADB_DATABASE`, `MARIADB_USER`, `MARIADB_PASSWORD`, `MARIADB_ROOT_PASSWORD`, `MARIADB_PORT` |
| Kernel | `OJ_HOST_NAME`, `OJ_USER_NAME`, `OJ_PASSWORD`, `OJ_DB_NAME`, `OJ_*` de tiempo, memoria y lenguajes |
| Web | `PATITO_WEB_PUBLIC_URL`, `APP_DOMAIN*`, `SITE_ID`, `THEME_TEMPLATE` |
| API | `ADMIN_API_PUBLIC_URL`, `ASPNETCORE_ENVIRONMENT`, `JWT_ISS`, `JWT_AUD` |
| IDE | `VIBE_IDE_PUBLIC_URL`, `VIBE_IDE_CONTEXT_URL`, `VIBE_IDE_TOKEN_SECRET` |
| LSP | `VIBE_LSP_PORT`, `LSP_AUTH_TOKEN` |
| Traefik | `PATITO_HOST`, `TRAEFIK_ACME_EMAIL`, puertos y resolver de certificados |
| Opcionales | correo, Telegram y phpMyAdmin |

`OJ_USER_NAME` y `OJ_PASSWORD` deben coincidir con el usuario de aplicación de MariaDB. `JWT_ISS`, `JWT_AUD` y `VIBE_IDE_TOKEN_SECRET` también deben coincidir entre la web, la API y el IDE.

## Orden de arranque

Docker Compose se encarga de las dependencias. El orden general es:

```text
MariaDB
  ├──> web
  ├──> kernel
  └──> API ──> panel e IDE
LSP ──────────> IDE
```

No hace falta iniciar contenedor por contenedor. `docker compose up -d` levanta el stack y respeta los `depends_on` definidos en el archivo.

Para desarrollo desde el código fuente se usa el `docker-compose.yml` de la carpeta superior. El compose de esta carpeta descarga imágenes ya publicadas.

## Levantar por puertos

```bash
cd patito-public-deploy
docker compose pull
docker compose up -d
docker compose ps
```

phpMyAdmin es opcional:

```bash
docker compose --profile tools up -d
```

## Levantar con Traefik

```bash
docker compose \
  -f docker-compose.yml \
  -f docker-compose.traefik.yml \
  up -d
```

El DNS de `PATITO_HOST` debe apuntar al servidor. También deben estar abiertos los puertos 80 y 443.

| Ruta | Servicio |
| --- | --- |
| `/oj/` | web |
| `/api/` | API |
| `/admin/` | panel administrativo |
| `/ide/` | IDE |
| `/lsp/` | WebSocket del LSP |
| `/pma/` | phpMyAdmin, con el perfil `tools` |

La ruta `/` también entra a la web. El dashboard de Traefik no se publica.

## Estructura del proyecto

```text
.
├── config/                    archivos montados en los clientes
├── data/
│   ├── judge/                 configuración y problemas
│   └── vibe-lsp/              workspace y caché
├── db/
│   ├── init/                  scripts para una base nueva
│   └── mysql_data/            datos de MariaDB
├── scripts/                   permisos y generación de judge.conf
├── traefik/                   reglas y certificados
├── .env.example               configuración sin secretos
├── docker-compose.yml          servicios base
└── docker-compose.traefik.yml  proxy HTTPS
```

Los scripts de `db/init/` corren solamente cuando `db/mysql_data/` está vacío. No borres esa carpeta ni uses `docker compose down -v` si quieres conservar la base.

El kernel genera `data/judge/etc/judge.conf` con `scripts/write-judge-conf.sh`. Para conectarse a MariaDB usa `MARIADB_USER` y `MARIADB_PASSWORD`, no la cuenta root.

## Comandos de uso diario

```bash
docker compose ps
docker compose logs -f api patito-web patito-judge-kernel
docker compose pull
docker compose up -d
```

Si una base antigua no tiene los permisos del usuario de la aplicación, ejecuta `./scripts/apply-db-grants.sh`.

La configuración de Traefik está explicada en [`traefik/README.md`](traefik/README.md).
