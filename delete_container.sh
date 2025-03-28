#!/bin/bash


# Nome do container passado como argumento
CONTAINER_NAME="$1"
# Verifica se o script recebeu o nome do container como argumento
if [ -z "$CONTAINER_NAME" ]; then
    read -p "Por favor, insira o nome do container: " CONTAINER_NAME
    if [ -z "$CONTAINER_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do container não pode estar vazio.${NC}"
        exit 1
    fi
fi

# Verifica se o container existe
if ! lxc list | grep -q "^| $CONTAINER_NAME "; then
    echo "O container $CONTAINER_NAME não existe ou está inacessível."
    exit 1
fi

# Para o container (caso esteja em execução)
echo "Parando o container $CONTAINER_NAME (se estiver em execução)..."
lxc stop "$CONTAINER_NAME" 2>/dev/null

# Remove o container
echo "Removendo o container $CONTAINER_NAME..."
lxc delete "$CONTAINER_NAME"

# Confirmação
echo "Container $CONTAINER_NAME removido com sucesso."

