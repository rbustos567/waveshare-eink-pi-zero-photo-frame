#!/usr/bin/env bash

mode=$1
photo_query=$2

# Cambiar explícitamente al directorio del proyecto
cd /home/pi/projects/display-on-eink-random-photo || exit 1

LOG_DIR="logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d)

# Ejecutar el script desde el directorio correcto
./display_on_eink_random_info_photo.sh $mode "$photo_query" >> "$LOG_DIR/run_${TIMESTAMP}.log" 2>&1
