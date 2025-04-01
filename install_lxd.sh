#!/bin/bash

# Cores
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Atualizar os repositórios
echo -e "${BLUE}Atualizando os repositórios...${RESET}"
sudo apt update

# Verificar se o LXD está instalado
if snap list | grep -q "^lxd "; then
    echo -e "${YELLOW}O LXD já está instalado. Deseja removê-lo? (s/n)${RESET}"
    read -r resposta
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        echo -e "${BLUE}Removendo o LXD...${RESET}"
        sudo snap remove lxd
    else
        echo -e "${RED}Saindo do script.${RESET}"
        exit 1
    fi
fi

# Instalar o Snap
echo -e "${BLUE}Instalando o Snap...${RESET}"
sudo apt install -y snapd

# Instalar o LXD via Snap
echo -e "${BLUE}Instalando o LXD via Snap...${RESET}"
sudo snap install lxd

# Configurar o LXD
echo -e "${BLUE}Configurando o LXD...${RESET}"
sudo lxd init --auto

# Configurar acesso remoto no LXD
echo -e "${BLUE}Configurando acesso remoto no LXD na porta 8443...${RESET}"
sudo lxc config set core.https_address :8443

# Configurar firewall para permitir conexões na porta 8443
echo -e "${BLUE}Configurando o firewall para permitir conexões na porta 8443...${RESET}"
sudo ufw allow 8443/tcp

# Finalização
echo -e "${BLUE}LXD instalado e configurado com sucesso!${RESET}"
echo -e "${BLUE}Acesso remoto habilitado na porta 8443.${RESET}"
echo -e "${YELLOW}Para acessar remotamente, use o endereço: https://127.0.0.1:8443/${RESET}"