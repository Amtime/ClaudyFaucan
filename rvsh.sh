#! /bin/bash
# Réseau virtuel de machines Linux

if [ $1 = "-connect" ];then
  if [ $# = 3 ];then
    nom_machine = $2
    nom_utilisateur = $3
  else echo "Préciser nom machine et nom utilisateur"  
  fi
elif [ $1 = "-admin" ];then
else echo "Préciser l'option -connect ou -admin"
fi
Bisous
