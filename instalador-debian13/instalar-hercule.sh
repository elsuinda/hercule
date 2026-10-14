#!/usr/bin/env bash
# =====================================================================
#  HERCULE - Instalador de personalizacion para Debian 13 (trixie)
#  Fase D del proyecto Hercule.
#
#  Que hace:
#    1. Exige ejecutarse como root (o con sudo).
#    2. Crea el usuario de trabajo (login: hercule / nombre: Hercule).
#    3. Instala el tema de terminal Hercule (banner, prompt, colores).
#    4. Al final pregunta si eliminar todos los otros usuarios o dejarlos.
#    5. Avisa el resultado e indica como cambiar la contrasena.
#
#  Uso:
#    sudo ./instalar-hercule.sh            # instalacion normal
#    sudo ./instalar-hercule.sh --dry-run  # simula, no toca nada
#    ./instalar-hercule.sh --help          # ayuda
#
#  Autor: Miguel - proyecto Hercule.
# =====================================================================

set -euo pipefail

# ---------------------------------------------------------------------
# Parametros
# ---------------------------------------------------------------------
HERCULE_USER="hercule"          # login (minuscula por convencion de Linux)
HERCULE_NAME="Hercule"          # nombre completo (GECOS)
HERCULE_PASS="hercule"          # contrasena por defecto = login (minuscula). Se DEBE cambiar luego.
LOGFILE="/var/log/hercule-install.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="$SCRIPT_DIR/../terminal"     # tema de terminal del proyecto
ESC_SRC="$SCRIPT_DIR/../escritorio"     # fondos / escritorio del proyecto
APLICADOR="$SCRIPT_DIR/aplicar-terminal-gnome.sh"  # aplicador de paleta (GNOME Terminal)
PROYECTO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"       # raiz del repo local
REPO_SIS="/opt/hercule"                 # copia del repo en el sistema (para actualizar)
REMOTO_DEFECTO="https://github.com/elsuinda/hercule"
DRY_RUN=0
MODO_UPDATE=0                           # 1 = re-aplicar personalizacion (hercule-update)

# ---------------------------------------------------------------------
# Colores (estetica Hercule - mensajes sin tildes)
# ---------------------------------------------------------------------
G="\e[38;2;57;255;20m"      # verde fosforo - lo importante
D="\e[38;2;31;168;11m"      # verde senal   - bordes/dim
O="\e[38;2;255;106;0m"      # naranja       - acentos/advertencias
T="\e[38;2;200;214;200m"    # texto
R="\e[0m"

ok()   { printf "  ${G}[ ok ]${R} ${T}%b${R}\n" "$1"; }
info() { printf "  ${D}[ .. ]${R} ${T}%b${R}\n" "$1"; }
warn() { printf "  ${O}[ !! ]${R} ${O}%b${R}\n" "$1"; }
err()  { printf "  ${O}[ XX ]${R} ${O}%b${R}\n" "$1" >&2; }
step() { printf "\n${D}--[ ${G}%b${D} ]----------------------------------------${R}\n" "$1"; }

run() {  # ejecuta, o solo muestra si --dry-run
  if [ "$DRY_RUN" -eq 1 ]; then
    printf "  ${O}[dry]${R} ${T}%s${R}\n" "$*"
  else
    "$@"
  fi
}

banner() {
  if [ -f "$THEME_SRC/hercule-banner.ans" ]; then
    cat "$THEME_SRC/hercule-banner.ans"
  fi
  printf "\n   ${G}H E R C U L E${R}  ${O}- instalador Debian 13 -${R}\n"
  printf "   ${O}les petites cellules grises${R}\n\n"
}

ayuda() {
  cat <<EOF
Instalador de personalizacion Hercule para Debian 13.

  sudo ./instalar-hercule.sh            instalacion normal
  sudo ./instalar-hercule.sh --dry-run  simula sin aplicar cambios
  sudo ./instalar-hercule.sh --update   re-aplica personalizacion (lo usa hercule-update)
  ./instalar-hercule.sh --help          esta ayuda

Debe ejecutarse como root (o con sudo).
EOF
}

