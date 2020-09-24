#!/bin/bash

# =========================== Encabezado =======================

# Nombre del script: frecuencias.sh
# Author: Lucas Tesan
# Fecha: 23/9/2020

# ==============================FUNCIONES================================

Help(){
	echo "**** MENU DE AYUDA ****"
	echo "--------------------------------------------------------------------------------"
	echo "Este script realiza el analisis de un texto, incluyendo el pre-procesamiento que consta de:"
	echo "1. Eliminación de stop words
2. Convertir a mayúsculas"
	echo "luego, contabiliza la frecuencia de aparición de cada palabra en el texto
y genera un reporte ordenando los resultados de mayor a menor frecuencia en	un
archivo de salida frecuencias_{Nombre archivo entrada}_{yyyy-mm-dd_hh:mm:ss}.out con
formato CSV y mostrando por pantalla sólo las 5 palabras con mayor frecuencia."
	echo "--------------------------------------------------------------------------------"
	echo "Modo de empleo: $0 -<OPCION> <PARAMETRO>"
	echo "--------------------------------------------------------------------------------"
	echo "OPCIONES DISPONIBLES"
	echo -e "-s “archivo stopwords”: path absoluto o relativo del archivo con los stopwords. Obligatorio."
	echo -e "-o “directorio resultado”: path absoluto o relativo del directorio donde se generará el archivo
			   de salida. Opcional. Si no se informa se generará en el directorio de ejecución"
	echo -e "-i “archivo a analizar”: path absoluto o relativo del archivo de texto a analizar."
	echo "--------------------------------------------------------------------------------"
	echo "ejemplo de uso 1: ./frecuencias.sh -i "lote de pruebas"/lote2/archivoEntrada.txt -s 'lote de pruebas'/lote2/stopwords.txt"
	echo "ejemplo de uso 2: ./frecuencias.sh -i "lote de pruebas"/lote2/archivoEntrada.txt -s 'lote de pruebas'/lote2/stopwords.txt -o 'lote de pruebas'"
	#./frecuencias.sh -i "lote de pruebas"/lote2/archivoEntrada.txt -s 'lote de pruebas'/lote2/stopwords.txt"
	#./frecuencias.sh -i "lote de pruebas"/lote2/archivoEntrada.txt -s 'lote de pruebas'/lote2/stopwords.txt -o 'lote de pruebas'
}
EliminarStopWords(){
    pifs=IFS
    IFS=":"

    for stopWordActual in $(cat "$stopWords")
	do
		awk -v reemplazar="$stopWordActual" -v asd="ASD" '{gsub(reemplazar,"")}1' "$archAuxiliar" > "$archPreProcesado"
		rm "$archAuxiliar"
		mv "$archPreProcesado" "$archAuxiliar"
	done
    IFS=$pifs
}

convertirAMayusculas()
{
	awk '{print toupper($0)}' "$archAuxiliar" > "$archPreProcesado"
	rm $archAuxiliar
}

contabilizarPalabras(){
	pifs=IFS
    IFS=" "

 	for palabraActual in $(cat "$archPreProcesado")
	do
		if [[ ${palabras["$palabraActual"]} -eq "" ]]; then
			palabras["$palabraActual"]=1
		else
			palabras["$palabraActual"]="$((${palabras["$palabraActual"]} + 1))"
		fi
	done
	IFS=$pifs
}

darResultado(){
	fecha=$(date +"%Y-%m-%d_%H:%M:%S")
	nombreArchivo="${pathArchivo##*/}" # elimina todo hasta la última /
	#pathInforme=""$directorioDestino""/frecuencias_{$nombreArchivo}_{"$fecha"}.out""
	pathInforme=""$directorioDestino""/frecuencias_"$nombreArchivo"_"$fecha".out""
	#echo "pathInforme: "$pathInforme""
	touch "$pathInforme"
	touch "$archAuxiliar"

	for key in "${!palabras[@]}"; do
		echo "$key,${palabras["$key"]}" >> $archAuxiliar
	done

	sort  -k 2nr --field-separator="," --output=$pathInforme $archAuxiliar
	# parametros usados:
	#-k : especifica segun que campo ordenar (en este caso segunda columna)
	#-nr : por numeros, invertido (en orden descendiente)
	#--field-separator : por defecto usa el espacio, le especifico que el ifs sea ;
	#--output : por alguna razon no se puede redirigir la salida a un archivo, se tiene que hacer con este parametro
	rm $archAuxiliar
	awk 'NR==1,NR==5 {print $0}' $pathInforme | awk '{gsub(","," -- ")}1'
	# El segundo comando awk reemplaza las comas por un espacio para mostrarse mejor por pantalla
}

# ==============================VALIDACION DE PARAMETROS================================

cantParametros=$#
directorioDestino="."	#default
declare -A palabras

if [[ $cantParametros -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
		Help
		exit 0
	fi

cantParametros=0
while getopts ":s:o:i:" opcion; do
  case ${opcion} in
    s )
      stopWords=$OPTARG
	  cantParametros="$(($cantParametros + 1))"
      ;;
	i )
      pathArchivo=$OPTARG
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

if [[ $cantParametros -lt 2 ]]; then
	echo "ERROR: Cantidad de parametros equivocada" 1>&2
	exit 1
fi

if [ ! -d "$directorioDestino" ]; then
	echo "ERROR: no existe el directorio de salida $directorioDestino" 1>&2
	exit 1
fi

if [ ! -f "$pathArchivo" ]; then
	echo "ERROR: no existe el archivo de entrada $pathArchivo" 1>&2
	exit 1
fi

if [ ! -f "$stopWords" ]; then
	echo "ERROR: no existe el archivo de stopwords $stopWords" 1>&2
	exit 1
fi
# ==============================MAIN================================

archPreProcesado="./preProcesado"
archAuxiliar="./archAuxiliar"
cat "$pathArchivo" > "$archAuxiliar"
EliminarStopWords
convertirAMayusculas
contabilizarPalabras
pathInforme="frecuencias"
darResultado