#!/usr/bin/env bash
# =====================================================================
#  HERCULE — personalizacion de la terminal (prompt + banner + alias)
#  Para cargarlo: agregar al final de ~/.bashrc:
#      source /ruta/a/hercule/terminal/hercule.bashrc
#  (el script de Debian 13 de la Fase D lo instala automaticamente)
# =====================================================================

HERC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
[ -f "$HERC_DIR/hercule-colors.sh" ] && . "$HERC_DIR/hercule-colors.sh"

# --- banner al abrir una terminal interactiva ---
# (comentar la linea siguiente si no se quiere el banner en cada terminal)
case "$-" in
  *i*) [ -f "$HERC_DIR/hercule-banner.sh" ] && bash "$HERC_DIR/hercule-banner.sh" ;;
esac

# --- rama de git para el prompt (si estamos en un repo) ---
_herc_git() {
  local b
  b=$(git branch --show-current 2>/dev/null) || return
  [ -n "$b" ] && printf " %s" "$b"
}

# --- PROMPT (PS1): dos lineas, estilo detective-hacker ---
#   ┌─[ usuario@host ]─[ ~/ruta ] (rama)
#   └─▶
PROMPT_COMMAND='__herc_ps1'
__herc_ps1() {
  local g="\[\e[38;2;57;255;20m\]" d="\[\e[38;2;31;168;11m\]"
  local o="\[\e[38;2;255;106;0m\]" t="\[\e[38;2;200;214;200m\]" x="\[\e[0m\]"
  PS1="${d}┌─[ ${g}\u${t}@${g}\h ${d}]─[ ${o}\w ${d}]${o}\$(_herc_git)${x}\n"
  PS1+="${d}└─${g}▶${x} "
}

# --- alias utiles para investigacion / OSINT (podes ampliarlos) ---
alias ll='ls -lah --color=auto'
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn'
alias myip='curl -s https://ifconfig.me; echo'
alias hgrep='grep --color=auto -rniI'
alias hhelp='echo -e "${E_GREEN}Hercule${E_RESET}: ll, ports, myip, hgrep. Banner: bash \$HERC_DIR/hercule-banner.sh"'

# --- less/grep con color ---
export GREP_COLORS='ms=38;2;57;255;20'
export LESS='-R'
