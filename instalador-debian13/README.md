# HERCULE — Instalador Debian 13 (Fase D)

*Script de personalización que convierte una instalación de Debian 13 (trixie) en una
estación de trabajo Hercule: crea el usuario de trabajo e instala el tema de terminal.*

> ⚠️ Es un script de administración que **crea y puede borrar usuarios**. Leé esta guía
> antes de ejecutarlo. Incluye un modo de simulación (`--dry-run`) para probarlo sin
> tocar el sistema.

---

## Qué hace

1. **Exige root.** Si no se ejecuta como root (o con `sudo`), se detiene y avisa.
2. **Crea el usuario de trabajo.** Login `hercule`, nombre "Hercule", shell bash,
   agregado al grupo `sudo`, con una **contraseña por defecto** (definida en la variable
   `HERCULE_PASS` del script).
3. **Instala el tema de terminal Hercule** (banner, prompt, colores) en la carpeta del
   usuario y lo deja cargándose solo al abrir una terminal.
4. **Pone todo el sistema en modo oscuro y aplica la paleta Hercule** (por defecto):
   - Modo oscuro + **acento verde** a nivel sistema (dconf) y apps GTK en oscuro.
   - **Fondo de pantalla** Hercule por defecto.
   - **Paleta Hercule en la terminal** (GNOME Terminal): se aplica sola en el primer
     login del usuario (vía un aplicador que luego se autodesactiva).
   - Deja los comandos **`normal`** y **`undercover`** para alternar el fondo al instante.
   - *Nota honesta:* GNOME es lo que Debian 13 trae por defecto; en otros entornos de
     escritorio el modo oscuro se aplica, pero algunos detalles pueden variar.
5. **Crea los documentos base** en `Documents/Hercule/` del usuario: un árbol por
   temática (osint, pentest, forense, red, informes, recursos) con **guías de qué
   herramienta usar y el procedimiento** para escenarios genéricos, plantilla de informe
   y cadena de custodia. Es la base para que el operador sepa usar la distro.
6. **Ofrece instalar el toolkit** OSINT / forense / red (opcional; ver abajo).
7. **Ofrece instalar las apps propias** de Hercule (opcional; ver abajo).
8. **Al final, pregunta** si querés **eliminar todos los otros usuarios** del sistema o
   conservarlos (por defecto: conservar). Si elegís eliminar, pide confirmación extra
   escribiendo la palabra `ELIMINAR`.
9. **Avisa el resultado** e indica cómo cambiar la contraseña más adelante.

---

## Requisitos

- Debian 13 (trixie) — también funciona en derivadas Debian/Ubuntu recientes y WSL.
- Ejecutarse como **root** o con **sudo**.
- La carpeta `terminal/` del proyecto Hercule junto al script (para instalar el tema).
  Lo más simple: correr el script desde el proyecto descomprimido.

---

## Uso

```bash
# 1) dar permisos de ejecución
chmod +x instalar-hercule.sh

# 2) PROBARLO primero sin tocar nada (muy recomendado)
sudo ./instalar-hercule.sh --dry-run

# 3) ejecutarlo de verdad
sudo ./instalar-hercule.sh

# ayuda
./instalar-hercule.sh --help
```

El modo `--dry-run` muestra **todo lo que haría** (crear usuario, instalar tema, borrar
cuentas) pero **no aplica ningún cambio**. Usalo siempre la primera vez.

---

## Credenciales del usuario

- **Login:** `hercule`  (en minúscula, por la convención de nombres de usuario de Linux;
  el nombre completo de la cuenta es "Hercule").
- **Contraseña por defecto:** está definida en la variable `HERCULE_PASS` al inicio del
  script. **Debe cambiarse** después de la instalación.

**Cambiar la contraseña** (el script te lo recuerda al final):
```bash
passwd hercule      # como root
passwd              # dentro de la sesión de hercule
```

---

## Sobre borrar usuarios (importante)

- La opción de eliminar usuarios es **irreversible**: borra las cuentas y sus **carpetas
  personales** (`--remove-home`).
