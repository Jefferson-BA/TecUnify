from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Usuario
from .serializers import UsuarioSerializer


@api_view(['POST'])
def login(request):
    email = request.data.get('email')
    password = request.data.get('password')

    try:
        usuario = Usuario.objects.get(email=email)

        # ⚠️ En producción usa hash de password
        if usuario.password == password:
            return Response({
                'message': 'Login exitoso',
                'user': {
                    'id': usuario.id,
                    'email': usuario.email,
                    'nombre': usuario.nombre,
                    'tipo': usuario.tipo_usuario
                }
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'message': 'Credenciales inválidas'
            }, status=status.HTTP_401_UNAUTHORIZED)

    except Usuario.DoesNotExist:
        return Response({
            'message': 'Usuario no encontrado'
        }, status=status.HTTP_404_NOT_FOUND)


class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer
