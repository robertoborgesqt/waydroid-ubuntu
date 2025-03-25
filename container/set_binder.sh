#!/bin/bash

# Verifica se o nome do container foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <nome_do_container>"
    exit 1
fi

# Nome do container passado como argumento
CONTAINER_NAME="$1"

echo "=== Compartilhando o binder com o container $CONTAINER_NAME ==="

# Verifica se o container existe
if ! lxc list | grep -q "^| $CONTAINER_NAME "; then
    echo "Erro: O container $CONTAINER_NAME não existe."
    exit 1
fi

# Configura o compartilhamento do binderfs com o container
echo "Compartilhando o /dev/binderfs do host com o container..."
lxc config device add "$CONTAINER_NAME" binderfs disk source=/dev/binderfs path=/dev/binderfs

# Compartilha o arquivo de dispositivo /dev/binder
echo "Compartilhando /dev/binder do host com o container..."
lxc config device add "$CONTAINER_NAME" binder unix-char source=/dev/binder path=/dev/binder

# Compartilha o arquivo de dispositivo /dev/binder-control
echo "Compartilhando /dev/binder-control do host com o container..."
lxc config device add "$CONTAINER_NAME" binder-control unix-char source=/dev/binder-control path=/dev/binder-control

# Confirmação
echo "=== Configuração concluída. Os dispositivos binder foram compartilhados com o container $CONTAINER_NAME ==="

