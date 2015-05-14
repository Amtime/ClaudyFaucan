#! /bin/bash
# Réseau virtuel de machines Linux

function who{
# Acces a l'ensemble des utilisateurs connectes sur une machine
# Doit renvoyer nom/heure/date
# Un meme utilisateur peut se connecter plusieurs fois sur une machine depuis diff. terminaux
}
function rusers{
# Liste des utilisateurs connectés sur le réseau
# Doit renvoyer nom/heure/date
}
function rhost{
# Renvoit la liste des machines rattachées au réseau virtuel  
}
function connect{
# Se connecter a une machine du réseau
}
function su{
# Changer d'utilisateur
}
function passwd{
# Changement de mot de passe sur l'ensemble du réseau virtuel
}
function finger{
# Renvoit des éléments complémentaires sur l'utilisateur  
}
function write{
# Envoyer un message à un utilisateur connecté sur une machine du réseau
# write nom_utilisateur@nom_machine message
}

function host{
# Admin ajoute/enlève machine au réseau  
}
function users{
# Admin ajoute/enlève utilisateur/droits/mdp
}
function afinger{
# Admin renseigne sur un utilisateur, accès avec finger
}

if [ $1 = "-connect" ];then
  if [ $# = 3 ];then
    nom_machine = $2
    nom_utilisateur = $3
  else echo "Préciser nom machine et nom utilisateur"  
  fi
elif [ $1 = "-admin" ];then
else echo "Préciser l'option -connect ou -admin"
fi