# ---------------------------------------------------------------------
# Argumentos
# ---------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --update) MODO_UPDATE=1 ;;
    --help|-h) ayuda; exit 0 ;;
    *) err "argumento desconocido: $arg"; ayuda; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------
# 1. Exigir root
# ---------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
  err "este script debe ejecutarse como root."
  info "volve a ejecutarlo asi:  sudo $0 $*"
  exit 1
fi

# A partir de aca ya somos root: registramos todo en el log.
if [ "$DRY_RUN" -eq 0 ]; then
  touch "$LOGFILE" 2>/dev/null || true
  exec > >(tee -a "$LOGFILE") 2>&1
fi

banner
[ "$DRY_RUN" -eq 1 ] && warn "modo simulacion (--dry-run): no se aplican cambios reales."
[ "$MODO_UPDATE" -eq 1 ] && info "modo actualizacion: re-aplica personalizacion y guias; no toca usuarios ni casos."
info "inicio: $(date '+%Y-%m-%d %H:%M:%S')"

# ---------------------------------------------------------------------
# 2. Crear el usuario Hercule
# ---------------------------------------------------------------------
step "Usuario de trabajo"
if id "$HERCULE_USER" &>/dev/null; then
  warn "el usuario $HERCULE_USER ya existe; no se toca su contrasena ni sus datos."
  USER_YA_EXISTIA=1
else
  USER_YA_EXISTIA=0
  run useradd -m -s /bin/bash -c "$HERCULE_NAME" "$HERCULE_USER"
  if [ "$DRY_RUN" -eq 0 ]; then
    echo "${HERCULE_USER}:${HERCULE_PASS}" | chpasswd
    # Seguridad: la contrasena por defecto es debil y conocida; forzar el cambio
    # obligatorio en el primer inicio de sesion.
    chage -d 0 "$HERCULE_USER" 2>/dev/null || true
  else
    printf "  ${O}[dry]${R} ${T}set password por defecto + forzar cambio en 1er login (chage -d 0)${R}\n"
  fi
  run usermod -aG sudo "$HERCULE_USER"
  ok "usuario $HERCULE_USER creado (nombre: $HERCULE_NAME) y agregado al grupo sudo."
  warn "la contrasena por defecto es debil; el sistema pedira cambiarla en el 1er login."
fi

HERCULE_HOME="$(getent passwd "$HERCULE_USER" 2>/dev/null | cut -d: -f6 || true)"
HERCULE_HOME="${HERCULE_HOME:-/home/$HERCULE_USER}"

# ---------------------------------------------------------------------
# 3. Instalar el tema de terminal Hercule
# ---------------------------------------------------------------------
step "Tema de terminal"
if [ -d "$THEME_SRC" ]; then
  DEST="$HERCULE_HOME/.hercule/terminal"
  run mkdir -p "$DEST"
  if [ "$DRY_RUN" -eq 0 ]; then
    cp -r "$THEME_SRC/." "$DEST/" 2>/dev/null || true
    # cargar el tema en el .bashrc del usuario (si no esta ya)
    BRC="$HERCULE_HOME/.bashrc"
    LINE="source \"\$HOME/.hercule/terminal/hercule.bashrc\""
    touch "$BRC"
    grep -qF "$LINE" "$BRC" || printf "\n# --- Hercule ---\n%s\n" "$LINE" >> "$BRC"
    chown -R "$HERCULE_USER:$HERCULE_USER" "$HERCULE_HOME/.hercule" "$BRC"
  fi
  ok "tema de terminal instalado en $DEST"
  info "se cargara solo al abrir una terminal como $HERCULE_USER."
else
  warn "no se encontro el tema de terminal en $THEME_SRC; se omite este paso."
  info "corre el script desde la carpeta del proyecto para instalarlo."
fi

# ---------------------------------------------------------------------
# 3b. Tema del sistema: modo oscuro + paleta Hercule + fondo
#     (por defecto; se aplica a nivel sistema con dconf y GTK)
# ---------------------------------------------------------------------
step "Modo oscuro + paleta Hercule (todo el sistema)"

