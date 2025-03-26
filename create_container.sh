#!/bin/bash

# Verifica se o nome do container foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <nome_do_container>"
    exit 1
fi

# Nome do container passado como parâmetro
CONTAINER_NAME="$1"

echo "=== Criando e Configurando o Container Waydroid ==="

# Verifica se o LXD está instalado
if ! command -v lxc &> /dev/null; then
    echo "O LXD não está instalado. Instalando agora..."
    apt update && apt install -y lxd
    echo "Inicializando o LXD..."
    lxd init --auto
fi

# Certifica-se de que o repositório de imagens está configurado
if ! lxc remote list | grep -q "images"; then
    echo "Adicionando o repositório de imagens..."
    lxc remote add images https://images.linuxcontainers.org --protocol=simplestreams	
fi

# Criação do container
echo "Criando o container $CONTAINER_NAME..."
#lxc launch images:ubuntu/20.04 "$CONTAINER_NAME"
lxc launch ubuntu:20.04 "$CONTAINER_NAME"

echo "Stop container $CONTAINER_NAME"
lxc stop "$CONTAINER_NAME"
lxc launch ubuntu:20.04 "$CONTAINER_NAME" -c security.privileged=true
echo "start container $CONTAINER_NAME"
lxc start "$CONTAINER_NAME"

echo "Container $CONTAINER_NAME criado com sucesso!"
