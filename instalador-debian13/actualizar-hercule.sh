#!/usr/bin/env bash
# =====================================================================
#  HERCULE - actualizador
#  Trae los ultimos cambios del repositorio y los re-aplica al sistema
#  ya personalizado, SIN tocar el trabajo del usuario (casos, informes).
#
#  Se instala como el comando  'hercule-update'  y opera sobre la copia
#  del repo que vive en /opt/hercule.
#
#  Uso:
#    sudo hercule-update            actualiza codigo + re-aplica + apps
#    sudo hercule-update --check    solo informa si hay actualizaciones
#    sudo hercule-update --tools    ademas reinstala/actualiza el toolkit
#    sudo hercule-update --force    re-aplica aunque ya este al dia
#    sudo hercule-update --dry-run  simula, no cambia nada
#  Autor: Miguel - proyecto Hercule.
# =====================================================================
set -euo pipefail

REPO="${HERCULE_REPO_DIR:-/opt/hercule}"
INST="$REPO/instalador-debian13"
REMOTO_DEFECTO="https://github.com/elsuinda/hercule"
VERFILE="$REPO/.hercule-version"

DRY_RUN=0; CHECK=0; TOOLS=0; FORCE=0; REENTRY=0

# ---------- colores ----------
G="\e[38;2;57;255;20m"; D="\e[38;2;31;168;11m"; O="\e[38;2;255;106;0m"
T="\e[38;2;200;214;200m"; R="\e[0m"
ok(){ printf "  ${G}[ ok ]${R} ${T}%b${R}\n" "$1"; }
info(){ printf "  ${D}[ .. ]${R} ${T}%b${R}\n" "$1"; }
warn(){ printf "  ${O}[ !! ]${R} ${O}%b${R}\n" "$1"; }
err(){ printf "  ${O}[ XX ]${R} ${O}%b${R}\n" "$1" >&2; }
step(){ printf "\n${D}--[ ${G}%b${D} ]----------------------------------------${R}\n" "$1"; }

ayuda(){ cat <<EOF
Actualizador de Hercule.

  sudo hercule-update            trae cambios y re-aplica (personalizacion + apps)
  sudo hercule-update --check    solo informa si hay actualizaciones, no aplica
  sudo hercule-update --tools    ademas actualiza el toolkit OSINT/forense
  sudo hercule-update --force    re-aplica aunque ya estes al dia
  sudo hercule-update --dry-run  simula: muestra que haria, sin cambiar nada

Opera sobre $REPO. Debe ejecutarse como root (o con sudo).
EOF
}

# ---------- argumentos ----------
PASS_FLAGS=()
for a in "$@"; do case "$a" in
  --check) CHECK=1 ;;
  --tools) TOOLS=1; PASS_FLAGS+=(--tools) ;;
  --force) FORCE=1; PASS_FLAGS+=(--force) ;;
  --dry-run) DRY_RUN=1; PASS_FLAGS+=(--dry-run) ;;
  --reentry) REENTRY=1 ;;
  --help|-h) ayuda; exit 0 ;;
  *) err "argumento desconocido: $a"; ayuda; exit 2 ;;
esac; done

# ---------- root ----------
if [ "$(id -u)" -ne 0 ]; then
  err "este comando debe ejecutarse como root."
  info "volve a ejecutarlo asi:  sudo hercule-update $*"
  exit 1
fi

# ---------- repo presente? ----------
if [ ! -d "$INST" ]; then
  err "no se encontro la copia del proyecto en $REPO."
  info "parece que Hercule no se instalo con soporte de actualizacion."
  info "reinstala desde el repo para habilitarlo:  $REMOTO_DEFECTO"
  exit 1
fi

printf "\n   ${G}H E R C U L E${R}  ${O}- actualizador -${R}\n"
printf "   ${O}les petites cellules grises${R}\n\n"
[ "$DRY_RUN" -eq 1 ] && warn "modo simulacion (--dry-run): no se aplica nada."

