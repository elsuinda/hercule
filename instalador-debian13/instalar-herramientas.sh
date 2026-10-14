#!/usr/bin/env bash
# =====================================================================
#  HERCULE - Instalador de herramientas OSINT / forenses / red
#  Fase D (modulo de herramientas) del proyecto Hercule.
#
#  Instala el toolkit de investigacion ordenado por la metodologia
#  "celulas grises": recolecta, infra/red, analisis/forense, ofensivo
#  (autorizado) y utilidades.
#
#  Uso:
#    sudo ./instalar-herramientas.sh                 # set de investigacion (pregunta por ofensivo)
#    sudo ./instalar-herramientas.sh --all           # todo, incluido ofensivo
#    sudo ./instalar-herramientas.sh --osint --red   # solo esos grupos
#    sudo ./instalar-herramientas.sh --dry-run       # simula, lista sin instalar
#    ./instalar-herramientas.sh --help
#
#  Autor: Miguel - proyecto Hercule.
# =====================================================================
set -euo pipefail

USUARIO_HERCULE="hercule"
LOGFILE="/var/log/hercule-tools.log"
DRY_RUN=0
SEL_BASE=0; SEL_RED=0; SEL_OSINT=0; SEL_FOR=0; SEL_OFEN=0; SEL_PIPX=0; SEL_EXTRA=0
EXPLICITO=0   # el usuario eligio grupos a mano

# ---------- colores ----------
G="\e[38;2;57;255;20m"; D="\e[38;2;31;168;11m"; O="\e[38;2;255;106;0m"
T="\e[38;2;200;214;200m"; R="\e[0m"
ok(){ printf "  ${G}[ ok ]${R} ${T}%b${R}\n" "$1"; }
info(){ printf "  ${D}[ .. ]${R} ${T}%b${R}\n" "$1"; }
warn(){ printf "  ${O}[ !! ]${R} ${O}%b${R}\n" "$1"; }
err(){ printf "  ${O}[ XX ]${R} ${O}%b${R}\n" "$1" >&2; }
step(){ printf "\n${D}--[ ${G}%b${D} ]----------------------------------------${R}\n" "$1"; }

# ---------- grupos de paquetes APT ----------
# Recolecta / OSINT
PKG_OSINT=(theharvester whatweb dmitry dnsutils whois libimage-exiftool-perl
           recon-ng metagoofil webhttrack)
# Infra / red
PKG_RED=(nmap masscan tcpdump tshark netcat-openbsd traceroute mtr-tiny
         net-tools dnsrecon dnsenum)
# Analisis / forense
PKG_FOR=(sleuthkit autopsy binwalk foremost testdisk gddrescue steghide
         hashdeep bulk-extractor ewf-tools)
# Ofensivo (uso en pentesting AUTORIZADO)
PKG_OFEN=(nikto dirb gobuster ffuf hydra john hashcat sqlmap wfuzz
          proxychains4 tor)
# Utilidades base
PKG_BASE=(git curl wget python3-pip pipx jq ripgrep tmux htop tree
          build-essential golang-go unzip p7zip-full)
# Herramientas OSINT via pipx (se instalan para el usuario hercule)
PIPX_OSINT=(sherlock-project holehe maigret socialscan)
# OSINT avanzado via pipx
PIPX_EXTRA=(dnstwist spiderfoot)
# OSINT avanzado via 'go install' (nombre|modulo)
# Importante: se apunta al paquete main concreto (cmd/...), no al comodin /...,
# para que 'go install' no intente compilar paquetes que no son ejecutables.
GO_TOOLS=(
  "amass|github.com/owasp-amass/amass/v4/cmd/amass@master"
  "subfinder|github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "phoneinfoga|github.com/sundowndev/phoneinfoga/v2@latest"
)
# recon-ng via git (lo pidio explicitamente por git)
RECONNG_REPO="https://github.com/lanmaster53/recon-ng"
RECONNG_DIR="/opt/recon-ng"

