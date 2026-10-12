# HERCULE — Identidad visual / Paleta

*Estética hacker aplicada a una marca de investigación. Negro de fondo, verde fósforo
para lo importante, naranja para acentos y texto secundario.*

---

## Colores

| Rol | Nombre | HEX | Uso |
|-----|--------|-----|-----|
| Fondo | Negro terminal | `#0A0E0A` | Fondo principal de todo |
| Fondo alt | Negro puro | `#000000` | Iconos, favicon |
| Primario | Verde fósforo | `#39FF14` | Lo importante: logo, títulos, bordes |
| Primario oscuro | Verde señal | `#1FA80B` | Sombras y trazos secundarios del verde |
| Acento | Naranja Hercule | `#FF6A00` | Texto de acento, el lema, detalles |
| Texto | Gris claro | `#C8D6C8` | Texto corrido sobre negro |
| Tenue | Verde apagado | `#2A3A2A` | Líneas de rejilla, scanlines, fondos sutiles |

### Variables CSS (listas para usar)

```css
:root {
  --herc-bg:        #0A0E0A;
  --herc-bg-pure:   #000000;
  --herc-green:     #39FF14;
  --herc-green-dk:  #1FA80B;
  --herc-orange:    #FF6A00;
  --herc-text:      #C8D6C8;
  --herc-grid:      #2A3A2A;
}
```

---

## Tipografías

| Uso | Fuente | Alternativa libre |
|-----|--------|-------------------|
| Logotipo / títulos | Mono con carácter | **DejaVu Sans Mono**, JetBrains Mono, Fira Code |
| Lema / detective | Serif elegante | **DejaVu Serif**, Playfair Display |
| Texto / UI | Mono legible | **DejaVu Sans Mono**, IBM Plex Mono |

El contraste **mono (hacker) + serif (detective clásico)** es la firma visual de
Hercule: lo técnico y lo elegante conviviendo.

---

## El símbolo

**La silueta de Hercule.** Busto del detective clásico a 3/4: **bombín, mostacho,
moñito y cuello del saco**. Recoloreado a verde fósforo sobre negro (estilo fósforo de
CRT), con los rasgos (ojos, cejas, mostacho) como espacio negativo oscuro. Se lee al
instante como "detective" y encaja perfecto con la terminal.

- Monocromo verde: elegante, directo, ideal para favicon, avatar y banner de terminal.
- El naranja de la marca vive en el lema y los acentos de texto, no en la silueta.
- Fuente editable: `_fuentes_svg/hercule-silueta-fuente.png` (silueta verde,
  fondo transparente) y `referencia-original.png`. El generador `hercule_sil.py`
  rearma todas las piezas.

---

## Reglas de uso

1. **Siempre sobre fondo oscuro.** La marca nace en terminal.
2. **Verde = importante.** No usar verde para relleno decorativo; se reserva para lo que
   debe destacar.
3. **Naranja con moderación.** Acentos y lema, no bloques grandes.
4. **Aire alrededor del logo.** Mínimo un radio de lupa de margen libre.

---

*— Hercule @v@   |   les petites cellules grises*
