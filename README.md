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

Una base nueva arranca con dos usuarios, problemas y concursos de ejemplo:

| Usuario | Contraseña | Rol |
| --- | --- | --- |
| `patitoAdmin` | `patitoAdmin` | administrador |
| `patito` | `patito` | estudiante |

Cambia esas contraseñas al entrar por primera vez.

Las contraseñas y tokens van solo en `.env`. En `config/` están los archivos que se montan en los servicios:

- `appsettings.json`: API. Las conexiones y el JWT se pasan por variables de entorno.
- `admin.config.js` y `patito-ide.config.json`: usan rutas relativas (`/api`), así sirven para cualquier dominio detrás de Traefik.
- `patito-web.env`: vacío, la web usa las variables del compose.

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

Este compose descarga imágenes ya publicadas. Para trabajar sobre el código fuente usa el entorno de [desarrollo local](#desarrollo-local).

## Levantar por puertos

```bash
cd patito-public-deploy
docker compose pull --ignore-buildable
docker compose up -d --build
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
  up -d --build
```

`control-server` no tiene imagen publicada: se construye en el servidor (`--build`) y `pull --ignore-buildable` lo salta.

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

## Máquinas de laboratorio

Para exámenes en PCs con el ISO de concurso. Cada concurso marcado como examen es un grupo de máquinas; se ven y se manejan desde el concurso, en el panel admin.

1. Genera la clave con la que se firman los comandos:

   ```bash
   mkdir -p control/keys control/config control/data
   openssl genpkey -algorithm ed25519 -out control/keys/command-signing.key
   openssl pkey -in control/keys/command-signing.key -pubout -out control/keys/command-signing.pub
   ```

2. En `.env` completa `CONTROL_TOKEN_SECRET`, `CONTROL_LOBBY_ENROLL_TOKEN` y `CONTROL_ADMIN_TOKEN`.
3. Arma el ISO con esta configuración en `config/iso.conf`:

   ```bash
   AUTH_SERVICE_URL="https://<PATITO_HOST>/api/lab/login"
   CONTROL_SERVICE_URL="https://<PATITO_HOST>/control"
   GROUP_ID="lobby"
   ENROLL_TOKEN="<CONTROL_LOBBY_ENROLL_TOKEN>"
   ```

   y hornea `control/keys/command-signing.pub` como clave pública del ISO. El dominio de Patito tiene que estar en la allowlist de red para que los alumnos lleguen al juez.

Los alumnos inician sesión en la PC con su cuenta de Patito. Si tienen un examen activo, la PC pasa al grupo de ese examen; si no, el login se rechaza.

## Desarrollo local

Para trabajar con el código fuente:

```bash
./scripts/init-development-local.sh --up
```

El script clona los repos en `src/`, crea `.env.development` con claves locales y levanta todo con `docker-compose.dev.yml`. Si los repos ya están clonados, los actualiza. Usa `--https` si no tienes SSH configurado en GitHub.

Para levantarlo después:

```bash
docker compose --env-file .env.development -f docker-compose.dev.yml up -d
```

| Servicio | URL |
| --- | --- |
| Web | <http://localhost:8082/oj/> |
| Panel | <http://localhost:8083/admin/> |
| API | <http://localhost:8088/api> |
| IDE | <http://localhost:3000/ide/> |
| MariaDB | `localhost:3307` |

Usuarios de prueba: `patito`/`patito` y `patitoAdmin`/`patitoAdmin`.

Para empezar con una base limpia, detén el stack y borra `db/dev_mysql_data/`.

## Estructura del proyecto

```text
.
├── config/                    archivos montados en los clientes
├── control/                   claves, grupos y datos del control de máquinas (no versionado)
├── control-server/            control de máquinas de laboratorio (copia de icpcbo-live)
├── data/
│   ├── judge/                 configuración y problemas
│   └── vibe-lsp/              workspace y caché
├── db/
│   ├── init/                  scripts para una base nueva
│   └── mysql_data/            datos de MariaDB
├── scripts/                   permisos y generación de judge.conf
├── src/                       repos clonados para desarrollo (no versionado)
├── traefik/                   reglas y certificados
├── .env.example               configuración sin secretos
├── docker-compose.yml          servicios base
├── docker-compose.dev.yml      desarrollo desde el código fuente
└── docker-compose.traefik.yml  proxy HTTPS
```

Los scripts de `db/init/` corren solamente cuando `db/mysql_data/` está vacío. No borres esa carpeta ni uses `docker compose down -v` si quieres conservar la base.

El kernel genera `data/judge/etc/judge.conf` con `scripts/write-judge-conf.sh`. Para conectarse a MariaDB usa `MARIADB_USER` y `MARIADB_PASSWORD`, no la cuenta root.

## Comandos de uso diario

```bash
docker compose ps
docker compose logs -f api patito-web patito-judge-kernel
docker compose pull --ignore-buildable
docker compose up -d --build
```

Si una base antigua no tiene los permisos del usuario de la aplicación, ejecuta `./scripts/apply-db-grants.sh`.

La configuración de Traefik está explicada en [`traefik/README.md`](traefik/README.md).
