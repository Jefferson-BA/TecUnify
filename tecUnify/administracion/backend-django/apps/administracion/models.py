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
