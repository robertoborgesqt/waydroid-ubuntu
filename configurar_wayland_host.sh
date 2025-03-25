#!/bin/bash

# Nome do container
CONTAINER_NAME="$1"

# Caminho local do socket Wayland no host
WAYLAND_HOST_DIR="/opt/wayland-share"

# Caminho no container onde o socket será montado
WAYLAND_CONTAINER_DIR="/opt/wayland-share"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$CONTAINER_NAME" ]; then
    echo "Uso: $0 <nome_do_container>"
    exit 1
fi

# Verifica se o diretório compartilhado existe no host
if [ ! -d "$WAYLAND_HOST_DIR" ]; then
    echo "O diretório $WAYLAND_HOST_DIR não existe no host. Certifique-se de configurá-lo primeiro."
    exit 1
fi

# Adiciona o diretório ao container
echo "Montando o diretório $WAYLAND_HOST_DIR no container $CONTAINER_NAME..."
lxc config device add "$CONTAINER_NAME" wayland-share disk source="$WAYLAND_HOST_DIR" path="$WAYLAND_CONTAINER_DIR"

# Configura a variável WAYLAND_DISPLAY no container
echo "Configurando a variável WAYLAND_DISPLAY no container..."
lxc exec "$CONTAINER_NAME" -- bash -c "echo 'export WAYLAND_DISPLAY=$WAYLAND_CONTAINER_DIR/wayland-0' >> /etc/environment"

# Confirmação de sucesso
echo "Configuração concluída. O container $CONTAINER_NAME agora pode acessar o Wayland através de $WAYLAND_CONTAINER_DIR/wayland-0."
echo "Reinicie o container ou use 'lxc exec $CONTAINER_NAME -- bash' para testar."

# Reinicia o container (opcional, caso necessário)
read -p "Deseja reiniciar o container agora? (s/n): " RESTART
if [[ "$RESTART" == "s" || "$RESTART" == "S" ]]; then
    echo "Reiniciando o container..."
    lxc restart "$CONTAINER_NAME"
    echo "Container reiniciado."
else
    echo "Não foi necessário reiniciar o container."
fi
