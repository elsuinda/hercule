# HERCULE — Empezar acá

> Bienvenido a tu estación de investigación **Hercule** (Debian 13 personalizada).
> Esta carpeta es tu base de trabajo y tu manual. Si no sabés por dónde arrancar, leé esto.

*Les petites cellules grises: pensá el caso antes de lanzar la herramienta.*

---

## Cómo está organizado

Dentro de `Documents/Hercule/` tenés una carpeta por temática. En cada una hay una
**GUÍA** (qué herramientas usar y el procedimiento) y subcarpetas para tu trabajo real:

| Carpeta | Para qué es |
|---------|-------------|
| `osint/` | Investigación de fuentes abiertas (personas, dominios, infraestructura, redes) |
| `pentest/` | Pruebas de intrusión **autorizadas** (hacking ético) |
| `forense/` | Análisis forense de discos, archivos y evidencia digital |
| `red/` | Análisis de red y respuesta a incidentes |
| `informes/` | Plantilla de informe y cadena de custodia; acá guardás lo que entregás |
| `recursos/` | Metodología "células grises" y hoja de comandos rápida |
| `utilidades/` | Herramientas de apoyo (cifrado, etc.) instaladas con Hercule |

En cada temática, `casos/` es donde creás **una carpeta por cada caso** que trabajás.

> **Fichas de herramientas:** cuando instalás las apps propias de Hercule (SEPTEM, LA
> RATA, …), cada una deja su **ficha de uso** en la subcarpeta `apps/` de su categoría —
> por ejemplo `osint/apps/larata.md` o `utilidades/apps/septem.md`. Ahí tenés cómo se
> abre/cierra cada herramienta y cómo encaja en el método.

---

## La regla de oro (vale para todo)

1. **Autorización primero.** No se investiga ni se prueba nada sin permiso por escrito y
   un alcance definido. El "ético" de hacking ético es la línea que no se cruza.
2. **Pensá antes de escanear.** Una hipótesis clara vale más que diez horas de ruido.
3. **Anotá todo con fecha y hora.** La fuente de cada dato. Si no está anotado, no pasó.
4. **Separá hecho / inferencia / suposición.** No mezcles lo que sabés con lo que creés.

---

## Flujo de trabajo (las 6 fases)

Todo caso sigue el mismo camino. Está explicado en
`recursos/METODOLOGIA-CELULAS-GRISES.md`:

```
1. ALCANCE  →  2. RECOLECTA  →  3. VERIFICA  →  4. ANALIZA  →  5. CONCLUYE  →  6. DOCUMENTA
```

---

## Primeros comandos útiles

- `hercule-tools` — muestra todas las herramientas instaladas, ordenadas por fase.
- `hhelp` — ayuda rápida de los alias de Hercule.
- `normal` / `undercover` — cambia el fondo de pantalla (branded / discreto).

---

## Cómo arrancar un caso nuevo (ejemplo)

```bash
# 1. elegí la temática y creá la carpeta del caso con fecha
mkdir -p ~/Documents/Hercule/osint/casos/2026-10-11_nombre-del-caso
cd ~/Documents/Hercule/osint/casos/2026-10-11_nombre-del-caso

# 2. copiá la plantilla de informe para ir completando
cp ~/Documents/Hercule/informes/PLANTILLA-INFORME.md ./informe.md

# 3. leé la guía de la temática y seguí el procedimiento
#    (osint/GUIA-OSINT.md en este ejemplo)
```

---

*Estación Hercule — Miguel.
— Hercule @v@  ·  les petites cellules grises*
