# GUÍA — Análisis de red y respuesta a incidentes

> Mirar el tráfico y reaccionar ante un incidente con orden. Primero entender, después
> actuar. No apagues ni borres nada hasta tener la foto completa (puede ser evidencia).

---

## Herramientas por tarea

| Tarea | Herramientas |
|-------|--------------|
| Mapear hosts y servicios | `nmap`, `masscan` |
| Capturar tráfico | `tcpdump`, `tshark` (Wireshark CLI) |
| Resolver / enumerar DNS | `dig`, `dnsrecon`, `dnsenum` |
| Ver conexiones del equipo | `ss -tulpn`, `netstat` (alias `ports`) |
| Ruta hacia un host | `mtr`, `traceroute` |

---

## Procedimiento: reconocimiento de red (autorizado)

1. **Alcance.** Rango/segmento autorizado y ventana horaria.
2. **Descubrimiento.** `nmap -sn 192.168.1.0/24` para ver hosts vivos.
3. **Servicios.** `nmap -sV -sC` sobre los hosts de interés.
4. **DNS.** `dnsrecon`/`dnsenum` sobre el dominio interno si aplica.
5. **Documentá** el inventario (host, servicios, versiones) en el informe.

---

## Procedimiento: respuesta a un incidente

**Escenario:** "Se sospecha que un equipo está comprometido."

1. **No improvises.** Definí si hay que **contener** (aislar de la red) o **preservar**
   (dejar corriendo para capturar evidencia). Esa decisión va antes que todo.
2. **Capturá el estado volátil** (si vas a preservar): conexiones (`ss -tulpn`),
   procesos, usuarios logueados, tráfico con `tcpdump -w captura.pcap`.
3. **Línea de tiempo.** Revisá logs del sistema con marcas de tiempo. Buscá lo que no
   cuadra (accesos raros, horarios, cuentas nuevas).
4. **Perfilá al adversario.** ¿Qué hizo? Mapealo a **MITRE ATT&CK** (ej. defacement web
   = T1491.001). Eso orienta qué buscar después.
5. **Contené y erradicá** solo cuando tengas la evidencia asegurada (hash de los pcap y
   logs). Aislá, cambiá credenciales, cerrá el vector.
6. **Informe.** Qué pasó, cómo, desde cuándo, qué se hizo y qué recomendás. Plantilla en
   `informes/`.

---

## Dónde guardar

`red/casos/AAAA-MM-DD_incidente/` — capturas (.pcap), logs y notas, cada uno con su hash.

---

*— Hercule @v@  ·  les petites cellules grises*
