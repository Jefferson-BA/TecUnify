# ��� Documentación de API - tecUnify

## Base URLs

- **Admin Backend (Django)**: `http://localhost:8000/api`
- **Usuario Backend (Spring Boot)**: `http://localhost:8080/api`

## Endpoints Disponibles

### 1. Gestión de Usuarios (Django - Admin)

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

### 2. Gestión de Usuarios (Spring Boot - Usuario)

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

## Códigos de Estado HTTP

- `200 OK` - Solicitud exitosa
- `201 Created` - Recurso creado exitosamente
- `204 No Content` - Eliminación exitosa
- `400 Bad Request` - Datos inválidos
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

## Autenticación

⚠️ **Nota**: Actualmente las APIs están configuradas sin autenticación para desarrollo.

Para producción se recomienda implementar:
- JWT (JSON Web Tokens)
- OAuth 2.0
- Session-based authentication
