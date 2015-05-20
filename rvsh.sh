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

function addcmd {
  for cmd in $@
  do
    adresscmd=$(whereis -b $cmd|cut -f2 -d ':')
    echo $adress
    for j in $adresscmd
    do
      echo "$j $ADRESS$j"
      mkdir -p $ADRESS$j
      cp -r $j $ADRESS$j
      for k in `ldd /usr/bin/ssh|cut -f2 -d '>'|cut -f1 -d '('`
      do
        mkdir -p $ADRESS$k
        cp -R -L $k $ADRESS$j
      done
    done
  done
}

function newuser {
  if [ -d "$ADRESS" ];then
    echo "L'utilisateur éxiste déjà"
  fi
  mkdir -p $ADRESS/bin $ADRESS/usr 
  addcmd ssh
}


if [ "`id -u`" != "0" ];then
  echo "Nous avons besoin d'être en root."
  exit 1
fi

if [ "$1" = "-connect" ];then
  if [ "$#" = "3" ];then
    MACHINE=$2
    USER=$3
    ADRESS=/srv/$USER
    newuser
  else 
    echo "Préciser nom machine et nom utilisateur"  
  fi
  elif [ "$1" = "-admin" ];then
      echo "admin"
  else
    echo "Préciser l'option -connect ou -admin"
fi
