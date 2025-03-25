#!/bin/bash

echo "Verificando containers relacionados ao Waydroid..."

# Lista e filtra os containers com "waydroid" no nome
containers=$(lxc list | grep waydroid | awk '{print $2}')

if [ -z "$containers" ]; then
    echo "Nenhum container relacionado ao Waydroid encontrado."
    exit 0
fi

# Para e remove os containers
for container in $containers; do
    echo "Parando o container: $container..."
    lxc stop "$container"

    echo "Removendo o container: $container..."
    lxc delete "$container"
done

echo "Todos os containers relacionados ao Waydroid foram removidos."

# Verificar e remover volumes relacionados, se existirem
echo "Verificando volumes relacionados ao Waydroid..."
volumes=$(lxc storage list | grep waydroid | awk '{print $2}')
for volume in $volumes; do
    echo "Removendo volume: $volume..."
    lxc storage delete "$volume"
done

# Verificar e remover perfis relacionados, se existirem
echo "Verificando perfis relacionados ao Waydroid..."
profiles=$(lxc profile list | grep waydroid | awk '{print $2}')
for profile in $profiles; do
    echo "Removendo perfil: $profile..."
    lxc profile delete "$profile"
done

echo "Limpeza concluída. Todos os recursos relacionados ao Waydroid foram removidos com sucesso!"

