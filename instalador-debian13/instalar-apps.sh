#!/usr/bin/env bash
# =====================================================================
#  HERCULE - Instalador de aplicaciones propias
#  Clona desde GitHub las herramientas propias de Hercule y las instala
#  en la estacion de trabajo, dejandolas disponibles como comando y como
#  acceso directo en el menu de aplicaciones.
#
#  Apps incluidas:
#    - SEPTEM    (proyecto_aureo)            -> comando: septem start | stop
#    - LA RATA   (la_rata)                   -> comando: larata start | stop
#    - BLACKCAT  (blackcat-osint-reporter)   -> comando: blackcat start | stop
#
#  Uso:
#    sudo ./instalar-apps.sh              instala todas las apps
#    sudo ./instalar-apps.sh --dry-run    simula, no instala
#    sudo ./instalar-apps.sh septem       instala solo esa app
#  Autor: Miguel - proyecto Hercule.
# =====================================================================
set -euo pipefail

APPS_DIR="/opt/hercule-apps"
LOGFILE="/var/log/hercule-apps.log"
DRY_RUN=0

# Catalogo de apps:  nombre|repo_git|script_instalacion
APPS=(
  "septem|https://github.com/elsuinda/proyecto_aureo|install.sh"
  "larata|https://github.com/elsuinda/la_rata|install.sh"
  "blackcat|https://github.com/elsuinda/blackcat-osint-reporter|install.sh"
)

# ---------- colores ----------
G="\e[38;2;57;255;20m"; D="\e[38;2;31;168;11m"; O="\e[38;2;255;106;0m"
T="\e[38;2;200;214;200m"; R="\e[0m"
ok(){ printf "  ${G}[ ok ]${R} ${T}%b${R}\n" "$1"; }
info(){ printf "  ${D}[ .. ]${R} ${T}%b${R}\n" "$1"; }
warn(){ printf "  ${O}[ !! ]${R} ${O}%b${R}\n" "$1"; }
err(){ printf "  ${O}[ XX ]${R} ${O}%b${R}\n" "$1" >&2; }
step(){ printf "\n${D}--[ ${G}%b${D} ]----------------------------------------${R}\n" "$1"; }

# ---------- argumentos ----------
FILTRO=""
for a in "$@"; do case "$a" in
  --dry-run) DRY_RUN=1 ;;
  --help|-h) echo "Uso: sudo $0 [--dry-run] [nombre-app]"; exit 0 ;;
  -*) err "argumento desconocido: $a"; exit 2 ;;
  *) FILTRO="$a" ;;
esac; done

# ---------- root ----------
if [ "$(id -u)" -ne 0 ]; then
  err "este script debe ejecutarse como root."
  info "volve a ejecutarlo asi:  sudo $0 $*"
  exit 1
fi
[ "$DRY_RUN" -eq 0 ] && { touch "$LOGFILE" 2>/dev/null || true; exec > >(tee -a "$LOGFILE") 2>&1; }

printf "\n   ${G}H E R C U L E${R}  ${O}- aplicaciones propias -${R}\n\n"
[ "$DRY_RUN" -eq 1 ] && warn "modo simulacion (--dry-run): no se instala nada."

# ---------- dependencias minimas ----------
if [ "$DRY_RUN" -eq 0 ]; then
  command -v git >/dev/null 2>&1 || apt-get install -y -q git >/dev/null 2>&1 || true
  command -v python3 >/dev/null 2>&1 || apt-get install -y -q python3 >/dev/null 2>&1 || true
  # tkinter y venv son necesarios para apps GUI en Python
  apt-get install -y -q python3-venv python3-tk >/dev/null 2>&1 || \
    warn "no se pudieron instalar python3-venv/python3-tk (revisa si ya estan)."
fi

mkdir -p "$APPS_DIR" 2>/dev/null || true

