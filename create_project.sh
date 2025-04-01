#------------------------------------------------------------------------------------------
# Script create_project.sh
#------------------------------------------------------------------------------------------
# Title: Script para criar e configurar um projeto LXD para o Waydroid
# Description: Este script cria um projeto LXD e um container LXD
#              com a imagem Ubuntu 20.04 e configura
#              o usuário do host no container.
#------------------------------------------------------------------------------------------
# Sintaxe: sudo ./create_project.sh <nome_do_projeto> <nome_do_container>
#------------------------------------------------------------------------------------------

#!/bin/bash

# Nome do projeto e do container passados como parâmetros
PROJECT_NAME="$1"
CONTAINER_NAME="$2"

echo -e "\e[32m=== Criando e Configurando o Projeto e Container Waydroid ===\e[0m"

# Verifica se o LXD está instalado
if ! command -v lxc &> /dev/null; then
    echo -e "\e[33m[AVISO]\e[0m O LXD não está instalado. Instalando agora..."
    apt update && apt install -y lxd
    echo -e "\e[32mInicializando o LXD...\e[0m"
    lxd init --auto
fi

# Certifica-se de que o repositório de imagens está configurado
if ! lxc remote list | grep -q "images"; then
    echo -e "\e[33m[AVISO]\e[0m Adicionando o repositório de imagens..."
    lxc remote add images https://images.linuxcontainers.org --protocol=simplestreams	
fi

# Verifica se o script recebeu o nome do projeto como argumento
if [ -z "$PROJECT_NAME" ]; then
    read -p "Por favor, insira o nome do projeto: " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "\e[33mErro: O nome do projeto não pode estar vazio.\e[0m"
        exit 1
    fi
fi

# Criação do projeto
if ! lxc project list | grep -q "$PROJECT_NAME"; then
    echo -e "\e[32mCriando o projeto $PROJECT_NAME...\e[0m"
    lxc project create "$PROJECT_NAME"
else
    echo -e "\e[32mO projeto $PROJECT_NAME já existe.\e[0m"
fi

# Ativa o projeto
echo -e "\e[32mAtivando o projeto $PROJECT_NAME...\e[0m"
lxc project switch "$PROJECT_NAME"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$CONTAINER_NAME" ]; then
    read -p "Por favor, insira o nome do container: " CONTAINER_NAME
    if [ -z "$CONTAINER_NAME" ]; then
        echo -e "\e[33mErro: O nome do container não pode estar vazio.\e[0m"
        exit 1
    fi
fi

# Criação do container
echo -e "\e[32mCriando o container $CONTAINER_NAME no projeto $PROJECT_NAME...\e[0m"
lxc launch ubuntu:20.04 "$CONTAINER_NAME" -c security.privileged=true

echo -e "\e[32mParando o container $CONTAINER_NAME...\e[0m"
lxc stop "$CONTAINER_NAME"
echo -e "\e[32mIniciando o container $CONTAINER_NAME...\e[0m"
lxc start "$CONTAINER_NAME"

# Obtém o nome do usuário que criou o diretório /run/user/1000
HOST_USER=$(stat -c '%U' /run/user/1000)

# Verifica se o usuário existe no container
if ! lxc exec "$CONTAINER_NAME" -- id "$HOST_USER" &> /dev/null; then
    echo -e "\e[33m[AVISO]\e[0m O usuário $HOST_USER não existe no container. Criando usuário..."
    
    # Obtém o UID do usuário no host
    HOST_UID=$(id -u "$HOST_USER")
    HOST_GID=$(id -g "$HOST_USER")
    
    # Cria o grupo e o usuário no container com o mesmo UID e GID
    lxc exec "$CONTAINER_NAME" -- groupadd -g "$HOST_GID" "$HOST_USER"
    lxc exec "$CONTAINER_NAME" -- useradd -m -u "$HOST_UID" -g "$HOST_GID" "$HOST_USER"
    lxc config set "$CONTAINER_NAME" raw.idmap "both $HOST_UID $HOST_GID"

    echo -e "\e[32mUsuário $HOST_USER criado no container com UID $HOST_UID e GID $HOST_GID.\e[0m"
else
    echo -e "\e[32mO usuário $HOST_USER já existe no container.\e[0m"
fi

echo -e "\e[32mProjeto $PROJECT_NAME e container $CONTAINER_NAME criados com sucesso!\e[0m"
