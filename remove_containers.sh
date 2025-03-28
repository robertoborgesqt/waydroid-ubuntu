#!/bin/bash

# Códigos de cores ANSI
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${BLUE}Verificando containers relacionados ao Waydroid...${RESET}"

# Lista e filtra os containers com "waydroid" no nome
containers=$(lxc list | grep waydroid | awk '{print $2}')

if [ -z "$containers" ]; then
    echo -e "${YELLOW}Nenhum container relacionado ao Waydroid encontrado.${RESET}"
    exit 0
fi

# Para e remove os containers
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

echo -e "${BLUE}Todos os containers relacionados ao Waydroid foram removidos.${RESET}"

# Verificar e remover volumes relacionados, se existirem
echo -e "${BLUE}Verificando volumes relacionados ao Waydroid...${RESET}"
volumes=$(lxc storage list | grep waydroid | awk '{print $2}')
for volume in $volumes; do
    echo -e "${BLUE}Removendo volume: $volume...${RESET}"
    if ! lxc storage delete "$volume"; then
        echo -e "${RED}Erro ao remover o volume: $volume.${RESET}"
    fi
done

# Verificar e remover perfis relacionados, se existirem
echo -e "${BLUE}Verificando perfis relacionados ao Waydroid...${RESET}"
profiles=$(lxc profile list | grep waydroid | awk '{print $2}')
for profile in $profiles; do
    echo -e "${BLUE}Removendo perfil: $profile...${RESET}"
    if ! lxc profile delete "$profile"; then
        echo -e "${RED}Erro ao remover o perfil: $profile.${RESET}"
    fi
done

echo -e "${BLUE}Limpeza concluída. Todos os recursos relacionados ao Waydroid foram removidos com sucesso!${RESET}"
