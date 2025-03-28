#!/bin/bash

# Cores para mensagens
NORMAL="\033[1;34m"  # Azul
WARNING="\033[1;33m" # Amarelo
ERROR="\033[1;31m"   # Vermelho
RESET="\033[0m"      # Resetar cor

# Verifica se o nome do container foi fornecido como argumento
if [ -z "$1" ]; then
    echo -e "${ERROR}Erro: Uso: $0 <nome_do_container>${RESET}"
    exit 1
fi

CONTAINER_NAME="$1"

# Diretório compartilhado do Wayland
WAYLAND_HOST_DIR="/run/user/1000"
WAYLAND_CONTAINER_DIR="/run/user/1000"

# Função para configurar a montagem persistente do Wayland no container
configurar_wayland_no_container() {
    echo -e "${NORMAL}Configurando o Wayland no container $CONTAINER_NAME...${RESET}"

    # Certifica-se de que o container está rodando
    if ! lxc info "$CONTAINER_NAME" | grep -q "RUNNING"; then
        echo -e "${WARNING}Aviso: O container $CONTAINER_NAME não está em execução. Iniciando o container...${RESET}"
        lxc start "$CONTAINER_NAME"
        sleep 5  # Aguarda o container iniciar
    fi

    # Remover e adicionar novamente a montagem Wayland
    echo -e "${NORMAL}Removendo e configurando montagem persistente do socket Wayland...${RESET}"
    lxc config device remove "$CONTAINER_NAME" wayland-share 2>/dev/null
    lxc config device add "$CONTAINER_NAME" wayland-share disk source="$WAYLAND_HOST_DIR" path="$WAYLAND_CONTAINER_DIR"
    
    # Verifica se a montagem foi realizada com sucesso
    if ! lxc exec "$CONTAINER_NAME" -- test -e "$WAYLAND_CONTAINER_DIR"; then
        echo -e "${ERROR}Erro: A montagem do socket Wayland não foi realizada com sucesso.${RESET}"
        exit 1
    fi

    lxc exec "$CONTAINER_NAME" -- bash -c "chown -R 1000:1000 $WAYLAND_CONTAINER_DIR"   

    # Configurar script de inicialização no container para recriar o diretório
    echo -e "${NORMAL}Configurando script de inicialização no container...${RESET}"
    lxc exec "$CONTAINER_NAME" -- bash -c "mkdir -p /etc/init.d"
    lxc exec "$CONTAINER_NAME" -- bash -c "cat <<EOF > /etc/init.d/recreate-run-user
#!/bin/bash
mkdir -p $WAYLAND_CONTAINER_DIR
EOF"
    lxc exec "$CONTAINER_NAME" -- bash -c "chmod +x /etc/init.d/recreate-run-user"

    # Configura a execução do script após reinicialização
    lxc exec "$CONTAINER_NAME" -- bash -c "ln -s /etc/init.d/recreate-run-user /etc/rc.local"

    echo -e "${NORMAL}Configuração do Wayland concluída no container $CONTAINER_NAME.${RESET}"
}

# Executa a configuração do Wayland no container
configurar_wayland_no_container

echo -e "${NORMAL}Configuração completa! O Wayland será configurado automaticamente após reinicializações do container.${RESET}"
