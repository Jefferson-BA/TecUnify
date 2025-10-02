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

-- Índices
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_tipo ON usuarios(tipo_usuario);

-- Datos de ejemplo
INSERT INTO usuarios (email, password, nombre, apellido, tipo_usuario) 
VALUES 
    ('admin@tecunify.com', 'admin123', 'Administrador', 'Sistema', 'ADMIN'),
    ('usuario@tecunify.com', 'user123', 'Usuario', 'Prueba', 'USUARIO')
ON CONFLICT (email) DO NOTHING;