instalar_app() {
  local nombre="$1" repo="$2" script="$3"
  step "App: $nombre"
  local dest="$APPS_DIR/$nombre"
  if [ "$DRY_RUN" -eq 1 ]; then
    info "[dry] git clone $repo -> $dest"
    info "[dry] ejecutar $dest/$script (instalacion a nivel sistema)"
    return 0
  fi
  # clonar o actualizar
  if [ -d "$dest/.git" ]; then
    info "actualizando repo existente..."
    git -C "$dest" pull --ff-only >/dev/null 2>&1 || warn "no se pudo actualizar; se usa lo existente."
  else
    info "clonando $repo ..."
    if ! git clone --depth 1 "$repo" "$dest" >/dev/null 2>&1; then
      err "fallo el clon de $nombre; se omite."
      return 1
    fi
  fi
  # ejecutar el instalador propio de la app (a nivel sistema por correr como root)
  if [ -f "$dest/$script" ]; then
    chmod +x "$dest/$script" 2>/dev/null || true
    if ( cd "$dest" && bash "$script" ); then
      ok "$nombre instalado (comando y acceso directo disponibles)."
    else
      warn "el instalador de $nombre devolvio un error; revisa el log."
    fi
  else
    warn "no se encontro $script en $nombre; se omite la instalacion."
  fi

  # documentacion de uso por categoria: copiar la ficha de la app a
  # Documents/Hercule/<categoria>/apps/<app>.md del usuario de trabajo
  documentar_app "$dest"
}

# usuario de trabajo cuyos Documents reciben las fichas (por defecto 'hercule')
USUARIO_DOCS="${USUARIO_DOCS:-hercule}"

_documents_dir() {
  local u="$1" home docs
  home="$(getent passwd "$u" 2>/dev/null | cut -d: -f6)"
  [ -z "$home" ] && return 1
  docs="$(sudo -u "$u" bash -lc 'xdg-user-dir DOCUMENTS 2>/dev/null' 2>/dev/null || true)"
  if [ -z "$docs" ] || [ "$docs" = "$home" ]; then
    docs=""
    for d in "$home/Documents" "$home/Documentos"; do [ -d "$d" ] && docs="$d" && break; done
  fi
  [ -z "$docs" ] && docs="$home/Documents"
  echo "$docs"
}

documentar_app() {
  local dest="$1"
  local conf="$dest/hercule-app.conf"
  [ -f "$conf" ] || return 0
  # leer metadatos de forma segura (solo CLAVE=valor conocidas)
  local CATEGORIA NOMBRE FICHA
  CATEGORIA="$(grep -E '^CATEGORIA=' "$conf" | head -1 | cut -d= -f2-)"
  NOMBRE="$(grep -E '^NOMBRE=' "$conf" | head -1 | cut -d= -f2-)"
  FICHA="$(grep -E '^FICHA=' "$conf" | head -1 | cut -d= -f2-)"
  [ -z "$CATEGORIA" ] && CATEGORIA="utilidades"
  [ -z "$FICHA" ] && FICHA="USO-HERCULE.md"
  if [ ! -f "$dest/$FICHA" ]; then
    warn "la app no trae ficha de uso ($FICHA); se omite la documentacion."
    return 0
  fi
  if ! id "$USUARIO_DOCS" &>/dev/null; then
    info "usuario $USUARIO_DOCS inexistente; la ficha de uso no se copia (instala Hercule primero)."
    return 0
  fi
  local docs destdir
  docs="$(_documents_dir "$USUARIO_DOCS")" || return 0
  destdir="$docs/Hercule/$CATEGORIA/apps"
  if [ "$DRY_RUN" -eq 1 ]; then
    info "[dry] copiar ficha de uso -> $destdir/$(basename "$dest").md"
    return 0
  fi
  mkdir -p "$destdir"
  cp -f "$dest/$FICHA" "$destdir/$(basename "$dest").md"
  chown -R "$USUARIO_DOCS:$USUARIO_DOCS" "$docs/Hercule" 2>/dev/null || true
  ok "documentacion de uso agregada en categoria '$CATEGORIA' ($destdir)."
}

for entry in "${APPS[@]}"; do
  IFS='|' read -r nombre repo script <<< "$entry"
  [ -n "$FILTRO" ] && [ "$FILTRO" != "$nombre" ] && continue
  instalar_app "$nombre" "$repo" "$script"
done

step "Final"
ok "aplicaciones propias procesadas."
info "ej: 'septem start' para abrir SEPTEM, o buscalo en el menu de aplicaciones."
[ "$DRY_RUN" -eq 0 ] && info "resultado guardado en $LOGFILE"
printf "  ${D}-- Hercule @v@   |   les petites cellules grises${R}\n\n"
