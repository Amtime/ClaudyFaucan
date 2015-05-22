#! /bin/bash
# Réseau virtuel de machines Linux

function who {
# Acces a l'ensemble des utilisateurs connectes sur une machine
# Doit renvoyer nom/heure/date
# Un meme utilisateur peut se connecter plusieurs fois sur une machine depuis diff. terminaux
    echo 1
}
function rusers {
# Liste des utilisateurs connectés sur le réseau
# Doit renvoyer nom/heure/date
    echo 1
}
function rhost {
# Renvoit la liste des machines rattachées au réseau virtuel  
    echo 1
}
function connect {
# Se connecter a une machine du réseau
    echo 1
}
function su {
# Changer d'utilisateur
    echo 1
}
function passwd {
# Changement de mot de passe sur l'ensemble du réseau virtuel
    echo 1
}
function finger {
# Renvoit des éléments complémentaires sur l'utilisateur  
    echo 1
}
function write {
# Envoyer un message à un utilisateur connecté sur une machine du réseau
# write nom_utilisateur@nom_machine message
    echo 1
}

function host {
# Admin ajoute/enlève machine au réseau  
    echo 1
}
function users {
# Admin ajoute/enlève utilisateur/droits/mdp
    echo 1
}
function afinger {
# Admin renseigne sur un utilisateur, accès avec finger
    echo 1
}

if [ "`id -u`" != "0" ];then
  echo "Nous avons besoin d'être en root."
  exit 1
fi

if [ "$1" = "-connect" ];then
  if [ "$#" = "3" ];then
    MACHINE=$2
    USER=$3
  else 
    echo "Préciser nom machine et nom utilisateur"  
  fi
  elif [ "$1" = "-admin" ];then
      echo "admin"
  else
    echo "Préciser l'option -connect ou -admin"
fi
