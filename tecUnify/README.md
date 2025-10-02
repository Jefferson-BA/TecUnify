# Ì∫Ä tecUnify - Plataforma Multi-M√≥dulo

Plataforma con arquitectura de microservicios que incluye m√≥dulos de administraci√≥n y usuario.

## Ì≥ã Arquitectura

### M√≥dulo de Administraci√≥n
- **Frontend**: React (Puerto 3000)
- **Backend**: Django + DRF (Puerto 8000)
- **Base de Datos**: PostgreSQL (Puerto 5432)

### M√≥dulo de Usuario
- **Frontend Web**: React (Puerto 3001)
- **Frontend M√≥vil**: Kotlin (Android)
- **Backend**: Spring Boot (Puerto 8080)
- **Base de Datos**: PostgreSQL (Compartida)

## Ìª†Ô∏è Requisitos Previos

- Docker & Docker Compose
- Node.js 18+ (desarrollo local)
- Python 3.11+ (desarrollo local)
- Java 17+ & Maven (desarrollo local)
- Android Studio (desarrollo m√≥vil)

## Ì∫Ä Inicio R√°pido

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

## Ì≥¶ Desarrollo Local

### Backend Django (Administraci√≥n)

```bash
cd administracion/backend-django
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend React (Administraci√≥n)

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

### Frontend M√≥vil (Kotlin)

```bash
cd usuario/frontend-movil
# Abrir con Android Studio
```

## Ì∑ÑÔ∏è Base de Datos

La base de datos PostgreSQL se inicializa autom√°ticamente con:
- Esquemas: `administracion` y `usuario`
- Tabla: `usuarios`
- Datos de prueba

### Credenciales

```
Usuario: admin
Password: admin123
Base de datos: tecunify
```

## Ì≥ù Scripts √ötiles

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

### Limpiar todo (incluyendo vol√∫menes)
```bash
docker-compose down -v
```

## Ì¥ß Configuraci√≥n

Cada m√≥dulo tiene su archivo `.env` para configuraci√≥n:

- `administracion/backend-django/.env`
- `administracion/frontend-web/.env`
- `usuario/frontend-web/.env`
- `usuario/backend-springboot/src/main/resources/application.properties`

## Ì≥ö Estructura del Proyecto

```
tecUnify/
‚îú‚îÄ‚îÄ administracion/
‚îÇ   ‚îú‚îÄ‚îÄ frontend-web/        # React + Vite
‚îÇ   ‚îî‚îÄ‚îÄ backend-django/      # Django + DRF
‚îú‚îÄ‚îÄ usuario/
‚îÇ   ‚îú‚îÄ‚îÄ frontend-web/        # React + Vite
‚îÇ   ‚îú‚îÄ‚îÄ frontend-movil/      # Kotlin Android
‚îÇ   ‚îî‚îÄ‚îÄ backend-springboot/  # Spring Boot
‚îú‚îÄ‚îÄ database/
‚îÇ   ‚îî‚îÄ‚îÄ init.sql            # Script de inicializaci√≥n
‚îî‚îÄ‚îÄ docker-compose.yml      # Orquestaci√≥n de servicios
```

## Ì∑™ Testing

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

## Ì¥ù Contribuci√≥n

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Ì≥Ñ Licencia

Este proyecto est√° bajo la Licencia MIT.

## Ì±• Autores

- Tu Nombre - Trabajo Inicial

## Ì∂ò Soporte

Para reportar problemas o solicitar caracter√≠sticas, por favor abre un issue en el repositorio.
