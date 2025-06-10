# Tutorial completo: Flyway + Docker + SQL Server para migraciones de base de datos

---

## 1. Levanta SQL Server en Docker

Ejecuta este comando en PowerShell para crear un contenedor de SQL Server:

```powershell
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=VotoPuraVida123#" -p 14333:1433 --name votopuravidaSQL -d mcr.microsoft.com/mssql/server:2022-latest
```

- Usuario: `sa`
- Contraseña: `VotoPuraVida#`
- Puerto: `14333`

Inicie sesión y ejecute `init.sql`

---

## 2. Prepara tus scripts de migración
- Cada cambio a la base de datos debe ser un nuevo archivo SQL, nombrado así:
  - `V1__creation.sql`, `V2__seeding.sql`, etc.
- Coloca todos los scripts en la carpeta `scripts/`.
- Cada vez que quieran agregar algo nuevo, sigan la versión: V3__nombre.sql
---

## 3. Crea el archivo de configuración Flyway para SQL Server
Crea un archivo llamado `flyway.conf` en la raíz del proyecto con el siguiente contenido:

```
flyway.url=jdbc:votopuravidaSQL://host.docker.internal:14333;databaseName=VotoPuraVida
flyway.user=sa
flyway.password=VotoPuraVida#
flyway.locations=filesystem:/flyway/sql
flyway.detectEncoding=true
```

- `host.docker.internal` permite que el contenedor de Flyway acceda al SQL Server que corre en tu máquina (o en otro contenedor en Windows).
---

## 4. Ejecuta las migraciones con Flyway (Docker)

```powershell
docker run --rm -v ${PWD}/scripts:/flyway/sql -v ${PWD}/flyway.conf:/flyway/conf/flyway.conf flyway/flyway migrate
```

- Este comando aplica todas las migraciones a la base de datos SQL Server que levantaste antes.

---

## 5. Recursos útiles
- [Documentación oficial de Flyway](https://flywaydb.org/documentation/)
- [Flyway Docker Hub](https://hub.docker.com/r/flyway/flyway)
- [SQL Server en Docker](https://hub.docker.com/_/microsoft-mssql-server)

---