ayuda(){ cat <<EOF
Instalador de herramientas Hercule (OSINT / forense / red).

  sudo ./instalar-herramientas.sh              set de investigacion (base, red, osint, forense, pipx)
                                               y pregunta si sumar el grupo ofensivo
  sudo ./instalar-herramientas.sh --all        instala TODO, incluido el grupo ofensivo
  sudo ./instalar-herramientas.sh [grupos]     solo los grupos elegidos:
       --base --red --osint --forense --ofensivo --pipx --extra
       (--extra = OSINT avanzado: amass, subfinder, phoneinfoga, recon-ng, spiderfoot, dnstwist)
  sudo ./instalar-herramientas.sh --dry-run    simula: lista lo que instalaria, sin instalar
  ./instalar-herramientas.sh --help            esta ayuda

Debe ejecutarse como root (o con sudo).
EOF
}

# ---------- argumentos ----------
for a in "$@"; do case "$a" in
  --all) SEL_BASE=1;SEL_RED=1;SEL_OSINT=1;SEL_FOR=1;SEL_OFEN=1;SEL_PIPX=1;SEL_EXTRA=1;EXPLICITO=1;;
  --base) SEL_BASE=1;EXPLICITO=1;;
  --red) SEL_RED=1;EXPLICITO=1;;
  --osint) SEL_OSINT=1;EXPLICITO=1;;
  --forense) SEL_FOR=1;EXPLICITO=1;;
  --ofensivo) SEL_OFEN=1;EXPLICITO=1;;
  --pipx) SEL_PIPX=1;EXPLICITO=1;;
  --extra) SEL_EXTRA=1;EXPLICITO=1;;
  --dry-run) DRY_RUN=1;;
  --help|-h) ayuda; exit 0;;
  *) err "argumento desconocido: $a"; ayuda; exit 2;;
esac; done

# default: set de investigacion completo (sin ofensivo), ofensivo se pregunta
if [ "$EXPLICITO" -eq 0 ]; then
  SEL_BASE=1; SEL_RED=1; SEL_OSINT=1; SEL_FOR=1; SEL_PIPX=1
fi

# ---------- root ----------
if [ "$(id -u)" -ne 0 ]; then
  err "este script debe ejecutarse como root."
  info "volve a ejecutarlo asi:  sudo $0 $*"
  exit 1
fi
if [ "$DRY_RUN" -eq 0 ]; then
  touch "$LOGFILE" 2>/dev/null || true
  exec > >(tee -a "$LOGFILE") 2>&1
fi

printf "\n   ${G}H E R C U L E${R}  ${O}- herramientas de investigacion -${R}\n"
printf "   ${O}les petites cellules grises${R}\n\n"
[ "$DRY_RUN" -eq 1 ] && warn "modo simulacion (--dry-run): no se instala nada."

if ! command -v apt-get >/dev/null 2>&1; then
  err "este modulo usa apt (Debian/Ubuntu) y no se encontro apt-get."
  exit 1
fi

# ---------- preguntar por el grupo ofensivo (si no se eligio a mano) ----------
if [ "$EXPLICITO" -eq 0 ]; then
  step "Grupo ofensivo (pentesting autorizado)"
  info "incluye: ${PKG_OFEN[*]}"
  warn "son herramientas para pruebas de intrusion AUTORIZADAS. Usalas solo con permiso."
  printf "  ${T}Instalar el grupo ofensivo? [s] si    [n] no (por defecto: no)${R}\n"
  read -rp "  > " RESP || RESP=""
  [[ "${RESP,,}" == "s" || "${RESP,,}" == "si" ]] && SEL_OFEN=1

  step "Grupo OSINT avanzado (go / git)"
  info "incluye: amass, subfinder, phoneinfoga (go), recon-ng (git), + spiderfoot/dnstwist (pipx)"
  info "descarga desde GitHub; necesita internet y tarda un poco mas."
  printf "  ${T}Instalar el grupo OSINT avanzado? [s] si    [n] no (por defecto: no)${R}\n"
  read -rp "  > " RESP2 || RESP2=""
  [[ "${RESP2,,}" == "s" || "${RESP2,,}" == "si" ]] && SEL_EXTRA=1
