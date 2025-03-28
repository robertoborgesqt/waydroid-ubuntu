
CONTAINER="$1"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$CONTAINER" ]; then
  read -p "Por favor, insira o nome do container: " CONTAINER
  if [ -z "$CONTAINER" ]; then
    echo -e "${RED}Erro: O nome do container não pode estar vazio.${NC}"
    exit 1
  fi
fi

sudo lxc exec $CONTAINER -- bash
