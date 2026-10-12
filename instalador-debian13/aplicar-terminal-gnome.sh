#!/usr/bin/env bash
# =====================================================================
#  HERCULE - aplicador de paleta de GNOME Terminal (corre como el usuario)
#  Lo instala el instalador y se ejecuta UNA vez en el primer login de
#  hercule (via autostart). Al terminar se autodesactiva.
# =====================================================================
set -u

# Paleta Hercule (16 colores, orden ANSI: 0-7 normales, 8-15 brillantes)
PALETTE="['#0A0E0A','#FF3B30','#39FF14','#FF6A00','#2D9CDB','#B86BFF','#1FA80B','#C8D6C8','#2A3A2A','#FF6B60','#7CFF5C','#FFA14D','#5FB8E8','#CF9BFF','#39FF14','#FFFFFF']"
BGCOLOR="#0A0E0A"
FGCOLOR="#C8D6C8"

# Modo oscuro y acento verde (por las dudas, aunque el sistema ya lo fija)
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface accent-color 'green' 2>/dev/null || true

  # GNOME Terminal: aplicar la paleta al perfil por defecto
  if gsettings list-schemas 2>/dev/null | grep -q "org.gnome.Terminal.ProfilesList"; then
    PROF="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null)"
    PROF="${PROF//\'/}"   # quitar comillas simples
    PROF="${PROF//\"/}"   # quitar comillas dobles
    if [ -n "$PROF" ]; then
      P="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROF}/"
      gsettings set "$P" use-theme-colors false            2>/dev/null || true
      gsettings set "$P" background-color "$BGCOLOR"        2>/dev/null || true
      gsettings set "$P" foreground-color "$FGCOLOR"        2>/dev/null || true
      gsettings set "$P" palette "$PALETTE"                 2>/dev/null || true
      gsettings set "$P" bold-color-same-as-fg true         2>/dev/null || true
      gsettings set "$P" cursor-colors-set true             2>/dev/null || true
      gsettings set "$P" cursor-background-color "#39FF14"  2>/dev/null || true
      gsettings set "$P" use-theme-transparency false       2>/dev/null || true
    fi
  fi
fi

# Autodesactivar: borrar el autostart para que no vuelva a correr
rm -f "$HOME/.config/autostart/hercule-tema.desktop" 2>/dev/null || true
exit 0
