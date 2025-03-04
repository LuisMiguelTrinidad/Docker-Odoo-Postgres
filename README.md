# Proyecto Odoo Docker

Este proyecto configura un entorno de Odoo 17.0 utilizando Docker y Docker Compose, facilitando el desarrollo y despliegue de aplicaciones Odoo.

## Estructura del proyecto

```
.
├── addons/                 # Directorio para módulos personalizados
├── .env                    # Variables de entorno para configuración
├── docker-compose.yml      # Configuración de servicios Docker
├── Dockerfile              # Definición de imagen personalizada de Odoo
├── entrypoint.sh           # Script de punto de entrada para el contenedor
├── external-requirements.txt  # Dependencias Python adicionales
├── fix-permissions.sh      # Script para corregir permisos
├── setup-project.sh        # Script para configurar el proyecto fácilmente
└── README.md               # Este archivo
```

## Requisitos previos

- Docker Engine (versión 20.10.0+)
- Docker Compose (versión 2.0.0+)
- Git (opcional)

## Script de configuración rápida

El proyecto incluye un script `setup-project.sh` que automatiza el proceso de instalación:

### Ejecutar directamente desde GitHub

Para usar el script sin necesidad de clonar todo el repositorio:

```bash
# Ejecutar directamente sin guardar el script
bash <(curl -s https://raw.githubusercontent.com/LuisMiguelTrinidad/Docker-Odoo-Postgres/main/setup-project.sh) [opciones]
```

### Opciones disponibles

- `-d, --dir DIR`: Directorio donde clonar (por defecto: odoo-docker-fresh)
- `-i, --init`: Inicializa un nuevo repositorio Git después de limpiar
- `-h, --help`: Muestra ayuda sobre el uso del script

### Ejemplos

Configuración básica usando valores por defecto:
```bash
bash <(curl -s https://raw.githubusercontent.com/LuisMiguelTrinidad/Docker-Odoo-Postgres/main/setup-project.sh)
```

Especificar directorio de destino:
```bash
bash <(curl -s https://raw.githubusercontent.com/LuisMiguelTrinidad/Docker-Odoo-Postgres/main/setup-project.sh) -d mi_proyecto_odoo
```

Inicializar Git:
```bash
bash <(curl -s https://raw.githubusercontent.com/LuisMiguelTrinidad/Docker-Odoo-Postgres/main/setup-project.sh) -d mi_odoo -i
```

El script realiza las siguientes acciones:
1. Clona el repositorio oficial
2. Elimina los datos de Git para empezar desde cero
3. Opcionalmente inicializa un nuevo repositorio Git con un commit inicial
4. Crea un archivo .gitignore básico para el proyecto

## Configuración y ejecución

1. **Clonar repositorio**:
   ```bash
   git clone https://github.com/LuisMiguelTrinidad/Docker-Odoo-Postgres.git
   cd Docker-Odoo-Postgres
   ```

2. **Iniciar contenedores**:
   ```bash
   docker-compose up -d
   ```
   Esto iniciará los contenedores pero NO iniciará el servicio Odoo automáticamente.

3. **Inicializar la base de datos**:
   ```bash
   docker exec -it odoo-app su odoo -c 'python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf -d odoo --init=base'
   ```
   Este comando creará la base de datos inicial e instalará el módulo base de Odoo.

4. **Iniciar Odoo manualmente**:
   ```bash
   docker exec -it odoo-app su odoo -c 'python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf'
   ```
   
   Para iniciar con modo desarrollador, añade `--dev=all`:
   ```bash
   docker exec -it odoo-app su odoo -c 'python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf --dev=all'
   ```

5. **Verificar que los servicios estén funcionando**:
   ```bash
   docker-compose ps
   ```

