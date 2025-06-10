# 🚀 Voto Pura Vida API - Configuración

API Serverless para el sistema de voto electrónico y crowdfunding.

## 🏗️ Arquitectura

- **Desarrollo Local**: Express + Docker SQL Server
- **Producción**: Vercel Functions + Azure SQL
- **Endpoints**: Stored Procedures + ORM

## ⚙️ Configuración Inicial

### 1. Instalar dependencias
```bash
npm install
```

### 2. Configurar variables de entorno
```bash
# Copiar el archivo de ejemplo
cp .env.example .env

# Editar con tus credenciales
notepad .env
```

### 3. Probar conexión a la base de datos
```bash
npm run db:test
```

## 🐳 Base de Datos (Docker)

Asegúrate de que tu contenedor SQL Server esté ejecutándose:

```bash
# Verificar contenedores activos
docker ps

# Si no está corriendo, iniciar desde la carpeta raíz del proyecto
cd ../
docker-compose up -d
```

## 🔧 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `npm run dev` | Servidor Express local |
| `npm run dev:vercel` | Servidor Vercel local |
| `npm run start` | Servidor de producción |
| `npm run deploy` | Deploy a Vercel |
| `npm run db:test` | Probar conexión BD |
| `npm test` | Ejecutar tests |

## 📁 Estructura del Proyecto

```
voto-pura-vida-api/
├── 📄 server.js              # Express server (desarrollo)
├── 📁 api/                   # Vercel Functions (producción)
│   ├── 📁 stored-procedures/ # Endpoints con SP
│   └── 📁 orm/              # Endpoints con ORM
├── 📁 src/
│   ├── 📁 config/           # Configuraciones
│   ├── 📁 routes/           # Rutas Express
│   ├── 📁 services/         # Lógica de negocio
│   ├── 📁 middlewares/      # Middlewares
│   ├── 📁 utils/            # Utilidades
│   └── 📁 scripts/          # Scripts de utilidad
├── 📄 .env                  # Variables locales
├── 📄 .env.production       # Variables de producción
└── 📄 vercel.json           # Configuración Vercel
```

## 🌐 Endpoints Implementados

### 📊 Stored Procedures
- `POST /api/stored-procedures/crear-propuesta`
- `POST /api/stored-procedures/revisar-propuesta`
- `POST /api/stored-procedures/invertir`
- `POST /api/stored-procedures/repartir-dividendos`

### 🔄 ORM
- `POST /api/orm/votar`
- `POST /api/orm/comentar`
- `GET /api/orm/listar-votos`
- `POST /api/orm/configurar-votacion`

## 🔒 Configuración de Seguridad

### Variables Críticas
- `JWT_SECRET`: Clave para tokens JWT
- `ENCRYPTION_KEY`: Clave para cifrado de votos
- `DB_PASSWORD`: Contraseña de la base de datos

### Recomendaciones
1. **Nunca** commitear archivos `.env`
2. Usar contraseñas fuertes en producción
3. Rotar claves periódicamente
4. Habilitar HTTPS en producción

## 🚀 Deploy a Vercel

### 1. Configurar variables de entorno
```bash
vercel env add DATABASE_URL
vercel env add JWT_SECRET
vercel env add ENCRYPTION_KEY
```

### 2. Deploy
```bash
npm run deploy
```

## 🐛 Troubleshooting

### Error de conexión BD
```bash
# Verificar Docker
docker ps

# Probar conexión
npm run db:test

# Ver logs del contenedor
docker logs nombre-contenedor-sql
```

### Error en Vercel
```bash
# Ver logs de deployment
vercel logs

# Deploy con debug
vercel --debug
```

## 📞 Soporte

- **Documentación Flyway**: `../docu/README_FLYWAY_DOCKER.md`
- **Documentación Databox**: `../README_DATABOX.md`
- **Scripts BD**: `../scripts/`
