#!/bin/bash

# Script para crear el proyecto tecUnify con toda su arquitectura
# Uso: bash create-tecunify.sh tecUnify

PROJECT_NAME=${1:-tecUnify}

echo "íº€ Creando proyecto $PROJECT_NAME..."

# Crear estructura de directorios principal
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo "í³ Creando estructura de carpetas..."

# Estructura de AdministraciÃ³n
mkdir -p administracion/frontend-web/src/{components,pages,services}
mkdir -p administracion/backend-django/{config,apps/administracion}

# Estructura de Usuario
mkdir -p usuario/frontend-movil/app/src/main/{java/com/tecunify/usuario,kotlin/com/tecunify/usuario,res}
mkdir -p usuario/frontend-web/src/{components,pages,services}
mkdir -p usuario/backend-springboot/src/{main/{java/com/tecunify/usuario/{controllers,services,repositories,models},resources},test/java}

# Estructura de Base de Datos
mkdir -p database/migrations

echo "í³ Creando archivos de configuraciÃ³n..."

# ===========================================
# ROOT - docker-compose.yml
# ===========================================
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: tecunify-db
    environment:
      POSTGRES_DB: tecunify
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - tecunify-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin"]
      interval: 10s
      timeout: 5s
      retries: 5

  django-backend:
    build: ./administracion/backend-django
    container_name: tecunify-django
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./administracion/backend-django:/app
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://admin:admin123@postgres:5432/tecunify
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - tecunify-network

  react-admin:
    build: ./administracion/frontend-web
    container_name: tecunify-react-admin
    volumes:
      - ./administracion/frontend-web:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=http://localhost:8000/api
    networks:
      - tecunify-network

  springboot-backend:
    build: ./usuario/backend-springboot
    container_name: tecunify-springboot
    ports:
      - "8080:8080"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/tecunify
      - SPRING_DATASOURCE_USERNAME=admin
      - SPRING_DATASOURCE_PASSWORD=admin123
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - tecunify-network

  react-usuario:
    build: ./usuario/frontend-web
    container_name: tecunify-react-usuario
    volumes:
      - ./usuario/frontend-web:/app
      - /app/node_modules
    ports:
      - "3001:3000"
    environment:
      - VITE_API_URL=http://localhost:8080/api
    networks:
      - tecunify-network

volumes:
  postgres_data:

networks:
  tecunify-network:
    driver: bridge
EOF

# ===========================================
# DATABASE - init.sql
# ===========================================
cat > database/init.sql << 'EOF'
-- Crear esquemas
CREATE SCHEMA IF NOT EXISTS administracion;
CREATE SCHEMA IF NOT EXISTS usuario;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo_usuario VARCHAR(20) CHECK (tipo_usuario IN ('ADMIN', 'USUARIO')) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ãndices
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_tipo ON usuarios(tipo_usuario);

-- Datos de ejemplo
INSERT INTO usuarios (email, password, nombre, apellido, tipo_usuario) 
VALUES 
    ('admin@tecunify.com', 'admin123', 'Administrador', 'Sistema', 'ADMIN'),
    ('usuario@tecunify.com', 'user123', 'Usuario', 'Prueba', 'USUARIO')
ON CONFLICT (email) DO NOTHING;
EOF

# ===========================================
# ADMINISTRACIÃ“N - Backend Django
# ===========================================
cat > administracion/backend-django/requirements.txt << 'EOF'
Django==4.2.7
djangorestframework==3.14.0
psycopg2-binary==2.9.9
django-cors-headers==4.3.1
python-decouple==3.8
gunicorn==21.2.0
EOF

cat > administracion/backend-django/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
EOF

cat > administracion/backend-django/.env << 'EOF'
SECRET_KEY=django-insecure-change-this-in-production
DEBUG=True
DATABASE_URL=postgresql://admin:admin123@postgres:5432/tecunify
ALLOWED_HOSTS=localhost,127.0.0.1
EOF

cat > administracion/backend-django/config/settings.py << 'EOF'
from pathlib import Path
from decouple import config
import dj_database_url

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='').split(',')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'apps.administracion',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL'),
        conn_max_age=600
    )
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'es-pe'
TIME_ZONE = 'America/Lima'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

CORS_ALLOW_ALL_ORIGINS = True

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ]
}
EOF

cat > administracion/backend-django/config/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('apps.administracion.urls')),
]
EOF

cat > administracion/backend-django/apps/administracion/models.py << 'EOF'
from django.db import models

class Usuario(models.Model):
    TIPO_CHOICES = [
        ('ADMIN', 'Administrador'),
        ('USUARIO', 'Usuario'),
    ]
    
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    nombre = models.CharField(max_length=100)
    apellido = models.CharField(max_length=100)
    tipo_usuario = models.CharField(max_length=20, choices=TIPO_CHOICES)
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'usuarios'
        
    def __str__(self):
        return f"{self.nombre} {self.apellido}"
EOF

cat > administracion/backend-django/apps/administracion/serializers.py << 'EOF'
from rest_framework import serializers
from .models import Usuario

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = '__all__'
EOF

cat > administracion/backend-django/apps/administracion/views.py << 'EOF'
from rest_framework import viewsets
from .models import Usuario
from .serializers import UsuarioSerializer

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer
EOF

cat > administracion/backend-django/apps/administracion/urls.py << 'EOF'
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UsuarioViewSet

router = DefaultRouter()
router.register(r'usuarios', UsuarioViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
EOF

# Crear archivos __init__.py
touch administracion/backend-django/config/__init__.py
touch administracion/backend-django/apps/__init__.py
touch administracion/backend-django/apps/administracion/__init__.py

# ===========================================
# ADMINISTRACIÃ“N - Frontend React
# ===========================================
cat > administracion/frontend-web/package.json << 'EOF'
{
  "name": "tecunify-admin-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8"
  }
}
EOF

cat > administracion/frontend-web/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
EOF

cat > administracion/frontend-web/.env << 'EOF'
VITE_API_URL=http://localhost:8000/api
EOF

cat > administracion/frontend-web/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000,
  }
})
EOF

cat > administracion/frontend-web/index.html << 'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>tecUnify - AdministraciÃ³n</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > administracion/frontend-web/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > administracion/frontend-web/src/App.jsx << 'EOF'
import React from 'react'

