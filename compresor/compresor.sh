#!/bin/bash

# =========================== Encabezado =======================

# Nombre del script: compresor.sh
# Author: Lucas Tesan
# Fecha: 23/9/2020

# -------------------------------------------------------------

Help(){
	echo "			 **** MENU DE AYUDA ****"
	echo "--------------------------------------------------------------------------------"
	echo "este script comprime los historiales medicos de todas las personas que no hayan visitado el centro medico en los ultimos N dias."
	echo "tambien permite descomprimir el historial de cada paciente de forma individual."
	echo "--------------------------------------------------------------------------------"
	echo "Modo de empleo: $0 -<OPCION> <PARAMETRO>"
	echo "--------------------------------------------------------------------------------"
	echo "OPCIONES DISPONIBLES: "
	echo "-c: comprimir. Si está presente, el script comprimirá las historias clínicas de los 
	pacientes que no realizaron una visita en los últimos -n días, y eliminará los directorios 
	para liberar el espacio. Obligatorio. No puede ser usado al mismo tiempo que -d."
	echo "-n: cantidad de días a tener en cuenta para comprimir las historias clínicas. Se puede
	utilizar solo con -c. Si no se indica se asumen 30 días."
	echo "-d: descomprimir. Si está presente, el script descomprimirá la historia clínica del
	paciente indicado en el parámetro -p. Obligatorio. No puede ser usado al mismo tiempoq ue -c."
	echo "-p “Nombre Paciente”: indica el nombre del paciente del cual se quiere descomprimir la 
	historia clínica. Obligatorio. Solo puede ser usado si se usa el parámetro -d."
	echo "-h “directorio”: path relativo o absoluto del directorio en donde se encuentran las
	historias clínicas de los pacientes y el archivo “últimas visitas.txt”. Obligatorio."
	echo "-z “directorio”: path relativo o absoluto del directorio en donde se guardan
	los archivos comprimidos. Obligatorio."
	echo "--------------------------------------------------------------------------------"
	echo "ejemplo de uso 1: $0 -c -n 20 -h ./lote/ultimasVisitas -z ./lote/comprimidos"
	echo "ejemplo de uso 2: $0 -d -p Elaine Marley -h ./lote/ultimasVisitas -z ./lote/comprimidos"
	#./compresor.sh -c -n 20 -h ./lote/ultimasVisitas -z ./lote/comprimidos
	#./compresor.sh -d -p "Elaine Marley" -h ./lote/ultimasVisitas -z ./lote/comprimidos
}

# ==============================FUNCIONES================================

funcionComprimir(){
	IFS=$'\n'
	fechaAComparar=$(date +"%Y-%m-%d" -d "-$N days")
	#obtengo la fecha actual y le resto N dias

    for paciente in $(cat "$ultimasVisitas")	#por cada entrada del archivo
	do
		nombrePaciente=$(echo "$paciente" | awk -F '|' '{print $1}')
		fechaPaciente=$(echo "$paciente" | awk -F '|' '{print $2}')

		directorioPaciente="$directorioEntrada"/"$nombrePaciente"
		if [ ! -d "$directorioPaciente" ]; then
			echo "no existe el directorio $directorioPaciente"
			continue;	#si no existe el directorio, salteo a la proxima iteracion
		fi

		if [[ "$fechaAComparar" > "$fechaPaciente" ]]; then
			tar -cf - "$directorioPaciente" > ""$directorioDestino"/"$nombrePaciente".tar"
			rm -r "$directorioPaciente"
		fi 
	done
}


funcionDescomprimir(){
	archivoADescomprimir=""$directorioDestino"/"$paciente".tar"
	if [ ! -f "$archivoADescomprimir" ]; then
		echo "ERROR: no existe el archivo a descomprimir $archivoADescomprimir" 1>&2
		exit 1
	fi

	tar -xf "$archivoADescomprimir"
	rm "$archivoADescomprimir"
}

# ==============================VALIDACION DE PARAMETROS================================

cantParametros=$#
N="nulo"
nombrePaciente="nulo"

if [[ $cantParametros -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
		Help
		exit 0
	fi

cantParametros=0
while getopts ":h:n:p:z:cd" OPCION; do
  case ${OPCION} in
    c )
      opcionElegida="comprimir"
	  cantParametros="$(($cantParametros + 1))"
      ;;
	n )
      if [[ $opcionElegida -eq "comprimir" ]]; then
            N=$OPTARG
	        cantParametros="$(($cantParametros + 1))"
        fi
      ;;
	d )
      opcionElegida="descomprimir"
      cantParametros="$(($cantParametros + 1))"
      ;;
    p )
      if [[ "$opcionElegida" -eq "descomprimir" ]]; then
            paciente=$OPTARG
	        cantParametros="$(($cantParametros + 1))"
      fi
      ;;
    h )
      directorioEntrada=$OPTARG
      cantParametros="$(($cantParametros + 1))"
      ;;
    z )
      directorioDestino=$OPTARG
      cantParametros="$(($cantParametros + 1))"
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

if [[ $cantParametros -lt 3 ]]; then
	echo "ERROR: Cantidad de parametros equivocada" 1>&2
    echo "la cant de parametros es $cantParametros"
	exit 1
fi

if [ ! -d "$directorioDestino" ]; then
	echo "ERROR: no existe el directorio de salida $directorioDestino" 1>&2
	exit 1
fi

ultimasVisitas=""$directorioEntrada"/ultimas visitas.txt"
if [ ! -f "$ultimasVisitas" ]; then
	echo "ERROR: no existe el archivo de ultimas visitas "$directorioEntrada"/ultimas visitas.txt" 1>&2
	exit 1
fi

if [[ $opcionElegida == "comprimir" && $N == "nulo" ]] ; then
	N=30
elif [[ $opcionElegida == "descomprimir" && $paciente == "nulo" ]] ; then
	echo "ERROR: no se pasaron correctamente los parametros, para la opcion descomprimir se necesita un -p" 1>&2
	exit 1
fi
# ==============================MAIN================================

case "$opcionElegida" in
	comprimir)
		funcionComprimir				
		;;
	descomprimir)
		funcionDescomprimir				
		;;
	*)
		echo "ERROR, se necesita elegir una opcion de comprimir o descomprimir"
		exit 1
		;;
esac

# ==============================FIN DE ARCHIVO================================