#!/bin/sh
set -e

# Ejecutar como root
/usr/local/bin/fix-permissions.sh

# Set default addons_path if not defined
if [ -z "$ODOO_ADDONS_PATH" ]; then
  ODOO_ADDONS_PATH="/opt/odoo/odoo/addons,/opt/odoo/custom-addons"
fi

# Wait for PostgreSQL to be available
echo "Waiting for PostgreSQL to be available..."
while ! pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER > /dev/null 2>&1; do
  echo "PostgreSQL not available yet... waiting 1s"
  sleep 1
done
echo "PostgreSQL is ready!"

# Generate config file dynamically in persistent volume
mkdir -p /etc/odoo
echo "[options]" > /etc/odoo/odoo.conf
echo "addons_path = $ODOO_ADDONS_PATH" >> /etc/odoo/odoo.conf
echo "db_host = $DB_HOST" >> /etc/odoo/odoo.conf
echo "db_port = $DB_PORT" >> /etc/odoo/odoo.conf
echo "db_user = $DB_USER" >> /etc/odoo/odoo.conf
echo "db_password = $DB_PASSWORD" >> /etc/odoo/odoo.conf
echo "db_name = $POSTGRES_DB" >> /etc/odoo/odoo.conf
echo "data_dir = /var/lib/odoo" >> /etc/odoo/odoo.conf
echo "list_db = True" >> /etc/odoo/odoo.conf

# Añadir el hook de depuración si está habilitado
if [ "$DEBUGPY_ENABLE" = "1" ]; then
  echo "Habilitando hook de depuración con debugpy"
  PYTHONPATH=$PYTHONPATH:/opt/odoo/scripts
  export PYTHONPATH
fi

# Configurar variables de entorno, pero no iniciar automáticamente
echo "==============================================="
echo "Contenedor de Odoo preparado pero NO iniciado."
echo "Para iniciar Odoo manualmente ejecute:"
echo "docker exec -it odoo-app su odoo -c 'python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf'"
echo "==============================================="

# Ejecutar el comando proporcionado o mantener el contenedor vivo
exec "$@"