# =====================================================================
#  FASE 1: traer cambios del repositorio (solo si no es el re-arranque)
# =====================================================================
if [ "$REENTRY" -eq 0 ]; then
  step "Revisando el repositorio"
  if ! command -v git >/dev/null 2>&1; then
    info "instalando git..."; [ "$DRY_RUN" -eq 0 ] && apt-get install -y -q git >/dev/null 2>&1 || true
  fi
  # evitar el aviso de 'dubious ownership' al correr como root sobre /opt/hercule
  git config --global --add safe.directory "$REPO" 2>/dev/null || true

  if [ ! -d "$REPO/.git" ]; then
    warn "$REPO no es un repositorio git; no se puede actualizar automaticamente."
    info "reinstala desde $REMOTO_DEFECTO para habilitar la actualizacion."
    exit 1
  fi

  RAMA="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
  UPSTREAM="$(git -C "$REPO" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "origin/$RAMA")"

  info "consultando origin..."
  if ! git -C "$REPO" fetch --quiet 2>/dev/null; then
    warn "no se pudo contactar al repositorio remoto (sin internet?)."
    info "verifica la conexion y volve a intentar."
    exit 1
  fi

  LOCAL="$(git -C "$REPO" rev-parse HEAD 2>/dev/null)"
  REMOTO="$(git -C "$REPO" rev-parse "$UPSTREAM" 2>/dev/null || echo "$LOCAL")"
  N_CAMBIOS="$(git -C "$REPO" rev-list --count "HEAD..$UPSTREAM" 2>/dev/null || echo 0)"

  if [ "$LOCAL" = "$REMOTO" ]; then
    ok "ya estas en la ultima version (${LOCAL:0:8})."
    if [ "$CHECK" -eq 1 ]; then exit 0; fi
    if [ "$FORCE" -eq 0 ]; then
      info "no hay nada nuevo que traer. Usa --force si queres re-aplicar igual."
      exit 0
    fi
    info "--force: se re-aplicara la personalizacion aunque no haya cambios."
  else
    warn "hay $N_CAMBIOS actualizacion(es) disponible(s):"
    git -C "$REPO" log --oneline --no-decorate "HEAD..$UPSTREAM" 2>/dev/null \
      | sed 's/^/        /' | head -20
    if [ "$CHECK" -eq 1 ]; then
      info "(solo --check: no se aplico nada). Corre 'sudo hercule-update' para actualizar."
      exit 0
    fi
  fi

  # traer los cambios
  if [ "$DRY_RUN" -eq 1 ]; then
    info "[dry] git pull --ff-only  ($UPSTREAM)"
    info "[dry] re-aplicar personalizacion (instalar-hercule.sh --update)"
    info "[dry] actualizar apps (instalar-apps.sh)"
    [ "$TOOLS" -eq 1 ] && info "[dry] actualizar toolkit (instalar-herramientas.sh)"
    exit 0
  fi
  step "Trayendo cambios"
  if [ "$LOCAL" != "$REMOTO" ]; then
    if git -C "$REPO" pull --ff-only --quiet; then
      ok "codigo actualizado a ${REMOTO:0:8}."
    else
      err "no se pudo hacer 'git pull --ff-only' (cambios locales o historial divergente)."
      info "revisa el estado con:  sudo git -C $REPO status"
      exit 1
    fi
  fi
  # re-arrancar con la version recien bajada del propio actualizador
  exec bash "$INST/actualizar-hercule.sh" --reentry "${PASS_FLAGS[@]}"
fi

# =====================================================================
#  FASE 2 (re-arranque): re-aplicar los cambios ya descargados
# =====================================================================
step "Re-aplicando personalizacion"
# instalar-hercule.sh --update: re-aplica tema, modo oscuro, paleta y guias,
# NO crea/borra usuarios ni pregunta por tools/apps, y preserva los casos.
bash "$INST/instalar-hercule.sh" --update || warn "la re-aplicacion devolvio un aviso; revisa arriba."

step "Actualizando apps propias (SEPTEM, LA RATA, BLACKCAT)"
# instalar-apps.sh ya hace 'git pull' de cada app y reinstala.
bash "$INST/instalar-apps.sh" || warn "la actualizacion de apps devolvio un aviso; revisa arriba."

if [ "$TOOLS" -eq 1 ]; then
  step "Actualizando toolkit OSINT/forense"
  bash "$INST/instalar-herramientas.sh" --all || warn "la actualizacion del toolkit devolvio un aviso."
else
  info "el toolkit no se toca (usa 'sudo hercule-update --tools' para actualizarlo tambien)."
fi

# registrar version instalada
COMMIT="$(git -C "$REPO" rev-parse HEAD 2>/dev/null || echo desconocido)"
FECHA="$(date '+%Y-%m-%d %H:%M:%S')"
printf "commit=%s\nfecha=%s\n" "$COMMIT" "$FECHA" > "$VERFILE" 2>/dev/null || true

step "Final"
ok "Hercule actualizado a ${COMMIT:0:8}."
info "los cambios de terminal/escritorio se veran al reabrir la sesion de hercule."
printf "  ${D}-- Hercule @v@   |   les petites cellules grises${R}\n\n"
