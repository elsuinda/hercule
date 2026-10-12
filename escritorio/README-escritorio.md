# HERCULE — Escritorio (fondos, iconos y undercover)

*Imágenes para personalizar el escritorio de la estación Hercule (Debian 13 u otros).*

---

## Qué hay

### `fondos/` — fondos de pantalla branded
| Archivo | Uso |
|---------|-----|
| `hercule-fondo-1920x1080.png` | Full HD (el principal) |
| `hercule-fondo-3840x2160.png` | 4K |
| `hercule-fondo-minimal-1920x1080.png` | Solo silueta, sin texto |
| `hercule-fondo-vertical-1080x1920.png` | Vertical / segundo monitor / celu |

Silueta verde fósforo con glow, lema y grilla sobre negro. Para tu escritorio de trabajo.

### `iconos-escritorio/` — iconos del sistema
| Archivo | Uso |
|---------|-----|
| `hercule-icono-128/256/512.png` | Icono de lanzador / app (con borde verde) |
| `hercule-usuario-login-512.png` | Avatar circular para la pantalla de login |

### `undercover/` — modo encubierto
Fondos **discretos** para cuando no querés que el equipo parezca una estación de
investigación/hacking (trabajo de campo, lugares públicos, reuniones). Pasan por un
fondo corporativo cualquiera: sin verde, sin Poirot, sin texto.

| Archivo | Uso |
|---------|-----|
| `hercule-undercover-slate-1920x1080.png` | Azul pizarra (principal) |
| `hercule-undercover-slate-3840x2160.png` | Azul pizarra 4K |
| `hercule-undercover-grafito-1920x1080.png` | Gris grafito |
| `hercule-undercover-guino-1920x1080.png` | Igual al slate pero con la silueta al ~2% (solo vos sabés que está) |

La idea: tener a mano un fondo "normal" para cambiar en un segundo y no exponer la
identidad Hercule cuando estás encubierto.

---

## Cómo aplicarlos en Debian 13 (GNOME)

**Fondo de pantalla** (interfaz): Configuración → Fondo → Añadir imagen, y elegís el PNG.

**Fondo por consola** (GNOME):
```bash
gsettings set org.gnome.desktop.background picture-uri "file:///ruta/hercule-fondo-1920x1080.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///ruta/hercule-fondo-1920x1080.png"
gsettings set org.gnome.desktop.background picture-options "zoom"
```
Para pasar a **undercover** al instante, el mismo comando apuntando al fondo undercover.

**Avatar de login** (GNOME/AccountsService):
```bash
sudo cp hercule-usuario-login-512.png /var/lib/AccountsService/icons/hercule
# luego en /var/lib/AccountsService/users/hercule agregar o editar:  Icon=/var/lib/AccountsService/icons/hercule
```

**Icono de lanzador**: usalo en el `.desktop` de una app propia con
`Icon=/ruta/hercule-icono-256.png`.

---

## Regenerar / ajustar

Todo sale del generador `_gen_escritorio.py` (usa la silueta fuente del proyecto).
Se pueden cambiar colores, tamaños y el nivel del "guiño" undercover editando ese script.

---

*— Hercule @v@   |   les petites cellules grises*
