# ��� Guía de Instalación - tecUnify

## Opción 1: Instalación con Docker (Recomendado)

### Requisitos
- Docker Desktop instalado
- Docker Compose instalado

### Pasos

1. **Clonar/Crear el proyecto**
```bash
# El proyecto ya está creado
cd tecUnify
```

2. **Inicializar el proyecto**
```bash
chmod +x init-project.sh
./init-project.sh
```

3. **Levantar todos los servicios**
```bash
docker-compose up -d
```

4. **Verificar que todo esté funcionando**
```bash
docker-compose ps
```

Todos los servicios deberían mostrar estado "Up".

## Opción 2: Instalación Local (Desarrollo)

### Requisitos
- Node.js 18+
- Python 3.11+
- Java 17+
- Maven 3.8+
- PostgreSQL 15+

### Backend Django

```bash
cd administracion/backend-django

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar base de datos en .env
# DATABASE_URL=postgresql://admin:admin123@localhost:5432/tecunify

# Ejecutar migraciones
python manage.py migrate

# Crear superusuario
python manage.py createsuperuser

# Ejecutar servidor
python manage.py runserver
```

### Frontend React Admin

```bash
cd administracion/frontend-web

# Instalar dependencias
npm install

# Configurar .env
# VITE_API_URL=http://localhost:8000/api

# Ejecutar en modo desarrollo
npm run dev
```

### Backend Spring Boot

```bash
cd usuario/backend-springboot

# Compilar proyecto
./mvnw clean install

# Ejecutar aplicación
./mvnw spring-boot:run
```

### Frontend React Usuario

```bash
cd usuario/frontend-web

# Instalar dependencias
npm install

# Configurar .env
# VITE_API_URL=http://localhost:8080/api

# Ejecutar en modo desarrollo
npm run dev
```

### Base de Datos PostgreSQL

```bash
# Crear base de datos
psql -U postgres
CREATE DATABASE tecunify;
CREATE USER admin WITH PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON DATABASE tecunify TO admin;
\q

# Ejecutar script de inicialización
psql -U admin -d tecunify -f database/init.sql
```

## Verificación

### Verificar Django
```bash
curl http://localhost:8000/api/usuarios/
```

### Verificar Spring Boot
```bash
curl http://localhost:8080/api/usuarios/
```

### Verificar Frontend Admin
Abrir navegador: http://localhost:3000

### Verificar Frontend Usuario
Abrir navegador: http://localhost:3001

## Solución de Problemas

### Puerto ya en uso
```bash
# Encontrar proceso usando el puerto
lsof -i :8000  # Linux/Mac
netstat -ano | findstr :8000  # Windows

# Cambiar puerto en docker-compose.yml o configuración
```

### Error de conexión a base de datos
```bash
# Verificar que PostgreSQL esté corriendo
docker-compose ps postgres

# Ver logs
docker-compose logs postgres
```

### Error en dependencias de Node
```bash
# Limpiar caché
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### Error en Django migrations
```bash
# Eliminar migraciones anteriores
python manage.py migrate --fake
python manage.py makemigrations
python manage.py migrate
```
