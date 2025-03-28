#!/bin/bash

# Definição de cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Solicitar o nome do container
CONTAINER_NAME="$1"
if [ -z "$CONTAINER_NAME" ]; then
    read -p "Por favor, insira o nome do container: " CONTAINER_NAME
fi

# Verificar se o nome foi fornecido
if [ -z "$CONTAINER_NAME" ]; then
    echo -e "${RED}Erro: Nome do container não pode estar vazio.${NC}"
    exit 1
fi

# Inicializar o Waydroid
echo -e "${YELLOW}Inicializando o container '${CONTAINER_NAME}'...${NC}"
if sudo waydroid container start "$CONTAINER_NAME"; then
    echo -e "${GREEN}Container '${CONTAINER_NAME}' inicializado com sucesso!${NC}"
else
    echo -e "${RED}Falha ao inicializar o container '${CONTAINER_NAME}'.${NC}"
    exit 1
fi

# Executar o Waydroid
echo -e "${YELLOW}Executando o Waydroid...${NC}"
if waydroid session start; then
    echo -e "${GREEN}Waydroid iniciado com sucesso!${NC}"
else
    echo -e "${RED}Falha ao iniciar o Waydroid.${NC}"
    exit 1
fi