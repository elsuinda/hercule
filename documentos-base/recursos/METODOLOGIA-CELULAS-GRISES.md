# Metodología "Células Grises" — las 6 fases

> El método que ordena todo trabajo en Hercule. Es siempre el mismo, repetible y
> trazable. Vale para OSINT, pentest, forense y respuesta a incidentes.

---

### 1. ALCANCE — definir el caso
- **Pregunta de investigación:** ¿qué quiero saber exactamente? Una sola frase.
- **Autorización:** ¿tengo permiso? ¿cuál es el alcance (qué entra y qué no)?
- **Hipótesis:** 2 o 3 explicaciones posibles, para no fijarme en una sola.

### 2. RECOLECTA — juntar datos
- De lo más abierto a lo más profundo.
- **Registrar la fuente y la fecha/hora de CADA dato.**
- Entorno aislado (VM/contenedor), y nunca con cuentas personales.

### 3. VERIFICA — una fuente no es un hecho
Clasificá cada dato:
- `[CONFIRMADO]` dos o más fuentes independientes coinciden
- `[PROBABLE]` una fuente confiable, sin contradicción
- `[SIN VERIFICAR]` dato suelto (se arrastra marcado como tal)
- `[DESCARTADO]` contradicho por evidencia más fuerte

Buscá el dato que **contradiga** tu hipótesis, no solo el que la confirme.

### 4. ANALIZA — conectar los puntos
- **Línea de tiempo:** ordená los eventos. Los timestamps que no cuadran son oro.
- **Relaciones:** quién/qué se conecta con qué (Maltego, Gephi).
- **Adversario:** motivación, capacidad y TTPs → mapear a **MITRE ATT&CK**.

### 5. CONCLUYE — afirmar con responsabilidad
- Respondé la pregunta de la Fase 1.
- Separá **hecho / inferencia / suposición**.
- Nivel de confianza (alto / medio / bajo) y por qué.

### 6. DOCUMENTA — el informe firmado
- Usá `informes/PLANTILLA-INFORME.md`.
- En forense, mantené la **cadena de custodia** (hash SHA-256 de cada evidencia).

---

*— Hercule @v@  ·  les petites cellules grises*
