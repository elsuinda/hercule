#!/usr/bin/env bash
# =====================================================================
#  HERCULE - enganche de autoactualizacion con APT
#  Lo invoca un hook de apt tras 'apt update'. Revisa el repositorio de
#  Hercule y, segun el modo configurado, aplica o avisa los cambios.
#  Es liviano y NUNCA interrumpe ni hace fallar a apt (siempre exit 0).
#
#  Modo en /etc/hercule/autoupdate.conf (variable MODO):
#     auto   aplica los cambios de Hercule en segundo plano (por defecto)
#     check  solo avisa en la salida de apt; aplicas con 'sudo hercule-update'
#     off    no hace nada
#
#  SEGURIDAD: 'auto' ejecuta codigo del repositorio como root sin
#  supervision. En equipos sensibles conviene 'check' u 'off' y aplicar a
#  mano tras revisar los cambios. La copia en /opt/hercule debe pertenecer
#  a root y no ser escribible por el usuario (el instalador lo garantiza).
#  El Suinda @v@ - les petites cellules grises
# =====================================================================
set -u

REPO="${HERCULE_REPO_DIR:-/opt/hercule}"
CONF="${HERCULE_AUTOUPDATE_CONF:-/etc/hercule/autoupdate.conf}"
STAMP="${HERCULE_AUTOUPDATE_STAMP:-/var/lib/hercule/last-autocheck}"
LOG="${HERCULE_AUTOUPDATE_LOG:-/var/log/hercule-autoupdate.log}"
MIN_INTERVALO="${HERCULE_AUTOUPDATE_INTERVALO:-3600}"   # no revisar mas de 1 vez/hora
MODO="auto"

# nunca romper apt: toda salida es exito
_fin(){ exit 0; }

# precondiciones: root, repo git presente, git y hercule-update disponibles
[ "$(id -u)" -eq 0 ] || _fin
[ -d "$REPO/.git" ] || _fin
command -v git >/dev/null 2>&1 || _fin
command -v hercule-update >/dev/null 2>&1 || _fin

# cargar modo desde la config (solo se toma la variable MODO)
if [ -f "$CONF" ]; then
  _m="$(grep -E '^[[:space:]]*MODO=' "$CONF" 2>/dev/null | tail -1 | cut -d= -f2 | tr -d '[:space:]"'"'"'')"
  [ -n "$_m" ] && MODO="$_m"
fi
case "$MODO" in auto|check|off) ;; *) MODO="auto" ;; esac
[ "$MODO" = "off" ] && _fin

# throttle: evitar revisar en cada 'apt update'
ahora="$(date +%s 2>/dev/null || echo 0)"
if [ -f "$STAMP" ]; then
  ult="$(cat "$STAMP" 2>/dev/null || echo 0)"
  case "$ult" in ''|*[!0-9]*) ult=0 ;; esac
  [ $((ahora - ult)) -lt "$MIN_INTERVALO" ] && _fin
fi
mkdir -p "$(dirname "$STAMP")" 2>/dev/null || true
echo "$ahora" > "$STAMP" 2>/dev/null || true

# consultar el remoto sin tocar nada local
git config --global --add safe.directory "$REPO" 2>/dev/null || true
git -C "$REPO" fetch --quiet 2>/dev/null || _fin
LOCAL="$(git -C "$REPO" rev-parse HEAD 2>/dev/null)" || _fin
UP="$(git -C "$REPO" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo origin/main)"
REMOTO="$(git -C "$REPO" rev-parse "$UP" 2>/dev/null || echo "$LOCAL")"

# al dia: nada que hacer
[ "$LOCAL" = "$REMOTO" ] && _fin

N="$(git -C "$REPO" rev-list --count "HEAD..$UP" 2>/dev/null || echo '?')"
echo "Hercule: hay $N actualizacion(es) del proyecto disponibles."

if [ "$MODO" = "check" ]; then
  echo "Hercule: aplicalas con  sudo hercule-update  (modo 'check' en $CONF)."
  _fin
fi

# modo auto: aplicar DESACOPLADO del lock de apt (el hook corre dentro de apt).
# systemd-run --no-block programa el servicio y vuelve de inmediato; los
# apt-get internos esperan el lock (DPkg::Lock::Timeout, fijado por el hook).
lanzado=0
if command -v systemd-run >/dev/null 2>&1; then
  if systemd-run --no-block --quiet --collect \
       --unit="hercule-autoupdate-$ahora" \
       --description="Autoactualizacion de Hercule disparada por apt" \
       /usr/local/bin/hercule-update >/dev/null 2>&1; then
    echo "Hercule: actualizacion lanzada en segundo plano."
    echo "Hercule: progreso con  journalctl -u hercule-autoupdate-$ahora"
    lanzado=1
  fi
fi
if [ "$lanzado" -eq 0 ]; then
  # sin systemd (o si fallo): segundo plano clasico, desacoplado de apt
  setsid bash -c "hercule-update >>'$LOG' 2>&1" </dev/null >/dev/null 2>&1 &
  echo "Hercule: actualizacion lanzada en segundo plano (log: $LOG)."
fi
_fin
