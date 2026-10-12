#!/usr/bin/env bash
# HERCULE — banner de bienvenida de la terminal.
# Imprime la silueta de Hercule (ANSI) + una linea de identidad + info del sistema.
# Uso:  bash hercule-banner.sh   (o llamarlo desde ~/.bashrc)

HERC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
[ -f "$HERC_DIR/hercule-colors.sh" ] && . "$HERC_DIR/hercule-colors.sh"

# --- silueta ANSI ---
if [ -f "$HERC_DIR/hercule-banner.ans" ]; then
    cat "$HERC_DIR/hercule-banner.ans"
fi

# --- identidad ---
printf "\n"
printf "   ${E_GREEN}H E R C U L E${E_RESET}\n"
printf "   ${E_ORANGE}les petites cellules grises${E_RESET}\n"
printf "   ${E_TEXT}OSINT - Ciberinteligencia - Hacking Etico${E_RESET}\n\n"

# --- info del sistema (estilo neofetch-lite) ---
_line() { printf "   ${E_GREEN_DK}%-9s${E_RESET} ${E_TEXT}%s${E_RESET}\n" "$1" "$2"; }
_line "host"   "$(hostname 2>/dev/null)"
_line "user"   "$(whoami 2>/dev/null)"
_line "so"     "$( (. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-$(uname -s)}") )"
_line "kernel" "$(uname -r 2>/dev/null)"
_line "uptime" "$(uptime -p 2>/dev/null | sed 's/^up //')"
_line "fecha"  "$(date '+%Y-%m-%d %H:%M')"
printf "\n   ${E_GREEN_DK}----------------------------------------${E_RESET}\n"
printf "   ${E_TEXT}Entorno de investigacion listo. @v@${E_RESET}\n\n"
