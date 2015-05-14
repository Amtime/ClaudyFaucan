#! /bin/bash

if [ $1 = "-connect" ];then
  if [ $# = 3 ];then
    nom_machine = $2
    nom_utilisateur = $3
  fi
elif [ $1 = "-admin" ];then
else echo "Il faut préciser l'option -connect ou -admin"
fi
