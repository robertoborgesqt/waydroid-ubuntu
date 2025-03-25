#!/bin/bash

# Verifica se o nome do container foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <nome_do_container>"
    exit 1
fi

# Nome do container passado como parâmetro
CONTAINER_NAME="$1"

# Função para verificar dependências do Wayland no host
verificar_dependencias() {
    echo "Verificando dependências do Wayland no host..."
    REQUIRED_PACKAGES=("wayland-protocols" "libwayland-dev" "xwayland" "weston" "libegl1-mesa" "libgl1-mesa-dri")

    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "$package"; then
            echo "Dependência ausente: $package"
            echo "Instalando $package..."
            sudo apt update && sudo apt install -y "$package"
        else
            echo "Dependência encontrada: $package"
        fi
    done

    echo "Todas as dependências do Wayland foram verificadas."
}

# Função para configurar Wayland no container
configurar_wayland_no_container() {
    echo "Configurando o Wayland no container $CONTAINER_NAME..."

    # Certifica-se de que o container está rodando
    if ! lxc info "$CONTAINER_NAME" | grep -q "RUNNING"; then
        echo "O container $CONTAINER_NAME não está em execução. Iniciando o container..."
        lxc start "$CONTAINER_NAME"
        sleep 5  # Aguarda o container iniciar
    fi

    # Diretório compartilhado para o socket Wayland no host
    WAYLAND_HOST_DIR="/run/user/1000"
    WAYLAND_CONTAINER_DIR="/run/user/1000"

    if [ ! -d "$WAYLAND_HOST_DIR" ]; then
        echo "O diretório $WAYLAND_HOST_DIR não existe no host. Certifique-se de que Wayland está rodando no host."
        exit 1
    fi

    # Compartilha o socket Wayland com o container
    echo "Compartilhando o socket Wayland do host com o container..."
    lxc config device add "$CONTAINER_NAME" wayland-share disk source="$WAYLAND_HOST_DIR" path="$WAYLAND_CONTAINER_DIR"

    # Configura a variável de ambiente WAYLAND_DISPLAY no container
    echo "Configurando a variável WAYLAND_DISPLAY no container..."
    lxc exec "$CONTAINER_NAME" -- bash -c "echo 'export WAYLAND_DISPLAY=$WAYLAND_CONTAINER_DIR/wayland-0' >> /etc/profile"

    # Adiciona o export ao arquivo de inicialização permanente
    echo "Aplicando configuração ao arquivo de inicialização do container..."
    lxc exec "$CONTAINER_NAME" -- bash -c "echo 'export WAYLAND_DISPLAY=$WAYLAND_CONTAINER_DIR/wayland-0' >> /etc/environment"

    # Permite que o container use o display Wayland
    echo "Certificando-se de que o Wayland está funcional no container..."
    lxc exec "$CONTAINER_NAME" -- bash -c "export WAYLAND_DISPLAY=$WAYLAND_CONTAINER_DIR/wayland-0"

    echo "Configuração do Wayland no container $CONTAINER_NAME concluída com sucesso."
}

# Executa as funções
verificar_dependencias
configurar_wayland_no_container

echo "Configuração permanente concluída! As alterações foram aplicadas automaticamente e não será necessário reexecutar o script no futuro."