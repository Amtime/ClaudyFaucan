#! /bin/bash
# Réseau virtuel de machines Linux

function who {
# Acces a l'ensemble des utilisateurs connectes sur une machine
# Doit renvoyer nom/heure/date
# Un meme utilisateur peut se connecter plusieurs fois sur une machine depuis diff. terminaux
# On passera le nom de la machine en paramètre
  echo `grep $1 log|grep ".* connecté"|sed "s/.* \(.*\) \(.* .* .*\) \(.*:.*:.*\) .*/\1 est connecté depuis \3 le \2"/`
}
function rusers {
# Liste des utilisateurs connectés sur le réseau
# Doit renvoyer nom/heure/date
  echo `grep ".* connecté" 'log'|sed  "s/\(.*\) \(.*\) \(.* .* .*\) \(.*:.*:.*\) .*/\2 est connecté sur \1 depuis \4 le \3"/`
}
function rhost {
# Renvoit la liste des machines rattachées au réseau virtuel  
    echo 1
}
function connect {
# Se connecter a une machine du réseau
# On passera la nom de la machine et de l'utilisateur en paramètre
 local machine=$1
 local user=$2
 virtualisation machine user
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

function log {

# Permet la création d'une nouvelle ligne de log

  local machine=$1 
  local user=$2
  local heure=`date|cut -f2 -d ','|cut -f1 -d '('|sed 's/ //g'`
  local date=`date|cut -f1 -d ','|sed 's/\(.*\) \(.*\) \(.*\) \(.*\)/\2 \3 \4/'`
  echo "$machine $user $date $heure connecté">>log
}

function virtualisation {

# Permet la création d'un prompt, cette fonction reçoit la 
# machine puis le nom d'utilisateur en paramètre. Elle met
# aussi les logs à jour ou crée une nouvelle ligne de log
# si nécessaire.

  local cmd=null
  local machine=$1
  local user=$2
  local heure=`date|cut -f2 -d ','|cut -f1 -d '('|sed 's/ //'`
  echo "Je suis sur la machine $machine avec l'utilisateur $user"

# Gestion des logs
  if [ -z "`grep $machine log && grep $user log`"  ];then
    echo "Création d'un new log"
    log $machine $user
  else
    echo "Actualisation des logs"
    sed -i "s/\($machine $user .*\)..:..:.*/\1${heure}connecté/" log
  fi
  
# Gestion du prompt

  while [ "$cmd" != "exit" ]
  do
    read -p "$2@$1 > " cmd  option
    case $cmd in
    who*)
      who $machine;;
    rusers*)
      rusers;;
    connect*)
      echo "Je suis rentré dans connect" 
      virtualisation $option $user;;
    exit*)
      ;;
    *)
      echo "La commande entrée n'est pas correcte.";;
    esac
  done

# Mis à jour des logs avant de quitter la session :
# Passage de l'état connecté à l'état déconnecté

  sed -i "s/\($machine $user .* \)connecté/\1déconnecté/g" log
}

function admin {
  local cmd=null

  while [ "$cmd" != "exit" ]
  do
    echo "rvsh >"
    read cmd
  done
}

# DEBUT DU SCRIPT

# Création du fichie log si ce dernier n'éxiste pas

if [ ! -w log ];then
    echo "Création du fichier log"
fi

if [ "$1" = "-connect" ];then
  if [ "$#" = "3" ];then
    MACHINE=$2
    USER=$3
    virtualisation $MACHINE $USER
  else 
    echo "Préciser nom machine et nom utilisateur"  
  fi
  elif [ "$1" = "-admin" ];then
      admin
  else
    echo "Préciser l'option -connect ou -admin"
fi
