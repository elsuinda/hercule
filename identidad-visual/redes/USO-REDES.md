# HERCULE — Guía de uso en redes

*Qué archivo va en cada lugar. Todas las piezas están en esta carpeta y en `../iconos`.*

---

## Qué archivo usar en cada plataforma

| Plataforma | Foto de perfil | Portada / banner |
|------------|----------------|------------------|
| X / Twitter | `avatar-400.png` | `banner-x-1500x500.png` |
| Instagram | `avatar-400.png` | — |
| LinkedIn | `avatar-400.png` | `banner-linkedin-1584x396.png` |
| Facebook / YouTube | `avatar-1000.png` | `banner-cover-1920x1080.png` |
| GitHub (perfil/org) | `avatar-400.png` | — (usar logo horizontal en el README) |
| Sitio web / blog | `../iconos/favicon.ico` + `favicon.svg` | `../logo/hercule-horizontal.png` |

---

## Zonas seguras (importante)

- **X / Twitter:** la foto de perfil (círculo) tapa la **esquina inferior izquierda**
  del banner. Por eso el emblema del banner está corrido hacia el centro-izquierda y el
  texto a la derecha: nada importante queda debajo del avatar.
- **Avatares:** casi todas las redes recortan en **círculo**. El `avatar` ya está
  diseñado para eso: el emblema va centrado y la grilla de las esquinas se pierde sin
  problema.
- **LinkedIn banner:** el recorte visible varía según dispositivo; el texto está dentro
  del tercio central vertical para que no se corte.

---

## Favicon (para web)

En el `<head>` de tu sitio:

```html
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link rel="icon" type="image/x-icon" href="/favicon.ico">
<link rel="apple-touch-icon" href="/app-icon-512.png">
```

El favicon usa la versión **verde monocromática** (sin naranja) porque a 16-32 px el
detalle del bigote naranja se pierde; en verde puro se lee mejor.

---

## Reglas rápidas

1. Siempre sobre fondo oscuro.
2. No deformes el logo (mantené proporción).
3. No cambies los colores de la marca.
4. Dejá aire alrededor del emblema (al menos medio radio de lupa).
5. Mismo avatar y mismo handle en todas las redes = marca reconocible y difícil de
   suplantar.

---

*— Hercule @v@   |   les petites cellules grises*
