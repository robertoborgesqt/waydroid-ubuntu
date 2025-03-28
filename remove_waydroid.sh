#!/bin/bash

# Cores
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${BLUE}Removendo o Waydroid...${RESET}"
# Atualiza os pacotes do sistema
echo -e "${BLUE}Atualizando lista de pacotes...${RESET}"
sudo apt update || echo -e "${RED}Erro ao atualizar a lista de pacotes.${RESET}"

# Remove o pacote do Waydroid
echo -e "${BLUE}Removendo o Waydroid...${RESET}"
sudo apt remove waydroid -y || echo -e "${RED}Erro ao remover o Waydroid.${RESET}"

# Purga arquivos de configuracao relacionados ao Waydroid
echo -e "${BLUE}Purga de arquivos de configuracao...${RESET}"
sudo apt purge waydroid -y || echo -e "${RED}Erro ao purgar arquivos de configuração.${RESET}"

# Remove repositórios adicionados anteriormente
echo -e "${BLUE}Removendo repositorio Waydroid...${RESET}"
sudo add-apt-repository --remove ppa:waydroid-team/waydroid -y || echo -e "${RED}Erro ao remover o repositório.${RESET}"

# Limpeza de pacotes nao utilizados
echo -e "${BLUE}Removendo pacotes não utilizados...${RESET}"
sudo apt autoremove -y || echo -e "${RED}Erro ao remover pacotes não utilizados.${RESET}"

# Confirmação de conclusao
echo -e "${BLUE}Remoção concluída. O Waydroid foi desinstalado com sucesso.${RESET}"
