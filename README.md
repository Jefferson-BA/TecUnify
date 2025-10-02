# 🎓 tecUnify - Plataforma Universitaria de Gestión

<div align="center">

![tecUnify Logo](https://via.placeholder.com/150x150?text=tecUnify)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![React](https://img.shields.io/badge/React-18.2-blue.svg)](https://reactjs.org/)
[![Django](https://img.shields.io/badge/Django-4.2-green.svg)](https://www.djangoproject.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)

**Una plataforma completa de gestión universitaria con arquitectura de microservicios**

[Características](#-características) • [Instalación](#-instalación-rápida) • [Documentación](#-documentación) • [Contribuir](#-contribuir)

</div>

---

## 📋 Tabla de Contenidos

- [Acerca del Proyecto](#-acerca-del-proyecto)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Características](#-características)
- [Instalación Rápida](#-instalación-rápida)
- [Configuración](#-configuración)
- [Uso](#-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [API Endpoints](#-api-endpoints)
- [Desarrollo](#-desarrollo)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)
- [Contacto](#-contacto)

---

## 🎯 Acerca del Proyecto

**tecUnify** es una plataforma integral de gestión universitaria diseñada con arquitectura de microservicios. Proporciona dos módulos principales:

- **🔐 Módulo de Administración**: Para gestión administrativa y control del sistema
- **👥 Módulo de Usuario**: Para estudiantes y personal con acceso web y móvil

### ¿Por qué tecUnify?

- ✅ **Escalable**: Arquitectura de microservicios independientes
- ✅ **Multiplataforma**: Web y móvil (Android)
- ✅ **Moderna**: Tecnologías actuales y mejores prácticas
- ✅ **Fácil de desplegar**: Docker Compose para desarrollo y producción
- ✅ **Bien documentada**: Guías completas y ejemplos

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                      ADMINISTRACIÓN                          │
├───────────────────────┬─────────────────────────────────────┤
│   Frontend Web        │        Backend                      │
│   React + Vite        │   Django + DRF                      │
│   Puerto: 3000        │   Puerto: 8000                      │
└───────────────────────┴──────────────┬──────────────────────┘
                                       │
                                       │
                        ┌──────────────▼──────────────┐
                        │   Base de Datos             │
                        │   PostgreSQL                │
                        │   Puerto: 5432              │
                        └──────────────┬──────────────┘
                                       │
┌─────────────────────────────────────┴───────────────────────┐
│                         USUARIO                              │
├──────────────────┬──────────────────┬───────────────────────┤
│ Frontend Web     │ Frontend Móvil   │    Backend            │
│ React + Vite     │ Kotlin (Android) │ Spring Boot + JPA     │
│ Puerto: 3001     │                  │ Puerto: 8080          │
└──────────────────┴──────────────────┴───────────────────────┘
```

---

## 🛠️ Tecnologías

### Frontend
- **React 18** - Biblioteca de UI
- **Vite** - Build tool y dev server
- **Axios** - Cliente HTTP
- **React Router DOM** - Enrutamiento

### Backend
- **Django 4.2** - Framework Python
- **Django REST Framework** - API REST
- **Spring Boot 3.2** - Framework Java
- **Spring Data JPA** - ORM

### Móvil
- **Kotlin** - Lenguaje nativo Android
- **Retrofit** - Cliente HTTP
- **Material Design** - UI Components

### Base de Datos
- **PostgreSQL 15** - Base de datos relacional

### DevOps
- **Docker** - Contenedorización
- **Docker Compose** - Orquestación
- **Git** - Control de versiones

---

## ✨ Características

### Módulo de Administración
- 📊 Dashboard administrativo
- 👥 Gestión de usuarios
- 📈 Reportes y estadísticas
- ⚙️ Configuración del sistema
- 🔒 Control de accesos

### Módulo de Usuario
- 👤 Perfil de usuario
- 📱 App móvil nativa
- 🌐 Portal web responsive
- 📚 Acceso a recursos
- 🔔 Notificaciones

### Características Técnicas
- 🔐 Autenticación y autorización
- 🔄 API RESTful
- 📦 Arquitectura modular
- 🐳 Docker ready
- 🔍 Búsqueda y filtrado
- 📄 Documentación de API

---

## 🚀 Instalación Rápida

### Prerrequisitos

- [Docker](https://www.docker.com/get-started) (20.10 o superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (2.0 o superior)
- [Git](https://git-scm.com/)

### Instalación en 3 pasos

#### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/tecunify.git
cd tecunify
```

#### 2️⃣ Crear el proyecto desde el script

```bash
# Dar permisos al script
chmod +x create-tecunify.sh

# Ejecutar el script
./create-tecunify.sh tecUnify

# Entrar al directorio creado
cd tecUnify
```

#### 3️⃣ Inicializar y levantar servicios

```bash
# Inicializar el proyecto
chmod +x init-project.sh
./init-project.sh

# Levantar todos los servicios con Docker
docker-compose up -d
```

### ✅ Verificar instalación

```bash
# Ver el estado de los contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f
```

### 🌐 Acceder a los servicios

Una vez levantados los servicios, accede a:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| 🖥️ Admin Frontend | http://localhost:3000 | Panel de administración |
| ⚙️ Admin Backend | http://localhost:8000 | API Django |
| 📱 Usuario Frontend | http://localhost:3001 | Portal de usuario |
| 🔧 Usuario Backend | http://localhost:8080 | API Spring Boot |
| 🗄️ PostgreSQL | localhost:5432 | Base de datos |

---

## ⚙️ Configuración

### Variables de Entorno

Cada módulo tiene su archivo de configuración:

#### Django (Administración)
```bash
# administracion/backend-django/.env
SECRET_KEY=tu-secret-key-aqui
DEBUG=True
DATABASE_URL=postgresql://admin:admin123@postgres:5432/tecunify
ALLOWED_HOSTS=localhost,127.0.0.1
```

#### Spring Boot (Usuario)
```bash
# usuario/backend-springboot/src/main/resources/application.properties
spring.datasource.url=jdbc:postgresql://postgres:5432/tecunify
spring.datasource.username=admin
spring.datasource.password=admin123
```

#### React Frontend
```bash
# administracion/frontend-web/.env
VITE_API_URL=http://localhost:8000/api

# usuario/frontend-web/.env
VITE_API_URL=http://localhost:8080/api
```

### Base de Datos

**Credenciales por defecto:**
- **Usuario**: admin
- **Contraseña**: admin123
- **Base de datos**: tecunify
- **Puerto**: 5432

⚠️ **Importante**: Cambia estas credenciales en producción.

---

## 💻 Uso

### Comandos Docker

```bash
# Iniciar todos los servicios
docker-compose up -d

# Detener todos los servicios
docker-compose down

# Ver logs de un servicio específico
docker-compose logs -f [nombre-servicio]

# Reconstruir y levantar servicios
docker-compose up -d --build

# Limpiar todo (incluye volúmenes)
docker-compose down -v
```

### Desarrollo Local (sin Docker)

#### Backend Django

```bash
cd administracion/backend-django
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

#### Frontend React (Admin)

```bash
cd administracion/frontend-web
npm install
npm run dev
```

#### Backend Spring Boot

```bash
cd usuario/backend-springboot
./mvnw spring-boot:run
```

#### Frontend React (Usuario)

```bash
cd usuario/frontend-web
npm install
npm run dev
```

---

## 📁 Estructura del Proyecto

```
tecUnify/
├── 📂 administracion/           # Módulo de administración
│   ├── 📂 frontend-web/         # React frontend
│   │   ├── src/
│   │   ├── package.json
│   │   ├── vite.config.js
│   │   └── Dockerfile
│   └── 📂 backend-django/       # Django backend
│       ├── config/
│       ├── apps/
│       ├── requirements.txt
│       └── Dockerfile
├── 📂 usuario/                  # Módulo de usuario
│   ├── 📂 frontend-web/         # React frontend
│   │   ├── src/
│   │   ├── package.json
│   │   └── Dockerfile
│   ├── 📂 frontend-movil/       # Kotlin Android
│   │   ├── app/
│   │   └── build.gradle
│   └── 📂 backend-springboot/   # Spring Boot backend
│       ├── src/
│       ├── pom.xml
│       └── Dockerfile
├── 📂 database/                 # Scripts de BD
│   └── init.sql
├── 📂 docs/                     # Documentación
│   ├── INSTALACION.md
│   └── API.md
├── 🐳 docker-compose.yml        # Orquestación Docker
├── 📜 create-tecunify.sh        # Script de creación
├── 🧹 clean-project.sh          # Script de limpieza
└── 📖 README.md                 # Este archivo
```

---

## 🔌 API Endpoints

### Administración (Django - Puerto 8000)

```http
GET    /api/usuarios/          # Listar usuarios
POST   /api/usuarios/          # Crear usuario
GET    /api/usuarios/{id}/     # Obtener usuario
PUT    /api/usuarios/{id}/     # Actualizar usuario
DELETE /api/usuarios/{id}/     # Eliminar usuario
```

### Usuario (Spring Boot - Puerto 8080)

```http
GET    /api/usuarios           # Listar usuarios
POST   /api/usuarios           # Crear usuario
GET    /api/usuarios/{id}      # Obtener usuario
PUT    /api/usuarios/{id}      # Actualizar usuario
DELETE /api/usuarios/{id}      # Eliminar usuario
```

### Ejemplo de Uso

```bash
# Listar usuarios (Django)
curl http://localhost:8000/api/usuarios/

# Crear usuario (Spring Boot)
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nuevo@tecunify.com",
    "password": "password123",
    "nombre": "Usuario",
    "apellido": "Nuevo",
    "tipoUsuario": "USUARIO"
  }'
```

📚 **Documentación completa de API**: Ver [docs/API.md](docs/API.md)

---

## 🔧 Desarrollo

### Ejecutar Tests

#### Django
```bash
cd administracion/backend-django
python manage.py test
```

#### Spring Boot
```bash
cd usuario/backend-springboot
./mvnw test
```

### Linting y Formato

#### JavaScript/React
```bash
npm run lint
npm run format
```

#### Python
```bash
black .
flake8 .
```

### Migraciones de Base de Datos

#### Django
```bash
python manage.py makemigrations
python manage.py migrate
```

#### Spring Boot
Las migraciones se manejan automáticamente con JPA/Hibernate.

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! 

### Proceso de contribución

1. 🍴 Fork el proyecto
2. 🌿 Crea tu rama de feature (`git checkout -b feature/AmazingFeature`)
3. 💾 Commit tus cambios (`git commit -m 'Add: nueva característica increíble'`)
4. 📤 Push a la rama (`git push origin feature/AmazingFeature`)
5. 🔃 Abre un Pull Request

### Convenciones de Commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva característica
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Formato, puntos y comas faltantes, etc
- `refactor:` Refactorización de código
- `test:` Añadir tests
- `chore:` Mantenimiento

### Código de Conducta

Este proyecto se adhiere al [Contributor Covenant](https://www.contributor-covenant.org/). Al participar, se espera que mantengas este código.

---

## 📄 Licencia

Distribuido bajo la Licencia MIT. Ver `LICENSE` para más información.

---

## 👥 Contacto

**Link del Proyecto**: [https://github.com/tu-usuario/tecunify](https://github.com/Jefferson-BA/tecunify)

---

## 🙏 Agradecimientos

- [React](https://reactjs.org/)
- [Django](https://www.djangoproject.com/)
- [Spring Boot](https://spring.io/projects/spring-boot)
- [PostgreSQL](https://www.postgresql.org/)
- [Docker](https://www.docker.com/)
- [Vite](https://vitejs.dev/)

---

## 📊 Estado del Proyecto

![Estado](https://img.shields.io/badge/Estado-En%20Desarrollo-yellow)
![Versión](https://img.shields.io/badge/Versi%C3%B3n-1.0.0-blue)
![Contribuidores](https://img.shields.io/badge/Contribuidores-1-green)

---

## 🗺️ Roadmap

- [x] Configuración inicial del proyecto
- [x] Módulo de administración (Backend Django)
- [x] Módulo de administración (Frontend React)
- [x] Módulo de usuario (Backend Spring Boot)
- [x] Módulo de usuario (Frontend React)
- [ ] App móvil Android (Kotlin)
- [ ] Sistema de autenticación JWT
- [ ] Dashboard con gráficos
- [ ] Sistema de notificaciones
- [ ] Chat en tiempo real
- [ ] Integración con servicios externos

---

<div align="center">

**⭐ Si te gusta este proyecto, dale una estrella en GitHub ⭐**

Hecho con ❤️ por [Jefferson, Carlos,Cesar]

</div>