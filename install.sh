#!/bin/bash
if [ -f /etc/arch-release ]; then
    sudo pacman -Syu $1
elif [ -f /etc/lsb-release ]; then
    sudo apt update && sudo apt install $1
elif [ -f /etc/redhat-release ]; then
    sudo dnf install $1
else
    echo "Distribuição não suportada."
    exit 1
fi