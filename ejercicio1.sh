#!/bin/bash
#ejercicio1.sh

#1Verificar que root ejecute el script
if [[ $EUID -ne 0 ]]; then
	echo " Error debe ejecutar este script como root."
	exit 1
fi

#2 Recibir como parametros el nombre de un usuario, el nombre de un grupo
#y la ruta a un archivo en el sistema

if [[ $# -ne 3 ]]; then 
	echo "Manera de uso: $0 (usuario) (Grupo) (archivo)"
	exit 1
fi
#Definiendo variables 

USUARIO="$1"
GRUPO="$2"
ARCHIVO="$3"

#Informacion que se recibe a los parametors 
 
echo " Usuario : $USUARIO"
echo " Grupo: $GRUPO"
echo " Archivo: $ARCHIVO"

#3 Verificar que la ruta al archivo existe.

if [[ ! -f "$ARCHIVO" ]]; then 
	echo "[Error]	el archivo '$ARCHIVO' no existe"
       exit 1

fi
echo "[Bien] El archivo existe."

#4 Crear el grupo si no existe 
if getent group "$GRUPO" >/dev/null 2>&1; then
	echo "[Info] El grupo '$GRUPO' ya existe."
else
	echo "[Info] Creando Grupo '$GRUPO'..."
	if groupadd "$GRUPO"; then
	echo "[bien] Grupo '$GRUPO' creado."
else
	echo "[error] No se pudo crear el grupo '$GRUPO'."
	exit 1
	fi
fi

 # 5) Crear el usuario si no existe
if id -u "$USUARIO" >/dev/null 2>&1; then
  echo "[Info] El usuario '$USUARIO' ya existe."
else
  echo "[Info] Creando usuario '$USUARIO'..."
  if useradd -m -s /bin/bash "$USUARIO"; then
    echo "[bien] Usuario '$USUARIO' creado."
  else
    echo "[error] No se pudo crear el usuario '$USUARIO'."
    exit 1
  fi
fi

# Agregar el usuario al grupo (si ya estaba, no pasa nada)
if usermod -aG "$GRUPO" "$USUARIO"; then
  echo "[OK] Usuario '$USUARIO' agregado al grupo '$GRUPO'."
else
  echo "[ERROR] No se pudo agregar '$USUARIO' al grupo '$GRUPO'."
  exit 1
fi

# Paso 6) Cambiar pertenencia del archivo al usuario nuevo y grupo nuevo
if chown "$USUARIO:$GRUPO" "$ARCHIVO"; then
  echo "[OK] Propietario del archivo cambiado a $USUARIO:$GRUPO."
else
  echo "[Error] No se pudo cambiar el propietario del archivo."
  exit 1
fi

# Paso 7) Ajustar permisos: usuario rwx, grupo r, otros ---
# (rwx=7, r=4, ---=0) => 740
if chmod 740 "$ARCHIVO"; then
  echo "[bien] Permisos ajustados a 740 (u=rwx, g=r, o=---)."
else
  echo "[error] No se pudieron ajustar los permisos del archivo."
  exit 1
fi



