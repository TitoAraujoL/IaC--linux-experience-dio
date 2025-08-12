#!/bin/bash

# =========================================================
# Script de Provisionamento de Servidor Web
# Autor: Vitor Araujo
# Versão: 2.0
# Descrição: Atualiza o servidor, instala pacotes necessários,
#   baixa aplicação e copia para o diretório do Apache.
# =========================================================

# Configuração
APP_URL="https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip"
TMP_DIR="/tmp/app"
DEST_DIR="/var/www/html"
LOG_FILE="/var/log/provisionamento.log"

# Funções
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "Este script precisa ser executado como root."
        exit 1
    fi
}

atualizar_servidor() {
    log "Atualizando o servidor..."
    apt-get update -y && apt-get upgrade -y || {
        log "Falha ao atualizar o servidor."
        exit 1
    }
}

instalar_pacotes() {
    log "nstalando pacotes necessários..."
    apt-get install -y apache2 unzip wget || {
        log "Falha ao instalar pacotes."
        exit 1
    }
}

baixar_aplicacao() {
    log "Baixando aplicação..."
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR" || exit 1
    wget -q "$APP_URL" -O app.zip || {
        log "Falha ao baixar a aplicação."
        exit 1
    }
    unzip -o app.zip || {
        log "Falha ao descompactar a aplicação."
        exit 1
    }
}

implantar_aplicacao() {
    log "Implantando aplicação no Apache..."
    APP_FOLDER=$(find . -type d -name "linux-site-dio*" | head -n 1)
    if [[ -d "$APP_FOLDER" ]]; then
        cp -R "$APP_FOLDER"/* "$DEST_DIR" || {
            log "Falha ao copiar arquivos para o Apache."
            exit 1
        }
        log "Aplicação implantada com sucesso."
    else
        log "Pasta da aplicação não encontrada."
        exit 1
    fi
}

# Execução
check_root
log "Iniciando provisionamento..."
atualizar_servidor
instalar_pacotes
baixar_aplicacao
implantar_aplicacao
log "Provisionamento concluído."
