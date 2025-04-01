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

# Verifica se o projeto está ativo
if ! lxc project show "$PROJECT_NAME" | grep -q "default"; then
    echo -e "\e[33m[AVISO]\e[0m O projeto $PROJECT_NAME não está ativo. Ativando projeto..."
    lxc project switch "$PROJECT_NAME"
fi

# Seleciona o projeto
lxc project switch "$PROJECT_NAME"

# Verifica se o instância original existe
if ! lxc list --project "$PROJECT_NAME" | grep -q "$INSTANCE_NAME"; then
    echo -e "\e[31mErro: O instância $INSTANCE_NAME não existe no projeto $PROJECT_NAME.\e[0m"
    exit 1
fi

# Define o nome da nova instância
NEW_INSTANCE_NAME="${INSTANCE_NAME}1"

# Verifica se a nova instância já existe
if lxc list --project "$PROJECT_NAME" | grep -q "$NEW_INSTANCE_NAME"; then
    echo -e "\e[33m[AVISO]\e[0m O instância $NEW_INSTANCE_NAME já existe. Parando e excluindo o instância..."
    lxc stop "$NEW_INSTANCE_NAME"
    lxc delete "$NEW_INSTANCE_NAME"
fi

# Clona a instância original
echo -e "\e[32mClonando o instância $INSTANCE_NAME para $NEW_INSTANCE_NAME...\e[0m"
lxc copy "$INSTANCE_NAME" "$NEW_INSTANCE_NAME"

# Inicia a nova instância
echo -e "\e[32mIniciando o instância $NEW_INSTANCE_NAME...\e[0m"
lxc start "$NEW_INSTANCE_NAME"

echo -e "\e[32mInstância $NEW_INSTANCE_NAME criada com sucesso!\e[0m"
