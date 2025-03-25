#!/bin/bash

echo "Configurando Binder ..."
# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script deve ser executado como root. Use 'sudo'."
    exit 1
fi

# Certifica-se de que os módulos do kernel necessários estão carregados
echo "Carregando os módulos necessários no kernel..."
modprobe binder_linux devices="binder,hwbinder,vndbinder"

# Verifica se os módulos foram carregados corretamente
if lsmod | grep -q "binder_linux"; then
    echo "O módulo 'binder_linux' foi carregado com sucesso."
else
    echo "Falha ao carregar o módulo 'binder_linux'. Verifique se o kernel suporta o binder."
    exit 1
fi

# Configura a montagem do binder no sistema de arquivos
echo "Criando os pontos de montagem para o binder..."
mkdir -p /dev/binderfs
mount -t binder binder /dev/binderfs

# Verifica se a montagem foi bem-sucedida
if mount | grep -q "/dev/binderfs"; then
    echo "O sistema de arquivos 'binderfs' foi montado com sucesso."
else
    echo "Falha ao montar o sistema de arquivos 'binderfs'."
    exit 1
fi

# Ajusta permissões, se necessário
echo "Ajustando permissões para o uso do binder..."
chmod 755 /dev/binderfs

# Adiciona as configurações ao fstab para montagem automática (opcional)
echo "Adicionando configuração ao fstab para montagem automática..."
echo "binder /dev/binderfs binder defaults 0 0" >> /etc/fstab

# Confirmação de conclusão
echo "Configuração do binder concluída. O sistema está preparado para compartilhar o binder com o container Waydroid."
