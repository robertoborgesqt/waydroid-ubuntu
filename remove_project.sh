#!/bin/bash

# Códigos de cores ANSI
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"


# Nome do container passado como parâmetro
PROJECT_NAME="$1"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$PROJECT_NAME" ]; then
    read -p "Por favor, insira o nome do projeto: " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do projeto não pode estar vazio.${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}Verificando o projeto LXD: ${PROJECT_NAME}...${RESET}"

# Verifica se o projeto existe
if ! lxc project list | grep -q "^| ${PROJECT_NAME} "; then
    echo -e "${YELLOW}Projeto ${PROJECT_NAME} não encontrado.${RESET}"
    exit 0
fi

# Define o projeto como ativo
echo -e "${BLUE}Ativando o projeto: ${PROJECT_NAME}...${RESET}"
lxc project switch "$PROJECT_NAME"

# Lista e remove os containers do projeto
echo -e "${BLUE}Verificando containers no projeto ${PROJECT_NAME}...${RESET}"
containers=$(lxc list | awk '{if (NR>3) print $2}' | grep -v "^$")
for container in $containers; do
    echo -e "${BLUE}Parando o container: $container...${RESET}"
    if ! lxc stop "$container"; then
        echo -e "${RED}Erro ao parar o container: $container.${RESET}"
        continue
    fi

    echo -e "${BLUE}Removendo o container: $container...${RESET}"
    if ! lxc delete "$container"; then
        echo -e "${RED}Erro ao remover o container: $container.${RESET}"
    fi
done

# Verifica e remove volumes relacionados ao projeto
echo -e "${BLUE}Verificando volumes no projeto ${PROJECT_NAME}...${RESET}"
volumes=$(lxc storage volume list default --project "$PROJECT_NAME" | awk '{if (NR>3) print $2}' | grep -v "^$")
for volume in $volumes; do
    echo -e "${BLUE}Removendo volume: $volume...${RESET}"
    if ! lxc storage volume delete default "$volume" --project "$PROJECT_NAME"; then
        echo -e "${RED}Erro ao remover o volume: $volume.${RESET}"
    fi
done

# Verifica e remove perfis relacionados ao projeto
echo -e "${BLUE}Verificando perfis no projeto ${PROJECT_NAME}...${RESET}"
profiles=$(lxc profile list --project "$PROJECT_NAME" | awk '{if (NR>3) print $2}' | grep -v "^$")
for profile in $profiles; do
    echo -e "${BLUE}Removendo perfil: $profile...${RESET}"
    if ! lxc profile delete "$profile" --project "$PROJECT_NAME"; then
        echo -e "${RED}Erro ao remover o perfil: $profile.${RESET}"
    fi
done

# Remove o projeto
echo -e "${BLUE}Removendo o projeto: ${PROJECT_NAME}...${RESET}"
if ! lxc project delete "$PROJECT_NAME"; then
    echo -e "${RED}Erro ao remover o projeto: ${PROJECT_NAME}.${RESET}"
    exit 1
fi

echo -e "${BLUE}Projeto ${PROJECT_NAME} e todos os recursos associados foram removidos com sucesso!${RESET}"