function App() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h1>í¾¯ tecUnify - Panel de AdministraciÃ³n</h1>
      <p>Frontend React conectado con Django</p>
      <p>Estado: âœ… Funcionando</p>
    </div>
  )
}

export default App
EOF

cat > administracion/frontend-web/src/services/api.js << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000/api',
});

export default api;
EOF

# ===========================================
# USUARIO - Backend Spring Boot
# ===========================================
cat > usuario/backend-springboot/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>
    
    <groupId>com.tecunify</groupId>
    <artifactId>usuario</artifactId>
    <version>1.0.0</version>
    <name>tecUnify Usuario Backend</name>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

cat > usuario/backend-springboot/Dockerfile << 'EOF'
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

cat > usuario/backend-springboot/src/main/resources/application.properties << 'EOF'
spring.application.name=tecunify-usuario

# PostgreSQL Configuration
spring.datasource.url=${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/tecunify}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME:admin}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD:admin123}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.format_sql=true

# Server Configuration
server.port=8080
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/UsuarioApplication.java << 'EOF'
package com.tecunify.usuario;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UsuarioApplication {
    public static void main(String[] args) {
        SpringApplication.run(UsuarioApplication.class, args);
    }
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/models/Usuario.java << 'EOF'
package com.tecunify.usuario.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "usuarios")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    private String password;
    private String nombre;
    private String apellido;
    
    @Column(name = "tipo_usuario")
    private String tipoUsuario;
    
    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion;
    
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;
    
    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }
    
    public String getTipoUsuario() { return tipoUsuario; }
    public void setTipoUsuario(String tipoUsuario) { this.tipoUsuario = tipoUsuario; }
    
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    
    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/repositories/UsuarioRepository.java << 'EOF'
package com.tecunify.usuario.repositories;

import com.tecunify.usuario.models.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/services/UsuarioService.java << 'EOF'
package com.tecunify.usuario.services;

import com.tecunify.usuario.models.Usuario;
import com.tecunify.usuario.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UsuarioService {
    @Autowired
    private UsuarioRepository usuarioRepository;
    
    public List<Usuario> getAllUsuarios() {
        return usuarioRepository.findAll();
    }
    
    public Usuario getUsuarioById(Long id) {
        return usuarioRepository.findById(id).orElse(null);
    }
    
    public Usuario saveUsuario(Usuario usuario) {
        return usuarioRepository.save(usuario);
    }
    
    public void deleteUsuario(Long id) {
        usuarioRepository.deleteById(id);
    }
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/controllers/UsuarioController.java << 'EOF'
package com.tecunify.usuario.controllers;

import com.tecunify.usuario.models.Usuario;
import com.tecunify.usuario.services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {
    @Autowired
    private UsuarioService usuarioService;
    
    @GetMapping
    public List<Usuario> getAllUsuarios() {
        return usuarioService.getAllUsuarios();
    }
    
    @GetMapping("/{id}")
    public Usuario getUsuarioById(@PathVariable Long id) {
        return usuarioService.getUsuarioById(id);
    }
    
    @PostMapping
    public Usuario createUsuario(@RequestBody Usuario usuario) {
        return usuarioService.saveUsuario(usuario);
    }
    
    @PutMapping("/{id}")
    public Usuario updateUsuario(@PathVariable Long id, @RequestBody Usuario usuario) {
        usuario.setId(id);
        return usuarioService.saveUsuario(usuario);
    }
    
    @DeleteMapping("/{id}")
    public void deleteUsuario(@PathVariable Long id) {
        usuarioService.deleteUsuario(id);
    }
}
EOF

# ===========================================
# USUARIO - Frontend React
# ===========================================
cat > usuario/frontend-web/package.json << 'EOF'
{
  "name": "tecunify-usuario-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8"
  }
}
EOF

cat > usuario/frontend-web/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
EOF

cat > usuario/frontend-web/.env << 'EOF'
VITE_API_URL=http://localhost:8080/api
EOF

cat > usuario/frontend-web/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000,
  }
})
EOF

cat > usuario/frontend-web/index.html << 'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>tecUnify - Usuario</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > usuario/frontend-web/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > usuario/frontend-web/src/App.jsx << 'EOF'
import React from 'react'

function App() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h1>í±¤ tecUnify - Portal Usuario</h1>
      <p>Frontend React conectado con Spring Boot</p>
      <p>Estado: âœ… Funcionando</p>
    </div>
  )
}

export default App
EOF

cat > usuario/frontend-web/src/services/api.js << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8080/api',
});

export default api;
EOF

# ===========================================
# USUARIO - Frontend MÃ³vil (Kotlin)
# ===========================================
cat > usuario/frontend-movil/build.gradle << 'EOF'
// Top-level build file
buildscript {
    ext.kotlin_version = "1.9.0"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.1.0"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

cat > usuario/frontend-movil/settings.gradle << 'EOF'
rootProject.name = "tecUnify"
include ':app'
EOF

cat > usuario/frontend-movil/gradle.properties << 'EOF'
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

mkdir -p usuario/frontend-movil/app/src/main/kotlin/com/tecunify/usuario
cat > usuario/frontend-movil/app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.tecunify.usuario'
    compileSdk 34

    defaultConfig {
        applicationId "com.tecunify.usuario"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
}
EOF

cat > usuario/frontend-movil/app/src/main/kotlin/com/tecunify/usuario/MainActivity.kt << 'EOF'
package com.tecunify.usuario

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // TODO: Setup layout
    }
}
EOF

# ===========================================
# README principal
# ===========================================
cat > README.md << 'EOF'
# íº€ tecUnify - Plataforma Multi-MÃ³dulo

Plataforma con arquitectura de microservicios que incluye mÃ³dulos de administraciÃ³n y usuario.

## í³‹ Arquitectura

### MÃ³dulo de AdministraciÃ³n
- **Frontend**: React (Puerto 3000)
- **Backend**: Django + DRF (Puerto 8000)
- **Base de Datos**: PostgreSQL (Puerto 5432)

### MÃ³dulo de Usuario
- **Frontend Web**: React (Puerto 3001)
- **Frontend MÃ³vil**: Kotlin (Android)
- **Backend**: Spring Boot (Puerto 8080)
- **Base de Datos**: PostgreSQL (Compartida)

