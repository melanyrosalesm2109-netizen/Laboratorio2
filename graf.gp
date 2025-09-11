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
