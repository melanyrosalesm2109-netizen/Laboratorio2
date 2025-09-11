#!/bin/bash
## Uso: ./ejercicio2.sh comando [args...]

if [ $# -eq 0 ]; then
  echo "Uso: $0 comando [args...]"
  exit 1
fi

"$@" &             
PID=$!              
echo "Monitoreando PID $PID: $*"

echo "segundos,cpu_pct,mem_mb" > log.csv
T0=$(date +%s)      # tiempo inicial en segundos desde epoch

while kill -0 "$PID" 2>/dev/null; do
  ahora=$(date +%s)
  seg=$((ahora - T0))

  linea=$(ps -p "$PID" -o %cpu=,rss=)
  cpu=$(echo "$linea" | awk '{print $1}')
  rss=$(echo "$linea" | awk '{print $2}')
  mem=$(awk -v r="$rss" 'BEGIN{printf "%.2f", r/1024}')

  echo "$seg,$cpu,$mem" >> log.csv
  sleep 1
done

cat > graf.gp <<'EOF'
set datafile separator ','
set term pngcairo size 1000,600
set output 'graf.png'
set title 'Monitoreo CPU y Memoria'
set xlabel 'Tiempo (s)'
set ylabel 'CPU (%)'
set y2label 'Memoria (MB)'
set y2tics
set grid
plot 'log.csv' using 1:2 with lines title 'CPU %', \
     'log.csv' using 1:3 axes x1y2 with lines title 'Mem MB'
EOF

if command -v gnuplot >/dev/null 2>&1; then
  gnuplot graf.gp
  echo "Listo: log.csv y graf.png"
else
  echo "Listo: log.csv (para gráfica: sudo apt install gnuplot && gnuplot graf.gp)"
fi

