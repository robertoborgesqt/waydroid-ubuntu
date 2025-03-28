#!/bin/bash

CONTAINER="$1"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$CONTAINER_NAME" ]; then
    read -p "Por favor, insira o nome do container: " CONTAINER_NAME
    if [ -z "$CONTAINER_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do container não pode estar vazio.${NC}"
        exit 1
    fi
fi

# Verifica o estado do container
STATUS=$(sudo lxc info "$CONTAINER" | grep -i "Status" | awk '{print $2}')

if [ "$STATUS" != "Running" ]; then
  echo "O container '$CONTAINER' não está em execução. Iniciando..."
  sudo lxc start "$CONTAINER"
  sleep 5 # Dá um tempo para o container ser totalmente iniciado
else
  echo "O container '$CONTAINER' já está em execução."
fi

# Verifica se os arquivos de imagem estão na pasta ./images
IMAGES_DIR="./images"
if [ -d "$IMAGES_DIR" ]; then
  echo "Procurando imagens no diretório $IMAGES_DIR..."
  REQUIRED_IMAGES=("system.img" "vendor.img")
  for IMAGE in "${REQUIRED_IMAGES[@]}"; do
    if [ -f "$IMAGES_DIR/$IMAGE" ]; then
      echo "Encontrado $IMAGE. Copiando para o container..."
      sudo lxc file push "$IMAGES_DIR/$IMAGE" "$CONTAINER"/var/lib/waydroid/images/
    else
      echo "Imagem $IMAGE não encontrada no diretório $IMAGES_DIR."
    fi
  done
else
  echo "O diretório $IMAGES_DIR não existe. Certifique-se de que as imagens estão no local correto."
  exit 1
fi

# Verifica se o Waydroid está inicializado no container
echo "Verificando se o Waydroid está inicializado dentro do container '$CONTAINER'..."
WAYDROID_STATUS=$(sudo lxc exec "$CONTAINER" -- bash -c "systemctl is-active waydroid-container" 2>/dev/null)

if [ "$WAYDROID_STATUS" != "active" ]; then
  echo "O Waydroid não está inicializado. Inicializando..."
  sudo lxc exec "$CONTAINER" -- bash -c "sudo waydroid init"
  sudo lxc exec "$CONTAINER" -- bash -c "sudo systemctl start waydroid-container"
else
  echo "O Waydroid já está inicializado."
fi

# Inicia a sessão do Waydroid
echo "Iniciando uma sessão no Waydroid..."
sudo lxc exec "$CONTAINER" -- bash -c "waydroid session start"

# Exibe a interface gráfica do Waydroid
echo "Abrindo a interface gráfica do Waydroid..."
sudo lxc exec "$CONTAINER" -- bash -c "waydroid show-full-ui"


