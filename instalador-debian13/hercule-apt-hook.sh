#!/usr/bin/env bash
# =====================================================================
#  HERCULE - enganche con apt
#  Lo invoca apt despues de 'apt update'. Segun /etc/hercule/update.conf
#  revisa el repositorio de Hercule y, si hay cambios, los trae.
#
#    auto  = actualiza Hercule en segundo plano si hay cambios (por defecto)
#    check = solo avisa en la salida de apt si hay novedades
#    off   = no hace nada
#
#  Nunca interrumpe ni hace fallar a apt (siempre termina con exito).
#  El Suinda @v@ - les petites cellules grises
# =====================================================================

# No depende de hercule-update instalado: si no esta, no hace nada.
command -v hercule-update >/dev/null 2>&1 || exit 0

MODO="auto"
# shellcheck disable=SC1091
[ -f /etc/hercule/update.conf ] && . /etc/hercule/update.conf 2>/dev/null
MODO="${HERCULE_APT_HOOK:-auto}"

LOG="/var/log/hercule-apt-update.log"

case "$MODO" in
  off)
    exit 0
    ;;

  check)
    # solo consulta el repo (git fetch); no toca apt ni aplica nada
    if salida="$(timeout 60 hercule-update --check 2>/dev/null)"; then
      if printf '%s' "$salida" | grep -q "actualizacion(es) disponible"; then
        echo "Hercule: hay cambios nuevos en el proyecto. Para aplicarlos: sudo hercule-update"
      fi
    fi
    ;;

  auto|*)
    # actualiza si hay cambios. Se lanza DESACOPLADO de apt (segundo plano)
    # para no bloquear apt ni chocar con sus locks: el update corre cuando
    # apt ya termino. El detalle queda en el log.
    if command -v systemd-run >/dev/null 2>&1; then
      systemd-run --quiet --collect \
        --unit="hercule-update-$(date +%s)" \
        --description="Actualizacion de Hercule disparada por apt" \
        /bin/bash -c "hercule-update >>'$LOG' 2>&1" 2>/dev/null \
        && echo "Hercule: revisando/aplicando actualizaciones del proyecto en segundo plano (log: $LOG)." \
        || setsid bash -c "hercule-update >>'$LOG' 2>&1" </dev/null >/dev/null 2>&1 &
    else
      # sin systemd: background clasico, desacoplado de la sesion de apt
      setsid bash -c "sleep 2; hercule-update >>'$LOG' 2>&1" </dev/null >/dev/null 2>&1 &
      echo "Hercule: revisando/aplicando actualizaciones del proyecto en segundo plano (log: $LOG)."
    fi
    ;;
esac

exit 0
