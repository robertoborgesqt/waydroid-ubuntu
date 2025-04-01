

PROJECT_NAME="$1"

# Verifica se o script recebeu o nome do projeto como argumento
if [ -z "$PROJECT_NAME" ]; then
    read -p "Por favor, insira o nome do projeto: " PROJECT_NAME 
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${YELLOW}Erro: O nome do projeto não pode estar vazio.${NC}"
        exit 1
    fi
fi

lxc list --project "$PROJECT_NAME" 
