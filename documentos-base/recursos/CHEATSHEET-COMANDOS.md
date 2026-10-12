# Hoja de comandos rápida — Hercule

> Los comandos que más vas a usar, por tema. Copiá, cambiá el objetivo, y adelante.
> Recordá: autorización primero, y pensá antes de lanzar.

---

## Hercule (propios)
```bash
hercule-tools          # lista el toolkit por fase
hhelp                  # ayuda de alias
normal | undercover    # cambiar fondo (branded / discreto)
ports                  # conexiones y puertos en escucha
myip                   # tu IP publica
```

## OSINT
```bash
sherlock usuario                      # cuentas por nombre de usuario
maigret usuario                       # idem, mas fuentes
holehe correo@dominio.com             # donde esta registrado un email
subfinder -d dominio.com              # subdominios
amass enum -d dominio.com             # subdominios (mas profundo)
theHarvester -d dominio.com -b all    # correos/hosts
whatweb https://sitio                 # tecnologias del sitio
whois dominio.com ; dig dominio.com   # registros
exiftool archivo.jpg                  # metadatos
dnstwist dominio.com                  # dominios falsos / typosquatting
phoneinfoga scan -n "+54911XXXXXXX"   # telefono
```

## Red
```bash
nmap -sn 192.168.1.0/24               # hosts vivos
nmap -sV -sC 192.168.1.10             # servicios y versiones
tcpdump -i eth0 -w captura.pcap       # capturar trafico
tshark -r captura.pcap                # leer captura
dnsrecon -d dominio.com               # enumeracion DNS
```

## Pentest (autorizado)
```bash
gobuster dir -u https://sitio -w lista.txt   # rutas/archivos ocultos
ffuf -u https://sitio/FUZZ -w lista.txt      # fuzzing
nikto -h https://sitio                       # problemas conocidos
sqlmap -u "https://sitio?id=1"               # inyeccion SQL (si autorizado)
hydra -l user -P claves.txt ssh://IP         # fuerza bruta (si autorizado)
john hash.txt ; hashcat -m 0 hash.txt dic    # crackeo offline
```

## Forense
```bash
sha256sum medio.img                   # hash del original
ddrescue /dev/sdX copia.img log       # clonado seguro
mmls copia.img                        # particiones
fls -r copia.img                      # archivos (incl. borrados)
foremost -i copia.img -o salida/      # recuperar borrados
binwalk archivo.bin                   # analizar firmware/contenedor
bulk_extractor -o salida/ copia.img   # extraer artefactos
steghide extract -sf imagen.jpg       # datos ocultos
```

---

*— Hercule @v@  ·  les petites cellules grises*
