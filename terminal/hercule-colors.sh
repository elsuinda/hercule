#!/usr/bin/env bash
# HERCULE — paleta de colores para la terminal (truecolor / 24-bit).
# Se incluye (source) desde hercule.bashrc y hercule-banner.sh.

# Colores de marca (verde fosforo, naranja, verde apagado)
HERC_GREEN="\[\e[38;2;57;255;20m\]"     # verde fosforo  (#39FF14) - lo importante
HERC_GREEN_DK="\[\e[38;2;31;168;11m\]"  # verde senal    (#1FA80B) - bordes/dim
HERC_ORANGE="\[\e[38;2;255;106;0m\]"    # naranja        (#FF6A00) - acentos
HERC_TEXT="\[\e[38;2;200;214;200m\]"    # gris verdoso   (#C8D6C8) - texto
HERC_RESET="\[\e[0m\]"

# Variantes sin el \[...\] (para echo -e fuera del prompt)
E_GREEN="\e[38;2;57;255;20m"
E_GREEN_DK="\e[38;2;31;168;11m"
E_ORANGE="\e[38;2;255;106;0m"
E_TEXT="\e[38;2;200;214;200m"
E_RESET="\e[0m"
