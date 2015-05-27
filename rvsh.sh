#! /bin/bash
# Réseau virtuel de machines Linux

function who {
# Acces a l'ensemble des utilisateurs connectes sur une machine
# Doit renvoyer nom/heure/date
# Un meme utilisateur peut se connecter plusieurs fois sur une machine depuis diff. terminaux
# On passera le nom de la machine en paramètre
  local machine=$1
  echo "`grep $machine log|awk '/^.* connecté.*$/{print $2," est connecté depuis "$6" le "$3" "$4" "$5}' `"
  
}
function rusers {
# Liste des utilisateurs connectés sur le réseau
# Doit renvoyer nom/heure/date
  echo "`awk '/^.* connecté.*$/{print $2," est connecté sur "$1" depuis "$6" le "$3" "$4" "$5}' log`"
}
function rhost {
# Renvoit la liste des machines rattachées au réseau virtuel  
  echo "La liste des machines du réseau : "
  echo "`cat vlan`"
}
function connect {
# Se connecter a une autre machine du réseau
# On passera la nom de la machine et de l'utilisateur en paramètre
  local machine=$1
  local user=$2
  checkright $machine $user
  if [ "$?" -eq '2' ];then
    virtualisation $machine $user
  else
    echo "Problème de droit d'accès"
  fi
}
function su {
# Changer d'utilisateur mais pas de machine
# On passera le nom de la machine et de l'utilisateur en paramètre
  local machine=$1
  local user=$2
  checkpasswd $user
    if [ $? -eq '2' ];then
      virtualisation $machine $user
    else
        echo "Problème d'autentification : mot de passe incorrect"
    fi

# /!\ Vérifier que la machine est bien accessible, et que les paramètresi ############################################
# soient bien rentré (2 params) "###################################################################################"

}
function passwd {
# Changement de mot de passe sur l'ensemble du réseau virtuel
# On passera l'utilisateur et le mot de passe en paramètre
  local user=$1
  local passwd=$2
  echo "Je suis dans passwd"
# On cherche à quelle ligne correspond l'utilisateur dont
# on veut changer le mot de passe puis on le modifie
  while read line
  do
    if [ -n "`echo $line|grep $user`" ];then
      sed -i "s/^\($user \).*$/\1$passwd/" passwd
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


# /!\ On doit faire un test préalable pour voir si la personne est connectée #######################################

}

function host {
# Admin ajoute/enlève machine au réseau  
# On passe la commande et la machine en paramètre
#
  local cmd=$1
  local machine=$2
  if [ "$cmd" = "add" ];then
    if [ -z "`grep $machine vlan`" ];then
      echo $machine >> vlan
      echo "Création de la machine $machine"
    else
      echo "La machine est déjà dans le vlan"
    fi
  elif [ "$cmd" = "del" ];then
    if [ -n "`grep $machine vlan`" ];then
      sed -i "s/^$machine .*$//" vlan
      echo "$machine supprimée"
    else
      echo "La machine n'est pas dans le vlan"
    fi
  else
    echo "La commande est incorrecte"
  fi
}
function users {
# Admin ajoute/enlève utilisateur/droits/mdp
# La "sous commande" sera passée en premier paramètre
# Le if redirigera vers la fonction appropriée
# Le nom d'utilisateur et le mdp seront passé en paramètre
  local cmd=$1
  echo "hello"
  echo "cmd : $cmd"
  if [ "$cmd" = "passwd" ];then
    echo "Je suis rentré dans passwd de users"
    local user=$2
    local mdp=$3
    echo "user : $user, mdp : $mdp"
    passwd $user $mdp
  elif [ "$cmd" = "right" ];then
    echo "Je suis rentré dans right"
    local opt=$2
    local machine=$3
    local user=$4
    right $opt $machine $user
  elif [ "$cmd" = "add" ];then
    local user=$2
    local mdp=$3
    add $user $mdp
  elif [ "$cmd" = "del" ];then
    local user=$2
    del $user
  else
    echo "Argument de users invalide"
  fi
}
function afinger {
# Admin renseigne sur un utilisateur, accès avec finger
    echo 1
}

function right {
# Gère la distribution des droits 
  local opt=$1
  local machine=$2
  local user=$3
  echo $opt
# On regarde si on veut ajouter ou retirer des droits
  if [ "$opt" = "add" ];then
    checkright $machine $user
# On vérifie que l'utilisateur n'a pas déjà le droit à ajouter
    if [ "$?" -ne '2' ];then
      sed -i "s/^\($machine .*\)$/\1 $user/" vlan
      echo "Ajout du droit d'accès de $user sur $machine"
    else
      echo "Cet utilisateur a déjà le droit d'accès à $machine"
    fi
  elif [ "$opt" = "del" ];then
# On vérifie que l'utilisateur a bien les droits à retirer
    checkright $machine $user
    if [ "$?" -eq '2' ];then
      sed -i "s/^\($machine .*\)$user\(.*\)$/\1\2/" vlan
      echo "Suppression du droit d'accès de $user sur $machine"
    else
      echo "Cet utilisateur n'a pas encore le droit d'accès à $machine"
    fi
  else
    echo "Commande erronée : users right add/del user machine"
  fi
}

