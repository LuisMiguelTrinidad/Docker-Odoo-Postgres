#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con formato
print_message() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

# URL del repositorio por defecto
DEFAULT_REPO="https://github.com/LuisMiguelTrinidad/Docker-Odoo-Postgres.git"
# Directorio destino por defecto
DEFAULT_DIR="odoo-docker-fresh"

# Mostrar ayuda
show_help() {
    echo "Uso: $0 [opciones]"
    echo
    echo "Este script clona un repositorio de Odoo Docker y elimina todos los datos de Git"
    echo "para comenzar con un proyecto limpio."
    echo
    echo "Opciones:"
    echo "  -r, --repo URL     URL del repositorio a clonar (por defecto: $DEFAULT_REPO)"
    echo "  -d, --dir DIR      Directorio donde clonar (por defecto: $DEFAULT_DIR)"
    echo "  -i, --init         Inicializa un nuevo repositorio Git después de limpiar"
    echo "  -h, --help         Muestra esta ayuda"
    echo
}

# Valores por defecto
REPO_URL=$DEFAULT_REPO
TARGET_DIR=$DEFAULT_DIR
INIT_GIT=false

# Procesar opciones de línea de comandos
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--repo)
            REPO_URL="$2"
            shift 2
            ;;
        -d|--dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        -i|--init)
            INIT_GIT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Comenzar el proceso
print_message "Iniciando configuración del proyecto Odoo Docker"
print_info "Repositorio: $REPO_URL"
print_info "Directorio destino: $TARGET_DIR"

# Comprobar si el directorio ya existe
if [ -d "$TARGET_DIR" ]; then
    print_error "El directorio $TARGET_DIR ya existe. Por favor, especifique otro directorio o elimínelo."
    exit 1
fi

# Clonar el repositorio
print_message "Clonando repositorio..."
if git clone "$REPO_URL" "$TARGET_DIR"; then
    print_info "Repositorio clonado correctamente"
else
    print_error "Error al clonar el repositorio"
    exit 1
fi

# Cambiar al directorio clonado
cd "$TARGET_DIR" || { print_error "No se pudo acceder al directorio $TARGET_DIR"; exit 1; }

# Eliminar los datos de Git
print_message "Eliminando datos de Git..."
if [ -d ".git" ]; then
    rm -rf .git
    print_info "Datos de Git eliminados correctamente"
else
    print_info "No se encontró directorio .git"
fi

# Inicializar nuevo repositorio Git si se solicita
if $INIT_GIT; then
    print_message "Inicializando nuevo repositorio Git..."
    if git init; then
        print_info "Nuevo repositorio Git inicializado"
        
        # Crear archivo .gitignore si no existe
        if [ ! -f ".gitignore" ]; then
            echo "odoo-data/" > .gitignore
            echo "postgres_data/" >> .gitignore
            echo ".env.local" >> .gitignore
            print_info "Archivo .gitignore creado"
        fi
        
        # Hacer commit inicial
        git add .
        git commit -m "Configuración inicial del proyecto Odoo Docker"
        print_info "Commit inicial creado"
    else
        print_error "Error al inicializar nuevo repositorio Git"
    fi
fi

print_message "Configuración completada exitosamente!"
print_info "El proyecto está listo en: $(pwd)"
print_info "Para comenzar, ejecute:"
print_info "  cd $TARGET_DIR"
print_info "  docker-compose up -d"
print_info "  docker exec -it odoo-app su odoo -c 'python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf -d odoo --init=base'"

# Hacer ejecutable el script setup-project.sh
chmod +x setup-project.sh

exit 0
