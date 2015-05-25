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
 virtualisation $machine $user
}
function su {
# Changer d'utilisateur
  local machine=$1
  local user=$2
  virtualisation $machine $user
}
function passwd {
# Changement de mot de passe sur l'ensemble du réseau virtuel
# On passera l'utilisateur et le mdp en paramètre
  local user=$1
  local passwd=$2
  echo "Je suis dans passwd"
  while read line
  do
    if [ -n "`echo $line|grep $user`"];then
      sed -i "s/\(^$user \).*$line$/\1$passwd/" passwd
      echo "Mot de passe changé"
    fi
  done < passwd
}
function finger {
# Renvoit des éléments complémentaires sur l'utilisateur  
    echo 1
}
function write {
# Envoyer un message à un utilisateur connecté sur une machine du réseau
# write nom_utilisateur@nom_machine message
  local dest=$1
  local message=$2
  `echo "$message" > "./Message/$dest"`
}

function host {
# Admin ajoute/enlève machine au réseau  
    echo 1
}
function users {
# Admin ajoute/enlève utilisateur/droits/mdp
  local cmd=$1
  local user=$2
  echo "hello"
  echo "cmd : $cmd"
  if [ "$cmd" = "passwd" ];then
    echo "Je suis rentré dans passwd de users"
    local mdp=$3
    echo "user : $user, mdp : $mdp"
    passwd $user $mdp
  elif [ "$cmd" = "right" ];then
    right $user
  elif [ "$cmd" = "add" ];then
    local mdp=$3
    add $user $mdp
  elif [ "$cmd" = "del" ];then
    del $user
  else
    echo "Argument de users invalide"
  fi
}
function afinger {
# Admin renseigne sur un utilisateur, accès avec finger
    echo 1
}

function add {

  local flag=0
  local user=$1
  local mdp=$2
  while read line
  do
    a=`echo $line|grep $user`
    echo $a
    if [ -n "a" ];then 
      echo "Je suis dans la if"
      local flag=1
    fi
  done < passwd
    
  if [ "$flag" -eq '0' ];then
    echo "$user $mdp" >> passwd
  else
    echo "Cet utilisateur éxiste déjà"
  fi
}

function del {

  local $user
  while read line 
  do
    echo "Je suis rentré dans le while de del"
    if [ -n "`echo $line|grep $user`" ];then
        echo "Je suis rentré dans le if de del"
      sed -i "s/^$user .*$//" passwd
    fi
 done < passwd   
}

function log {

# Permet la création d'une nouvelle ligne de log

  local machine=$1 
  local user=$2
  local heure=`date|cut -f2 -d ','|cut -f1 -d '('|sed 's/ //g'`
  local date=`date|cut -f1 -d ','|sed 's/\(.*\) \(.*\) \(.*\) \(.*\)/\2 \3 \4/'`
  echo "$machine $user $date $heure connecté">>log
}

function checkpasswd {
  
  local flag=1
  local user=$1
  echo "Veuillez entrer votre mot de passe"
  read -p "Mot de pass : " passwd
  while read line
  do
    if [ -n "`echo $line|grep $user`"];then
      if [ -n "`echo $line|grep $passwd`" ];then
        flag=0
      fi
    fi
  done < passwd
    
  if [ $flag -eq '0' ];then
    return 0
  else
    return 1
  fi
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
  local flag=0
  echo "Je suis sur la machine $machine avec l'utilisateur $user"

# Gestion des logs
  
# Vérification si le fichier est vide, car sinon on ne rentre pas 
# dans la boucle while

  if [ -z "`cat log`" ];then
    local flag=0
  fi

# On vérifie ligne à ligne si l'utilisateur a déjà un log
# Si c'est le cas le flag est à 1

  while read line 
  do
    if [ -n "`echo $line|grep $machine|grep $user`" ];then
      local flag=1
    fi
  done < log

# Si le flag est à 0 on crée un nouveau log, sinon on actualise

  if [ "$flag" -eq "0" ];then
    echo "Création d'un new log"
    log $machine $user
  else
    echo "Actualisation des logs"
    sed -i "s/\($machine $user .*\)..:..:.*/\1${heure}connecté/" log
  fi
  local flag=0
  
# Gestion du prompt

  while [ "$cmd" != "exit" ]
  do
# Vérification si aucun message n'a été reçu
    if [ -n  "`ls './Message'|grep "^$user@$machine$"`" ];then
      echo "Vous avez un message : `cat ./Message/$user@$machine`"
      `rm "./Message/$user@$machine"`
    fi

    read -p "$2@$1 > " cmd arg1 arg2
    case $cmd in
    who*)
      who $machine;;
    rusers*)
      rusers;;
    connect*)
      echo "Je suis rentré dans connect" 
      connect $arg1 $user;;
    su*)
      echo "Je suis rentré dans su"
      su $machine $arg1;;
    passwd*)
      echo "Je suis rentré dans passwd"
      passwd $user $arg1;;
    write*)
      echo "Je suis rentré dans write"
      write $arg1 $arg2;;
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
    read -p "rvsh > " cmd arg1 arg2 arg3
    echo $cmd
    case $cmd in
    host*)
      host $arg1 $arg2;;
    users*)
      echo "Je suis rentré dans users"
      users $arg1 $arg2 $arg3;;
    afinger*)
      afinger;;
    exit*)
      exit;;
    *)
      echo "La commande entrée n'est pas correcte.";;
    esac
  done
}

# DEBUT DU SCRIPT

# Création du fichie log et du répertoire à message si ces derniers 
# n'éxistent pas

if [ ! -w 'log' ];then
    echo "Création du fichier log"
    touch 'log'
fi

if [ ! -w 'passwd' ];then
    echo "Création du fichier passwd"
    touch 'passwd'
fi

if [ ! -r "Message" ];then
  echo "Création du répertoire à message"
  mkdir 'Message'
fi

# Détection du mode invoqué 

if [ "$1" = "-connect" ];then
  if [ "$#" = "3" ];then
    MACHINE=$2
    USER=$3
    checkpasswd $USER
    if [ $? -eq '0' ];then
      virtualisation $MACHINE $USER
    else
        echo "Problème d'autentification : mot de passe incorrect"
    fi
  else 
    echo "Préciser nom machine et nom utilisateur"  
  fi
  
elif [ "$1" = "-admin" ];then
  admin
else
  echo "Préciser l'option -connect ou -admin"
fi
