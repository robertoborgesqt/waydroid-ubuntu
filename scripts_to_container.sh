#!/bin/bash
#set -x  # Mostra os comandos à medida que são executados
#set -e  # Para o script em caso de erro

# Verifica se um nome de container foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <nome_do_container>"
    exit 1
fi

# Nome do container é passado como argumento
CONTAINER_NAME="$1"

# Diretório local onde os scripts estão localizados
LOCAL_SCRIPTS_DIR="./container"

# Diretório dentro do container onde os scripts serão copiados
CONTAINER_SCRIPTS_DIR="/opt/scripts"

# Verifica se o diretório local existe
if [ ! -d "$LOCAL_SCRIPTS_DIR" ]; then
    echo "O diretório $LOCAL_SCRIPTS_DIR não existe. Certifique-se de que ele contém os scripts."
    exit 1
fi

# Certifica-se de que o container está em execução
echo "Verificando se o container $CONTAINER_NAME está rodando..."
if ! lxc info "$CONTAINER_NAME" | grep -q "RUNNING"; then
    echo "O container $CONTAINER_NAME não está em execução. Iniciando o container..."
    lxc start "$CONTAINER_NAME"
    sleep 5  # Aguarda o container iniciar
fi

# Cria o diretório de destino no container
echo "Criando o diretório $CONTAINER_SCRIPTS_DIR dentro do container $CONTAINER_NAME..."
lxc exec "$CONTAINER_NAME" -- mkdir -p "$CONTAINER_SCRIPTS_DIR"

# Copia os scripts para dentro do container
echo "Copiando scripts do host para o container..."
lxc file push "$LOCAL_SCRIPTS_DIR/"* "$CONTAINER_NAME/$CONTAINER_SCRIPTS_DIR/"

# Ajusta permissões para os scripts dentro do container
echo "Ajustando permissões dos scripts dentro do container..."
lxc exec "$CONTAINER_NAME" -- chmod +x "$CONTAINER_SCRIPTS_DIR"/*

# Executa os scripts dentro do container, passando CONTAINER_NAME como argumento
echo "Executando scripts dentro do container..."
for script in $(ls "$LOCAL_SCRIPTS_DIR"); do
    echo "Executando $script dentro do container com argumento CONTAINER_NAME=$CONTAINER_NAME..."
    lxc exec "$CONTAINER_NAME" -- bash -c "$CONTAINER_SCRIPTS_DIR/$script '$CONTAINER_NAME'"
done

echo "Todos os scripts foram copiados e executados com sucesso no container."