# --- copiar fondos al home del usuario ---
FONDO_DEST="$HERCULE_HOME/.hercule/fondos"
FONDO_PRIN="$FONDO_DEST/hercule-fondo-1920x1080.png"
FONDO_UC="$FONDO_DEST/hercule-undercover-slate-1920x1080.png"
if [ -d "$ESC_SRC" ]; then
  run mkdir -p "$FONDO_DEST"
  if [ "$DRY_RUN" -eq 0 ]; then
    cp "$ESC_SRC/fondos/"*.png "$FONDO_DEST/" 2>/dev/null || true
    cp "$ESC_SRC/undercover/"*.png "$FONDO_DEST/" 2>/dev/null || true
    chown -R "$HERCULE_USER:$HERCULE_USER" "$FONDO_DEST" 2>/dev/null || true
  fi
  ok "fondos copiados en $FONDO_DEST"
else
  warn "no se encontro la carpeta escritorio/ en $ESC_SRC; se omiten los fondos."
fi

# --- dconf: defaults de sistema (modo oscuro, acento verde, fondo) ---
if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p /etc/dconf/profile /etc/dconf/db/local.d
  cat > /etc/dconf/profile/user <<'EOF'
user-db:user
system-db:local
EOF
  cat > /etc/dconf/db/local.d/01-hercule <<EOF
# Hercule - tema de sistema (modo oscuro + acento verde + fondo)
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Adwaita-dark'
accent-color='green'

[org/gnome/desktop/background]
picture-uri='file://$FONDO_PRIN'
picture-uri-dark='file://$FONDO_PRIN'
picture-options='zoom'
primary-color='#0A0E0A'

[org/gnome/desktop/screensaver]
picture-uri='file://$FONDO_PRIN'
primary-color='#0A0E0A'
EOF
  dconf update 2>/dev/null || true
  ok "modo oscuro, acento verde y fondo fijados a nivel sistema (dconf)."
else
  printf "  ${O}[dry]${R} ${T}escribir defaults dconf (modo oscuro + acento + fondo)${R}\n"
fi

# --- GTK: forzar tema oscuro tambien en apps GTK legacy ---
if [ "$DRY_RUN" -eq 0 ]; then
  for V in gtk-3.0 gtk-4.0; do
    mkdir -p "/etc/$V"
    cat > "/etc/$V/settings.ini" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF
  done
  ok "apps GTK forzadas a tema oscuro."
else
  printf "  ${O}[dry]${R} ${T}escribir /etc/gtk-3.0 y gtk-4.0 settings.ini (oscuro)${R}\n"
fi

# --- GNOME Terminal: instalar el aplicador que corre en el 1er login ---
if [ -f "$APLICADOR" ]; then
  if [ "$DRY_RUN" -eq 0 ]; then
    install -m 0755 "$APLICADOR" "$HERCULE_HOME/.hercule/aplicar-terminal-gnome.sh"
    mkdir -p "$HERCULE_HOME/.config/autostart"
    cat > "$HERCULE_HOME/.config/autostart/hercule-tema.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Hercule tema
Comment=Aplica la paleta Hercule a la terminal (una vez)
Exec=$HERCULE_HOME/.hercule/aplicar-terminal-gnome.sh
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF
    chown -R "$HERCULE_USER:$HERCULE_USER" "$HERCULE_HOME/.hercule" "$HERCULE_HOME/.config" 2>/dev/null || true
  fi
  ok "paleta de terminal: se aplicara en el primer login de $HERCULE_USER."
else
  warn "no se encontro $APLICADOR; la paleta de GNOME Terminal se omite."
fi

# --- alias para alternar fondo normal / undercover ---
if [ "$DRY_RUN" -eq 0 ] && [ -d "$FONDO_DEST" ]; then
  ALIASF="$HERCULE_HOME/.hercule/terminal/hercule-fondos.sh"
  cat > "$ALIASF" <<EOF
