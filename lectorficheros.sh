#!/bin/bash

function IntroducirArchivo(){
read -p 'Introduzca un archivo >>> ' archiv
read -p 'Introduzca delimitación del archivo >>> ("" o :)' delimiter
}

function PedirOpcion(){
read -p 'Elija una opción >>> ' opcion
echo $opcion
}

function ArchivoVacio(){
if [[ -s "$archiv" ]];then
    echo "El fichero $archiv tiene datos"
else
    echo "El fichero $archiv está vacío"
fi
}

function CambioMenu(){
if [[ -z "$archiv" ]];then
    IntroducirArchivo
fi
MostrarMenu2
opcion=$( PedirOpcion )
DevolverMenu2
}

function ValidaCopia(){
local co=.copia
read -p '¿En que directorio lo quieres copiar?(escribe desde la raiz)' direct 
if [ -f $direct/$archiv$co ];then 
    echo 'El archivo ya existe'
else
    sudo cp $archiv $archiv$co ; sudo mv $archiv$co $direct
fi
}

function Completa0(){
local num=$1
local num2=$2
while (( ${#num} < num2 ));do
    num='0'$num
done
echo $num
}

function EnumerarLineas(){
if [[ -z "$archiv" ]];then 
    IntroducirArchivo 
fi 
local cont=$(cat $archiv | wc -l ) 
local long=${#cont} 
local i=0 
while read linea ; do 
    a=$( Completa0 $i $long ) 
    echo $a $linea 
    (( i+=1 )) 
done < $archiv
}

function PaginarArchivo(){
if [[ -z "$archiv" ]];then 
    IntroducirArchivo 
fi
local cont=$(cat $archiv | wc -l ) 
local long=${#cont} 
read -p '¿cuantas líneas quieres ver ? ' cantidad
local j=1
local jc=1
local cuentalinea=0
local pass=$cantidad
while (( j< cont ));do
    (( cuentalinea += $cantidad ))
    j=$( Completa0 $jc $long ) ; cuentalinea=$( Completa0 $pass $long )
    clear ;echo "Lineas $j y $cuentalinea : "
    (( j=$jc )) ; (( cuentalinea = pass ))
    (( j += cantidad )) ; (( jc += cantidad ))
    head -n$pass $archiv | tail -n$cantidad  
    (( pass += cantidad )) 
    echo " "
    read -p '                    <<<  pulsar  >>> ' kla    
done
}

function Pag(){
read -p '¿cuantas líneas quieres ver ? ' canty
less -N $canty $archiv
}

function MostrarMenu(){
clear
echo '

      0. Salir
      1.Información acerca del Fichero
      2.Copiar Fichero
      3.Crear Fichero vacío
      4.Añadir una  nueva línea en el archivo
      5.Ordenar el fichero
      6.Numerar las líneas del fichero
      7.Paginar un archivo 
      8.Cambiar de archivo 
     '
}

function MostrarMenu2(){
clear
echo '
      0.Volver a Menú Principal
      1.¿Existe el fichero?
      2.Fecha de creación
      3.¿Está vacío el archivo?
      4.Tamaño del fichero
      5.¿Cuántas líneas hay?
      6.Primera línea del archivo
      7.Primera palabra del archivo
      8.¿Cuántas palabras contiene el archivo?
      9.Última línea del archivo
      A.Última palabra del archivo
      B.Tercera línea del archivo 
      C.Segunda palabra de la segunda línea
      D.Mostrar todo el archivo desde primera a última línea
      E.Mostrar todo el archivo desde última a primera línea
      F.Mostrar todo el archivo ordenado
     '
}

function MostrarMenuOrdenar(){
clear
echo ' 
      0.Volver al Menú Principal
      1.Ordenación(por defecto)
      2.Ordenación por primer campo(sólo ver)
      3.Ordenación por segundo campo(sólo ver)
     '
}

function DevolverMenuOrdenar(){
if [[ -z "$archiv" ]];then
    IntroducirArchivo
fi
local or=.ordenado
while true;do
    case $opcion in
    0) clear; MostrarMenu ; break ;;
    1) clear; touch $archiv$or ;cp $archiv $archiv$or; cat $archiv$or | sort ;;
    2) clear; cat $archiv | sort -t$delimiter -k1 ;;
    3) clear; cat $archiv | sort -t$delimiter -k2 ;;
    esac
    echo " "
    read -p '                  <<<  pulsar  >>> ' kla
    MostrarMenuOrdenar
    opcion=$( PedirOpcion )
    DevolverMenuOrdenar
done
}

function DevolverMenu(){
local cop=.autocopia
while true;do
    case $opcion in
    0) exit;;
    1) clear; CambioMenu ;;
    2) clear; IntroducirArchivo; ValidaCopia ;;
    3) clear; read -p '¿Que nombre quieres dar al archivo?' nom; if [ -f $nom ];then cp $nom $nom$cop ;echo 'El fichero ya existe'; else touch $nom;fi ;;
    4) clear; IntroducirArchivo;read -p '¿Que texto quieres escribir?' text; echo $text >> $archiv;;
    5) clear; MostrarMenuOrdenar; opcion=$( PedirOpcion ); DevolverMenuOrdenar ;;
    6) clear; EnumerarLineas ;;
    7) clear; IntroducirArchivo; PaginarArchivo ;;
    8) clear; IntroducirArchivo ;;
    esac
    echo " "
    read -p '                 <<<  pulsar  >>> ' kla
    MostrarMenu
    opcion=$( PedirOpcion )
done
}

function DevolverMenu2(){
while true ;do
    case $opcion in
    0) MostrarMenu ; break ;;
    1) clear; find ~ -iname *$archiv ;;
    2) clear; stat $archiv ;;
    3) clear; ArchivoVacio ;;
    4) clear; stat -c "El tamaño de %n es %s bytes" $archiv ;;
    5) clear; echo 'Hay' $(cat $archiv | wc -l ) 'líneas en el archivo ' $archiv ;;
    6) clear; echo $(head -n1 $archiv ) ;;
    7) clear; awk '{print $1 }' $archiv | head -n1 ;;
    8) clear; echo 'Hay' $(cat $archiv | wc -w ) 'palabras en el fichero ' $archiv ;;
    9) clear; echo $(tail -n1 $archiv ) ;;
    A) clear; echo $(tail -n1 $archiv | rev | cut -d$delimiter -f1 | rev );;
    B) clear; echo $(head -n3 $archiv | tail -n1) ;;
    C) clear; echo $(head -n2 $archiv | tail -n1 | cut -d$delimiter -f2 ) ;;
    D) clear; while IFS= read -r line; do echo $line;done < $archiv ;;
    E) clear; cat $archiv | tac ;;
    F) clear; cat $archiv | sort ;;
    esac
    echo "  "
    read -p '                <<<  pulsar  >>> ' kla
    MostrarMenu2
    opcion=$( PedirOpcion )
    DevolverMenu2
done
}

MostrarMenu
opcion=$( PedirOpcion )
DevolverMenu
