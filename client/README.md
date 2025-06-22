# 🗳️ Voto Pura Vida - Panel Web

Panel de administración web para el sistema de votación democrática participativa "Voto Pura Vida" desarrollado con Next.js 15 y React.

## 🚀 Características

- **Dashboard Interactivo**: Vista general del sistema con estadísticas en tiempo real
- **Gestión de Votaciones**: Crear, configurar y monitorear votaciones
- **Gestión de Propuestas**: Administrar propuestas ciudadanas
- **Control de Inversiones**: Monitorear inversiones y distribución de dividendos
- **Gestión de Usuarios**: Administrar usuarios del sistema
- **Diseño Responsivo**: Optimizado para dispositivos móviles y desktop
- **Modo Oscuro**: Soporte completo para tema claro y oscuro

## 🛠️ Tecnologías

- **Next.js 15** - Framework de React con App Router
- **React 18** - Biblioteca de interfaz de usuario
- **TypeScript** - Tipado estático
- **Tailwind CSS** - Framework de estilos utilitarios
- **ESLint** - Linting de código

## 📦 Instalación

Las dependencias ya están instaladas. Para ejecutar el proyecto:

```bash
npm run dev
```

El servidor de desarrollo estará disponible en [http://localhost:3000](http://localhost:3000).

## 🏗️ Scripts Disponibles

- `npm run dev` - Inicia el servidor de desarrollo
- `npm run build` - Construye la aplicación para producción
- `npm run start` - Inicia el servidor de producción
- `npm run lint` - Ejecuta ESLint para verificar el código

## 📁 Estructura del Proyecto

```
src/
├── app/                 # App Router de Next.js
│   ├── layout.tsx      # Layout principal
│   ├── page.tsx        # Página principal
│   └── globals.css     # Estilos globales
├── components/          # Componentes reutilizables
│   ├── Navigation.tsx  # Componente de navegación
│   └── StatsCard.tsx   # Tarjetas de estadísticas
└── ...
```

## 🎨 Diseño

El panel utiliza una paleta de colores verde y azul que representa la naturaleza costarricense ("Pura Vida") con:

- Verde primario: Representa la naturaleza y sostenibilidad
- Diseño limpio y moderno
- Iconografía intuitiva
- Experiencia de usuario optimizada

## 🔗 Integración con Backend

Este panel se conecta con el backend Node.js ubicado en `../core/` que incluye:

- API REST para gestión de datos
- Base de datos con Prisma ORM
- Autenticación y autorización
- Stored procedures para operaciones complejas

## 📱 Características Responsive

- **Mobile First**: Diseño optimizado primero para móviles
- **Breakpoints**: Adaptación automática para tablet y desktop
- **Navigation**: Menú adaptivo según el tamaño de pantalla
- **Grid System**: Layout flexible con CSS Grid y Flexbox

## 🌙 Modo Oscuro

Soporte completo para modo oscuro usando las clases de Tailwind CSS:

- Detección automática de preferencias del sistema
- Transiciones suaves entre temas
- Consistencia en todos los componentes

## 🚧 Próximas Características

- [ ] Autenticación integrada
- [ ] Dashboard en tiempo real con WebSockets
- [ ] Gráficos y visualizaciones avanzadas
- [ ] Exportación de reportes
- [ ] Notificaciones push
- [ ] PWA (Progressive Web App)

## 🤝 Contribución

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Añade nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia especificada en el archivo LICENSE del repositorio principal.

---

**Voto Pura Vida** - Democratizando las decisiones ciudadanas en Costa Rica 🇨🇷
