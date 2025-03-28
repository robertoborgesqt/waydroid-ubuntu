#!/bin/bash

# Códigos de cores ANSI
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Por favor, execute este script como root ou usando sudo.${RESET}"
  exit 1
fi

echo -e "${BLUE}Atualizando pacotes do sistema...${RESET}"
apt update && apt upgrade -y

echo -e "${BLUE}Instalando pacotes necessários para Wayland...${RESET}"
apt install -y wayland gnome-session-wayland

echo -e "${BLUE}Configurando o LightDM para suportar Wayland...${RESET}"

LIGHTDM_CONFIG="/usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf"

if [ -f "$LIGHTDM_CONFIG" ]; then
  echo -e "${YELLOW}Editando $LIGHTDM_CONFIG...${RESET}"
  sed -i 's/session-wrapper=\/etc\/X11\/Xsession/session-wrapper=\/etc\/wayland-session/' "$LIGHTDM_CONFIG"
else
  echo -e "${YELLOW}Criando configuração do LightDM...${RESET}"
  cat <<EOF >"$LIGHTDM_CONFIG"
[Seat:*]
allow-guest=false
session-wrapper=/etc/wayland-session
EOF
fi

echo -e "${BLUE}Criando arquivo de sessão para Wayland...${RESET}"
WAYLAND_SESSION="/usr/share/wayland-sessions/gnome-wayland.desktop"

cat <<EOF >"$WAYLAND_SESSION"
[Desktop Entry]
Name=GNOME on Wayland
Comment=This session runs GNOME Shell on Wayland
Exec=/usr/bin/gnome-session --session=gnome
TryExec=/usr/bin/gnome-session
Type=Application
DesktopNames=GNOME
X-LightDM-DesktopName=GNOME
EOF

echo -e "${BLUE}Reiniciando o sistema...${RESET}"
reboot
