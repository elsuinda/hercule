# Política de seguridad — Hercule

## Uso responsable

Hercule es un proyecto de **investigación OSINT, ciberinteligencia y hacking ético**.
Las herramientas y guías que incluye están pensadas para usarse **únicamente** sobre
sistemas y objetivos para los que se tenga **autorización expresa** y dentro del marco
legal aplicable. El uso indebido es responsabilidad exclusiva de quien lo realice.

## Advertencias del instalador

El instalador de Debian 13 (`instalador-debian13/`) realiza acciones administrativas:

- Crea un usuario con una **contraseña por defecto débil y conocida**. El sistema fuerza
  su cambio en el primer inicio de sesión; cambiala igualmente lo antes posible.
- Puede **eliminar otros usuarios** del sistema (acción irreversible, con doble
  confirmación). Probá siempre con `--dry-run` antes de ejecutarlo en real.
- Instala herramientas de terceros desde repositorios públicos (apt, pipx, go, git).

## Qué NO versionar

Este repositorio es un **template**. No subas nunca:

- Casos reales, evidencia, informes con datos de clientes o de personas (las carpetas
  `casos/`, `evidencia/` e `informes/emitidos/` están protegidas por `.gitignore`).
- Credenciales, tokens, claves API o archivos de configuración con secretos.
- Logs de ejecución de los instaladores.

## Reportar un problema de seguridad

Si encontrás un problema de seguridad en este proyecto, reportalo de forma privada al
responsable del repositorio (no abras un issue público con los detalles). Se dará
respuesta y, de corresponder, se corregirá antes de divulgarlo.

---

*— Hercule @v@  ·  les petites cellules grises*
