import os
import sys

# Si DEBUGPY_ENABLE está activado (1), configuramos el depurador
if os.environ.get('DEBUGPY_ENABLE') == '1':
    import debugpy
    
    # Permitir conexiones remotas
    debugpy.listen(('0.0.0.0', 5678))
    
    # Opcional: esperar a que el cliente se conecte antes de continuar
    # Descomenta la siguiente línea si quieres que Odoo espere
    # debugpy.wait_for_client()
    
    print("🐞 Depurador de debugpy iniciado en el puerto 5678")
