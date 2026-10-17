#!/usr/bin/env bash
# =====================================================================
#  HERCULE - enganche de autoactualizacion con APT
#  Lo invoca un hook de apt tras 'apt update'. Es liviano y NUNCA
#  interrumpe apt: si el repositorio de Hercule tiene cambios, lanza
#  'hercule-update' de forma desacoplada (fuera del lock de apt), para
#  que la actualizacion de Hercule acompane a la del sistema operativo.
#
#  Comportamiento configurable en /etc/hercule/autoupdate.conf:
#     AUTO_APPLY=1   -> aplica los cambios automaticamente (por defecto)
#     AUTO_APPLY=0   -> solo avisa; se aplican con 'sudo hercule-update'
#  Autor: Miguel - proyecto Hercule.
# =====================================================================
set -u

REPO="${HERCULE_REPO_DIR:-/opt/hercule}"
CONF="${HERCULE_AUTOUPDATE_CONF:-/etc/hercule/autoupdate.conf}"
STAMP="${HERCULE_AUTOUPDATE_STAMP:-/var/lib/hercule/last-autocheck}"
MIN_INTERVALO="${HERCULE_AUTOUPDATE_INTERVALO:-3600}"   # no revisar mas de 1 vez/hora
AUTO_APPLY=1

# nunca romper apt: cualquier salida es exito
_fin(){ exit 0; }

# solo root; repo git presente; git disponible
[ "$(id -u)" -eq 0 ] || _fin
[ -d "$REPO/.git" ] || _fin
command -v git >/dev/null 2>&1 || _fin

# cargar config (si existe)
[ -f "$CONF" ] && . "$CONF" 2>/dev/null

# throttle: evitar revisar en cada 'apt update'
ahora="$(date +%s 2>/dev/null || echo 0)"
if [ -f "$STAMP" ]; then
  ult="$(cat "$STAMP" 2>/dev/null || echo 0)"
  [ $((ahora - ult)) -lt "$MIN_INTERVALO" ] && _fin
fi
mkdir -p "$(dirname "$STAMP")" 2>/dev/null || true
echo "$ahora" > "$STAMP" 2>/dev/null || true

# consultar el remoto (sin tocar nada local)
git config --global --add safe.directory "$REPO" 2>/dev/null || true
git -C "$REPO" fetch --quiet 2>/dev/null || _fin
LOCAL="$(git -C "$REPO" rev-parse HEAD 2>/dev/null)" || _fin
UP="$(git -C "$REPO" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo origin/main)"
REMOTO="$(git -C "$REPO" rev-parse "$UP" 2>/dev/null || echo "$LOCAL")"

# al dia: nada que hacer
[ "$LOCAL" = "$REMOTO" ] && _fin

N="$(git -C "$REPO" rev-list --count "HEAD..$UP" 2>/dev/null || echo '?')"
echo "Hercule: hay $N actualizacion(es) del proyecto disponibles."

if [ "${AUTO_APPLY:-1}" != "1" ]; then
  echo "Hercule: aplicalas con  sudo hercule-update  (auto-aplicar desactivado en $CONF)."
  _fin
fi

# aplicar DESACOPLADO del lock de apt (el hook corre dentro de apt):
#   systemd-run --no-block programa el servicio y vuelve de inmediato,
#   asi apt no se bloquea; los apt-get internos esperan el lock
#   (DPkg::Lock::Timeout, fijado por el hook de apt de Hercule).
if command -v systemd-run >/dev/null 2>&1; then
  if systemd-run --no-block --quiet --collect \
       --unit="hercule-autoupdate-$ahora" \
       /usr/local/bin/hercule-update >/dev/null 2>&1; then
    echo "Hercule: actualizacion lanzada en segundo plano."
    echo "Hercule: segui el progreso con  journalctl -u hercule-autoupdate-$ahora"
  else
    echo "Hercule: no se pudo lanzar la actualizacion automatica; corre  sudo hercule-update"
  fi
else
  nohup /usr/local/bin/hercule-update >>/var/log/hercule-autoupdate.log 2>&1 &
  echo "Hercule: actualizacion lanzada en segundo plano (ver /var/log/hercule-autoupdate.log)."
fi
_fin
