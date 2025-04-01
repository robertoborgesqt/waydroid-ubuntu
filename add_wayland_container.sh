#--------------------------------------------------------------------------------
# Script Name: add_wayland_container.sh 
# Title: Adiciona suporte ao Wayland em um container LXD
# Description:  Este script configura o compartilhamento do socket Wayland entre o 
#               host e um container LXD.
#--------------------------------------------------------------------------------

#!/bin/bash

# Cores ANSI
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Erro: Este script precisa ser executado como root.${NC}"
    exit 1
fi

# Nome do container
PROJECT_NAME="$2"
INSTANCE_NAME="$1"

# Verifica se o script recebeu o nome do projeto como argumento
if [ -z "$PROJECT_NAME" ]; then
    read -p "Por favor, insira o nome do projeto: " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do projeto não pode estar vazio.${NC}"
        exit 1
    fi
fi
# Verifica se o script recebeu o nome do container como argumento
if [ -z "$INSTANCE_NAME" ]; then
    read -p "Por favor, insira o nome do container: " INSTANCE_NAME
    if [ -z "$INSTANCE_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do container não pode estar vazio.${NC}"
        exit 1
    fi
fi

# Verifica se o projeto existe
if ! lxc project list | grep -q "$PROJECT_NAME"; then
    echo -e "${RED}Erro: O projeto '$PROJECT_NAME' não existe.${NC}"
    exit 1
fi

lxc project switch "$PROJECT_NAME"

# Caminho local do socket Wayland no host
WAYLAND_HOST_DIR="/opt/wayland-share"
WAYLAND_SOCKET="$WAYLAND_HOST_DIR/wayland-0"

# Caminho no container onde o socket será montado
WAYLAND_CONTAINER_DIR="/opt/wayland-share"

# Verifica o estado do container
STATUS=$(sudo lxc info "$INSTANCE_NAME" | grep -i "Status" | awk '{print $2}')

if [ "$STATUS" != "RUNNING" ]; then
  echo -e "${YELLOW}O container '$INSTANCE_NAME' não está em execução. Iniciando...${NC}"
  lxc config set "$INSTANCE_NAME" security.secureboot=false
  sudo lxc start "$INSTANCE_NAME"
  sleep 5 # Dá um tempo para o container ser totalmente iniciado
else
  echo -e "${BLUE}O container '$INSTANCE_NAME' já está em execução.${NC}"
fi

STATUS=$(sudo lxc info "$INSTANCE_NAME" | grep -i "Status" | awk '{print $2}')

if [ "$STATUS" != "RUNNING" ]; then
  echo -e "${RED}Erro ao iniciar '$INSTANCE_NAME' ${NC}"
  exit 1
fi

# Verifica se o diretório compartilhado existe no host
if [ ! -d "$WAYLAND_HOST_DIR" ]; then
    echo -e "${RED}O diretório $WAYLAND_HOST_DIR não existe no host. Certifique-se de configurá-lo primeiro.${NC}"
    exit 1
fi

# Verifica se o socket Wayland existe no host
if [ ! -e "$WAYLAND_SOCKET" ]; then
    echo -e "${RED}O arquivo $WAYLAND_SOCKET não existe. Certifique-se de que o Wayland está configurado corretamente no host.${NC}"
    exit 1
fi

# Adiciona o diretório ao container, com as permissões corretas
echo -e "${GREEN}Montando o diretório $WAYLAND_HOST_DIR no container $INSTANCE_NAME...${NC}"
echo "${YELLOW} lxc config device add "$INSTANCE_NAME" wayland-share disk source="$WAYLAND_HOST_DIR" path="$WAYLAND_CONTAINER_DIR""
lxc config device add "$INSTANCE_NAME" wayland-share disk source="$WAYLAND_HOST_DIR" path="$WAYLAND_CONTAINER_DIR"


# Configura a variável WAYLAND_DISPLAY no container
echo -e "${GREEN}Configurando a variável WAYLAND_DISPLAY no container...${NC}"
lxc exec "$INSTANCE_NAME" -- bash -c "echo 'export WAYLAND_DISPLAY=$WAYLAND_CONTAINER_DIR/wayland-0' >> /etc/environment"

# Configura o script de inicialização no container para recriar o diretório compartilhado
echo -e "${GREEN}Configurando script de inicialização no container...${NC}"
lxc exec "$INSTANCE_NAME" -- bash -c "mkdir -p /etc/init.d"
lxc exec "$INSTANCE_NAME" -- bash -c "cat <<EOF > /etc/init.d/recreate-wayland
#!/bin/bash
mkdir -p $WAYLAND_CONTAINER_DIR
EOF"
lxc exec "$INSTANCE_NAME" -- bash -c "chmod +x /etc/init.d/recreate-wayland"

# Configura a execução do script após reinicialização
lxc exec "$INSTANCE_NAME" -- bash -c "ln -s /etc/init.d/recreate-wayland /etc/rc.local"

# mostra o caminho do socket Wayland no container com suas permissões
echo -e "${BLUE}O socket Wayland está disponível em $WAYLAND_CONTAINER_DIR/wayland-0.${NC}"
lxc exec "$INSTANCE_NAME" -- ls -l "$WAYLAND_CONTAINER_DIR/wayland-0"

# Verifica se o socket Wayland foi montado corretamente no container
if ! lxc exec "$INSTANCE_NAME" -- test -e "$WAYLAND_CONTAINER_DIR/wayland-0"; then
    echo -e "${RED}Erro: O socket Wayland não foi encontrado no container em $WAYLAND_CONTAINER_DIR/wayland-0.${NC}"
    exit 1
fi

# Confirmação de sucesso
echo -e "${BLUE}Configuração concluída. O container $INSTANCE_NAME agora pode acessar o Wayland através de $WAYLAND_CONTAINER_DIR/wayland-0.${NC}"
echo -e "${YELLOW}Reinicie o container ou use 'lxc exec $INSTANCE_NAME -- bash' para testar.${NC}"

# Reinicia o container (opcional, caso necessário)
read -p "Deseja reiniciar o container agora? (s/n): " RESTART
if [ "$RESTART" = "s" ] || [ "$RESTART" = "S" ]; then
    echo -e "${BLUE}Reiniciando o container...${NC}"
    lxc restart "$INSTANCE_NAME"
    echo -e "${BLUE}Container reiniciado.${NC}"
else
    echo -e "${YELLOW}Não foi necessário reiniciar o container.${NC}"
fi
