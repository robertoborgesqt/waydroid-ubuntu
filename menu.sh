#!/bin/bash
# Inclui scripts do diretório principal e da subpasta "containers"
# Diretório contendo os scripts
SCRIPT_DIR="/home/roberto/projetos/waydroid-ubuntu"
SCRIPT_DIR_CONTAINERS="$SCRIPT_DIR/containers"

# Função para exibir o menu
exibir_menu() {
    echo -e "\e[32m--------------------------------\e[0m"
    echo -e "\e[32mSelecione uma opção:\e[0m"
    echo -e "\e[32m--------------------------------\e[0m"
    local i=1
    for script in "$SCRIPT_DIR"/*.sh; do
        if [ -f "$script" ]; then
            if [ "$i" -lt 10 ]; then
                echo " $i) $(basename "$script")"
            else
                echo "$i) $(basename "$script")"
            fi
        fi
        ((i++))
    done
    echo " 0) Sair"
}

# Função para executar o script selecionado
executar_opcao() {
    local opcao=$1
    local i=1
    for script in "$SCRIPT_DIR"/*.sh; do
        if [ "$i" -eq "$opcao" ]; then
            clear
            bash "$script"
            return
        fi
        ((i++))
    done
    echo "Opção inválida!"
}

# Loop principal
while true; do
    exibir_menu
    echo -e "\e[32m--------------------------------\e[0m"
    read -p "Digite sua escolha: " escolha
    echo -e "\e[32m--------------------------------\e[0m"
    if [ "$escolha" -eq 0 ]; then
        echo "Saindo..."
        break
    fi
    executar_opcao "$escolha"
done