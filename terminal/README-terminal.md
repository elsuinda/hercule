# HERCULE — Personalización de la terminal

*La silueta de Hercule, su paleta y su prompt, llevados a la terminal. Este es el germen
de la **Fase D** (el script de personalización de Debian 13): lo que acá queda como piezas
sueltas, el script de la Fase D lo instala y configura solo.*

---

## Qué hay en esta carpeta

| Archivo | Qué es |
|---------|--------|
| `hercule-banner.ans` | La silueta de Hercule en ANSI (verde, medios bloques). Se imprime tal cual. |
| `hercule-banner.txt` | La misma silueta en ASCII monocromo (fallback para terminales sin truecolor). |
| `hercule-banner.sh` | Imprime el banner + identidad + info del sistema (host, SO, kernel, uptime). |
| `hercule-colors.sh` | Define las variables de color de la paleta Hercule. |
| `hercule.bashrc` | Prompt (PS1) de dos líneas, banner al abrir la terminal y alias útiles. |
| `hercule.Xresources` | Esquema de 16 colores para xterm/urxvt. |
| `_gen_banner.py` | Regenera el banner desde la silueta (por si cambiás el ancho). |

---

## Cómo probarlo ya (Debian / Ubuntu / WSL)

Requisito: una terminal con **truecolor** (GNOME Terminal, Tilix, Kitty, Alacritty,
Windows Terminal, iTerm2 — casi todas las modernas lo tienen).

**1. Ver el banner una vez:**
```bash
bash /ruta/a/hercule/terminal/hercule-banner.sh
```

**2. Activar el prompt + banner en tus terminales:**
Agregá esta línea al final de tu `~/.bashrc`:
```bash
source /ruta/a/hercule/terminal/hercule.bashrc
```
y recargá:
```bash
source ~/.bashrc
```

**3. Colores de la terminal (xterm/urxvt):**
```bash
xrdb -merge /ruta/a/hercule/terminal/hercule.Xresources
```

Para otras terminales, usá la paleta de `hercule.Xresources` como referencia:
- **GNOME Terminal / Tilix:** Preferencias → Perfil → Colores → Personalizado, y cargá
  fondo `#0A0E0A`, texto `#C8D6C8`, y los 16 colores.
- **Kitty:** copiá los valores a `~/.config/kitty/kitty.conf` (`foreground`,
  `background`, `color0`..`color15`).
- **Alacritty:** a `~/.config/alacritty/alacritty.toml`, sección `[colors]`.
- **Windows Terminal (WSL):** a `settings.json`, en el `scheme` del perfil.

---

## El prompt

```
┌─[ usuario@host ]─[ ~/ruta ] (rama-git)
└─▶
```

- Corchetes y líneas en **verde señal** (tenue), usuario/host en **verde fósforo**,
  ruta en **naranja**, y la flecha `▶` en verde fósforo.
- Si estás dentro de un repo git, muestra la rama al final.
- Dos líneas: la de arriba con el contexto, la de abajo para escribir cómodo.

---

## Ajustar el tamaño del banner

Si el banner te resulta muy alto para tu terminal, regeneralo más chico:
```bash
# editar _gen_banner.py: en load_on_black(46) cambiar 46 por 36 (más chico) y correr:
python3 /ruta/a/hercule/terminal/_gen_banner.py
```

---

## Cómo se conecta con la Fase D (Debian 13)

El script de personalización de Debian 13 (Fase D del proyecto Hercule) va a:

1. Copiar esta carpeta a `~/.hercule/terminal/`.
2. Agregar el `source` del `hercule.bashrc` al `.bashrc` del usuario.
3. Aplicar el esquema de colores según la terminal detectada.
4. Opcional: instalar herramientas OSINT/forenses base y dejar los alias apuntando a
   ellas, encuadradas en la metodología "células grises".

Es decir: lo de acá es el **tema**; la Fase D es el **instalador** que lo deja andando
en una estación de trabajo nueva, con la estética y el método de Hercule.

---

*— Hercule @v@   |   les petites cellules grises*
