#!/bin/bash

# Função para exibir mensagens coloridas
function green() {
    echo -e "\e[32m$1\e[0m"
}

function red() {
    echo -e "\e[31m$1\e[0m"
}

function yellow() {
    echo -e "\e[33m$1\e[0m"
}

# Nome do container passado como argumento
INSTANCE_NAME="$1"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$INSTANCE_NAME" ]; then
  read -p "Por favor, insira o nome do container: " INSTANCE_NAME
  if [ -z "$INSTANCE_NAME" ]; then
    echo -e "${RED}Erro: O nome do container não pode estar vazio.${NC}"
    exit 1
  fi
fi

green "=== Compartilhando o binder com o container $INSTANCE_NAME ==="

# Verifica se o container existe
if ! lxc list | grep -q "^| $INSTANCE_NAME "; then
    red "Erro: O container $INSTANCE_NAME não existe."
    exit 1
fi

# Verifica se o módulo binder_linux está disponível
yellow "Verificando se o módulo binder_linux está disponível..."
if ! grep -q "binder" /proc/filesystems; then
    red "Erro: O sistema não suporta o módulo binder_linux. Verifique se o kernel tem suporte ao Android Binder."
    exit 1
fi

# Monta o binderfs no host, se necessário
yellow "Verificando se o binderfs está montado no host..."
if ! mount | grep -q "/dev/binderfs"; then
    yellow "Montando o binderfs no host..."
    sudo mkdir -p /dev/binderfs
    sudo mount -t binder binder /dev/binderfs || {
        red "Erro ao montar o binderfs no host."
        exit 1
    }
else
    green "O binderfs já está montado no host."
fi

# Remove o compartilhamento atual do binderfs com o container, se existir
yellow "Removendo o compartilhamento atual do /dev/binderfs com o container..."
if lxc config device remove "$INSTANCE_NAME" binderfs --quiet; then
    green "O compartilhamento do /dev/binderfs foi removido com sucesso."
else
    yellow "Nenhum compartilhamento do /dev/binderfs foi encontrado para remover."
fi

# Remove o compartilhamento atual do /dev/binder com o container, se existir
yellow "Removendo o compartilhamento atual do /dev/binder com o container..."
if lxc config device remove "$INSTANCE_NAME" binder --quiet; then
    green "O compartilhamento do /dev/binder foi removido com sucesso."
else
    yellow "Nenhum compartilhamento do /dev/binder foi encontrado para remover."
fi

# Remove o compartilhamento atual do /dev/binder-control com o container, se existir
yellow "Removendo o compartilhamento atual do /dev/binder-control com o container..."
if lxc config device remove "$INSTANCE_NAME" binder-control --quiet; then
    green "O compartilhamento do /dev/binder-control foi removido com sucesso."
else
    yellow "Nenhum compartilhamento do /dev/binder-control foi encontrado para remover."
fi

# executa o comando mount no container
yellow "Executando o comando mount no container..."
sudo chown 0:0 /dev/binderfs || {
    red "Erro ao executar o comando chown no host."
    exit 1
}

yellow "Ajustando raw.idmap ..."
lxc config set w1 raw.idmap "both 0 0" || {
    red "Erro ao ajustar o raw.idmap no container."
    exit 1
}

# Configura o compartilhamento do binderfs com o container
yellow "Compartilhando o /dev/binderfs do host com o container..."
lxc config device add "$INSTANCE_NAME" binderfs disk source=/dev/binderfs path=/dev/binderfs --quiet || {
    red "Erro ao compartilhar o /dev/binderfs com o container."
    exit 1
}

# Verifica se o arquivo de dispositivo /dev/binder existe no host
if [ -e /dev/binder ]; then
    yellow "Compartilhando /dev/binder do host com o container..."
    lxc config device add "$INSTANCE_NAME" binder unix-char source=/dev/binder path=/dev/binder --quiet || {
        red "Erro ao compartilhar /dev/binder com o container."
        exit 1
    }
else
    yellow "/dev/binder não existe no host. Pulando o compartilhamento deste dispositivo."
fi

# Compartilha o arquivo de dispositivo /dev/binder-control
yellow "Compartilhando /dev/binder-control do host com o container..."
lxc config device add "$INSTANCE_NAME" binder-control unix-char source=/dev/binderfs/binder-control path=/dev/binder-control || {
    red "Erro ao compartilhar /dev/binder-control com o container."

}

# Cria links simbólicos para os dispositivos binder
yellow "Criando links simbólicos para os dispositivos binder..."
lxc exec "$INSTANCE_NAME" -- ln -sf /dev/binderfs/anbox-binder /dev/binder
lxc exec "$INSTANCE_NAME" -- ln -sf /dev/binderfs/anbox-hwbinder /dev/hwbinder
lxc exec "$INSTANCE_NAME" -- ln -sf /dev/binderfs/anbox-vndbinder /dev/vndbinder
lxc exec "$INSTANCE_NAME" -- ln -sf /dev/binderfs/binder-control /dev/binder-control

# Verifica se os links simbólicos foram criados corretamente dentro da instância
yellow "Verificando se os links simbólicos foram criados dentro do container..."
if lxc exec "$INSTANCE_NAME" -- ls -l /dev/binder /dev/hwbinder /dev/vndbinder /dev/binder-control | grep -q "No such file or directory"; then
    red "Erro: Alguns links simbólicos não foram criados corretamente dentro do container."
    exit 1
else
    green "Todos os links simbólicos foram criados corretamente dentro do container."
fi

# Confirmação
green "=== Configuração concluída. Os dispositivos binder foram compartilhados com o container $INSTANCE_NAME ==="
