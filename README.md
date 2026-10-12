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
    ├── instalar-hercule.sh       ← crea usuario + instala tema (root, --dry-run)
    ├── instalar-herramientas.sh  ← toolkit OSINT/forense/red por fase
    ├── aplicar-terminal-gnome.sh ← paleta de GNOME Terminal (1er login)
    ├── README.md
    └── .gitignore
```

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
