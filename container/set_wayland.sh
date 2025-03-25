#!/bin/bash

# Verifica se o nome do container foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <nome_do_container>"
    exit 1
fi

CONTAINER_NAME="$1"

# Diretório compartilhado do Wayland
WAYLAND_HOST_DIR="/run/user/1000"
WAYLAND_CONTAINER_DIR="/run/user/1000"

# Função para configurar a montagem persistente do Wayland no container
configurar_wayland_no_container() {
    echo "Configurando o Wayland no container $CONTAINER_NAME..."

    # Certifica-se de que o container está rodando
    if ! lxc info "$CONTAINER_NAME" | grep -q "RUNNING"; then
        echo "O container $CONTAINER_NAME não está em execução. Iniciando o container..."
        lxc start "$CONTAINER_NAME"
        sleep 5  # Aguarda o container iniciar
    fi

    # Remover e adicionar novamente a montagem Wayland
    echo "Removendo e configurando montagem persistente do socket Wayland..."
    lxc config device remove "$CONTAINER_NAME" wayland-share 2>/dev/null
    lxc config device add "$CONTAINER_NAME" wayland-share disk source="$WAYLAND_HOST_DIR" path="$WAYLAND_CONTAINER_DIR"

    # Configurar script de inicialização no container para recriar o diretório
    echo "Configurando script de inicialização no container..."
    lxc exec "$CONTAINER_NAME" -- bash -c "mkdir -p /etc/init.d"
    lxc exec "$CONTAINER_NAME" -- bash -c "cat <<EOF > /etc/init.d/recreate-run-user
#!/bin/bash
mkdir -p $WAYLAND_CONTAINER_DIR
EOF"
    lxc exec "$CONTAINER_NAME" -- bash -c "chmod +x /etc/init.d/recreate-run-user"

    # Configura a execução do script após reinicialização
    lxc exec "$CONTAINER_NAME" -- bash -c "ln -s /etc/init.d/recreate-run-user /etc/rc.local"

    echo "Configuração do Wayland concluída no container $CONTAINER_NAME."
}

# Executa a configuração do Wayland no container
configurar_wayland_no_container

echo "Configuração completa! O Wayland será configurado automaticamente após reinicializações do container."


