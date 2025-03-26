#!/bin/bash

echo "Configurando Wayland..."

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script deve ser executado como root. Use 'sudo'."
    exit 1
fi

# Define o caminho correto para o socket Wayland
WAYLAND_DIR="/run/user/1000/wayland-0"
if [ ! -S "$WAYLAND_DIR" ]; then
    echo "O socket Wayland não foi encontrado em $WAYLAND_DIR."
    echo "Certifique-se de que você está executando um ambiente Wayland e que o diretório está acessível."
    exit 1
fi

# Cria um diretório de compartilhamento para o container
echo "Criando o diretório de compartilhamento para o container..."
SHARE_DIR="/opt/wayland-share"
mkdir -p "$SHARE_DIR"

# Ajusta permissões para o diretório compartilhado
echo "Ajustando permissões no diretório compartilhado..."
chmod 777 "$SHARE_DIR"

# Liga o socket Wayland ao diretório de compartilhamento
echo "Ligando o socket Wayland ao diretório compartilhado..."
ln -sf "$WAYLAND_DIR" "$SHARE_DIR/wayland-0"

# Verifica se o link foi criado com sucesso
if [ -L "$SHARE_DIR/wayland-0" ]; then
    echo "Socket Wayland ligado com sucesso em $SHARE_DIR/wayland-0."
else
    echo "Falha ao criar o link simbólico do socket Wayland."
    exit 1
fi

# Configuração adicional para containers (se necessário)
echo "Certifique-se de que o container tenha acesso a $SHARE_DIR e às permissões necessárias para usar o Wayland."

# Confirmação de conclusão
echo "Configuração do compartilhamento do Wayland concluída. O container pode acessar o Wayland através de $SHARE_DIR/wayland-0."
