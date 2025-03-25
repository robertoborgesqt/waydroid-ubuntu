#!/bin/bash

# Verifica se um nome de container foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <nome_do_container>"
    exit 1
fi

# Nome do container é passado como argumento
CONTAINER_NAME="$1"

# Certifica-se de que o container está em execução
echo "Verificando se o container $CONTAINER_NAME está rodando..."
if ! lxc info "$CONTAINER_NAME" | grep -q "RUNNING"; then
    echo "O container $CONTAINER_NAME não está em execução. Iniciando o container..."
    lxc start "$CONTAINER_NAME"
    sleep 5  # Aguarda o container iniciar
fi

# Atualiza os pacotes dentro do container
echo "Atualizando os pacotes no container..."
lxc exec "$CONTAINER_NAME" -- apt update && apt upgrade -y

# Instala pacotes necessários para o Waydroid
echo "Instalando pacotes necessários no container..."
lxc exec "$CONTAINER_NAME" -- apt install -y \
    waydroid \
    lxc-utils \
    python3 \
    python3-pip \
    curl \
    wget \
    git

# Certifica-se de que os módulos do kernel binder estão disponíveis
echo "Configurando módulos do kernel binder dentro do container..."
lxc exec "$CONTAINER_NAME" -- modprobe binder_linux devices="binder,hwbinder,vndbinder"
lxc exec "$CONTAINER_NAME" -- mkdir -p /dev/binderfs
lxc exec "$CONTAINER_NAME" -- mount -t binder binder /dev/binderfs

# Configurações extras para o Waydroid
echo "Finalizando a configuração do Waydroid dentro do container..."
lxc exec "$CONTAINER_NAME" -- systemctl enable waydroid-container
lxc exec "$CONTAINER_NAME" -- systemctl start waydroid-container

# Confirmação de conclusão
echo "Todos os pacotes foram instalados e configurados no container $CONTAINER_NAME."
echo "Você pode verificar o status do Waydroid com: lxc exec $CONTAINER_NAME -- waydroid status"

