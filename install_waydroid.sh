#!/bin/bash

# Verifica se um nome de container foi fornecido como argumento
if [ -z "$1" ]; then
    echo -e "\033[31mErro: Uso: $0 <nome_do_container>\033[0m"
    exit 1
fi

# Nome do container é passado como argumento
CONTAINER_NAME="$1"

# Certifica-se de que o container está em execução
echo -e "\033[32mVerificando se o container $CONTAINER_NAME está rodando...\033[0m"
if ! lxc info "$CONTAINER_NAME" | grep -q "RUNNING"; then
    echo -e "\033[33mAviso: O container $CONTAINER_NAME não está em execução. Iniciando o container...\033[0m"
    lxc start "$CONTAINER_NAME"
    sleep 5  # Aguarda o container iniciar
fi

# Atualiza os pacotes dentro do container
echo -e "\033[32mAtualizando os pacotes no container...\033[0m"
lxc exec "$CONTAINER_NAME" -- apt update && lxc exec "$CONTAINER_NAME" -- apt upgrade -y || {
    echo -e "\033[31mErro ao atualizar os pacotes no container.\033[0m"
    exit 1
}

# Certifica-se de que o curl está instalado
echo -e "\033[32mInstalando dependências básicas...\033[0m"
lxc exec "$CONTAINER_NAME" -- apt install -y curl || {
    echo -e "\033[31mErro ao instalar o curl.\033[0m"
    exit 1
}

# Configura o repositório do Waydroid e instala o pacote
echo -e "\033[32mConfigurando o repositório do Waydroid e instalando o pacote...\033[0m"
lxc exec "$CONTAINER_NAME" -- bash -c "curl -s https://repo.waydro.id | sudo bash" || {
    echo -e "\033[31mErro ao configurar o repositório do Waydroid.\033[0m"
    exit 1
}

# Instala o Waydroid
lxc exec "$CONTAINER_NAME" -- apt install -y waydroid || {
    echo -e "\033[31mErro ao instalar o Waydroid.\033[0m"
    exit 1
}

# Certifica-se de que os módulos do kernel binder estão disponíveis
echo -e "\033[32mConfigurando módulos do kernel binder dentro do container...\033[0m"
if ! lxc exec "$CONTAINER_NAME" -- modprobe binder_linux devices="binder,hwbinder,vndbinder"; then
    echo -e "\033[31mErro ao carregar o módulo binder_linux. Verifique se o kernel suporta este módulo.\033[0m"
    exit 1
fi

lxc exec "$CONTAINER_NAME" -- mkdir -p /dev/binderfs || {
    echo -e "\033[31mErro ao criar o diretório /dev/binderfs.\033[0m"
    exit 1
}
lxc exec "$CONTAINER_NAME" -- mount -t binder binder /dev/binderfs || {
    echo -e "\033[31mErro ao montar o sistema de arquivos binder.\033[0m"
    exit 1
}

# Configurações extras para o Waydroid
echo -e "\033[32mFinalizando a configuração do Waydroid dentro do container...\033[0m"
lxc exec "$CONTAINER_NAME" -- systemctl enable waydroid-container || {
    echo -e "\033[31mErro ao habilitar o serviço waydroid-container.\033[0m"
    exit 1
}
lxc exec "$CONTAINER_NAME" -- systemctl start waydroid-container || {
    echo -e "\033[31mErro ao iniciar o serviço waydroid-container.\033[0m"
    exit 1
}

# Confirmação de conclusão
echo -e "\033[32mTodos os pacotes foram instalados e configurados no container $CONTAINER_NAME.\033[0m"
echo -e "\033[32mVocê pode verificar o status do Waydroid com: lxc exec $CONTAINER_NAME -- waydroid status\033[0m"