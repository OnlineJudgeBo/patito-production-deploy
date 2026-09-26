# control-server

Copia del control-server de `icpcbo-live` (`control-server/`, 2026-09-26), sin cambios en el código.
Los SVG `icpc-bolivia-logo.svg` e `icpc-bolivia-wallpaper.svg` llevan el logo de Patito; conservan el nombre porque `server.py` los sirve con esa ruta.
Maneja las PCs de laboratorio del ISO: registro, comandos firmados, estado y alertas.

En Patito:

- Cada examen es un grupo `contest-<id>`. La API de Patito lo escribe en `control/config/groups.json`
  (el servidor relee ese archivo en cada pedido) con tokens derivados de `CONTROL_TOKEN_SECRET`.
- Los alumnos inician sesión en el ISO con su cuenta de Patito (`/api/lab/login`).
- El panel de máquinas está en el admin de Patito; este servidor no se expone salvo `/enroll` y `/cmd/`.

Para actualizarlo, volver a copiar `server.py` (y los demás archivos del `Dockerfile`) desde `icpcbo-live`.