fi

# ---------- actualizar indices ----------
step "Actualizando indices de paquetes"
if [ "$DRY_RUN" -eq 0 ]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y || warn "apt-get update devolvio un error; se continua."
else
  info "[dry] apt-get update"
fi

# ---------- instalar un grupo (filtrando a los paquetes disponibles) ----------
instalar_grupo(){
  local nombre="$1"; shift
  local pkgs=("$@")
  step "Grupo: $nombre"
  local disp=() falt=()
  for p in "${pkgs[@]}"; do
    if apt-cache show "$p" >/dev/null 2>&1; then disp+=("$p"); else falt+=("$p"); fi
  done
  if [ "${#disp[@]}" -gt 0 ]; then
    info "a instalar: ${disp[*]}"
    if [ "$DRY_RUN" -eq 0 ]; then
      if apt-get install -y --no-install-recommends "${disp[@]}"; then
        ok "grupo $nombre instalado (${#disp[@]} paquetes)."
      else
        warn "algunos paquetes de $nombre fallaron; revisa el log."
      fi
    else
      info "[dry] apt-get install ${disp[*]}"
    fi
  fi
  if [ "${#falt[@]}" -gt 0 ]; then
    warn "no disponibles en este repo (se omiten): ${falt[*]}"
  fi
}

[ "$SEL_BASE" -eq 1 ] && instalar_grupo "Utilidades base"       "${PKG_BASE[@]}"
[ "$SEL_RED"  -eq 1 ] && instalar_grupo "Infra / Red"           "${PKG_RED[@]}"
[ "$SEL_OSINT" -eq 1 ] && instalar_grupo "Recolecta / OSINT"    "${PKG_OSINT[@]}"
[ "$SEL_FOR"  -eq 1 ] && instalar_grupo "Analisis / Forense"    "${PKG_FOR[@]}"
[ "$SEL_OFEN" -eq 1 ] && instalar_grupo "Ofensivo (autorizado)" "${PKG_OFEN[@]}"

# ---------- herramientas OSINT via pipx (para el usuario hercule) ----------
if [ "$SEL_PIPX" -eq 1 ]; then
  step "OSINT via pipx (usuario $USUARIO_HERCULE)"
  if id "$USUARIO_HERCULE" &>/dev/null; then
    if [ "$DRY_RUN" -eq 0 ]; then
      sudo -u "$USUARIO_HERCULE" bash -lc 'command -v pipx >/dev/null 2>&1 && pipx ensurepath >/dev/null 2>&1 || true'
      for t in "${PIPX_OSINT[@]}"; do
        if sudo -u "$USUARIO_HERCULE" bash -lc "pipx install '$t'" >/dev/null 2>&1; then
          ok "pipx: $t instalado."
        else
          warn "pipx: no se pudo instalar $t (se omite)."
        fi
      done
    else
      info "[dry] pipx install (como $USUARIO_HERCULE): ${PIPX_OSINT[*]}"
    fi
  else
    warn "el usuario $USUARIO_HERCULE no existe; se omite el bloque pipx."
    info "corre primero instalar-hercule.sh para crear el usuario."
  fi
fi

