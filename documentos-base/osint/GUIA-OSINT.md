# GUÍA — OSINT (investigación de fuentes abiertas)

> Recolectar e interpretar información pública con método. Qué herramienta usar en cada
> paso y cómo encararlo. Seguí siempre las 6 fases (ver `recursos/`).

> ⚠️ Solo sobre objetivos autorizados. No hostigues ni expongas a personas privadas.

---

## Herramientas por tipo de dato

| Qué buscás | Herramientas | Ejemplo rápido |
|------------|--------------|----------------|
| Usuario / alias en redes | `sherlock`, `maigret` | `sherlock usuario` |
| Si un email está en sitios/filtraciones | `holehe` | `holehe correo@dominio.com` |
| Dominios, subdominios | `amass`, `subfinder`, `theHarvester` | `subfinder -d dominio.com` |
| Infraestructura / web | `whatweb`, `dmitry`, `whois`, `dig` | `whatweb https://sitio` |
| Metadatos de archivos/fotos | `exiftool` | `exiftool foto.jpg` |
| Variantes typosquatting de un dominio | `dnstwist` | `dnstwist dominio.com` |
| Teléfono | `phoneinfoga` | `phoneinfoga scan -n "+54911..."` |
| Todo-en-uno / reconocimiento | `spiderfoot`, `recon-ng` | `spiderfoot -l 127.0.0.1:5001` |

---

## Procedimiento para un escenario genérico

**Escenario:** "Investigar la huella digital de un objetivo (persona, empresa o dominio)."

1. **Alcance.** Escribí la pregunta exacta (¿qué querés saber del objetivo?) y confirmá
   que tenés autorización. Definí qué queda afuera.
2. **Identidad.** Si es persona/alias: `sherlock` y `maigret` para cuentas; `holehe`
   para el email. Anotá cada hallazgo con la URL y la fecha.
3. **Infraestructura.** Si es dominio/empresa: `subfinder`/`amass` para subdominios,
   `whois` y `dig` para registros, `whatweb` para tecnologías.
4. **Enriquecimiento.** `exiftool` sobre imágenes/documentos públicos (autor, GPS,
   software). `dnstwist` para detectar dominios falsos relacionados.
5. **Verificá.** Cruzá cada dato con una segunda fuente. Marcá CONFIRMADO / PROBABLE /
   SIN VERIFICAR. Descartá lo que se contradiga.
6. **Analizá.** Armá una línea de tiempo y un mapa de relaciones (quién se conecta con
   qué). Si hay un adversario, perfilá motivación y capacidad.
7. **Documentá.** Completá `informe.md` (plantilla en `informes/`). Guardá capturas en
   la carpeta del caso.

---

## Higiene operativa (OPSEC)

- Trabajá en una VM o perfil separado; usá VPN cuando corresponda.
- Nunca te loguees en el objetivo con cuentas personales.
- Guardá evidencia (capturas, exports) con nombre `AAAA-MM-DD_descripcion`.

---

## Dónde guardar

`osint/casos/AAAA-MM-DD_nombre-del-caso/` — una carpeta por caso.

---

*— Hercule @v@  ·  les petites cellules grises*
