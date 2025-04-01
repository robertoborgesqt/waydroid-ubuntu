

INSTANCE_NAME="$1"

# Verifica se o script recebeu o nome do container como argumento
if [ -z "$INSTANCE_NAME" ]; then
    read -p "Por favor, insira o nome da instancia: " INSTANCE_NAME 
    if [ -z "$INSTANCE_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do instancia não pode estar vazio.${NC}"
        exit 1
    fi
fi

lxc list --project "$INSTANCE_NAME" 
