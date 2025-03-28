#!/bin/bash

# Cores para mensagens
NORMAL="\033[1;34m"  # Azul
WARNING="\033[1;33m" # Amarelo
ERROR="\033[1;31m"   # Vermelho
RESET="\033[0m"      # Resetar cor

echo -e "${NORMAL}Configurando Binder ...${RESET}"
# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ERROR}Este script deve ser executado como root. Use 'sudo'.${RESET}"
    exit 1
fi

# Certifica-se de que os módulos do kernel necessários estão carregados
echo -e "${NORMAL}Carregando os módulos necessários no kernel...${RESET}"
modprobe binder_linux devices="binder,hwbinder,vndbinder"

# Verifica se os módulos foram carregados corretamente
if lsmod | grep -q "binder_linux"; then
    echo -e "${NORMAL}O módulo 'binder_linux' foi carregado com sucesso.${RESET}"
else
    echo -e "${ERROR}Falha ao carregar o módulo 'binder_linux'. Verifique se o kernel suporta o binder.${RESET}"
    exit 1
fi

# Configura a montagem do binder no sistema de arquivos
echo -e "${NORMAL}Criando os pontos de montagem para o binder...${RESET}"
mkdir -p /dev/binderfs
mount -t binder binder /dev/binderfs

# Verifica se a montagem foi bem-sucedida
if mount | grep -q "/dev/binderfs"; then
    echo -e "${NORMAL}O sistema de arquivos 'binderfs' foi montado com sucesso.${RESET}"
else
    echo -e "${ERROR}Falha ao montar o sistema de arquivos 'binderfs'.${RESET}"
    exit 1
fi

# Ajusta permissões, se necessário
echo -e "${NORMAL}Ajustando permissões para o uso do binder...${RESET}"
chmod 755 /dev/binderfs

# Adiciona as configurações ao fstab para montagem automática (opcional)
echo -e "${WARNING}Adicionando configuração ao fstab para montagem automática...${RESET}"
echo "binder /dev/binderfs binder defaults 0 0" >> /etc/fstab

# Confirmação de conclusão
echo -e "${NORMAL}Configuração do binder concluída. O sistema está preparado para compartilhar o binder com o container Waydroid.${RESET}"