# ---------- OSINT avanzado: go install + git (recon-ng) ----------
if [ "$SEL_EXTRA" -eq 1 ]; then
  step "OSINT avanzado (go / git / pipx)"
  if ! id "$USUARIO_HERCULE" &>/dev/null; then
    warn "el usuario $USUARIO_HERCULE no existe; se omite el grupo avanzado."
    info "corre primero instalar-hercule.sh para crear el usuario."
  else
    # --- pipx extra (dnstwist, spiderfoot) ---
    if [ "$DRY_RUN" -eq 0 ]; then
      for t in "${PIPX_EXTRA[@]}"; do
        if sudo -u "$USUARIO_HERCULE" bash -lc "pipx install '$t'" >/dev/null 2>&1; then
          ok "pipx: $t instalado."
        else warn "pipx: no se pudo instalar $t (se omite)."; fi
      done
    else
      info "[dry] pipx install (como $USUARIO_HERCULE): ${PIPX_EXTRA[*]}"
    fi
    # --- go tools (amass, subfinder, phoneinfoga) ---
    # Si falta go (p.ej. no se eligio --base), se intenta instalar golang-go.
    if ! command -v go >/dev/null 2>&1 && [ "$DRY_RUN" -eq 0 ]; then
      info "go no estaba instalado; instalando golang-go..."
      apt-get install -y --no-install-recommends golang-go >/dev/null 2>&1 || true
    fi
    if command -v go >/dev/null 2>&1; then
      HHOME="$(getent passwd "$USUARIO_HERCULE" | cut -d: -f6)"
      GOLOG="${LOGFILE%/*}/hercule-go.log"
      GOVER="$(go version 2>/dev/null | awk '{print $3}')"
      info "usando $GOVER (toolchain=auto: descarga la version que pida cada herramienta)."
      if [ "$DRY_RUN" -eq 0 ]; then
        # ~/go/bin en el PATH del usuario
        BRC="$HHOME/.bashrc"
        LINEP='export PATH="$HOME/go/bin:$PATH"'
        grep -qF "$LINEP" "$BRC" 2>/dev/null || printf "%s\n" "$LINEP" >> "$BRC"
        # crear dirs de go con ownership correcto (evita fallos de cache/escritura)
        mkdir -p "$HHOME/go/bin" "$HHOME/.cache/go-build"
        chown -R "$USUARIO_HERCULE:$USUARIO_HERCULE" "$HHOME/go" "$HHOME/.cache/go-build" "$BRC" 2>/dev/null || true
        : > "$GOLOG" 2>/dev/null || true
      fi
      # Entorno robusto para 'go install' como usuario hercule:
      #  - GOTOOLCHAIN=auto : Debian fija 'local' y hace fallar modulos que piden
      #    otra version de Go; 'auto' deja que go descargue la toolchain correcta.
      #  - GOPROXY/GOSUMDB  : por si el entorno del usuario tiene uno roto.
      #  - GOBIN/GOPATH     : binarios en ~/go/bin.
      GOENV='export GOTOOLCHAIN=auto GOFLAGS=-mod=mod \
             GOPROXY=https://proxy.golang.org,direct GOSUMDB=sum.golang.org \
             GOPATH="$HOME/go" GOBIN="$HOME/go/bin" GOCACHE="$HOME/.cache/go-build";'
      for entry in "${GO_TOOLS[@]}"; do
        nombre="${entry%%|*}"; modulo="${entry#*|}"
        if [ "$DRY_RUN" -eq 1 ]; then
          info "[dry] go install $modulo  (-> $nombre, como $USUARIO_HERCULE, GOTOOLCHAIN=auto)"
        else
          if sudo -u "$USUARIO_HERCULE" bash -lc "$GOENV go install -v '$modulo'" >>"$GOLOG" 2>&1; then
            ok "go: $nombre instalado (en ~/go/bin)."
          else
            warn "go: no se pudo instalar $nombre. Ultimo error:"
            tail -n 3 "$GOLOG" 2>/dev/null | sed 's/^/      /'
            info "detalle completo en $GOLOG"
          fi
        fi
      done
    else
      warn "go no esta instalado y no se pudo instalar; se omiten amass/subfinder/phoneinfoga."
    fi
    # --- recon-ng via git (+ venv aislado) ---
    if command -v git >/dev/null 2>&1; then
      if [ "$DRY_RUN" -eq 1 ]; then
        info "[dry] git clone $RECONNG_REPO -> $RECONNG_DIR (+ venv + wrapper /usr/local/bin/recon-ng)"
      else
        if [ -d "$RECONNG_DIR/.git" ]; then
          git -C "$RECONNG_DIR" pull --ff-only >/dev/null 2>&1 || true
        else
          git clone --depth 1 "$RECONNG_REPO" "$RECONNG_DIR" >/dev/null 2>&1 || warn "recon-ng: fallo el git clone."
        fi
        if [ -d "$RECONNG_DIR" ]; then
          python3 -m venv "$RECONNG_DIR/.venv" >/dev/null 2>&1 || true
          "$RECONNG_DIR/.venv/bin/pip" install -q -r "$RECONNG_DIR/REQUIREMENTS.txt" >/dev/null 2>&1 \
            || warn "recon-ng: fallaron algunas dependencias."
          cat > /usr/local/bin/recon-ng <<EOF
