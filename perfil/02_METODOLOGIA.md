# HERCULE — Metodología "Células Grises"

*Marco de trabajo operativo para investigación OSINT, ciberinteligencia y forense.
Es el "cómo" detrás de la identidad: un proceso de seis fases, repetible y trazable.*

---

## Las 6 fases

```
   ┌───────────┐   ┌─────────────┐   ┌────────────┐
   │ 1. ALCANCE│──▶│ 2. RECOLECTA│──▶│ 3. VERIFICA│──┐
   └───────────┘   └─────────────┘   └────────────┘  │
                                                      ▼
   ┌───────────┐   ┌─────────────┐   ┌────────────┐
   │ 6. DOCUMEN│◀──│ 5. CONCLUYE │◀──│ 4. ANALIZA │
   └───────────┘   └─────────────┘   └────────────┘
```

---

### Fase 1 — ALCANCE (definir el caso)

Antes de tocar una herramienta:
- **Pregunta de investigación:** ¿qué se quiere saber exactamente? Una sola frase.
- **Autorización:** ¿hay permiso? ¿cuál es el alcance legal/ético? Sin esto, no se empieza.
- **Hipótesis iniciales:** 2 o 3 explicaciones posibles, para no fijarse en una sola.
- **Límites:** qué queda adentro y qué queda afuera (dominios, personas, plazos).

> *Regla Poirot:* el que no define el caso termina investigando el caso equivocado.

---

### Fase 2 — RECOLECTA (OSINT disciplinado)

Recolección por capas, de lo más abierto a lo más profundo. **Siempre registrar la
fuente y la fecha/hora de cada dato.**

| Capa | Qué se busca | Herramientas base |
|------|--------------|-------------------|
| Identidad | nombres, alias, correos, usuarios | Sherlock, Holehe, Maltego |
| Infraestructura | dominios, IPs, ASN, DNS, certificados | amass, crt.sh, Shodan, GeoIP* |
| Redes sociales | cuentas, conexiones, actividad, bots | Twint/alternativas, Gephi |
| Documentos | metadatos, autores, software | exiftool, FOCA |
| Fugas | credenciales, bases filtradas | HaveIBeenPwned, dehashed |

\* *La herramienta GeoIP de Owltech encaja acá como fuente propia de enriquecimiento de IP.*

**Higiene operativa:** usar entorno aislado (Kali en VM/contenedor), VPN cuando
corresponda, y nunca autenticarse con cuentas personales en objetivos de investigación.

---

### Fase 3 — VERIFICA (una fuente no es un hecho)

Cada dato recolectado se clasifica:

- **[CONFIRMADO]** — dos o más fuentes independientes coinciden.
- **[PROBABLE]** — una fuente confiable, sin contradicción.
- **[SIN VERIFICAR]** — dato suelto, se arrastra marcado como tal.
- **[DESCARTADO]** — contradicho por evidencia más fuerte.

Se cruza, se busca el dato que *contradiga* la hipótesis (no solo el que la confirme —
sesgo de confirmación), y se deja constancia de qué quedó sin poder verificarse.

---

### Fase 4 — ANALIZA (conectar los puntos)

- **Línea de tiempo:** ordenar eventos cronológicamente. Los timestamps que no cuadran
  son oro.
- **Grafo de relaciones:** entidades y sus vínculos (Maltego / Gephi). El patrón
  aparece cuando se ve el conjunto, no el dato aislado.
- **Perfilado del adversario:** motivación, capacidad, TTPs. Mapear a **MITRE ATT&CK**
  (ej. defacement → T1491.001, como en el caso Drupal ya investigado).
- **Hipótesis sobreviviente:** de las 2-3 iniciales, cuál resiste la evidencia y cuáles
  caen, y por qué.

---

### Fase 5 — CONCLUYE (afirmar con responsabilidad)

- Respuesta directa a la pregunta de la Fase 1.
- Separar explícitamente **hecho / inferencia / suposición**.
- Nivel de confianza (alto / medio / bajo) con su justificación.
- Qué faltó y qué haría falta para cerrarlo (líneas abiertas).

---

### Fase 6 — DOCUMENTA (el informe firmado)

El entregable final. Estructura estándar Hercule:

```
1. Resumen ejecutivo (3-5 líneas, para quien no es técnico)
2. Alcance y autorización
3. Metodología y herramientas usadas
4. Hallazgos (con nivel de verificación por cada uno)
5. Línea de tiempo / grafo
6. Perfilado del adversario (si aplica)
7. Conclusiones y nivel de confianza
8. Recomendaciones
9. Anexos: evidencia, fuentes con fecha/hora, hashes
```

**Cadena de custodia (forense):** hash SHA-256 de cada pieza de evidencia, registro de
quién la tocó y cuándo, copias de trabajo (nunca sobre el original).

> Los informes formales se firman **a nombre de Miguel como autor y supervisor**, no
> como producto de una IA ni como borrador pendiente de revisión.

---

## Caja de herramientas de referencia

- **OSINT:** Maltego, Sherlock, Holehe, SpiderFoot, theHarvester, Twint/alternativas
- **Infra:** Shodan, Censys, amass, nmap, crt.sh, GeoIP propia (Owltech)
- **Forense:** Autopsy, Volatility, exiftool, DBeaver (sobre Kali), PowerShell forense
- **Análisis/visual:** Gephi, Maltego, timelines
- **Entorno:** Kali Linux, VMs (ESXi/Proxmox), contenedores, WireGuard

---

*— Hercule @v@   |   les petites cellules grises*