## í» ï¸ Requisitos Previos

- Docker & Docker Compose
- Node.js 18+ (desarrollo local)
- Python 3.11+ (desarrollo local)
- Java 17+ & Maven (desarrollo local)
- Android Studio (desarrollo mÃ³vil)

## íº€ Inicio RÃ¡pido

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

## í³¦ Desarrollo Local

### Backend Django (AdministraciÃ³n)

```bash
cd administracion/backend-django
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend React (AdministraciÃ³n)

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

### Frontend MÃ³vil (Kotlin)

```bash
cd usuario/frontend-movil
# Abrir con Android Studio
```

## í·„ï¸ Base de Datos

La base de datos PostgreSQL se inicializa automÃ¡ticamente con:
- Esquemas: `administracion` y `usuario`
- Tabla: `usuarios`
- Datos de prueba

### Credenciales

```
Usuario: admin
Password: admin123
Base de datos: tecunify
```

## í³ Scripts Ãštiles

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

### Limpiar todo (incluyendo volÃºmenes)
```bash
docker-compose down -v
```

## í´§ ConfiguraciÃ³n

Cada mÃ³dulo tiene su archivo `.env` para configuraciÃ³n:

- `administracion/backend-django/.env`
- `administracion/frontend-web/.env`
- `usuario/frontend-web/.env`
- `usuario/backend-springboot/src/main/resources/application.properties`

## í³š Estructura del Proyecto

```
tecUnify/
â”œâ”€â”€ administracion/
â”‚   â”œâ”€â”€ frontend-web/        # React + Vite
â”‚   â””â”€â”€ backend-django/      # Django + DRF
â”œâ”€â”€ usuario/
â”‚   â”œâ”€â”€ frontend-web/        # React + Vite
â”‚   â”œâ”€â”€ frontend-movil/      # Kotlin Android
â”‚   â””â”€â”€ backend-springboot/  # Spring Boot
â”œâ”€â”€ database/
â”‚   â””â”€â”€ init.sql            # Script de inicializaciÃ³n
â””â”€â”€ docker-compose.yml      # OrquestaciÃ³n de servicios
```

## í·ª Testing

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

## í´ ContribuciÃ³n

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## í³„ Licencia

Este proyecto estÃ¡ bajo la Licencia MIT.

## í±¥ Autores

- Tu Nombre - Trabajo Inicial

## í¶˜ Soporte

Para reportar problemas o solicitar caracterÃ­sticas, por favor abre un issue en el repositorio.
EOF

# ===========================================
# Crear .gitignore
# ===========================================
cat > .gitignore << 'EOF'
# Python
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
__pycache__/
*.egg-info/
.pytest_cache/
.coverage

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
dist/
build/
.env.local
.env.production.local

# Java
target/
*.class
*.jar
*.war
.mvn/
mvnw
mvnw.cmd

# Android
*.apk
*.ap_
*.dex
.gradle/
local.properties
*.iml
.idea/
captures/

# Database
*.sql~
*.db

# Docker
*.log

# OS
.DS_Store
Thumbs.db

# IDEs
.vscode/
*.swp
*.swo
*~
EOF

# ===========================================
# Crear script de inicializaciÃ³n
# ===========================================
cat > init-project.sh << 'EOF'
#!/bin/bash

echo "í¾‰ Inicializando proyecto tecUnify..."

# Crear manage.py para Django
cat > administracion/backend-django/manage.py << 'MANAGE'
#!/usr/bin/env python
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
MANAGE

chmod +x administracion/backend-django/manage.py

# Crear wsgi.py y asgi.py
cat > administracion/backend-django/config/wsgi.py << 'WSGI'
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
application = get_wsgi_application()
WSGI

cat > administracion/backend-django/config/asgi.py << 'ASGI'
import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
application = get_asgi_application()
ASGI

# Instalar dependencias si no estÃ¡ usando Docker
read -p "Â¿Deseas instalar las dependencias localmente? (s/n): " install_deps

if [ "$install_deps" = "s" ]; then
    echo "í³¦ Instalando dependencias de React Admin..."
    cd administracion/frontend-web && npm install && cd ../..
    
    echo "í³¦ Instalando dependencias de React Usuario..."
    cd usuario/frontend-web && npm install && cd ../..
    
    echo "í° Instalando dependencias de Django..."
    cd administracion/backend-django
    python -m venv venv
    source venv/bin/activate 2>/dev/null || venv\Scripts\activate
    pip install -r requirements.txt
    cd ../..
    
    echo "â˜• Compilando Spring Boot..."
    cd usuario/backend-springboot
    chmod +x mvnw
    ./mvnw clean install -DskipTests
    cd ../..
fi

echo ""
echo "âœ… Proyecto inicializado correctamente!"
echo ""
echo "í³‹ PrÃ³ximos pasos:"
echo ""
echo "1. Levantar servicios con Docker:"
echo "   docker-compose up -d"
echo ""
echo "2. Acceder a los servicios:"
echo "   - Admin Frontend: http://localhost:3000"
echo "   - Admin Backend: http://localhost:8000"
echo "   - Usuario Frontend: http://localhost:3001"
echo "   - Usuario Backend: http://localhost:8080"
echo ""
echo "3. Ver logs:"
echo "   docker-compose logs -f"
echo ""
EOF

chmod +x init-project.sh

# ===========================================
# Crear script de limpieza
# ===========================================
cat > clean-project.sh << 'EOF'
#!/bin/bash

echo "í·¹ Limpiando proyecto tecUnify..."

# Detener y eliminar contenedores
docker-compose down -v

# Limpiar node_modules
rm -rf administracion/frontend-web/node_modules
rm -rf usuario/frontend-web/node_modules

# Limpiar venv de Python
rm -rf administracion/backend-django/venv

# Limpiar compilados de Spring Boot
rm -rf usuario/backend-springboot/target

# Limpiar archivos de compilaciÃ³n
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -type f -name "*.pyc" -delete

echo "âœ… Proyecto limpiado!"
EOF

chmod +x clean-project.sh

# ===========================================
# Crear documentaciÃ³n adicional
# ===========================================
mkdir -p docs

cat > docs/INSTALACION.md << 'EOF'
# í³¦ GuÃ­a de InstalaciÃ³n - tecUnify

## OpciÃ³n 1: InstalaciÃ³n con Docker (Recomendado)

### Requisitos
- Docker Desktop instalado
- Docker Compose instalado

### Pasos

1. **Clonar/Crear el proyecto**
```bash
# El proyecto ya estÃ¡ creado
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

