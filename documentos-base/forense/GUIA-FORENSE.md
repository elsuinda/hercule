# GUÍA — Forense digital

> Analizar evidencia digital preservando su integridad. Lo más importante del forense no
> es la herramienta: es la **cadena de custodia**. Si la evidencia se altera, no sirve.

> ⚠️ Trabajá SIEMPRE sobre una COPIA. Nunca sobre el original.

---

## Herramientas por tarea

| Tarea | Herramientas |
|-------|--------------|
| Imagen de disco / análisis | `sleuthkit` (mmls, fls, icat), `autopsy`, `ewf-tools` |
| Recuperar archivos borrados | `foremost`, `testdisk`, `sleuthkit` |
| Analizar un archivo/firmware | `binwalk` |
| Clonado seguro de un disco | `ddrescue` |
| Datos ocultos en imágenes | `steghide` |
| Metadatos | `exiftool` |
| Hashes / verificación | `hashdeep`, `sha256sum` |
| Extracción masiva de artefactos | `bulk_extractor` |

---

## Procedimiento para un escenario genérico

**Escenario:** "Analizar un medio (disco/pendrive/imagen) en busca de evidencia."

1. **Alcance y custodia.** Registrá qué recibiste, de quién, cuándo. Sacá el **hash
   SHA-256** del original apenas lo tengas: `sha256sum medio.img` → anotalo.
2. **Copia de trabajo.** Cloná con `ddrescue` y verificá que el hash de la copia
   coincide con el del original. A partir de ahí trabajás sobre la copia.
3. **Inventario.** `mmls copia.img` (particiones), `fls -r` (archivos, incl. borrados).
   `binwalk` si es firmware o un archivo contenedor.
4. **Recuperación.** `foremost`/`testdisk` para archivos borrados; `icat` para extraer
   por inodo. Guardá lo recuperado en `evidencia/`.
5. **Búsqueda dirigida.** `bulk_extractor` para correos, URLs, tarjetas, etc.;
   `exiftool` para metadatos; `steghide` si sospechás esteganografía.
6. **Línea de tiempo.** Ordená por timestamps (creación/modificación/acceso). Las
   inconsistencias de tiempo suelen ser la clave.
7. **Informe + custodia.** Completá `informe.md` y la `CADENA-DE-CUSTODIA.md`. Cada pieza
   de evidencia va con su hash y de dónde salió.

---

## Cadena de custodia (regla)

Por cada evidencia anotá: **qué es, hash SHA-256, cuándo se obtuvo, quién la tocó, dónde
se guarda.** Usá la plantilla `informes/CADENA-DE-CUSTODIA.md`.

---

## Dónde guardar

- `forense/casos/AAAA-MM-DD_caso/` — notas y análisis del caso.
- `forense/evidencia/` — copias de trabajo y artefactos extraídos (con sus hashes).

---

*— Hercule @v@  ·  les petites cellules grises*
