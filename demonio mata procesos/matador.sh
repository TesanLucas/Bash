#!/bin/bash

blackList=$1
directorioDestino=$2

fechaPath=$(date +"%Y-%m-%d_%H:%M:%S") #la fecha para el nombre del archivo
pathSalida=""$directorioDestino"/blacklist_"$fechaPath"" 
#pathSalida=""$directorioDestino"/blacklist_{"$fechaPath"}.out"
touch "$pathSalida"

while true ; do
    fecha=$(date +"%Y-%m-%d_%H:%M:%S")  #la fecha para el registro del proceso matado
    listaProcesos=$(ps -ao pid,user,cmd)

    for procesoActual in $(cat $blackList)
    do
        procesoAMatar=$(echo "$listaProcesos" | awk -v proceso="$procesoActual" '$3==proceso {print $0}' | tr -s " ")
        #echo "proceso a matar: -$procesoAMatar-"
        if [ ! -z "$procesoAMatar" ]; then
            nombreProceso="$procesoActual"
            pid=$(echo $procesoAMatar | awk '{print $1}')
            usuario=$(echo $procesoAMatar | awk '{print $2}')
            echo "$nombreProceso    $pid    $usuario    $fecha" >> "$pathSalida"
            kill "$pid"
        fi
    done
sleep 3
done