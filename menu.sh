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

# Função para exibir menu com opçoes fixas
exibir_menu_containers() {
    echo -e "\e[32m--------------------------------\e[0m"
    echo -e "\e[32mSelecione uma opção:\e[0m"
    echo -e "\e[32m--------------------------------\e[0m"
    echo " 1) Instalar LXD/LXC"
    echo " 2) Criar Projeto LXD"
    echo " 3) Criar Instancia"
    echo " 4) Instalar Wayland (host) "
    echo " 5) Instalar Wayland (instância) "
    echo " 6) Instalar Waydroid"
    echo " 7) Iniciar instancia"
    echo " 8) Iniciar Waydroid na instância"
    echo " 9) Parar instância"
    echo "10) Listar Instancias"
    echo "11) Listar Projetos"
    echo "12) Remover Instancia"
    echo "13) Remover Projeto LXD"
    echo "14) Remover LXD/LXC"
    echo "15) Duplicar instancia"
    echo "16) Instalar Binder na instancia"
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
clear
while true; do
    exibir_menu_containers
    echo -e "\e[32m--------------------------------\e[0m"
    read -p "Digite sua escolha: " escolha
    echo -e "\e[32m--------------------------------\e[0m"
    if [ "$escolha" -eq 0 ]; then
        echo "Saindo..."
        break
    fi
    if [ "$escolha" -lt 1 ] || [ "$escolha" -gt 17 ]; then
        echo "Opção inválida! Tente novamente."
        continue
    fi

    # se opção for 1 executar install_lxd.sh
    if [ "$escolha" -eq 1 ]; then
        clear
        bash "$SCRIPT_DIR/install_lxd.sh"
        continue
    fi
    # se opção for 2 executar create_project.sh
    if [ "$escolha" -eq 2 ]; then
        clear
        bash "$SCRIPT_DIR/create_project.sh"
        continue
    fi
    # se opção for 3 executar create_instance.sh
    if [ "$escolha" -eq 3 ]; then
        clear
        bash "$SCRIPT_DIR/create_instance.sh"
        continue
    fi
    # se opção for 4 executar add_wayland_host.sh
    if [ "$escolha" -eq 4 ]; then
        clear
        bash "$SCRIPT_DIR/add_wayland_host.sh"
        continue
    fi
    # se opção for 5 executar add_wayland_container.sh
    if [ "$escolha" -eq 5 ]; then
        clear
        bash "$SCRIPT_DIR/add_wayland_container.sh"
        continue
    fi
    # se opção for 6 executar install_waydroid.sh
    if [ "$escolha" -eq 6 ]; then
        clear
        bash "$SCRIPT_DIR/install_waydroid.sh"
        continue
    fi
    # se opção for 7 executar initialize_waydroid.sh
    if [ "$escolha" -eq 7 ]; then
        clear
        bash "$SCRIPT_DIR/initialize_waydroid.sh"
        continue
    fi
    # se opção for 8 executar initialize_waydroid.sh
    if [ "$escolha" -eq 8 ]; then
        clear
        bash "$SCRIPT_DIR/initialize_waydroid.sh"
        continue
    fi
    # se opção for 9 executar stop_container.sh
    if [ "$escolha" -eq 9 ]; then
        clear
        bash "$SCRIPT_DIR/stop_container.sh"
        continue
    fi
    # se opção for 10 executar list-instances.sh
    if [ "$escolha" -eq 10 ]; then
        clear
        bash "$SCRIPT_DIR/list-instances.sh"
        continue
    fi
    # se opção for 11 executar list-projects.sh
    if [ "$escolha" -eq 11 ]; then
        clear
        bash "$SCRIPT_DIR/list-projects.sh"
        continue
    fi
    # se opção for 10 executar remove_instancia.sh
    if [ "$escolha" -eq 12 ]; then
        clear
        bash "$SCRIPT_DIR/remove_instancia.sh"
        continue
    fi
    # se opção for 13 executar remove_project.sh
    if [ "$escolha" -eq 13 ]; then
        clear
        bash "$SCRIPT_DIR/remove_project.sh"
        continue
    fi
    # se opção for 14 executar remove_project.sh
    if [ "$escolha" -eq 14 ]; then
        clear
        bash "$SCRIPT_DIR/remove_project.sh"
        continue
    fi
    # se opção for 15 executar duplicate_instance.sh
    if [ "$escolha" -eq 15 ]; then
        clear
        bash "$SCRIPT_DIR/duplicate_instance.sh"
        continue
    fi

    # se opção for 16 executar set_binder.sh
    if [ "$escolha" -eq 16 ]; then
        clear
        bash "$SCRIPT_DIR/set_binder.sh"
        continue
    fi



    executar_opcao "$escolha"
done