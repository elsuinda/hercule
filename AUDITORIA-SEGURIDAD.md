# Auditoría de seguridad y buenas prácticas — Repositorio Hercule

**Autor:** Miguel (Hercule)
**Fecha:** 2026-10-12
**Alcance:** Repositorio completo `github.com/elsuinda/hercule` (69 archivos).
**Objetivo:** Verificar que el repositorio no exponga riesgos de seguridad y que cumpla
buenas prácticas de desarrollo.

---

## 1. Resumen ejecutivo

El repositorio **no contiene secretos ni código malicioso**, y los scripts no usan
patrones peligrosos (`curl | bash`, `rm -rf` sin control, `chmod 777`, escritura directa
a dispositivos). Se detectaron y **corrigieron** cuatro puntos de mejora: una regla de
`.gitignore` que dejaba la estructura incompleta, la contraseña por defecto sin cambio
forzado, y la ausencia de `LICENSE`, `SECURITY.md` y advertencia de uso ético. Tras las
correcciones, el repositorio queda en buen estado para ser público.

**Nivel de riesgo final:** Bajo.

---

## 2. Verificaciones realizadas

| Verificación | Resultado |
|--------------|-----------|
| Secretos embebidos (tokens, API keys, claves privadas) | ✅ Ninguno |
| Patrones peligrosos en scripts (`eval`, `curl\|bash`, `rm -rf`, `dd`, `mkfs`) | ✅ Ninguno |
| Archivos sensibles versionados (logs, casos, evidencia, zips) | ✅ Ninguno |
| `set -euo pipefail` en scripts de instalación | ✅ Presente |
| Permisos de archivos (git mode) | ✅ Correctos (solo los 3 instaladores son 755) |
| Manejo de errores y confirmaciones en acciones destructivas | ✅ Doble confirmación + `--dry-run` |

---

## 3. Hallazgos y correcciones aplicadas

### H1 — `.gitignore` dejaba la estructura incompleta *(corregido)*
La regla ignoraba los directorios `casos/`, `evidencia/` e `informes/emitidos/` enteros,
por lo que sus `LEEME.txt` (placeholders de la estructura) no se versionaban y el árbol
del template quedaba incompleto al clonar.
**Corrección:** se cambió a ignorar el *contenido* (`/*`) y re-incluir explícitamente
cada `LEEME.txt`. Ahora se versiona la estructura pero **nunca** un caso real.

### H2 — Contraseña por defecto débil sin cambio forzado *(corregido)*
El instalador crea el usuario `hercule` con contraseña por defecto igual al nombre de
usuario (decisión funcional conocida). Riesgo si el equipo queda accesible antes del
primer cambio.
**Corrección:** se agregó `chage -d 0 hercule`, que **obliga a cambiar la contraseña en
el primer inicio de sesión**, y una advertencia explícita en pantalla. Documentado en
`SECURITY.md`.

### H3 — Faltaba `LICENSE` *(corregido)*
Un repositorio público sin licencia deja indefinidos los derechos de uso.
**Corrección:** se agregó licencia **MIT** a nombre de Miguel. *(Cambiable si se prefiere
otra; MIT es permisiva y estándar para proyectos de divulgación.)*

### H4 — Faltaban `SECURITY.md` y advertencia de uso ético *(corregido)*
Un repositorio de herramientas OSINT/pentest debe dejar explícito el uso responsable y
cómo reportar problemas.
**Corrección:** se agregó `SECURITY.md` (uso responsable, advertencias del instalador,
qué no versionar, reporte privado) y una sección **"Uso responsable"** en el `README.md`.

---

## 4. Observaciones (sin acción obligatoria)

- **O1 — Herramientas `go install` sin versión fijada.** `amass`, `subfinder` y
  `phoneinfoga` se instalan con `@latest`/`@master`. Es la práctica habitual para estas
  herramientas, pero implica confiar en la última versión publicada (riesgo de
  supply-chain). Si se busca reproducibilidad, se pueden fijar versiones concretas.
- **O2 — Scripts de `source` sin `set -e` (correcto).** `hercule-banner.sh`,
  `hercule-colors.sh` y `aplicar-terminal-gnome.sh` no usan `set -euo pipefail` a
  propósito: los dos primeros se cargan con `source` desde `.bashrc` (un `set -e` ahí
  rompería la shell del usuario) y el tercero usa `|| true` de forma defensiva. No es un
  defecto.
- **O3 — Repositorio público.** El contenido no tiene secretos, pero el instalador puede
  eliminar usuarios; la documentación lo advierte. Si en algún momento se quiere limitar
  la difusión, puede volverse privado.

---

## 5. Conclusión

El repositorio quedó **ordenado, documentado y sin exposición de datos sensibles**. Las
cuatro correcciones aplicadas elevan el estándar de seguridad y de buenas prácticas de
desarrollo. No se identificaron vulnerabilidades que impidan mantenerlo público.

---

*Auditoría realizada y supervisada por Miguel.
— Hercule @v@  ·  les petites cellules grises*
