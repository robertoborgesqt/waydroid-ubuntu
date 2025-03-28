#!/bin/bash

# Códigos de cores ANSI
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${BLUE}Configurando Wayland...${RESET}"

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Este script deve ser executado como root. Use 'sudo'.${RESET}"
    exit 1
fi

# Define o caminho correto para o socket Wayland
WAYLAND_DIR="/run/user/1000/wayland-0"
if [ ! -S "$WAYLAND_DIR" ]; then
    echo -e "${RED}O socket Wayland não foi encontrado em $WAYLAND_DIR.${RESET}"
    echo -e "${YELLOW}Certifique-se de que você está executando um ambiente Wayland e que o diretório está acessível.${RESET}"
    exit 1
fi

# Cria um diretório de compartilhamento para o container
echo -e "${BLUE}Criando o diretório de compartilhamento para o container...${RESET}"
SHARE_DIR="/opt/wayland-share"
mkdir -p "$SHARE_DIR"

# Ajusta permissões para o diretório compartilhado
echo -e "${BLUE}Ajustando permissões no diretório compartilhado...${RESET}"
chmod 777 "$SHARE_DIR"

# Liga o socket Wayland ao diretório de compartilhamento
echo -e "${BLUE}Ligando o socket Wayland ao diretório compartilhado...${RESET}"
ln -sf "$WAYLAND_DIR" "$SHARE_DIR/wayland-0"

# Verifica se o link foi criado com sucesso
if [ -L "$SHARE_DIR/wayland-0" ]; then
    echo -e "${BLUE}Socket Wayland ligado com sucesso em $SHARE_DIR/wayland-0.${RESET}"
else
    echo -e "${RED}Falha ao criar o link simbólico do socket Wayland.${RESET}"
    exit 1
fi

# Configuração adicional para containers (se necessário)
echo -e "${YELLOW}Certifique-se de que o container tenha acesso a $SHARE_DIR e às permissões necessárias para usar o Wayland.${RESET}"

# Confirmação de conclusão
echo -e "${BLUE}Configuração do compartilhamento do Wayland concluída. O container pode acessar o Wayland através de $SHARE_DIR/wayland-0.${RESET}"
