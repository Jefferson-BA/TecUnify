# � tecUnify - Plataforma Multi-Módulo

Plataforma con arquitectura de microservicios que incluye módulos de administración y usuario.

## � Arquitectura

### Módulo de Administración
- **Frontend**: React (Puerto 3000)
- **Backend**: Django + DRF (Puerto 8000)
- **Base de Datos**: PostgreSQL (Puerto 5432)

### Módulo de Usuario
- **Frontend Web**: React (Puerto 3001)
- **Frontend Móvil**: Kotlin (Android)
- **Backend**: Spring Boot (Puerto 8080)
- **Base de Datos**: PostgreSQL (Compartida)

## �️ Requisitos Previos

- Docker & Docker Compose
- Node.js 18+ (desarrollo local)
- Python 3.11+ (desarrollo local)
- Java 17+ & Maven (desarrollo local)
- Android Studio (desarrollo móvil)

## � Inicio Rápido

### 1. Levantar toda la infraestructura con Docker

```bash
docker-compose up -d
```

### 2. Verificar servicios activos

```bash
docker-compose ps
```

### 3. Acceder a los servicios

- **Admin Frontend**: http://localhost:3000
- **Admin Backend**: http://localhost:8000
- **Usuario Frontend**: http://localhost:3001
- **Usuario Backend**: http://localhost:8080
- **PostgreSQL**: localhost:5432

## � Desarrollo Local

### Backend Django (Administración)

```bash
cd administracion/backend-django
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend React (Administración)

```bash
cd administracion/frontend-web
npm install
npm run dev
```

### Backend Spring Boot (Usuario)

```bash
cd usuario/backend-springboot
./mvnw spring-boot:run
```

### Frontend React (Usuario)

```bash
cd usuario/frontend-web
npm install
npm run dev
```

### Frontend Móvil (Kotlin)

```bash
cd usuario/frontend-movil
# Abrir con Android Studio
```

## �️ Base de Datos

La base de datos PostgreSQL se inicializa automáticamente con:
- Esquemas: `administracion` y `usuario`
- Tabla: `usuarios`
- Datos de prueba

### Credenciales

```
Usuario: admin
Password: admin123
Base de datos: tecunify
```

## � Scripts Útiles

### Detener todos los servicios
```bash
docker-compose down
```

### Ver logs
```bash
docker-compose logs -f [servicio]
```

### Reconstruir servicios
```bash
docker-compose up -d --build
```

### Limpiar todo (incluyendo volúmenes)
```bash
docker-compose down -v
```

## � Configuración

Cada módulo tiene su archivo `.env` para configuración:

- `administracion/backend-django/.env`
- `administracion/frontend-web/.env`
- `usuario/frontend-web/.env`
- `usuario/backend-springboot/src/main/resources/application.properties`

## � Estructura del Proyecto

```
tecUnify/
├── administracion/
│   ├── frontend-web/        # React + Vite
│   └── backend-django/      # Django + DRF
├── usuario/
│   ├── frontend-web/        # React + Vite
│   ├── frontend-movil/      # Kotlin Android
│   └── backend-springboot/  # Spring Boot
├── database/
│   └── init.sql            # Script de inicialización
└── docker-compose.yml      # Orquestación de servicios
```

## � Testing

### Django
```bash
cd administracion/backend-django
python manage.py test
```

### Spring Boot
```bash
cd usuario/backend-springboot
./mvnw test
```

## � Contribución

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## � Licencia

Este proyecto está bajo la Licencia MIT.

## � Autores

- Tu Nombre - Trabajo Inicial

## � Soporte

Para reportar problemas o solicitar características, por favor abre un issue en el repositorio.