# Hercule - alternar fondo de pantalla (GNOME)
alias normal='gsettings set org.gnome.desktop.background picture-uri "file://$FONDO_PRIN"; gsettings set org.gnome.desktop.background picture-uri-dark "file://$FONDO_PRIN"'
alias undercover='gsettings set org.gnome.desktop.background picture-uri "file://$FONDO_UC"; gsettings set org.gnome.desktop.background picture-uri-dark "file://$FONDO_UC"'
EOF
  BRC="$HERCULE_HOME/.bashrc"; SRCL="source \"\$HOME/.hercule/terminal/hercule-fondos.sh\""
  grep -qF "$SRCL" "$BRC" 2>/dev/null || printf "%s\n" "$SRCL" >> "$BRC"
  chown "$HERCULE_USER:$HERCULE_USER" "$ALIASF" "$BRC" 2>/dev/null || true
  ok "comandos 'normal' y 'undercover' listos para alternar el fondo."
fi

# ---------------------------------------------------------------------
# 3bb. Documentos base: arbol por tematica + guias en Documents
# ---------------------------------------------------------------------
step "Documentos base (guias por tematica)"
DOCS_SRC="$SCRIPT_DIR/../documentos-base"
if [ -d "$DOCS_SRC" ]; then
  # detectar la carpeta Documents del usuario (localizada: Documents / Documentos)
  DOCS="$(sudo -u "$HERCULE_USER" bash -lc 'xdg-user-dir DOCUMENTS 2>/dev/null' 2>/dev/null || true)"
  if [ -z "$DOCS" ] || [ "$DOCS" = "$HERCULE_HOME" ]; then
    DOCS=""
    for d in "$HERCULE_HOME/Documents" "$HERCULE_HOME/Documentos"; do
      [ -d "$d" ] && DOCS="$d" && break
    done
  fi
  [ -z "$DOCS" ] && DOCS="$HERCULE_HOME/Documents"
  DEST_DOCS="$DOCS/Hercule"
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$DEST_DOCS"
    if [ "$MODO_UPDATE" -eq 1 ]; then
      # update: actualiza las guias/plantillas del proyecto, PERO nunca toca los
      # 'casos/' del usuario (cp no borra; el repo no trae casos con datos).
      cp -r "$DOCS_SRC/." "$DEST_DOCS/" 2>/dev/null || true
      ok "guias actualizadas en $DEST_DOCS (tus casos quedaron intactos)."
    else
      cp -rn "$DOCS_SRC/." "$DEST_DOCS/" 2>/dev/null || true  # -n: no pisa lo que el usuario edito
      ok "guias y arbol de trabajo creados en $DEST_DOCS"
    fi
    chown -R "$HERCULE_USER:$HERCULE_USER" "$DOCS" 2>/dev/null || true
  else
    info "[dry] copiar documentos-base -> $DEST_DOCS"
  fi
  info "el usuario arranca por $DEST_DOCS/00-EMPEZAR-ACA.md"
else
  warn "no se encontro documentos-base/ en $DOCS_SRC; se omite."
fi

# ---------------------------------------------------------------------
# 3c. Herramientas de investigacion (OSINT / forense / red) - opcional
#     (en modo --update no se pregunta; el toolkit se actualiza aparte)
# ---------------------------------------------------------------------
if [ "$MODO_UPDATE" -eq 0 ]; then
step "Herramientas de investigacion"
TOOLS_SRC="$SCRIPT_DIR/instalar-herramientas.sh"
if [ -f "$TOOLS_SRC" ]; then
  printf "  ${T}Instalar ahora el toolkit OSINT/forense de Hercule? [s] si    [n] no (podes hacerlo luego)${R}\n"
  read -rp "  > " RTOOLS || RTOOLS=""
  if [[ "${RTOOLS,,}" == "s" || "${RTOOLS,,}" == "si" ]]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      bash "$TOOLS_SRC" --dry-run || warn "el modulo de herramientas devolvio un error."
    else
      bash "$TOOLS_SRC" || warn "el modulo de herramientas devolvio un error."
    fi
  else
    info "podes instalarlas luego con:  sudo $TOOLS_SRC"
  fi
else
  warn "no se encontro $TOOLS_SRC; se omite. Corre el script desde la carpeta del proyecto."
fi

