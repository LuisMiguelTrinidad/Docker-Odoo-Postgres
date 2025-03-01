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
  ODOO_ARGS="--dev=all"
else
  ODOO_ARGS=""
fi

# Cambiar al usuario odoo para ejecutar el servidor
if [ "$1" = "python3" ] && [ "$2" = "odoo-bin" ]; then
  # Use double quotes for variable expansion in db-filter
  DB_FILTER="^${POSTGRES_DB}$"
  
  # Check if database already exists
  DB_EXISTS=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -tAc "SELECT 1 FROM pg_database WHERE datname='$POSTGRES_DB'" 2>/dev/null || echo "0")
  
  if [ "$DB_EXISTS" = "1" ]; then
    exec su odoo -c "$* -c /etc/odoo/odoo.conf --db-filter=\"$DB_FILTER\" $ODOO_ARGS --limit-time-real=0 --limit-memory-hard=0"
  else
    exec su odoo -c "$* -c /etc/odoo/odoo.conf --db-filter=\"$DB_FILTER\" --without-demo=all --init=base $ODOO_ARGS --limit-time-real=0 --limit-memory-hard=0"
  fi
else
  exec su odoo -c "$*"
fi