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
