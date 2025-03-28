#!/bin/bash

CONTAINER="$1"

# Definição de cores
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m" # Sem cor

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$CONTAINER" ]; then
  read -p "Por favor, insira o nome do container: " CONTAINER
  if [ -z "$CONTAINER" ]; then
    echo -e "${RED}Erro: O nome do container não pode estar vazio.${NC}"
    exit 1
  fi
fi

# Verifica o estado do container
STATUS=$(sudo lxc info "$CONTAINER" | grep -i "Status" | awk '{print $2}')

if [ "$STATUS" != "Running" ]; then
  echo -e "${YELLOW}O container '$CONTAINER' não está em execução. Iniciando...${NC}"
  sudo lxc start "$CONTAINER"
  sleep 5 # Dá um tempo para o container ser totalmente iniciado
else
  echo -e "${BLUE}O container '$CONTAINER' já está em execução.${NC}"
fi

# Verifica se os arquivos de imagem estão na pasta ./images
IMAGES_DIR="./images"
if [ -d "$IMAGES_DIR" ]; then
  echo -e "${BLUE}Procurando imagens no diretório $IMAGES_DIR...${NC}"
  REQUIRED_IMAGES=("system.img" "vendor.img")
  for IMAGE in "${REQUIRED_IMAGES[@]}"; do
  if [ -f "$IMAGES_DIR/$IMAGE" ]; then
    echo -e "${BLUE}Encontrado $IMAGE. Copiando para o container...${NC}"
    sudo lxc file push "$IMAGES_DIR/$IMAGE" "$CONTAINER"/var/lib/waydroid/images/
  else
    echo -e "${YELLOW}Imagem $IMAGE não encontrada no diretório $IMAGES_DIR.${NC}"
  fi
  done
else
  echo -e "${RED}O diretório $IMAGES_DIR não existe. Certifique-se de que as imagens estão no local correto.${NC}"
fi

# Verifica se o Waydroid está inicializado no container
echo -e "${BLUE}Verificando se o Waydroid está inicializado dentro do container '$CONTAINER'...${NC}"
WAYDROID_STATUS=$(sudo lxc exec "$CONTAINER" -- bash -c "systemctl is-active waydroid-container" 2>/dev/null)

if [ "$WAYDROID_STATUS" != "active" ]; then
  echo -e "${YELLOW}O Waydroid não está inicializado. Inicializando...${NC}"
  sudo lxc exec "$CONTAINER" -- bash -c "sudo waydroid init"
  sudo lxc exec "$CONTAINER" -- bash -c "sudo systemctl start waydroid-container"
else
  echo -e "${BLUE}O Waydroid já está inicializado.${NC}"
fi

# Inicia a sessão do Waydroid
echo -e "${BLUE}Iniciando uma sessão no Waydroid...${NC}"
sudo lxc exec "$CONTAINER" -- bash -c "waydroid session start"

# Exibe a interface gráfica do Waydroid
echo -e "${BLUE}Abrindo a interface gráfica do Waydroid...${NC}"
sudo lxc exec "$CONTAINER" -- bash -c "waydroid show-full-ui"
