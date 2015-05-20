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
# Permet d'ajouter les librairies et les fichiers au bon fonctionnement des commandes passées en argument et qui
# aura l'adresse de la racine du fichier utilisateur en premier paramètre
  local locadress=$1
  shift 
  echo $*
  for cmd in $@
  do
# On trouve toutes les adresses de la commande grâce à whereis    
    adresscmd=$(whereis -b $cmd|cut -f2 -d ':')
    echo "Installation des commandes : $*"
    for j in $adresscmd
    do
# On crée les répertoires et copie leurs contenus        
      echo "Installation du répertoire : $j à l'adresse $locadress$j"
      mkdir -p $locadress$j
      cp -r $j $locadress$j
    done
    for k in `ldd /usr/bin/ssh|cut -f2 -d '>'|cut -f1 -d '('`
    do
# On s'occupe maintenant des bibliothèques nécessaires grâce à la commande ldd et procède de la même façon        
      echo "Installation de la librairie $k à l'adresse $locadress$k"
      mkdir -p $locadress$k
      cp -R -L $k $locadress$j
    done
  done
}

function newuser {
# Fonction qui permet de créer un nouvel utilisateur donc l'adresse de la racine sera passée en paramètre
  if [ -d "$1" ];then
    echo "L'utilisateur éxiste déjà"
    exit 1
  fi
  locadress=$1
  echo $locadress
  echo Salut
# On crée ce qui sera la racine du dossier de l'utilisateur virtualisé
  mkdir -p $1/bin $1/usr 
  addcmd $locadress ssh
  echo "Création du nouvel utilisateur finie"
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
    newuser $ADRESS
  else 
    echo "Préciser nom machine et nom utilisateur"  
  fi
  elif [ "$1" = "-admin" ];then
      echo "admin"
  else
    echo "Préciser l'option -connect ou -admin"
fi
