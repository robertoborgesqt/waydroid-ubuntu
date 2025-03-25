#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Por favor, execute este script como root ou usando sudo."
  exit 1
fi

echo "Atualizando pacotes do sistema..."
apt update && apt upgrade -y

echo "Instalando pacotes necessários para Wayland..."
apt install -y wayland gnome-session-wayland

echo "Configurando o LightDM para suportar Wayland..."

LIGHTDM_CONFIG="/usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf"

if [ -f "$LIGHTDM_CONFIG" ]; then
  echo "Editando $LIGHTDM_CONFIG..."
  sed -i 's/session-wrapper=\/etc\/X11\/Xsession/session-wrapper=\/etc\/wayland-session/' "$LIGHTDM_CONFIG"
else
  echo "Criando configuração do LightDM..."
  cat <<EOF >"$LIGHTDM_CONFIG"
[Seat:*]
allow-guest=false
session-wrapper=/etc/wayland-session
EOF
fi

echo "Criando arquivo de sessão para Wayland..."
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

echo "Reiniciando o sistema..."
reboot

