#!/bin/bash

#Creamos el fichero ldif que utilizaremos para agregar los usuarios al LDAP
touch empleados.ldif

#Abrimos el fichero y contamos las líneas que tiene, donde cada línea, hace referencia a un alumno
users=`cat usuarios.csv | wc -l`

#Variable donde empezará el uid de cada usuario a crearse en el equipo servidor
uid=1500
gid=2200

#Mientras haya un usuario como minimo en el fichero, ejecuta la instrucción

while [ $users -gt 0 ]
do

#Extrae cada campo del fichero separados por dos puntos, al ser un fichero CSV

	nombre=`cat usuarios.csv | head -$users | tail -1 | cut -d ":" -f1`
	apellidos=`cat usuarios.csv | head -$users | tail -1 | cut -d ":" -f2`
	email=`cat usuarios.csv | head -$users | tail -1 | cut -d ":" -f3`
	usuarioGN=`cat usuarios.csv | head -$users | tail -1 | cut -d ":" -f4`
	passwordGN=`cat usuarios.csv | head -$users | tail -1 | cut -d ":" -f5`

#Añade cada campo y objeto para el árbol de LDAP que tenemos creado, atentiendo a la cantidad de lineas almacenadas en el fichero, que hace referencia a un usuario

	echo "dn: uid=$usuarioGN,ou=Empleados,dc=gonzalonazareno,dc=org" >> empleados.ldif
	echo "objectClass: inetOrgPerson" >> empleados.ldif
	echo "objectClass: posixAccount" >> empleados.ldif
	echo "objectClass: top" >> empleados.ldif
	echo "uid:" $usuarioGN >> empleados.ldif
	echo "gidNumber:" $gid >> empleados.ldif
	echo "uidNumber:" $uid >> empleados.ldif
	echo "homeDirectory:" /home/$usuarioGN >> empleados.ldif
	echo "loginShell:" /bin/bash >> empleados.ldif
	echo "description: 1" >> empleados.ldif
	echo "sn:" $apellidos >> empleados.ldif
	echo "givenName:" $nombre >> empleados.ldif
	echo "cn:" $nombre $apellidos >> empleados.ldif
	echo "mail:" $email >> empleados.ldif
	echo "l:" Dos Hermanas >> empleados.ldif
	echo "userPassword:" $passwordGN >> empleados.ldif
	echo "" >> empleados.ldif

#Añade una entrada al fichero ldif y le añade un uid mayor al sistema a cada usuario añadido al fichero

	let users=users-1
	let uid=uid+1
done

#Añade los usuarios al arbol del LDAP, mediante el fichero .ldif que hemos generado anteriormente

ldapadd -x -D cn=admin,dc=gonzalonazareno,dc=org -W -f empleados.ldif