# ---------------------------------------------------------------------
# 3d. Aplicaciones propias de Hercule (SEPTEM, etc.) - opcional
# ---------------------------------------------------------------------
step "Aplicaciones propias"
APPS_SRC="$SCRIPT_DIR/instalar-apps.sh"
if [ -f "$APPS_SRC" ]; then
  printf "  ${T}Instalar las apps propias de Hercule (SEPTEM, cifrador aureo)? [s] si    [n] no${R}\n"
  read -rp "  > " RAPPS || RAPPS=""
  if [[ "${RAPPS,,}" == "s" || "${RAPPS,,}" == "si" ]]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      bash "$APPS_SRC" --dry-run || warn "el modulo de apps devolvio un error."
    else
      bash "$APPS_SRC" || warn "el modulo de apps devolvio un error."
    fi
  else
    info "podes instalarlas luego con:  sudo $APPS_SRC"
  fi
else
  warn "no se encontro $APPS_SRC; se omite. Corre el script desde la carpeta del proyecto."
fi
fi  # fin bloque tools/apps (solo instalacion normal)

# ---------------------------------------------------------------------
# 3e. Sistema de actualizacion: copia del repo en /opt/hercule + comando
#     'hercule-update' (solo en instalacion normal).
# ---------------------------------------------------------------------
if [ "$MODO_UPDATE" -eq 0 ]; then
step "Sistema de actualizacion (hercule-update)"
if [ "$DRY_RUN" -eq 1 ]; then
  info "[dry] instalar copia del repo en $REPO_SIS (git clone/copia) + comando hercule-update"
else
  command -v git >/dev/null 2>&1 || apt-get install -y -q git >/dev/null 2>&1 || true
  if [ -d "$REPO_SIS/.git" ]; then
    info "ya existe una copia del proyecto en $REPO_SIS; se conserva."
  elif [ "$PROYECTO_DIR" = "$REPO_SIS" ]; then
    info "el proyecto ya esta en $REPO_SIS."
  elif [ -d "$PROYECTO_DIR/.git" ]; then
    info "copiando el proyecto (con su historial git) a $REPO_SIS..."
    mkdir -p "$REPO_SIS"
    cp -a "$PROYECTO_DIR/." "$REPO_SIS/" 2>/dev/null || true
    ok "copia del proyecto lista en $REPO_SIS."
  elif command -v git >/dev/null 2>&1; then
    info "clonando el proyecto desde $REMOTO_DEFECTO a $REPO_SIS..."
    if git clone --quiet "$REMOTO_DEFECTO" "$REPO_SIS" 2>/dev/null; then
      ok "proyecto clonado en $REPO_SIS."
    else
      warn "no se pudo clonar el repo (sin internet?); la autoactualizacion quedara deshabilitada."
    fi
  else
    warn "git no disponible; no se pudo preparar la autoactualizacion."
  fi
  # marcar el repo como seguro para git corriendo como root
  git config --global --add safe.directory "$REPO_SIS" 2>/dev/null || true
  # instalar el comando hercule-update (wrapper que usa siempre la version actual)
  if [ -f "$REPO_SIS/instalador-debian13/actualizar-hercule.sh" ]; then
    cat > /usr/local/bin/hercule-update <<EOF
#!/usr/bin/env bash
# Actualiza Hercule desde el repositorio y re-aplica los cambios.
exec bash "$REPO_SIS/instalador-debian13/actualizar-hercule.sh" "\$@"
EOF
    chmod 0755 /usr/local/bin/hercule-update
    # registrar la version instalada
    COMMIT_INI="$(git -C "$REPO_SIS" rev-parse HEAD 2>/dev/null || echo desconocido)"
    printf "commit=%s\nfecha=%s\n" "$COMMIT_INI" "$(date '+%Y-%m-%d %H:%M:%S')" \
      > "$REPO_SIS/.hercule-version" 2>/dev/null || true
    ok "comando 'hercule-update' instalado."
    info "para actualizar Hercule en el futuro:  sudo hercule-update"
    info "para solo ver si hay novedades:        sudo hercule-update --check"
  else
    warn "no se encontro el actualizador en $REPO_SIS; 'hercule-update' no se instalo."
  fi