4. **Verificar que todo estÃ© funcionando**
```bash
docker-compose ps
```

Todos los servicios deberÃ­an mostrar estado "Up".

## OpciÃ³n 2: InstalaciÃ³n Local (Desarrollo)

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

# Ejecutar aplicaciÃ³n
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

# Ejecutar script de inicializaciÃ³n
psql -U admin -d tecunify -f database/init.sql
```

## VerificaciÃ³n

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

## SoluciÃ³n de Problemas

### Puerto ya en uso
```bash
# Encontrar proceso usando el puerto
lsof -i :8000  # Linux/Mac
netstat -ano | findstr :8000  # Windows

# Cambiar puerto en docker-compose.yml o configuraciÃ³n
```

### Error de conexiÃ³n a base de datos
```bash
# Verificar que PostgreSQL estÃ© corriendo
docker-compose ps postgres

# Ver logs
docker-compose logs postgres
```

### Error en dependencias de Node
```bash
# Limpiar cachÃ©
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
EOF

cat > docs/API.md << 'EOF'
# í³¡ DocumentaciÃ³n de API - tecUnify

## Base URLs

- **Admin Backend (Django)**: `http://localhost:8000/api`
- **Usuario Backend (Spring Boot)**: `http://localhost:8080/api`

## Endpoints Disponibles

### 1. GestiÃ³n de Usuarios (Django - Admin)

#### Listar todos los usuarios
```http
GET /api/usuarios/
```

**Respuesta exitosa (200)**
```json
[
  {
    "id": 1,
    "email": "admin@tecunify.com",
    "nombre": "Administrador",
    "apellido": "Sistema",
    "tipo_usuario": "ADMIN",
    "fecha_creacion": "2024-01-01T00:00:00Z",
    "fecha_actualizacion": "2024-01-01T00:00:00Z"
  }
]
```

#### Obtener usuario por ID
```http
GET /api/usuarios/{id}/
```

#### Crear nuevo usuario
```http
POST /api/usuarios/
Content-Type: application/json

{
  "email": "nuevo@tecunify.com",
  "password": "password123",
  "nombre": "Nuevo",
  "apellido": "Usuario",
  "tipo_usuario": "USUARIO"
}
```

#### Actualizar usuario
```http
PUT /api/usuarios/{id}/
Content-Type: application/json

{
  "email": "actualizado@tecunify.com",
  "nombre": "Nombre Actualizado"
}
```

#### Eliminar usuario
```http
DELETE /api/usuarios/{id}/
```

### 2. GestiÃ³n de Usuarios (Spring Boot - Usuario)

#### Listar todos los usuarios
```http
GET /api/usuarios
```

#### Obtener usuario por ID
```http
GET /api/usuarios/{id}
```

#### Crear nuevo usuario
```http
POST /api/usuarios
Content-Type: application/json

{
  "email": "nuevo@tecunify.com",
  "password": "password123",
  "nombre": "Nuevo",
  "apellido": "Usuario",
  "tipoUsuario": "USUARIO"
}
```

#### Actualizar usuario
```http
PUT /api/usuarios/{id}
Content-Type: application/json

{
  "email": "actualizado@tecunify.com",
  "nombre": "Nombre Actualizado"
}
```

#### Eliminar usuario
```http
DELETE /api/usuarios/{id}
```

## CÃ³digos de Estado HTTP

- `200 OK` - Solicitud exitosa
- `201 Created` - Recurso creado exitosamente
- `204 No Content` - EliminaciÃ³n exitosa
- `400 Bad Request` - Datos invÃ¡lidos
- `404 Not Found` - Recurso no encontrado
- `500 Internal Server Error` - Error del servidor

## Ejemplos con cURL

### Django (Admin)

```bash
# Listar usuarios
curl http://localhost:8000/api/usuarios/

# Crear usuario
curl -X POST http://localhost:8000/api/usuarios/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@tecunify.com",
    "password": "test123",
    "nombre": "Test",
    "apellido": "Usuario",
    "tipo_usuario": "USUARIO"
  }'
```

### Spring Boot (Usuario)

```bash
# Listar usuarios
curl http://localhost:8080/api/usuarios

# Crear usuario
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@tecunify.com",
    "password": "test123",
    "nombre": "Test",
    "apellido": "Usuario",
    "tipoUsuario": "USUARIO"
  }'
```

## AutenticaciÃ³n

âš ï¸ **Nota**: Actualmente las APIs estÃ¡n configuradas sin autenticaciÃ³n para desarrollo.

Para producciÃ³n se recomienda implementar:
- JWT (JSON Web Tokens)
- OAuth 2.0
- Session-based authentication
EOF

# ===========================================
# FinalizaciÃ³n
# ===========================================
echo ""
echo "âœ… Â¡Proyecto $PROJECT_NAME creado exitosamente!"
echo ""
echo "í³ Estructura del proyecto:"
tree -L 2 -I 'node_modules|venv|target' $PROJECT_NAME 2>/dev/null || find $PROJECT_NAME -maxdepth 2 -type d
echo ""
echo "íº€ PrÃ³ximos pasos:"
echo ""
echo "1. Entrar al directorio:"
echo "   cd $PROJECT_NAME"
echo ""
echo "2. Inicializar el proyecto:"
echo "   chmod +x init-project.sh"
echo "   ./init-project.sh"
echo ""
echo "3. Levantar servicios con Docker:"
echo "   docker-compose up -d"
echo ""
echo "4. Acceder a los servicios:"
echo "   - Admin Frontend: http://localhost:3000"
echo "   - Admin Backend: http://localhost:8000"
echo "   - Usuario Frontend: http://localhost:3001"
echo "   - Usuario Backend: http://localhost:8080"
echo "   - PostgreSQL: localhost:5432"
echo ""
echo "í³š DocumentaciÃ³n adicional en:"
echo "   - README.md"
echo "   - docs/INSTALACION.md"
echo "   - docs/API.md"
echo ""
echo "í¾‰ Â¡Feliz desarrollo!"#!/bin/bash

