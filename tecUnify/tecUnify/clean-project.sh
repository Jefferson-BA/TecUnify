#!/bin/bash

echo "� Limpiando proyecto tecUnify..."

# Detener y eliminar contenedores
docker-compose down -v

# Limpiar node_modules
rm -rf administracion/frontend-web/node_modules
rm -rf usuario/frontend-web/node_modules

# Limpiar venv de Python
rm -rf administracion/backend-django/venv

# Limpiar compilados de Spring Boot
rm -rf usuario/backend-springboot/target

# Limpiar archivos de compilación
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -type f -name "*.pyc" -delete

echo "✅ Proyecto limpiado!"
