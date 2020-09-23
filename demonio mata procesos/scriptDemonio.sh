#!/bin/bash

# =========================== Encabezado =======================

# Nombre del script: scriptDemonio.sh
# Author: Lucas Tesan
# Fecha: 23/9/2020

# ==============================FUNCIONES================================

Help(){
	echo "			 **** MENU DE AYUDA ****"
	echo "--------------------------------------------------------------------------------"
	echo "este script corre un demonio el cual mata cualquier proceso que este especificado dentro del archivo de texto BLACKLIST"
	echo "dejando un archivo log en el directorio DIRDESTINO"
	echo "--------------------------------------------------------------------------------"
	echo "Modo de empleo: $0 -<OPCION> <PARAMETRO>"
	echo "--------------------------------------------------------------------------------"
	echo "OPCIONES DISPONIBLES"
	echo -e "-b “BLACKLIST”: path absoluto o relativo del archivo con la blacklist de procesos. Requerido."
	echo -e "-o “DIRDESTINO”: path absoluto o relativo del directorio donde se generará el archivo de salida. Opcional. Si no se informa se generará en el directorio de ejecución."
	echo "--------------------------------------------------------------------------------"
	echo "ejemplo de uso 1: $0 -b blacklist.txt"
	echo "ejemplo de uso 2: $0 -b blacklist.txt -o .."
}

ejecutarDemonio(){
	./matador.sh $blacklist $directorioDestino >/dev/null 2>&1 &
	retornoDemonio=$?
	echo $! > $archPID
 	if [ ${retornoDemonio} -eq 0 ]; then
        echo "Se ha iniciado el demonio"
 	else
        echo "No se ha podido iniciar el demonio"
 	fi	
}

# ==============================VALIDACION DE PARAMETROS================================
cantParametros=$#
directorioDestino="."

if [[ $cantParametros -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
		Help
		exit 0
	fi

cantParametros=0
while getopts ":b:o:" opcion; do
  case ${opcion} in
    b )
      blacklist=$OPTARG
	  cantParametros="$(($cantParametros + 1))"
      ;;
	o )
      directorioDestino=$OPTARG
      ;;
    \? )
      echo "opcion invalida: -$OPTARG no es un argumento valido" 1>&2
	  exit 1
      ;;
    : )
      echo "opcion invalida: -$OPTARG requiere un argumento" 1>&2
	  exit 1
      ;;
  esac
done

if [[ $cantParametros -lt 1 ]]; then
	echo "ERROR: Cantidad de parametros equivocada" 1>&2
	exit 1
fi

if [ ! -d "$directorioDestino" ]; then
	echo "ERROR: no existe el directorio de salida $directorioDestino" 1>&2
	exit 1
fi

if [ ! -f "$blacklist" ]; then
	echo "ERROR: no existe el archivo blacklist $blacklist" 1>&2
	exit 1
fi

# ==============================MAIN================================
archPID=/tmp/demonio.pid

if [ -f ${archPID} ]; then	#chequeo si el archivo donde esta el PID del demonio existe
	pidDemonio=$(cat $archPID)
	nombreDemonio=$(ps -e |grep ${pidDemonio} | awk '{print $4}')	#retorno el nombre del proceso de dicho PID
	if [ "$nombreDemonio" = "matador.sh" ]; then	#si coincide el nombre, es porque el domonio ya estaba activo
    	echo "El demonio ya esta en marcha"
		#para probar:
 		#kill -9 ${pidDemonio}
		#echo "se a matado al demonio"
	else
		ejecutarDemonio
	fi
else
	ejecutarDemonio
fi