function add {
# Permet l'ajout d'un utilisateur avec son mdp si cet
# utilisateur n'est pas encore dans la base de donnée
  local flag=0
  local user=$1
  local mdp=$2
  echo "user : $user" 
# Vérification de l'absence de l'utilisateur
  while read line
  do
    a=`echo $line|grep $user`
    echo $a
    if [ -n "`echo $line|grep $user`" ];then 
# L'utilisateur éxiste déjà si on rentre dans ce if
      echo "Je suis dans le if"
      local flag=1
    fi
  done < passwd
    
  if [ "$flag" -eq '0' ];then
    echo "$user $mdp" >> passwd
    echo "Utilisateur créé"
  else
    echo "Cet utilisateur éxiste déjà"
  fi
}

function del {
# Permet la suppression d'un utilisateur de la base de donnée
# On passera le nom d'utilisateur en paramètre
  local $user
  while read line 
  do
    echo "Je suis rentré dans le while de del"
    if [ -n "`echo $line|grep $user`" ];then
        echo "Je suis rentré dans le if de del"
      sed -i "s/^.*$//" passwd
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

function checkright {
# La fonction doit retourner 2 si l'utilisateur à les droits
# d'accès pour la machines

  local machine=$1
  local user=$2
  echo "machine : $machine, user : $user"
  echo "Vérification de vos droits sur la machine demandée"
  while read line 
  do
    echo $line
    if [ -n "`echo $line|grep $machine|grep $user`" ];then
        return 2
    fi
  done < vlan
  }

function checkpasswd {
# Permet de vérifier sur le mdp fourni est correct
# Retourne 0 si le mdp est correct, 1 sinon
# On passera l'utilisateur puis le mdp en paramètre
  local flag=1
  local user=$1
  echo "Veuillez entrer votre mot de passe"
  read -p "Mot de pass : " passwd
# On Cherche l'utilisateur ligne par ligne puis
# Une fois la ligne correspondante on vérifie le mdp
  while read line
  do
    if [ -n "`echo $line|grep $user`" ];then
      if [ -n "`echo $line|grep $passwd`" ];then
        return 2
      fi
    fi
  done < passwd
    
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
# Gestion du prompt admin

  checkpasswd admin
  local cmd=null
  while [ "$cmd" != "exit" ]
  do
    read -p "rvsh > " cmd arg1 arg2 arg3 arg4
    echo $cmd
    case $cmd in
    host*)
      host $arg1 $arg2;;
    users*)
      echo "Je suis rentré dans users"
      users $arg1 $arg2 $arg3 $arg4;;
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

# Création du fichie log, passwd, vlan
# et du répertoire à message si ces derniers n'éxistent pas

if [ ! -w 'log' ];then
    echo "Création du fichier log"
    touch 'log'
fi

if [ ! -w 'passwd' ];then
    echo "Création du fichier passwd"
    touch 'passwd'
fi

if [ ! -w 'vlan' ];then
    echo "Création du fichier vlan"
    touch 'vlan'
fi

if [ ! -r "Message" ];then
  echo "Création du répertoire à message"
  mkdir 'Message'
fi

# Création des comptes et machines par défaut

if [ -z "`cat passwd`" ];then
  echo "user pass" >> passwd
  echo "Création du compte utilisateur par défaut"
fi

if [ -z "`cat vlan`" ];then
  echo "machine user" >> vlan
  echo "Création de la machine par défaut et de son droit d'accès par l'utilisateur par défaut"
fi

if [ -z "`grep admin passwd`" ];then
  echo "admin admin" >> passwd
  echo "Création du compte admin par défaut"
fi

# Détection du mode invoqué 

if [ "$1" = "-connect" ];then
  if [ "$#" = "3" ];then
    MACHINE=$2
    USER=$3
    checkright $MACHINE $USER
    if [ "$?" -eq '2' ];then
      echo "Vous avez le droit de vous connecter"
      checkpasswd $USER
      if [ "$?" -eq '2' ];then
        echo "Mot de passe correct, accès au prompt"
        virtualisation $MACHINE $USER
      else
          echo "Problème d'autentification : mot de passe incorrect"
      fi
    else
      echo "Vous n'avez pas le droit de vous connecter"
    fi
  else 
    echo "Préciser nom machine puis nom utilisateur"  
  fi
elif [ "$1" = "-admin" ];then
  admin
else
  echo "Préciser l'option -connect ou -admin"
fi

# Ajout d'un -help dans les prompts ou commandes complexes

# who ==> mettre par défaut la machine actuelle, mais rajouter
# la possibilité de regarder sur une autre machine

# who et rusers faire le cas où personne n'est connecté dans les
# fonctionso

# comparer les hashs plutôt que les mdp en clair sur le dossier passwd

# Il faudrait créer une fonction qui enlève les lignes vides dans 
# les fichiers pour nettoyer les fichiers comme passwd et machines
# où on supprime sauvagement en remplaçant tout par des blancs

# On pourrait rajouter l'envoyeur du message

# Faire en sorte que quand machine et user sont passés en paramètre
# machine soit toujours le premier paramètre pour moins d'ambiguïté
# password entre autre déroge à la règle

# fonction users du mode admin très complexe, vérifier sa parfaite 
# fonctionnalité

# faire une fonction qui filtre les caractère spéciaux qui 
# pourraient être rentré dans les mdp et les noms d'utilisateurs
# et pourrait faire buguer la saisie genre " ' $ ect

# Problème avec les logs de l'utilisateur par défaut
