#!/usr/bin/env bash

# Cambiar explícitamente al directorio del proyecto
cd /home/pi/projects/display-on-eink-random-photo || exit 1

LOG_DIR="logs/eink_random_info"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d)

# Ejecutar el script desde el directorio correcto
./display_on_eink_random_info_from_api_url.sh >> "$LOG_DIR/run_${TIMESTAMP}.log" 2>&1