# Script para crear el proyecto tecUnify con toda su arquitectura
# Uso: bash create-tecunify.sh tecUnify

PROJECT_NAME=${1:-tecUnify}

echo "íº€ Creando proyecto $PROJECT_NAME..."

# Crear estructura de directorios principal
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo "í³ Creando estructura de carpetas..."

# Estructura de AdministraciÃ³n
mkdir -p administracion/frontend-web/src/{components,pages,services}
mkdir -p administracion/backend-django/{config,apps/administracion}

# Estructura de Usuario
mkdir -p usuario/frontend-movil/app/src/main/{java/com/tecunify/usuario,kotlin/com/tecunify/usuario,res}
mkdir -p usuario/frontend-web/src/{components,pages,services}
mkdir -p usuario/backend-springboot/src/{main/{java/com/tecunify/usuario/{controllers,services,repositories,models},resources},test/java}

# Estructura de Base de Datos
mkdir -p database/migrations

echo "í³ Creando archivos de configuraciÃ³n..."

# ===========================================
# ROOT - docker-compose.yml
# ===========================================
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: tecunify-db
    environment:
      POSTGRES_DB: tecunify
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - tecunify-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin"]
      interval: 10s
      timeout: 5s
      retries: 5

  django-backend:
    build: ./administracion/backend-django
    container_name: tecunify-django
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./administracion/backend-django:/app
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://admin:admin123@postgres:5432/tecunify
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - tecunify-network

  react-admin:
    build: ./administracion/frontend-web
    container_name: tecunify-react-admin
    volumes:
      - ./administracion/frontend-web:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=http://localhost:8000/api
    networks:
      - tecunify-network

  springboot-backend:
    build: ./usuario/backend-springboot
    container_name: tecunify-springboot
    ports:
      - "8080:8080"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/tecunify
      - SPRING_DATASOURCE_USERNAME=admin
      - SPRING_DATASOURCE_PASSWORD=admin123
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - tecunify-network

  react-usuario:
    build: ./usuario/frontend-web
    container_name: tecunify-react-usuario
    volumes:
      - ./usuario/frontend-web:/app
      - /app/node_modules
    ports:
      - "3001:3000"
    environment:
      - VITE_API_URL=http://localhost:8080/api
    networks:
      - tecunify-network

volumes:
  postgres_data:

networks:
  tecunify-network:
    driver: bridge
EOF

# ===========================================
# DATABASE - init.sql
# ===========================================
cat > database/init.sql << 'EOF'
-- Crear esquemas
CREATE SCHEMA IF NOT EXISTS administracion;
CREATE SCHEMA IF NOT EXISTS usuario;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo_usuario VARCHAR(20) CHECK (tipo_usuario IN ('ADMIN', 'USUARIO')) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ãndices
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_tipo ON usuarios(tipo_usuario);

-- Datos de ejemplo
INSERT INTO usuarios (email, password, nombre, apellido, tipo_usuario) 
VALUES 
    ('admin@tecunify.com', 'admin123', 'Administrador', 'Sistema', 'ADMIN'),
    ('usuario@tecunify.com', 'user123', 'Usuario', 'Prueba', 'USUARIO')
ON CONFLICT (email) DO NOTHING;
EOF

# ===========================================
# ADMINISTRACIÃ“N - Backend Django
# ===========================================
cat > administracion/backend-django/requirements.txt << 'EOF'
Django==4.2.7
djangorestframework==3.14.0
psycopg2-binary==2.9.9
django-cors-headers==4.3.1
python-decouple==3.8
gunicorn==21.2.0
EOF

cat > administracion/backend-django/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
EOF

cat > administracion/backend-django/.env << 'EOF'
SECRET_KEY=django-insecure-change-this-in-production
DEBUG=True
DATABASE_URL=postgresql://admin:admin123@postgres:5432/tecunify
ALLOWED_HOSTS=localhost,127.0.0.1
EOF

cat > administracion/backend-django/config/settings.py << 'EOF'
from pathlib import Path
from decouple import config
import dj_database_url

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='').split(',')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'apps.administracion',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL'),
        conn_max_age=600
    )
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'es-pe'
TIME_ZONE = 'America/Lima'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

CORS_ALLOW_ALL_ORIGINS = True

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ]
}
EOF

cat > administracion/backend-django/config/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('apps.administracion.urls')),
]
EOF

cat > administracion/backend-django/apps/administracion/models.py << 'EOF'
from django.db import models

class Usuario(models.Model):
    TIPO_CHOICES = [
        ('ADMIN', 'Administrador'),
        ('USUARIO', 'Usuario'),
    ]
    
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    nombre = models.CharField(max_length=100)
    apellido = models.CharField(max_length=100)
    tipo_usuario = models.CharField(max_length=20, choices=TIPO_CHOICES)
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'usuarios'
        
    def __str__(self):
        return f"{self.nombre} {self.apellido}"
EOF

cat > administracion/backend-django/apps/administracion/serializers.py << 'EOF'
from rest_framework import serializers
from .models import Usuario

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = '__all__'
EOF

cat > administracion/backend-django/apps/administracion/views.py << 'EOF'
from rest_framework import viewsets
from .models import Usuario
from .serializers import UsuarioSerializer

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer
EOF

cat > administracion/backend-django/apps/administracion/urls.py << 'EOF'
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UsuarioViewSet

router = DefaultRouter()
router.register(r'usuarios', UsuarioViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
EOF

# Crear archivos __init__.py
touch administracion/backend-django/config/__init__.py
touch administracion/backend-django/apps/__init__.py
touch administracion/backend-django/apps/administracion/__init__.py

# ===========================================
# ADMINISTRACIÃ“N - Frontend React
# ===========================================
cat > administracion/frontend-web/package.json << 'EOF'
{
  "name": "tecunify-admin-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8"
  }
}
EOF

cat > administracion/frontend-web/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
EOF

cat > administracion/frontend-web/.env << 'EOF'
VITE_API_URL=http://localhost:8000/api
EOF

cat > administracion/frontend-web/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000,
  }
})
EOF

cat > administracion/frontend-web/index.html << 'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>tecUnify - AdministraciÃ³n</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > administracion/frontend-web/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > administracion/frontend-web/src/App.jsx << 'EOF'
import React from 'react'

