#!/bin/bash

echo "removendo o Waydroid..."
# Atualiza os pacotes do sistema
echo "Atualizando lista de pacotes..."
sudo apt update

# Remove o pacote do Waydroid
echo "Removendo o Waydroid..."
sudo apt remove waydroid -y

# Purga arquivos de configuracao relacionados ao Waydroid
echo "Purga de arquivos de configuracao..."
sudo apt purge waydroid -y

# Remove repositórios adicionados anteriormente
echo "Removendo repositorio Waydroid..."
sudo add-apt-repository --remove ppa:waydroid-team/waydroid -y

# Limpeza de pacotes nao utilizados
echo "Removendo pacotes não utilizados..."
sudo apt autoremove -y

# Confirmação de conclusao
echo "Remoção conclusao. O Waydroid foi desinstalado com sucesso."