#!/usr/bin/env bash
exec "$RECONNG_DIR/.venv/bin/python" "$RECONNG_DIR/recon-ng" "\$@"
EOF
          chmod 0755 /usr/local/bin/recon-ng
          ok "recon-ng instalado por git en $RECONNG_DIR (comando: recon-ng)."
        fi
      fi
    else
      warn "git no esta instalado; instala el grupo base (--base) para recon-ng."
    fi
  fi
fi

# ---------- comando de ayuda 'hercule-tools' ----------
step "Referencia de herramientas"
if [ "$DRY_RUN" -eq 0 ]; then
  cat > /usr/local/bin/hercule-tools <<'EOF'
#!/usr/bin/env bash
G="\e[38;2;57;255;20m"; O="\e[38;2;255;106;0m"; D="\e[38;2;31;168;11m"; T="\e[38;2;200;214;200m"; R="\e[0m"
printf "\n  ${G}HERCULE - toolkit por fase de la metodologia celulas grises${R}\n\n"
printf "  ${O}Recolecta / OSINT${R}  ${T}theharvester, sherlock, holehe, maigret, whatweb, dmitry, exiftool, whois, dig${R}\n"
printf "  ${O}OSINT avanzado${R}     ${T}amass, subfinder, phoneinfoga, recon-ng, spiderfoot, dnstwist${R}\n"
printf "  ${O}Infra / Red${R}        ${T}nmap, masscan, tcpdump, tshark, netcat, dnsrecon, dnsenum, mtr${R}\n"
printf "  ${O}Forense${R}            ${T}sleuthkit/autopsy, binwalk, foremost, testdisk, steghide, hashdeep, bulk_extractor${R}\n"
printf "  ${O}Ofensivo (autoriz.)${R} ${T}nikto, dirb, gobuster, ffuf, hydra, john, hashcat, sqlmap, proxychains, tor${R}\n"
printf "  ${O}Utilidades${R}         ${T}git, pipx, jq, rg, tmux, htop, tree, go${R}\n\n"
printf "  ${D}-- les petites cellules grises : pensar el caso antes de lanzar la herramienta.${R}\n\n"
EOF
  chmod 0755 /usr/local/bin/hercule-tools
  ok "comando 'hercule-tools' instalado (muestra el toolkit por fase)."
else
  info "[dry] crear /usr/local/bin/hercule-tools"
fi

# ---------- cierre ----------
step "Final"
ok "modulo de herramientas finalizado."
info "ejecuta 'hercule-tools' para ver el toolkit ordenado por fase."
if [ "$DRY_RUN" -eq 0 ]; then
  info "resultado guardado en $LOGFILE"
fi
printf "  ${D}-- Hercule @v@   |   les petites cellules grises${R}\n\n"