function App() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h1>í¾¯ tecUnify - Panel de AdministraciÃ³n</h1>
      <p>Frontend React conectado con Django</p>
      <p>Estado: âœ… Funcionando</p>
    </div>
  )
}

export default App
EOF

cat > administracion/frontend-web/src/services/api.js << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000/api',
});

export default api;
EOF

# ===========================================
# USUARIO - Backend Spring Boot
# ===========================================
cat > usuario/backend-springboot/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>
    
    <groupId>com.tecunify</groupId>
    <artifactId>usuario</artifactId>
    <version>1.0.0</version>
    <name>tecUnify Usuario Backend</name>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

cat > usuario/backend-springboot/Dockerfile << 'EOF'
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

cat > usuario/backend-springboot/src/main/resources/application.properties << 'EOF'
spring.application.name=tecunify-usuario

# PostgreSQL Configuration
spring.datasource.url=${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/tecunify}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME:admin}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD:admin123}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.format_sql=true

# Server Configuration
server.port=8080
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/UsuarioApplication.java << 'EOF'
package com.tecunify.usuario;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UsuarioApplication {
    public static void main(String[] args) {
        SpringApplication.run(UsuarioApplication.class, args);
    }
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/models/Usuario.java << 'EOF'
package com.tecunify.usuario.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "usuarios")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    private String password;
    private String nombre;
    private String apellido;
    
    @Column(name = "tipo_usuario")
    private String tipoUsuario;
    
    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion;
    
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;
    
    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }
    
    public String getTipoUsuario() { return tipoUsuario; }
    public void setTipoUsuario(String tipoUsuario) { this.tipoUsuario = tipoUsuario; }
    
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    
    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/repositories/UsuarioRepository.java << 'EOF'
package com.tecunify.usuario.repositories;

import com.tecunify.usuario.models.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/services/UsuarioService.java << 'EOF'
package com.tecunify.usuario.services;

import com.tecunify.usuario.models.Usuario;
import com.tecunify.usuario.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UsuarioService {
    @Autowired
    private UsuarioRepository usuarioRepository;
    
    public List<Usuario> getAllUsuarios() {
        return usuarioRepository.findAll();
    }
    
    public Usuario getUsuarioById(Long id) {
        return usuarioRepository.findById(id).orElse(null);
    }
    
    public Usuario saveUsuario(Usuario usuario) {
        return usuarioRepository.save(usuario);
    }
    
    public void deleteUsuario(Long id) {
        usuarioRepository.deleteById(id);
    }
}
EOF

cat > usuario/backend-springboot/src/main/java/com/tecunify/usuario/controllers/UsuarioController.java << 'EOF'
package com.tecunify.usuario.controllers;

import com.tecunify.usuario.models.Usuario;
import com.tecunify.usuario.services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {
    @Autowired
    private UsuarioService usuarioService;
    
    @GetMapping
    public List<Usuario> getAllUsuarios() {
        return usuarioService.getAllUsuarios();
    }
    
    @GetMapping("/{id}")
    public Usuario getUsuarioById(@PathVariable Long id) {
        return usuarioService.getUsuarioById(id);
    }
    
    @PostMapping
    public Usuario createUsuario(@RequestBody Usuario usuario) {
        return usuarioService.saveUsuario(usuario);
    }
    
    @PutMapping("/{id}")
    public Usuario updateUsuario(@PathVariable Long id, @RequestBody Usuario usuario) {
        usuario.setId(id);
        return usuarioService.saveUsuario(usuario);
    }
    
    @DeleteMapping("/{id}")
    public void deleteUsuario(@PathVariable Long id) {
        usuarioService.deleteUsuario(id);
    }
}
EOF

# ===========================================
# USUARIO - Frontend React
# ===========================================
cat > usuario/frontend-web/package.json << 'EOF'
{
  "name": "tecunify-usuario-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8"
  }
}
EOF

cat > usuario/frontend-web/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
EOF

cat > usuario/frontend-web/.env << 'EOF'
VITE_API_URL=http://localhost:8080/api
EOF

cat > usuario/frontend-web/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000,
  }
})
EOF

cat > usuario/frontend-web/index.html << 'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>tecUnify - Usuario</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > usuario/frontend-web/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > usuario/frontend-web/src/App.jsx << 'EOF'
import React from 'react'

function App() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h1>í±¤ tecUnify - Portal Usuario</h1>
      <p>Frontend React conectado con Spring Boot</p>
      <p>Estado: âœ… Funcionando</p>
    </div>
  )
}

export default App
EOF

cat > usuario/frontend-web/src/services/api.js << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8080/api',
});

export default api;
EOF

# ===========================================
# USUARIO - Frontend MÃ³vil (Kotlin)
# ===========================================
cat > usuario/frontend-movil/build.gradle << 'EOF'
// Top-level build file
buildscript {
    ext.kotlin_version = "1.9.0"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.1.0"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

cat > usuario/frontend-movil/settings.gradle << 'EOF'
rootProject.name = "tecUnify"
include ':app'
EOF

cat > usuario/frontend-movil/gradle.properties << 'EOF'
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

mkdir -p usuario/frontend-movil/app/src/main/kotlin/com/tecunify/usuario
cat > usuario/frontend-movil/app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.tecunify.usuario'
    compileSdk 34

    defaultConfig {
        applicationId "com.tecunify.usuario"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
}
EOF

cat > usuario/frontend-movil/app/src/main/kotlin/com/tecunify/usuario/MainActivity.kt << 'EOF'
package com.tecunify.usuario

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // TODO: Setup layout
    }
}
EOF

# ===========================================
# README principal
# ===========================================
cat > README.md << 'EOF'
# íº€ tecUnify - Plataforma Multi-MÃ³dulo

Plataforma con arquitectura de microservicios que incluye mÃ³dulos de administraciÃ³n y usuario.

## í³‹ Arquitectura

### MÃ³dulo de AdministraciÃ³n
- **Frontend**: React (Puerto 3000)
- **Backend**: Django + DRF (Puerto 8000)
- **Base de Datos**: PostgreSQL (Puerto 5432)

### MÃ³dulo de Usuario
- **Frontend Web**: React (Puerto 3001)
- **Frontend MÃ³vil**: Kotlin (Android)
- **Backend**: Spring Boot (Puerto 8080)
- **Base de Datos**: PostgreSQL (Compartida)

