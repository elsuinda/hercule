# 🔍 HERCULE

> Identidad operativa para **investigación, ciberinteligencia y hacking ético**.
> Inspirada en el método de Hercule Poirot: *les petites cellules grises*.

Este directorio reúne todo sobre Hercule: el perfil, la identidad visual, el tema de
terminal, el escritorio, los documentos base y el instalador de Debian 13.

---

## ⚠️ Uso responsable

Hercule es para **investigación OSINT, ciberinteligencia y hacking ético**. Usá sus
herramientas y guías **solo** sobre objetivos para los que tengas **autorización expresa**
y dentro del marco legal. El instalador de Debian 13 realiza acciones administrativas
(crea un usuario con contraseña por defecto, puede eliminar usuarios): **probalo siempre
con `--dry-run` primero**. Ver `SECURITY.md` para el detalle.

---

## Estructura

```
hercule/
├── README.md                      ← este archivo
├── perfil/
│   ├── 00_IDENTIDAD.md            ← qué es Hercule, lema, voz, firma
│   ├── 01_MANIFIESTO.md           ← los 8 principios operativos
│   ├── 02_METODOLOGIA.md          ← marco "células grises" (6 fases)
│   ├── 03_BIO_REDES.md            ← bios listas para cada red social
│   └── 04_EVALUACION_ECOSISTEMA.md ← cómo Hercule integra tus proyectos
├── identidad-visual/
│   ├── paleta.md                  ← colores, tipografías, uso
│   ├── logo/                      ← logo maestro (SVG + PNG)
│   ├── iconos/                    ← favicon, app, perfil (varios tamaños)
│   ├── redes/                     ← avatar y banners para redes
│   └── _fuentes_svg/              ← fuentes editables SVG
├── terminal/                     ← tema de terminal (banner, prompt, colores)
│   ├── PREVISUALIZACION-TERMINAL.png
│   ├── hercule-banner.sh/.ans/.txt
│   ├── hercule.bashrc            ← prompt + banner + alias
│   ├── hercule-colors.sh / hercule.Xresources
│   └── README-terminal.md
├── escritorio/                   ← fondos de pantalla, iconos y modo undercover
│   ├── fondos/ · iconos-escritorio/ · undercover/
│   └── README-escritorio.md
├── documentos-base/              ← guías por temática que el instalador copia a Documents
│   ├── 00-EMPEZAR-ACA.md
│   ├── osint/ · pentest/ · forense/ · red/ · informes/ · recursos/
│   └── (cada temática: GUIA + carpeta casos/)
└── instalador-debian13/          ← Fase D: instalador para Debian 13
    ├── instalar-hercule.sh       ← crea usuario + tema + modo oscuro + autoactualizacion (root, --dry-run)
    ├── instalar-herramientas.sh  ← toolkit OSINT/forense/red por fase
    ├── instalar-apps.sh          ← apps propias (SEPTEM, LA RATA, BLACKCAT)
    ├── actualizar-hercule.sh     ← logica del comando 'hercule-update'
    ├── hercule-autoupdate.sh     ← enganche con apt (autoactualizacion al actualizar el SO)
    ├── aplicar-terminal-gnome.sh ← paleta de GNOME Terminal (1er login)
    ├── README.md
    └── .gitignore
```

---

## Actualización

Al instalarse, Hercule deja una copia del proyecto en `/opt/hercule` y el comando
**`hercule-update`**. Cuando el repositorio reciba cambios (nuevas funciones, apps o
correcciones), se actualiza el sistema ya instalado con:

```bash
sudo hercule-update            # trae cambios y re-aplica (personalizacion + apps)
sudo hercule-update --check    # solo informa si hay novedades, no aplica
sudo hercule-update --tools    # ademas actualiza el toolkit OSINT/forense
sudo hercule-update --dry-run  # simula, sin cambiar nada
```

Trae los cambios con `git pull`, re-aplica tema, guías y apps, y **nunca toca tus
casos ni informes** en `Documents/Hercule/`.

### Automática al actualizar el SO

El instalador deja además un **enganche con APT**: cada vez que actualizás el
sistema (`sudo apt update`), Hercule revisa su repositorio y, si hay cambios, lanza
la actualización en segundo plano (desacoplada del gestor de paquetes, sin frenar
`apt`). Así la actualización de Hercule acompaña a la del sistema operativo.

- Se controla desde `/etc/hercule/autoupdate.conf` (variable `MODO`):
  `auto` aplica los cambios solo (por defecto), `check` solo avisa y los aplicás
  con `sudo hercule-update`, `off` no revisa nada.
- Para desactivarlo del todo también podés borrar `/etc/apt/apt.conf.d/99hercule-update`.

> **Seguridad:** el modo `auto` ejecuta código del repositorio como root sin
> supervisión (modelo de confianza de "actualización automática"). En equipos
> sensibles conviene `check` u `off` y aplicar a mano tras revisar los cambios.
> La copia en `/opt/hercule` queda como `root` y no escribible por el usuario.

---

## Estado del proyecto

| Fase | Entregable | Estado |
|------|-----------|--------|
| A | Perfil completo | ✅ Listo |
| B | Identidad visual (silueta, logo, iconos, redes) | ✅ Listo |
| B+ | Tema de terminal (banner, prompt, colores) | ✅ Listo |
| C | Escritorio (fondos, iconos, undercover) | ✅ Listo |
| D | Instalador de Debian 13 (usuario, modo oscuro/paleta, herramientas, documentos base) | ✅ Listo |

---

## Principio rector

> **"El orden y el método. Siempre el orden y el método."**
> El análisis le gana a la fuerza bruta. Antes de la herramienta, la pregunta.

---

*— Hercule @v@   |   les petites cellules grises*
