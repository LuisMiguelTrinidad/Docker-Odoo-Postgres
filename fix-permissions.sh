#!/bin/bash
# Solo cambiar permisos en directorios no montados desde el host
chown -R odoo:odoo /var/lib/odoo
# Para directorios montados, solo establecer permisos sin cambiar propietario
chmod -R 777 /opt/odoo/custom-addons