## í» ï¸ Requisitos Previos

- Docker & Docker Compose
- Node.js 18+ (desarrollo local)
- Python 3.11+ (desarrollo local)
- Java 17+ & Maven (desarrollo local)
- Android Studio (desarrollo mÃ³vil)

## íº€ Inicio RÃ¡pido

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

## í³¦ Desarrollo Local

### Backend Django (AdministraciÃ³n)

```bash
cd administracion/backend-django
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend React (AdministraciÃ³n)

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

### Frontend MÃ³vil (Kotlin)

```bash
cd usuario/frontend-movil
# Abrir con Android Studio
```

## í·„ï¸ Base de Datos

La base de datos PostgreSQL se inicializa automÃ¡ticamente con:
- Esquemas: `administracion` y `usuario`
- Tabla: `usuarios`
- Datos de prueba

### Credenciales

```
Usuario: admin
Password: admin123
Base de datos: tecunify
```

## í³ Scripts Ãštiles

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

### Limpiar todo (incluyendo volÃºmenes)
```bash
docker-compose down -v
```

## í´§ ConfiguraciÃ³n

Cada mÃ³dulo tiene su archivo `.env` para configuraciÃ³n:

- `administracion/backend-django/.env`
- `administracion/frontend-web/.env`
- `usuario/frontend-web/.env`
- `usuario/backend-springboot/src/main/resources/application.properties`

## í³š Estructura del Proyecto

```
tecUnify/
â”œâ”€â”€ administracion/
â”‚   â”œâ”€â”€ frontend-web/        # React + Vite
â”‚   â””â”€â”€ backend-django/      # Django + DRF
â”œâ”€â”€ usuario/
â”‚   â”œâ”€â”€ frontend-web/        # React + Vite
â”‚   â”œâ”€â”€ frontend-movil/      # Kotlin Android
â”‚   â””â”€â”€ backend-springboot/  # Spring Boot
â”œâ”€â”€ database/
â”‚   â””â”€â”€ init.sql            # Script de inicializaciÃ³n
â””â”€â”€ docker-compose.yml      # OrquestaciÃ³n de servicios
```

## í·ª Testing

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

## í´ ContribuciÃ³n

1. Fork el proyecto
2. Crea tu rama (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## í³„ Licencia

Este proyecto estÃ¡ bajo la Licencia MIT.

## í±¥ Autores

- Tu Nombre - Trabajo Inicial

## í¶˜ Soporte

Para reportar problemas o solicitar caracterÃ­sticas, por favor abre un issue en el repositorio.
EOF

# ===========================================
# Crear .gitignore
# ===========================================
cat > .gitignore << 'EOF'
# Python
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
__pycache__/
*.egg-info/
.pytest_cache/
.coverage

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
dist/
build/
.env.local
.env.production.local

# Java
target/
*.class
*.jar
*.war
.mvn/
mvnw
mvnw.cmd

# Android
*.apk
*.ap_
*.dex
.gradle/
local.properties
*.iml
.idea/
captures/

# Database
*.sql~
*.db

# Docker
*.log

# OS
.DS_Store
Thumbs.db

# IDEs
.vscode/
*.swp
*.swo
*~
EOF

# ===========================================
# Crear script de inicializaciÃ³n
# ===========================================
cat > init-project.sh << 'EOF'
#!/bin/bash

echo "í¾‰ Inicializando proyecto tecUnify..."

# Crear manage.py para Django
cat > administracion/backend-django/manage.py << 'MANAGE'
#!/usr/bin/env python
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
MANAGE

chmod +x administracion/backend-django/manage.py

# Crear wsgi.py y asgi.py
cat > administracion/backend-django/config/wsgi.py << 'WSGI'
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
application = get_wsgi_application()
WSGI

cat > administracion/backend-django/config/asgi.py << 'ASGI'
import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
application = get_asgi_application()
ASGI

# Instalar dependencias si no estÃ¡ usando Docker
read -p "Â¿Deseas instalar las dependencias localmente? (s/n): " install_deps

if [ "$install_deps" = "s" ]; then
    echo "í³¦ Instalando dependencias de React Admin..."
    cd administracion/frontend-web && npm install && cd ../..
    
    echo "í³¦ Instalando dependencias de React Usuario..."
    cd usuario/frontend-web && npm install && cd ../..
    
    echo "í° Instalando dependencias de Django..."
    cd administracion/backend-django
    python -m venv venv
    source venv/bin/activate 2>/dev/null || venv\Scripts\activate
    pip install -r requirements.txt
    cd ../..
    
    echo "â˜• Compilando Spring Boot..."
    cd usuario/backend-springboot
    chmod +x mvnw
    ./mvnw clean install -DskipTests
    cd ../..
fi

echo ""
echo "âœ… Proyecto inicializado correctamente!"
echo ""
echo "í³‹ PrÃ³ximos pasos:"
echo ""
echo "1. Levantar servicios con Docker:"
echo "   docker-compose up -d"
echo ""
echo "2. Acceder a los servicios:"
echo "   - Admin Frontend: http://localhost:3000"
echo "   - Admin Backend: http://localhost:8000"
echo "   - Usuario Frontend: http://localhost:3001"
echo "   - Usuario Backend: http://localhost:8080"
echo ""
echo "3. Ver logs:"
echo "   docker-compose logs -f"
echo ""
EOF

chmod +x init-project.sh

# ===========================================
# Crear script de limpieza
# ===========================================
cat > clean-project.sh << 'EOF'
#!/bin/bash

echo "í·¹ Limpiando proyecto tecUnify..."

# Detener y eliminar contenedores
docker-compose down -v

# Limpiar node_modules
rm -rf administracion/frontend-web/node_modules
rm -rf usuario/frontend-web/node_modules

# Limpiar venv de Python
rm -rf administracion/backend-django/venv

# Limpiar compilados de Spring Boot
rm -rf usuario/backend-springboot/target

# Limpiar archivos de compilaciÃ³n
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -type f -name "*.pyc" -delete

echo "âœ… Proyecto limpiado!"
EOF

chmod +x clean-project.sh

# ===========================================
# Crear documentaciÃ³n adicional
# ===========================================
mkdir -p docs

cat > docs/INSTALACION.md << 'EOF'
# í³¦ GuÃ­a de InstalaciÃ³n - tecUnify

## OpciÃ³n 1: InstalaciÃ³n con Docker (Recomendado)

### Requisitos
- Docker Desktop instalado
- Docker Compose instalado

### Pasos

1. **Clonar/Crear el proyecto**
```bash
# El proyecto ya estÃ¡ creado
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

