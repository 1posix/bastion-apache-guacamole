#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

USER=root
LOCK_FILE="/app/.initialized/init.lock"

echo_info() { echo -e "${GREEN}[INIT]${NC} $1"; }
echo_error() { echo -e "${RED}[INIT]${NC} $1"; exit 1; }

echo_info "================================================"
echo_info "Initialisation du Bastion Guacamole"
echo_info "================================================"

if [ -f "$LOCK_FILE" ]; then
    echo_info "Bastion deja initialise (Lock file trouvé). Verification rapide des droits..."
fi

echo_info "Creation/Verification des dossiers des données"

mkdir -p /app/volumes/{drive,record,data}
mkdir -p /app/init

chmod -R +x /app/init

if [ ! -f /app/init/initdb.sql ]; then
    echo_info "Generation de initdb.sql..."

    if [ -S /var/run/docker.sock ]; then
        docker run --rm guacamole/guacamole:1.5.3 \
            /opt/guacamole/bin/initdb.sh --postgresql > /app/init/initdb.sql
    else
        echo_error "Docker socket non disponible, impossible de générer initdb"
    fi

    if [ ! -s /app/init/initdb.sql ]; then
        echo_error "Echec generation initdb.sql (fichier vide)"
    fi

    echo_info "initdb.sql genere ($(wc -l < /app/init/initdb.sql) lignes)"
else
    echo_info "initdb.sql deja present"
fi

echo_info "Creation du dossier extensions..."
mkdir -p /app/volumes/guacamole_home/extensions

EXTENSION_DIR="/app/volumes/guacamole_home/extensions"

if [ ! -f "$EXTENSION_DIR/guacamole-history-recording-storage-1.5.0.jar" ]; then
    echo_info "Telechargement de l'extension recording..."

    wget -q -O /tmp/guacamole-history-recording-storage-1.5.0.tar.gz \
        https://archive.apache.org/dist/guacamole/1.5.0/binary/guacamole-history-recording-storage-1.5.0.tar.gz

    tar -xf /tmp/guacamole-history-recording-storage-1.5.0.tar.gz \
        -C "$EXTENSION_DIR" --strip-components=1

    rm -f /tmp/guacamole-history-recording-storage-1.5.0.tar.gz

    echo_info "Extension recording installee"
else
    echo_info "Extension recording deja presente"
fi

echo_info "Application des permissions (User: $USER)..."

chown -R $USER:$USER /app/volumes/guacamole_home/extensions
chown $USER:$USER /app/volumes

chown -R 1000:1001 /app/volumes/record
chmod -R 2750 /app/volumes/record

GUAC_PROPS="/app/volumes/guacamole_home/guacamole.properties"

if [ ! -f "$GUAC_PROPS" ]; then
    echo_info "Copie de guacamole.properties depuis l'example..."

    if [ -f /app/volumes/guacamole_home/guacamole.properties.example ]; then
        cp /app/volumes/guacamole_home/guacamole.properties.example "$GUAC_PROPS"
        chown $USER:$USER "$GUAC_PROPS"
        echo_info "guacamole.properties cree depuis l'example"
    else
        echo -e "${RED}[WARN]${NC} Fichier guacamole.properties.example manquant, copie ignorée"
    fi
else
    echo_info "guacamole.properties deja present"
fi

touch "$LOCK_FILE"
echo_info "Initialisation terminee avec succes"
echo_info "================================================"

exit 0