6. **Acceder a Odoo**:
   Abra su navegador y visite: [http://localhost:8069](http://localhost:8069)

## Credenciales iniciales

Al crear una nueva base de datos, utilice estas credenciales:
- **Email/Usuario**: admin
- **Contraseña**: admin

## Personalización

### Modificar variables de entorno

Edite el archivo `.env` para personalizar:
- Versión de Odoo
- Puerto de acceso
- Credenciales de base de datos
- Rutas de addons

### Desarrollar módulos personalizados

1. Cree su módulo en el directorio `addons/`
2. La estructura básica de un módulo es:
   ```
   mi_modulo/
   ├── __init__.py
   ├── __manifest__.py
   ├── models/
   ├── views/
   ├── security/
   └── data/
   ```
3. Los módulos están automáticamente disponibles para instalación en Odoo

## Persistencia de datos

El proyecto utiliza dos volúmenes para garantizar la persistencia:
- `postgres_data`: Almacena los datos de la base de datos PostgreSQL
- `odoo-data`: Almacena archivos de sesión, subidos y generados por Odoo

## Comandos útiles

- **Ver logs**: `docker-compose logs -f odoo`
- **Reiniciar servicios**: `docker-compose restart`
- **Detener servicios**: `docker-compose down`
- **Acceder al shell**: `docker-compose exec odoo bash`
- **Actualizar módulo**: `docker exec -it odoo-app su odoo -c 'python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf -d <database> -u <module>'`

## Solución de problemas

### Problemas de permisos
Si tiene problemas con permisos en los directorios montados:
```bash
chmod -R 777 addons
```

### Error de conexión a la base de datos
Asegúrese de que el servicio PostgreSQL esté funcionando:
```bash
docker-compose ps db
```

### Restaurar base de datos
Para restaurar una copia de seguridad:
```bash
cat backup.sql | docker-compose exec -T db psql -U odoo
```

## Desarrollo dentro del contenedor

### Configuración de VS Code para desarrollo remoto

1. **Instalar extensiones necesarias en VS Code:**
   - Remote - Containers
   - Python
   - Odoo (opcional)

2. **Habilitar el depurador:**
   - Modifique el archivo `.env` y establezca `DEBUGPY_ENABLE=1`
   - Reinicie los contenedores: `docker-compose down && docker-compose up -d`

3. **Conectarse al contenedor:**
   - Abra la paleta de comandos (Ctrl+Shift+P)
   - Seleccione "Remote-Containers: Attach to Running Container..."
   - Elija el contenedor "odoo-app"

### Depuración de código

1. **Iniciar sesión de depuración:**
   - Abra el panel de depuración en VS Code (Ctrl+Shift+D)
   - Seleccione "Odoo: Debug en Contenedor Docker" de la lista desplegable
   - Inicie Odoo manualmente con el depurador:
     ```bash
     docker exec -it odoo-app su odoo -c 'python3 -m debugpy --listen 0.0.0.0:5678 --wait-for-client /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf --dev=all'
     ```
   - Presione F5 en VS Code para conectar el depurador

2. **Establecer puntos de interrupción:**
   - Coloque puntos de interrupción en su código haciendo clic a la izquierda del número de línea
   - Cuando la ejecución alcance ese punto, VS Code detendrá la ejecución

3. **Verificar variables y estado:**
   - Use el panel de variables para inspeccionar el estado actual
   - Use la consola de depuración para ejecutar comandos Python en el contexto actual

### Comandos útiles dentro del contenedor

```bash
# Actualizar un módulo específico
docker exec -it odoo-app su odoo -c 'python /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf -d odoo -u mi_modulo'

# Ejecutar tests de un módulo
docker exec -it odoo-app su odoo -c 'python /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf -d odoo --test-enable --stop-after-init -i mi_modulo'

# Abrir una shell interactiva
docker exec -it odoo-app su odoo -c 'python /opt/odoo/odoo/odoo-bin shell -c /etc/odoo/odoo.conf -d odoo'
```

### Opciones avanzadas

Para personalizar aún más su entorno de desarrollo, puede:

1. **Crear un devcontainer.json** para definir una configuración de desarrollo consistente
2. **Modificar el archivo launch.json** para agregar configuraciones de depuración adicionales
3. **Usar extensiones específicas de Odoo** para mejorar la productividad