4. **Verificar que todo estÃ© funcionando**
```bash
docker-compose ps
```

Todos los servicios deberÃ­an mostrar estado "Up".

## OpciÃ³n 2: InstalaciÃ³n Local (Desarrollo)

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

# Ejecutar aplicaciÃ³n
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

# Ejecutar script de inicializaciÃ³n
psql -U admin -d tecunify -f database/init.sql
```

## VerificaciÃ³n

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

## SoluciÃ³n de Problemas

### Puerto ya en uso
```bash
# Encontrar proceso usando el puerto
lsof -i :8000  # Linux/Mac
netstat -ano | findstr :8000  # Windows

# Cambiar puerto en docker-compose.yml o configuraciÃ³n
```

### Error de conexiÃ³n a base de datos
```bash
# Verificar que PostgreSQL estÃ© corriendo
docker-compose ps postgres

# Ver logs
docker-compose logs postgres
```

### Error en dependencias de Node
```bash
# Limpiar cachÃ©
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
EOF

cat > docs/API.md << 'EOF'
# í³¡ DocumentaciÃ³n de API - tecUnify

## Base URLs

- **Admin Backend (Django)**: `http://localhost:8000/api`
- **Usuario Backend (Spring Boot)**: `http://localhost:8080/api`

## Endpoints Disponibles

### 1. GestiÃ³n de Usuarios (Django - Admin)

#### Listar todos los usuarios
```http
GET /api/usuarios/
```

**Respuesta exitosa (200)**
```json
[
  {
    "id": 1,
    "email": "admin@tecunify.com",
    "nombre": "Administrador",
    "apellido": "Sistema",
    "tipo_usuario": "ADMIN",
    "fecha_creacion": "2024-01-01T00:00:00Z",
    "fecha_actualizacion": "2024-01-01T00:00:00Z"
  }
]
```

#### Obtener usuario por ID
```http
GET /api/usuarios/{id}/
```

#### Crear nuevo usuario
```http
POST /api/usuarios/
Content-Type: application/json

{
  "email": "nuevo@tecunify.com",
  "password": "password123",
  "nombre": "Nuevo",
  "apellido": "Usuario",
  "tipo_usuario": "USUARIO"
}
```

#### Actualizar usuario
```http
PUT /api/usuarios/{id}/
Content-Type: application/json

{
  "email": "actualizado@tecunify.com",
  "nombre": "Nombre Actualizado"
}
```

#### Eliminar usuario
```http
DELETE /api/usuarios/{id}/
```

### 2. GestiÃ³n de Usuarios (Spring Boot - Usuario)

#### Listar todos los usuarios
```http
GET /api/usuarios
```

#### Obtener usuario por ID
```http
GET /api/usuarios/{id}
```

#### Crear nuevo usuario
```http
POST /api/usuarios
Content-Type: application/json

{
  "email": "nuevo@tecunify.com",
  "password": "password123",
  "nombre": "Nuevo",
  "apellido": "Usuario",
  "tipoUsuario": "USUARIO"
}
```

#### Actualizar usuario
```http
PUT /api/usuarios/{id}
Content-Type: application/json

{
  "email": "actualizado@tecunify.com",
  "nombre": "Nombre Actualizado"
}
```

#### Eliminar usuario
```http
DELETE /api/usuarios/{id}
```

## CÃ³digos de Estado HTTP

- `200 OK` - Solicitud exitosa
- `201 Created` - Recurso creado exitosamente
- `204 No Content` - EliminaciÃ³n exitosa
- `400 Bad Request` - Datos invÃ¡lidos
- `404 Not Found` - Recurso no encontrado
- `500 Internal Server Error` - Error del servidor

## Ejemplos con cURL

### Django (Admin)

```bash
# Listar usuarios
curl http://localhost:8000/api/usuarios/

# Crear usuario
curl -X POST http://localhost:8000/api/usuarios/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@tecunify.com",
    "password": "test123",
    "nombre": "Test",
    "apellido": "Usuario",
    "tipo_usuario": "USUARIO"
  }'
```

### Spring Boot (Usuario)

```bash
# Listar usuarios
curl http://localhost:8080/api/usuarios

# Crear usuario
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@tecunify.com",
    "password": "test123",
    "nombre": "Test",
    "apellido": "Usuario",
    "tipoUsuario": "USUARIO"
  }'
```

## AutenticaciÃ³n

âš ï¸ **Nota**: Actualmente las APIs estÃ¡n configuradas sin autenticaciÃ³n para desarrollo.

Para producciÃ³n se recomienda implementar:
- JWT (JSON Web Tokens)
- OAuth 2.0
- Session-based authentication
EOF

# ===========================================
# FinalizaciÃ³n
# ===========================================
echo ""
echo "âœ… Â¡Proyecto $PROJECT_NAME creado exitosamente!"
echo ""
echo "í³ Estructura del proyecto:"
tree -L 2 -I 'node_modules|venv|target' $PROJECT_NAME 2>/dev/null || find $PROJECT_NAME -maxdepth 2 -type d
echo ""
echo "íº€ PrÃ³ximos pasos:"
echo ""
echo "1. Entrar al directorio:"
echo "   cd $PROJECT_NAME"
echo ""
echo "2. Inicializar el proyecto:"
echo "   chmod +x init-project.sh"
echo "   ./init-project.sh"
echo ""
echo "3. Levantar servicios con Docker:"
echo "   docker-compose up -d"
echo ""
echo "4. Acceder a los servicios:"
echo "   - Admin Frontend: http://localhost:3000"
echo "   - Admin Backend: http://localhost:8000"
echo "   - Usuario Frontend: http://localhost:3001"
echo "   - Usuario Backend: http://localhost:8080"
echo "   - PostgreSQL: localhost:5432"
echo ""
echo "í³š DocumentaciÃ³n adicional en:"
echo "   - README.md"
echo "   - docs/INSTALACION.md"
echo "   - docs/API.md"
echo ""
echo "í¾‰ Â¡Feliz desarrollo!"
