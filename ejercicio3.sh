#!/bin/bash
DIR="${1:-$HOME/monitoreado}"
LOG="${2:-$HOME/monitor_cambios.log}"

mkdir -p "$DIR"
touch "$LOG"

echo "[$(date '+%F %T')] Iniciando monitoreo en: $DIR" >> "$LOG"

inotifywait -m -e create,modify,delete --format '%T %w %e %f' --timefmt '%F %T' "$DIR" \
| while read -r FECHA RUTA EVENTO ARCHIVO; do
    echo "[$FECHA] $EVENTO en ${RUTA}${ARCHIVO}" >> "$LOG"
  done

