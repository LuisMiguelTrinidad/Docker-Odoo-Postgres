#!/bin/sh
set -e

# Establecer addons_path por defecto si no está definido
if [ -z "$ADDONS_PATH" ]; then
  ADDONS_PATH="/opt/odoo/odoo/addons,/opt/odoo/custom-addons"
fi

# Generar archivo de configuración dinámicamente
echo "[options]" > /tmp/odoo.conf
echo "addons_path = $ADDONS_PATH" >> /tmp/odoo.conf
echo "db_host = $DB_HOST" >> /tmp/odoo.conf
echo "db_port = $DB_PORT" >> /tmp/odoo.conf
echo "db_user = $DB_USER" >> /tmp/odoo.conf
echo "db_password = $DB_PASSWORD" >> /tmp/odoo.conf
echo "data_dir = /var/lib/odoo" >> /tmp/odoo.conf

# Ejecutar Odoo con el archivo de configuración generado
if [ "$1" = "python3" ] && [ "$2" = "odoo-bin" ]; then
  exec "$@" -c /tmp/odoo.conf
else
  exec "$@"
fi