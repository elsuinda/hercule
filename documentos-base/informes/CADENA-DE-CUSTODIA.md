# Cadena de custodia — [Caso Nº ___]

> Registro de cada pieza de evidencia: qué es, su hash, cuándo se obtuvo y quién la
> manipuló. Si la cadena se rompe, la evidencia pierde valor. Completá una fila por pieza.

**Responsable:** Miguel (Hercule)  ·  **Caso:** ___  ·  **Fecha de apertura:** AAAA-MM-DD

---

## Evidencias

| # | Descripción | Origen (de dónde salió) | Hash SHA-256 | Fecha/hora obtención | Ubicación de guardado |
|---|-------------|-------------------------|--------------|----------------------|-----------------------|
| 1 |             |                         |              |                      |                       |
| 2 |             |                         |              |                      |                       |

## Registro de manipulación (quién tocó qué y cuándo)

| Fecha/hora | Persona | Acción (copió / analizó / movió) | Evidencia # |
|------------|---------|----------------------------------|-------------|
|            |         |                                  |             |

---

### Cómo sacar el hash

```bash
sha256sum archivo_o_imagen        # un archivo
hashdeep -r -c sha256 carpeta/    # recursivo, varias piezas
```

Verificá que el hash de la **copia de trabajo** sea igual al del **original** antes de
analizar nada.

---

*— Hercule @v@  ·  les petites cellules grises*