- Solo afecta a usuarios "humanos" (UID 1000–59999); nunca a root ni a cuentas de sistema.
- Nunca borra al usuario `hercule`.
- Si ejecutaste el script con `sudo` desde tu cuenta normal y esa cuenta está en la lista,
  se borra **al final**; si no se puede (porque es tu sesión activa), el script te indica
  cómo eliminarla luego, ya logueado como `hercule`.
- Por defecto la respuesta es **conservar**. Para borrar hay que elegir `e` y después
  escribir `ELIMINAR` en mayúsculas.

---

## Herramientas de investigación (`instalar-herramientas.sh`)

Módulo aparte que instala el toolkit, **ordenado por las fases de la metodología
"células grises"**. El instalador principal ofrece correrlo; también se puede usar solo.

| Grupo | Incluye (ejemplos) |
|-------|--------------------|
| Utilidades base | git, pipx, jq, ripgrep, tmux, htop, tree, go, build-essential |
| Infra / Red | nmap, masscan, tcpdump, tshark, netcat, dnsrecon, dnsenum, mtr |
| Recolecta / OSINT | theHarvester, whatweb, dmitry, exiftool, whois, dig + (pipx) sherlock, holehe, maigret, socialscan |
| OSINT avanzado (`--extra`) | amass, subfinder, phoneinfoga (go), recon-ng (git), spiderfoot, dnstwist (pipx) |
| Análisis / Forense | sleuthkit/autopsy, binwalk, foremost, testdisk, steghide, hashdeep, bulk-extractor |
| Ofensivo (autorizado) | nikto, dirb, gobuster, ffuf, hydra, john, hashcat, sqlmap, proxychains, tor |

```bash
sudo ./instalar-herramientas.sh              # base+red+osint+forense (pregunta por ofensivo)
sudo ./instalar-herramientas.sh --all        # todo, incluido ofensivo
sudo ./instalar-herramientas.sh --osint --red  # solo esos grupos
sudo ./instalar-herramientas.sh --dry-run    # simula, lista sin instalar
```

- Verifica que cada paquete exista en el repo antes de instalar y **omite los que falten**
  (sin cortar la instalación).
- El **grupo ofensivo** es para pruebas de intrusión **autorizadas**; se pregunta antes
  de instalarlo (o se fuerza con `--ofensivo` / `--all`).
- El **grupo OSINT avanzado** (`--extra`) baja herramientas desde GitHub (go/git/pipx):
  necesita internet y tarda un poco más; también se pregunta antes de instalarlo. recon-ng
  queda en `/opt/recon-ng` con su propio entorno virtual y un comando `recon-ng`; amass,
  subfinder y phoneinfoga quedan en `~/go/bin` del usuario `hercule`.
- Deja el comando **`hercule-tools`**, que muestra el toolkit ordenado por fase.
- Log en `/var/log/hercule-tools.log`.

---

## Aplicaciones propias (`instalar-apps.sh`)

Clona desde GitHub las herramientas propias de Hercule y las instala en la estación,
dejándolas como comando y como acceso directo (con icono) en el menú de aplicaciones.

| App | Repo | Comando |
|-----|------|---------|
| **SEPTEM** (cifrador áureo) | `elsuinda/proyecto_aureo` | `septem start` / `septem stop` |
| **LA RATA** (OSINT noticias+perfiles) | `elsuinda/la_rata` | `larata start` / `larata stop` |

```bash
sudo ./instalar-apps.sh              # instala todas las apps
sudo ./instalar-apps.sh septem       # solo SEPTEM
sudo ./instalar-apps.sh --dry-run    # simula
```

Cada app se clona en `/opt/hercule-apps/<app>` y se instala con su propio `install.sh`
(entorno virtual aislado + comando global + `.desktop`). Para sumar una app nueva, se
agrega una línea al arreglo `APPS` del script.

---

## Registro (log)

Cada ejecución real queda registrada en:
```
/var/log/hercule-install.log
```

---

## Cómo encaja en el proyecto

Este instalador es la **Fase D** de Hercule. Usa el **tema de terminal** de la carpeta
`../terminal/` (Fase B+). En las próximas iteraciones se le puede sumar, de forma opcional
y modular, la instalación de herramientas OSINT/forenses base encuadradas en la
metodología "células grises".

---

*Instalador del proyecto Hercule, a cargo de Miguel.
— Hercule @v@   |   les petites cellules grises*
