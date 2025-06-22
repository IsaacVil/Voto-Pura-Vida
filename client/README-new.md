# Voto Pura Vida - Cliente Web

Panel web del sistema de voto electrónico y crowdfunding para Costa Rica.

## 🚀 Descripción

Este es el frontend de **Voto Pura Vida**, una plataforma que combina:

- **Votaciones Democráticas**: Sistema seguro de voto electrónico con cifrado avanzado
- **Crowdfunding de Proyectos**: Inversiones ciudadanas en proyectos innovadores validados

## 🌟 Características

### Módulo de Votaciones
- ✅ Autenticación multifactor (MFA) con biometría
- ✅ Votaciones seguras con cifrado AES-256
- ✅ Anonimato garantizado del votante
- ✅ Transparencia total de resultados
- ✅ Segmentación por perfil ciudadano

### Módulo de Crowdfunding  
- ✅ Proyectos validados por expertos
- ✅ Fiscalización ciudadana en tiempo real
- ✅ Gestión transparente de fondos
- ✅ Retornos garantizados a inversores
- ✅ Dashboard de seguimiento

### Seguridad
- 🔐 Identidades cifradas con llaves privadas
- 🛡️ Arquitectura Zero Trust
- 📱 Verificación biométrica
- ⚡ Auditoría completa en tiempo real

## 🛠️ Tecnologías

- **Framework**: Next.js 15 con React 19
- **Estilos**: Tailwind CSS
- **Lenguaje**: TypeScript
- **Deployment**: Vercel

## 🏃‍♂️ Ejecutar en Desarrollo

```bash
# Instalar dependencias
npm install

# Ejecutar servidor de desarrollo
npm run dev

# O usar la tarea de VS Code
# Ejecutar: "Dev - Next.js Client" desde el Command Palette
```

El proyecto estará disponible en [http://localhost:3000](http://localhost:3000)

## 📱 Páginas Implementadas

### Públicas
- `/` - Landing page principal
- `/auth/login` - Inicio de sesión (MFA + Biometría)
- `/auth/register` - Registro de ciudadanos (3 pasos)

### Autenticadas  
- `/dashboard` - Panel principal del usuario
- `/votaciones` - Lista y participación en votaciones
- `/crowdfunding` - Exploración e inversión en proyectos
- `/perfil` - Gestión de cuenta personal

## 🎨 Diseño

El diseño utiliza una paleta **blanquita y moderna** con:
- **Verde primario** (#059669) para elementos de votación
- **Azul secundario** (#0284c7) para crowdfunding  
- **Grises suaves** para textos y fondos
- **Gradientes sutiles** para secciones hero

## 🔒 Requerimientos de Seguridad Implementados

### Autenticación
- [x] Registro con validación de identidad costarricense
- [x] MFA obligatorio con códigos temporales
- [x] Verificación biométrica (simulada)
- [x] Prueba de vida digital

### Votaciones
- [x] Un voto por ciudadano por propuesta
- [x] Votos cifrados y anónimos
- [x] Verificación de elegibilidad por perfil
- [x] Auditoría sin comprometer anonimato

### Inversiones
- [x] Validación de proyectos por expertos
- [x] Transparencia en uso de fondos
- [x] Fiscalización ciudadana
- [x] Protección de inversores

## 🏗️ Estructura del Proyecto

```
src/
├── app/                    # App Router de Next.js
│   ├── auth/              # Páginas de autenticación
│   │   ├── login/         # Inicio de sesión
│   │   └── register/      # Registro de usuarios
│   ├── crowdfunding/      # Módulo de inversiones
│   ├── dashboard/         # Panel principal
│   ├── votaciones/        # Módulo de votaciones
│   ├── globals.css        # Estilos globales
│   ├── layout.tsx         # Layout principal
│   └── page.tsx           # Página de inicio
└── components/            # Componentes reutilizables
```

## 🎯 Próximos Pasos

- [ ] Integración con API del backend
- [ ] Implementación de WebSockets para actualizaciones en tiempo real
- [ ] Pruebas unitarias y de integración
- [ ] Optimización de performance
- [ ] PWA para uso móvil

## 👥 Desarrollo

Este proyecto es parte del prototipo presentado al **MICITT** (Ministerio de Ciencia, Innovación, Tecnología y Telecomunicaciones de Costa Rica) para demostrar las capacidades de la plataforma de democracia digital.

---

**🇨🇷 Desarrollado para Costa Rica | MICITT 2025**
