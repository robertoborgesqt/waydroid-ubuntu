#!/bin/bash

# Códigos de cores ANSI
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

projeto="$1"
instancia="$2"


# Verifica se o script recebeu o nome do projeto como argumento
if [ -z "$projeto" ]; then
    read -p "Por favor, insira o nome do projeto: " projeto 
    if [ -z "$projeto" ]; then
        echo -e "${YELLOW}Erro: O nome do projeto não pode estar vazio.${NC}"
        exit 1
    fi
fi


# Verifica se o script recebeu o nome do instância como argumento
if [ -z "$instancia" ]; then
    read -p "Por favor, insira o nome do instância: " instancia
    if [ -z "$instancia" ]; then
        echo -e "${YELLOW}Erro: O nome do instância não pode estar vazio.${NC}"
        exit 1
    fi
fi


echo -e "${BLUE}Verificando a existência do projeto '${projeto}' e da instância '${instancia}'...${RESET}"

# Verifica se a instância existe no projeto
container=$(lxc list | grep "$instancia" | awk '{print $2}')

if [ -z "$container" ]; then
    echo -e "${RED}Nenhuma instância '${instancia}' encontrada no projeto '${projeto}'.${RESET}"
    exit 1
fi

# Para e remove a instância
echo -e "${BLUE}Parando a instância: $container...${RESET}"
if ! lxc stop "$container"; then
    echo -e "${YELLOW}Erro ao parar a instância: $container.${RESET}"
fi

echo -e "${BLUE}Removendo a instância: $container...${RESET}"
if ! lxc delete "$container"; then
    echo -e "${RED}Erro ao remover a instância: $container.${RESET}"
    exit 1
fi

echo -e "${BLUE}Instância '${instancia}' do projeto '${projeto}' removida com sucesso.${RESET}"
