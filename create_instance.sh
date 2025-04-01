# Verifica se o projeto já existe
# (This line was incomplete and has been removed or corrected in the script below)
#------------------------------------------------------------------------------------------
# Title: Script para criar e configurar um instância LXD para o Waydroid
# Description: Este script cria um instância LXD
#              com a imagem Ubuntu 20.04 e configura
#              o usuário do host no instância.
#------------------------------------------------------------------------------------------
# Sintaxe: sudo ./create_container.sh <nome_do_container>
#------------------------------------------------------------------------------------------

#!/bin/bash

# Nome do instância passado como parâmetro
INSTANCE_NAME="$1"
PROJECT_NAME="$2"


# Verifica se o script recebeu o nome do projeto como argumento
if [ -z "$PROJECT_NAME" ]; then
    read -p "Por favor, insira o nome do projeto: " PROJECT_NAME 
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do projeto não pode estar vazio.${NC}"
        exit 1
    fi
fi


# Verifica se o script recebeu o nome do instância como argumento
if [ -z "$INSTANCE_NAME" ]; then
    read -p "Por favor, insira o nome do instância: " INSTANCE_NAME
    if [ -z "$INSTANCE_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do instância não pode estar vazio.${NC}"
        exit 1
    fi
fi

echo -e "\e[32m=== Criando e Configurando instância $PROJECT_NAME/$INSTANCE_NAME ===\e[0m"

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

# Verifica se o projeto já existe
if ! lxc project list | grep -q "$PROJECT_NAME"; then
    echo -e "\e[33m[AVISO]\e[0m O projeto $PROJECT_NAME não existe. Criando projeto..."
    lxc project create "$PROJECT_NAME"
fi
# Verifica se o instância já existe
if lxc list --project "$PROJECT_NAME" | grep -q "$INSTANCE_NAME"; then
    echo -e "\e[33m[AVISO]\e[0m O instância $INSTANCE_NAME já existe. Parando e excluindo o instância..."
    lxc stop "$INSTANCE_NAME"
    lxc delete "$INSTANCE_NAME"
fi
# Verifica se o projeto está ativo
if ! lxc project show "$PROJECT_NAME" | grep -q "default"; then
    echo -e "\e[33m[AVISO]\e[0m O projeto $PROJECT_NAME não está ativo. Ativando projeto..."
    lxc project switch "$PROJECT_NAME"
fi

# seleciona o projeto
lxc project switch "$PROJECT_NAME"

# Criação do instância
echo -e "\e[32mCriando o instância $INSTANCE_NAME...\e[0m"
#lxc launch images:ubuntu/20.04 "$INSTANCE_NAME"
lxc launch ubuntu:20.04 "$INSTANCE_NAME" -c security.privileged=true

echo -e "\e[32mParando o instância $INSTANCE_NAME...\e[0m"
lxc stop "$INSTANCE_NAME"
echo -e "\e[32mIniciando o instância $INSTANCE_NAME...\e[0m"
lxc start "$INSTANCE_NAME"
# Obtém o nome do usuário que criou o diretório /run/user/1000
HOST_USER=$(stat -c '%U' /run/user/1000)

# Verifica se o usuário existe no instância
if ! lxc exec "$INSTANCE_NAME" -- id "$HOST_USER" &> /dev/null; then
    echo "\e[33m[AVISO]\e[0m O usuário $HOST_USER ($HOST_UID-$HOST_GID) não existe no instância. Criando usuário..."
    
    # Obtém o UID do usuário no host
    HOST_UID=$(id -u "$HOST_USER")
    HOST_GID=$(id -g "$HOST_USER")
    
    # Cria o grupo e o usuário no instância com o mesmo UID e GID
    lxc exec "$INSTANCE_NAME" -- groupadd -g "$HOST_GID" "$HOST_USER"
    lxc exec "$INSTANCE_NAME" -- useradd -m -u "$HOST_UID" -g "$HOST_GID" "$HOST_USER"
    lxc config set "$INSTANCE_NAME" raw.idmap "both $HOST_UID $HOST_GID"

    echo -e "\e[32mUsuário $HOST_USER criado no instância com UID $HOST_UID e GID $HOST_GID.\e[0m"
else
    echo -e "\e[32mO usuário $HOST_USER já existe no instância.\e[0m"
fi

echo -e "\e[32mContainer $INSTANCE_NAME criado com sucesso!\e[0m"
