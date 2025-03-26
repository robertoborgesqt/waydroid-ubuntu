#!/bin/bash

# Atualizar os repositórios
echo "Atualizando os repositórios..."
sudo apt update

# Instalar o Snap
echo "Instalando o Snap..."
sudo apt install -y snapd

# Instalar o LXD via Snap
echo "Instalando o LXD via Snap..."
sudo snap install lxd

# Configurar o LXD
echo "Configurando o LXD..."
lxd init --auto

# Adicionar o usuário ao grupo LXD
echo "Adicionando o usuário atual ao grupo LXD..."
sudo usermod -aG lxd $USER

# Finalização
echo "LXD instalado e configurado com sucesso!"
echo "Reinicie sua sessão para que as alterações de grupo tenham efeito."

# Testar o LXD
echo "Para testar o LXD, execute o comando: lxc list"