fi
fi  # fin sistema de actualizacion

# ---------------------------------------------------------------------
# 4. (al final) Preguntar si eliminar los otros usuarios
#    (en modo --update NO se toca a los usuarios)
# ---------------------------------------------------------------------
if [ "$MODO_UPDATE" -eq 0 ]; then
step "Limpieza de usuarios"
mapfile -t OTROS < <(awk -F: -v keep="$HERCULE_USER" \
  '$3>=1000 && $3<60000 && $1!=keep && $1!="nobody" {print $1}' /etc/passwd)

if [ "${#OTROS[@]}" -eq 0 ]; then
  info "no hay otros usuarios humanos en el sistema; nada que limpiar."
else
  warn "se detectaron otros usuarios en el sistema:"
  for u in "${OTROS[@]}"; do printf "       ${T}- %s${R}\n" "$u"; done
  printf "\n  ${O}Deseas ELIMINAR todos estos usuarios (borra sus cuentas y carpetas),${R}\n"
  printf "  ${O}o conservarlos?${R}\n"
  printf "  ${T}[e] eliminar    [c] conservar (por defecto: conservar)${R}\n"
  read -rp "  > " RESP || RESP=""

  if [[ "${RESP,,}" == "e" || "${RESP,,}" == "eliminar" ]]; then
    warn "esta accion es IRREVERSIBLE y borra las carpetas personales."
    printf "  ${O}Para confirmar, escribi exactamente la palabra ELIMINAR:${R}\n"
    read -rp "  > " CONF || CONF=""
    if [ "$CONF" == "ELIMINAR" ]; then
      DEFERIDO=""
      for u in "${OTROS[@]}"; do
        if [ "$u" == "${SUDO_USER:-}" ]; then DEFERIDO="$u"; continue; fi
        run pkill -KILL -u "$u" 2>/dev/null || true
        if run deluser --remove-home "$u"; then ok "usuario $u eliminado."
        else warn "no se pudo eliminar $u (puede estar en uso)."; fi
      done
      if [ -n "$DEFERIDO" ]; then
        if run deluser --remove-home "$DEFERIDO"; then
          ok "usuario $DEFERIDO eliminado."
        else
          warn "no se pudo eliminar $DEFERIDO ahora (es tu sesion actual)."
          info "eliminalo luego, logueado como $HERCULE_USER:  sudo deluser --remove-home $DEFERIDO"
        fi
      fi
    else
      info "confirmacion incorrecta; no se elimino ningun usuario."
    fi
  else
    info "se conservan todos los usuarios existentes."
  fi
fi
fi  # fin limpieza de usuarios (solo instalacion normal)

# ---------------------------------------------------------------------
# 5. Mensaje final
# ---------------------------------------------------------------------
step "Final"
if [ "$MODO_UPDATE" -eq 1 ]; then
  printf "\n  ${G}============================================${R}\n"
  ok "re-aplicacion de la personalizacion finalizada."
  info "los cambios de terminal/escritorio se veran al reabrir la sesion de $HERCULE_USER."
  printf "  ${G}============================================${R}\n\n"
else
  printf "\n  ${G}============================================${R}\n"
  ok "el script finalizo con exito."
  ok "se creo el usuario Hercule (login: $HERCULE_USER)."
  printf "\n"
  info "por seguridad, deberas cambiar su contrasena mas adelante."
  info "para cambiarla, usa el comando:"
  printf "       ${G}passwd $HERCULE_USER${R}   ${T}(ejecutado como root)${R}\n"
  printf "       ${G}passwd${R}           ${T}(dentro de la sesion de $HERCULE_USER)${R}\n"
  printf "\n"
  info "para actualizar Hercule cuando haya cambios:  ${G}sudo hercule-update${R}"
  printf "  ${G}============================================${R}\n\n"
fi

if [ "$DRY_RUN" -eq 0 ]; then
  info "resultado guardado en $LOGFILE"
fi
printf "  ${D}-- Hercule @v@   |   les petites cellules grises${R}\n\n"
