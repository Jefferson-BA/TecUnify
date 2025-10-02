# 🚀 Guía de Instalación Local - tecUnify

Esta guía te ayudará a configurar y ejecutar el proyecto **tecUnify** en tu computadora local.

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado lo siguiente en tu computadora:

### ✅ Requisitos Obligatorios

#### 1. **Git** (Control de versiones)
- **Descargar**: [https://git-scm.com/downloads](https://git-scm.com/downloads)
- **Verificar instalación**:
  ```bash
  git --version
  ```
  Deberías ver algo como: `git version 2.x.x`

#### 2. **Docker Desktop** (Para contenedores)
- **Windows/Mac**: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
- **Linux**: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
- **Verificar instalación**:
  ```bash
  docker --version
  docker-compose --version
  ```
  Deberías ver las versiones instaladas.

> ⚠️ **Importante**: Asegúrate de que Docker Desktop esté **ejecutándose** antes de continuar.

---

## 🎯 Opción 1: Instalación Rápida con Docker (Recomendado)

Esta es la forma más rápida y sencilla. Docker se encarga de todo automáticamente.

### Paso 1: Clonar el Repositorio

```bash
# Clona el repositorio
git clone https://github.com/tu-usuario/tecunify.git

# Entra al directorio
cd tecunify
```

### Paso 2: Levantar los Servicios

```bash
# Construir y levantar todos los contenedores
docker-compose up -d
```

**Esto descargará e instalará automáticamente:**
- ✅ PostgreSQL 15
- ✅ Django + Python 3.11
- ✅ Spring Boot + Java 17
- ✅ React + Node.js 18
- ✅ Todas las dependencias necesarias

### Paso 3: Esperar a que Todo se Inicie

```bash
# Ver el progreso (espera 2-3 minutos)
docker-compose logs -f
```

Presiona `Ctrl+C` para salir de los logs cuando veas mensajes como:
- `django-backend | Starting development server at http://0.0.0.0:8000/`
- `springboot-backend | Started UsuarioApplication`

### Paso 4: Verificar que Todo Funcione

```bash
# Ver el estado de los contenedores
docker-compose ps
```

Todos deberían mostrar estado `Up`.

### Paso 5: Acceder a la Aplicación

Abre tu navegador en:
- **Admin Frontend**: http://localhost:3000
- **Usuario Frontend**: http://localhost:3001
- **Admin API**: http://localhost:8000/api/usuarios/
- **Usuario API**: http://localhost:8080/api/usuarios

---

## 💻 Opción 2: Instalación Local (Sin Docker)

Si prefieres ejecutar todo localmente sin Docker, necesitarás instalar cada herramienta manualmente.

### Requisitos Adicionales

#### 1. **Node.js** (Para React)
- **Versión**: 18 o superior
- **Descargar**: [https://nodejs.org/](https://nodejs.org/)
- **Verificar**:
  ```bash
  node --version
  npm --version
  ```

#### 2. **Python** (Para Django)
- **Versión**: 3.11 o superior
- **Descargar**: [https://www.python.org/downloads/](https://www.python.org/downloads/)
- **Verificar**:
  ```bash
  python --version  # o python3 --version
  pip --version     # o pip3 --version
  ```

#### 3. **Java JDK** (Para Spring Boot)
- **Versión**: 17 o superior
- **Descargar**: [https://adoptium.net/](https://adoptium.net/)
- **Verificar**:
  ```bash
  java --version
  javac --version
  ```

#### 4. **Maven** (Para Spring Boot)
- **Versión**: 3.8 o superior
- **Descargar**: [https://maven.apache.org/download.cgi](https://maven.apache.org/download.cgi)
- **Verificar**:
  ```bash
  mvn --version
  ```

#### 5. **PostgreSQL** (Base de datos)
- **Versión**: 15 o superior
- **Descargar**: [https://www.postgresql.org/download/](https://www.postgresql.org/download/)
- **Verificar**:
  ```bash
  psql --version
  ```

---

### Configuración Paso a Paso (Sin Docker)

#### 🗄️ Paso 1: Configurar PostgreSQL

```bash
# Inicia PostgreSQL y conéctate
psql -U postgres

# Crea la base de datos y el usuario
CREATE DATABASE tecunify;
CREATE USER admin WITH PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON DATABASE tecunify TO admin;
\q
```

```bash
# Ejecuta el script de inicialización
psql -U admin -d tecunify -f database/init.sql
```

---

#### 🐍 Paso 2: Configurar Backend Django (Administración)

```bash
# Ve al directorio
cd administracion/backend-django

# Crea un entorno virtual
python -m venv venv

# Activa el entorno virtual
# En Windows:
venv\Scripts\activate
# En Mac/Linux:
source venv/bin/activate

# Instala las dependencias
pip install -r requirements.txt

# Configura las variables de entorno
# Edita el archivo .env y ajusta la conexión a PostgreSQL si es necesario

# Ejecuta las migraciones
python manage.py migrate

# Crea un superusuario (opcional)
python manage.py createsuperuser

# Inicia el servidor
python manage.py runserver
```

✅ **Django corriendo en**: http://localhost:8000

---

#### ⚛️ Paso 3: Configurar Frontend React (Administración)

**Abre una nueva terminal** (deja Django corriendo)

```bash
# Ve al directorio
cd administracion/frontend-web

# Instala las dependencias
npm install

# Inicia el servidor de desarrollo
npm run dev
```

✅ **React Admin corriendo en**: http://localhost:3000

---

#### ☕ Paso 4: Configurar Backend Spring Boot (Usuario)

**Abre una nueva terminal**

```bash
# Ve al directorio
cd usuario/backend-springboot

# Compila el proyecto
./mvnw clean install

# En Windows usa:
# mvnw.cmd clean install

# Inicia la aplicación
./mvnw spring-boot:run

# En Windows:
# mvnw.cmd spring-boot:run
```

✅ **Spring Boot corriendo en**: http://localhost:8080

---

#### ⚛️ Paso 5: Configurar Frontend React (Usuario)

**Abre una nueva terminal**

```bash
# Ve al directorio
cd usuario/frontend-web

# Instala las dependencias
npm install

# Edita el archivo vite.config.js para cambiar el puerto a 3001
# O ejecuta con un puerto diferente:
npm run dev -- --port 3001
```

✅ **React Usuario corriendo en**: http://localhost:3001

---

## ✅ Verificación Final

### Prueba las APIs

```bash
# API Django (Administración)
curl http://localhost:8000/api/usuarios/

# API Spring Boot (Usuario)
curl http://localhost:8080/api/usuarios
```

### Accede a los Frontends

Abre tu navegador:
- Admin: http://localhost:3000
- Usuario: http://localhost:3001

---

## 🆘 Solución de Problemas Comunes

### ❌ Error: "Puerto ya en uso"

**Problema**: `Error: listen EADDRINUSE: address already in use :::3000`

**Solución**:
```bash
# En Windows:
netstat -ano | findstr :3000
taskkill /PID <numero_pid> /F

# En Mac/Linux:
lsof -ti:3000 | xargs kill -9
```

---

### ❌ Error: "Cannot connect to database"

**Problema**: No se puede conectar a PostgreSQL

**Soluciones**:
1. Verifica que PostgreSQL esté corriendo:
   ```bash
   # Windows: abre "Servicios" y busca PostgreSQL
   # Mac/Linux:
   sudo service postgresql status
   ```

2. Verifica las credenciales en los archivos `.env`

3. Asegúrate de que el puerto 5432 esté disponible

---

### ❌ Error: "Docker daemon not running"

**Problema**: `Cannot connect to the Docker daemon`

**Solución**:
- Abre **Docker Desktop** y espera a que inicie completamente
- Verifica que esté corriendo: `docker ps`

---

### ❌ Error: "Module not found" en Node.js

**Problema**: `Error: Cannot find module 'react'`

**Solución**:
```bash
# Elimina node_modules y reinstala
rm -rf node_modules package-lock.json
npm install
```

---

### ❌ Error: "Python venv not activating"

**Problema**: El entorno virtual no se activa correctamente

**Solución en Windows**:
```bash
# Habilita la ejecución de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Luego activa nuevamente
venv\Scripts\activate
```

---

### ❌ Error: "Java version incompatible"

**Problema**: Spring Boot requiere Java 17+

**Solución**:
```bash
# Verifica tu versión
java --version

# Descarga Java 17 desde:
# https://adoptium.net/temurin/releases/?version=17
```

---

## 🛑 Detener Todo

### Con Docker:
```bash
# Detener todos los contenedores
docker-compose down

# Detener y eliminar volúmenes (limpieza completa)
docker-compose down -v
```

### Sin Docker:
Presiona `Ctrl+C` en cada terminal donde estén corriendo los servicios.

---

## 🔄 Reiniciar Todo

### Con Docker:
```bash
# Reconstruir y levantar
docker-compose up -d --build
```

### Sin Docker:
Repite los pasos de ejecución para cada servicio que necesites.

---

## 📱 Desarrollo con Android (Opcional)

### Requisitos para la App Móvil:

1. **Android Studio**
   - Descargar: [https://developer.android.com/studio](https://developer.android.com/studio)

2. **Abrir el proyecto**:
   ```bash
   # Abre Android Studio y selecciona:
   # File > Open > tecunify/usuario/frontend-movil
   ```

3. **Ejecutar en emulador**:
   - Crea un dispositivo virtual (AVD)
   - Click en el botón "Run" (▶️)

---

## 💡 Consejos Adicionales

### Para Desarrollo Eficiente:

1. **Usa Docker** si quieres simplicidad
2. **Instalación local** si necesitas debuggear o modificar código
3. **Mantén Docker Desktop corriendo** si usas Docker
4. **Abre múltiples terminales** si instalas localmente
5. **Usa Visual Studio Code** como editor (recomendado)

### Extensiones Recomendadas para VS Code:

- Python
- Django
- ESLint
- Prettier
- Docker
- Spring Boot Extension Pack

---

## ✅ Checklist de Instalación

Marca lo que hayas completado:

- [ ] Git instalado
- [ ] Docker Desktop instalado (si usas Docker)
- [ ] Repositorio clonado
- [ ] Servicios levantados
- [ ] Frontend Admin funcionando (http://localhost:3000)
- [ ] Frontend Usuario funcionando (http://localhost:3001)
- [ ] API Django respondiendo (http://localhost:8000/api)
- [ ] API Spring Boot respondiendo (http://localhost:8080/api)
- [ ] Base de datos conectada

---

## 🎓 ¿Necesitas Ayuda?

Si tienes problemas:

1. 📖 Revisa la sección de **Solución de Problemas**
2. 🔍 Busca el error en Google/Stack Overflow
3. 💬 Abre un **Issue** en GitHub: [Crear Issue](https://github.com/tu-usuario/tecunify/issues)
4. 📧 Contacta al equipo: tu.email@ejemplo.com

---

<div align="center">

**¡Feliz codificación! 🚀**

Si esta guía te ayudó, dale ⭐ al repositorio

</div>

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