#!/bin/bash

# Função para exibir mensagens coloridas
function green() {
    echo -e "\e[32m$1\e[0m"
}

function red() {
    echo -e "\e[31m$1\e[0m"
}

function yellow() {
    echo -e "\e[33m$1\e[0m"
}

# Nome do container passado como argumento
CONTAINER_NAME="$1"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$CONTAINER_NAME" ]; then
  read -p "Por favor, insira o nome do container: " CONTAINER_NAME
  if [ -z "$CONTAINER_NAME" ]; then
    echo -e "${RED}Erro: O nome do container não pode estar vazio.${NC}"
    exit 1
  fi
fi

green "=== Compartilhando o binder com o container $CONTAINER_NAME ==="

# Verifica se o container existe
if ! lxc list | grep -q "^| $CONTAINER_NAME "; then
    red "Erro: O container $CONTAINER_NAME não existe."
    exit 1
fi

# Verifica se o módulo binder_linux está disponível
yellow "Verificando se o módulo binder_linux está disponível..."
if ! grep -q "binder" /proc/filesystems; then
    red "Erro: O sistema não suporta o módulo binder_linux. Verifique se o kernel tem suporte ao Android Binder."
    exit 1
fi

# Monta o binderfs no host, se necessário
yellow "Verificando se o binderfs está montado no host..."
if ! mount | grep -q "/dev/binderfs"; then
    yellow "Montando o binderfs no host..."
    sudo mkdir -p /dev/binderfs
    sudo mount -t binder binder /dev/binderfs || {
        red "Erro ao montar o binderfs no host."
        exit 1
    }
else
    green "O binderfs já está montado no host."
fi

# Configura o compartilhamento do binderfs com o container
yellow "Compartilhando o /dev/binderfs do host com o container..."
lxc config device add "$CONTAINER_NAME" binderfs disk source=/dev/binderfs path=/dev/binderfs --quiet || {
    red "Erro ao compartilhar o /dev/binderfs com o container."
    exit 1
}

# Compartilha o arquivo de dispositivo /dev/binder
yellow "Compartilhando /dev/binder do host com o container..."
lxc config device add "$CONTAINER_NAME" binder unix-char source=/dev/binder path=/dev/binder --quiet || {
    red "Erro ao compartilhar /dev/binder com o container."
    exit 1
}

# Compartilha o arquivo de dispositivo /dev/binder-control
yellow "Compartilhando /dev/binder-control do host com o container..."
lxc config device add "$CONTAINER_NAME" binder-control unix-char source=/dev/binder-control path=/dev/binder-control --quiet || {
    red "Erro ao compartilhar /dev/binder-control com o container."
    exit 1
}

# Cria links simbólicos para os dispositivos binder
yellow "Criando links simbólicos para os dispositivos binder..."
sudo ln -sf /dev/binderfs/anbox-binder /dev/binder
sudo ln -sf /dev/binderfs/anbox-hwbinder /dev/hwbinder
sudo ln -sf /dev/binderfs/anbox-vndbinder /dev/vndbinder
sudo ln -sf /dev/binderfs/binder-control /dev/binder-control

# Verifica se os links simbólicos foram criados corretamente
yellow "Verificando se os links simbólicos foram criados..."
if ls -l /dev/binder /dev/hwbinder /dev/vndbinder /dev/binder-control | grep -q "No such file or directory"; then
    red "Erro: Alguns links simbólicos não foram criados corretamente."
    exit 1
else
    green "Todos os links simbólicos foram criados corretamente."
fi

# Confirmação
green "=== Configuração concluída. Os dispositivos binder foram compartilhados com o container $CONTAINER_NAME ==="
