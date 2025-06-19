# Voto Pura Vida 🇨🇷

> Sistema de voto electrónico y crowdfunding para Costa Rica

## Integrantes:
- **Daniel Arce Campos** - Carnet: 2024174489
- **Allan David Bolaños Barrientos** - Carnet: 2024145458
- **Natalia Orozco Delgado** - Carnet: 2024099161
- **Isaac Villalobos Bonilla** - Carnet: 2024124285
---

### Lo que usamos

- **Backend**: Node.js con Express 
- **Base de Datos**: SQL Server con Prisma 
- **Migraciones**: Flyway (para no romper la BD cada vez que cambiamos algo)
- **Deploy**: Vercel 
- **Autenticación**: MFA 
- **Seguridad**: AES-256, RSA

### Cómo está organizado

```text
core/                     # API Principal
├── api/
│   ├── orm/             # Endpoints con ORM (Prisma)
│   │   ├── votar.js
│   │   ├── comentar.js
│   │   ├── listarvotos.js
│   │   └── configurarVotacion.js
│   └── stored-procedures/ # Endpoints con SP
│       ├── crearActualizarPropuesta.js
│       ├── revisarPropuesta.js
│       ├── invertirEnPropuesta.js
│       └── repartirDividendos.js
├── prisma/              # Configuración Prisma ORM
├── src/
│   ├── config/          # Configuraciones
│   └── scripts/         # Scripts de testing
└── package.json

scripts/                 # Migraciones Flyway
├── V1__creation.sql     # Creación inicial de BD
├── V2__alters.sql       # Alteraciones estructurales
├── V3__InvestmentSP.sql # Stored Procedures de inversión
├── V4__repartirDividendos.sql
├── V5__CrearActualizarPropuestaSP.sql
├── V6__RevisarPropuestaSP.sql
└── V7__seeding.sql      # Datos iniciales
```

---

## Cómo levantar esto

### 1. La base de datos

Docker:

```powershell
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=VotoPuraVida123#" -p 14333:1433 --name votopuravidaSQL -d mcr.microsoft.com/mssql/server:2022-latest
```

Los datos para conectarte:

- Usuario: `sa`
- Contraseña: `VotoPuraVida123#`
- Puerto: `14333`

### 2. Configurar Flyway

`flyway.conf` en la raíz con esto:

```properties
flyway.url=jdbc:sqlserver://host.docker.internal:14333;databaseName=VotoPuraVida
flyway.user=sa
flyway.password=VotoPuraVida123#
flyway.locations=filesystem:/flyway/sql
flyway.detectEncoding=true
```

### 3. Correr las migraciones

```powershell
docker run --rm -v ${PWD}/scripts:/flyway/sql -v ${PWD}/flyway.conf:/flyway/conf/flyway.conf flyway/flyway migrate
```

### 4. Instalar el API

```bash
cd core
npm install
npm run prisma:generate
```

### 5. Variables de entorno

Crear un `.env` en la carpeta `/core`:

```env
PRISMA_DATABASE_URL="sqlserver://localhost:14333;database=VotoPuraVida;user=sa;password=VotoPuraVida123#;trustServerCertificate=true"
NODE_ENV=development
PORT=3000
```

### 6. Arrancar el servidor

```bash
# Para desarrollo
npm run dev

# Para producción local
npm start:server

# Para subir a Vercel
npm run deploy
```

---

## Enlaces útiles

- [Flyway](https://flywaydb.org/documentation/)
- [Flyway en Docker](https://hub.docker.com/r/flyway/flyway)
- [SQL Server en Docker](https://hub.docker.com/_/microsoft-mssql-server)
- [Prisma](https://www.prisma.io/docs/)
- [Vercel](https://vercel.com/docs/functions)

---
