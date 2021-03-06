#! /bin/bash
# Réseau virtuel de machines Linux

function who {
# Acces a l'ensemble des utilisateurs connectes sur la machine
# Doit renvoyer nom/heure/date
# Un meme utilisateur peut se connecter plusieurs fois sur une machine depuis diff. terminaux
# On passera le nom de la machine en paramètre
  local machine=$1
  echo "`grep "^$machine .*$" log|awk '/^.* connecté.*$/{print $2,"est connecté depuis "$6" le "$3" "$4" "$5}' `"
  
}
function rusers {
# Liste des utilisateurs connectés sur le réseau
# Doit renvoyer nom/heure/date
  echo "`awk '/^.* connecté.*$/{print $2,"est connecté sur "$1" depuis "$6" le "$3" "$4" "$5}' log`"
}
function rhost {
# Renvoit la liste des machines rattachées au réseau virtuel  
  echo "La liste des machines du réseau : "
  echo "`cat vlan|cut -f1 -d':'`"
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
  checkright $machine $user
  local t=$?
  if [ "$t" -eq '1' ];then
    echo "Machine inconnue"
  elif [ "$t" -eq '3' ];then
    echo "Utilisateur inconnu"
  elif [ "$t" -eq '2' ];then
    checkpasswd $user 
    if [ $t -eq '2' ];then
      virtualisation $machine $user
    else
      echo "Problème d'autentification : mot de passe incorrect"
    fi
  else
    echo "Problème de droit d'accès."
  fi
  
# /!\ Vérifier que la machine est bien accessible, et que les paramètresi ############################################
# soient bien rentré (2 params) "###################################################################################"

}
function passwd {
# Changement de mot de passe sur l'ensemble du réseau virtuel
# On passera l'utilisateur et le mot de passe en paramètre
  local user=$1
  local passwd=$2
# On cherche à quelle ligne correspond l'utilisateur dont
# on veut changer le mot de passe puis on le modifie
  while read line
  do
    if [ -n "`echo $line|grep "^$user:.*$"`" ];then
      sed -i "s/^\($user:\).*\(:.*\)$/\1$passwd\2/" passwd
      echo "Mot de passe changé"
    fi
  done < passwd
}
function finger {
# Renvoit des éléments complémentaires sur l'utilisateur
# Pointe un utilisateur et donne info style nom, mail..
  local user=$1
  if [ -n "`grep "$user" passwd`" ];then
    echo "`grep "$user:" passwd|cut -f3 -d':'`"
  else
    echo "L'utilisateur n'éxiste pas"
  fi
}

function write {
# Envoyer un message à un utilisateur connecté sur une machine du réseau
# write nom_utilisateur@nom_machine message
  local nom_utilisateur=null
  local nom_machine=null
  local dest=null
  local flag=1
  local message=null
  clear
  echo "------------------ Envoi de message ------------------"
  echo "Utilisateurs enregistrés à qui envoyer message :"
  echo "`awk '/ connecté$/{print $2" connecté sur "$1}' log`"
# Afficher les utilisateurs depuis sed sur le fichier log
  read -p "Destinataire > " nom_utilisateur
# On vérifie que l'utilisateur existe dans la base de donnée  
  if [ -n "`grep "^$nom_utilisateur:" passwd`" ]; then
    while read line 
    do
      echo $line
      echo $nom_utilisateur
      if [ -n "`echo "$line"|grep " $nom_utilisateur .* connecté$"`" ];then
        flag=0
      fi
    done < log
  
    if [ "$flag" -ne '0' ]; then
      echo "L'utilisateur n'est pas connecté"
      return 1
    fi
  else
    echo "L'utilisateur n'existe pas"
    return 1
  fi

  read -p "Machine de destination > " nom_machine
  if [ -z "`grep "^$nom_machine $nom_utilisateur .* connecté$" log`" ];then
    echo "L'utilisateur n'est pas connecté sur cette machine"
    return 1
  fi

  read -p "Saisir message > " message
  if [ -n "`ls ./Message|grep $nom_utilisateur@$nom_machine`" ]; then
    echo "----------------------------------------------------------
    Message de $user :
    
    $message
    " >> "./Message/$dest"
  else
    echo "Message de $user :
    
    $message
    " > "./Message/$dest"
  fi
  clear
}
function host {
# Admin ajoute/enlève machine au réseau  
# On passe la commande et la machine en paramètre
  clear
  echo "------------------Gestion des machines virtuelles------------------"
  local machine=null
  local cmd=null
  
  echo "Selection ajout/suppression"
  read -p "add/del > " cmd
  
  if [ "$cmd" = "add" ];then
    echo "Nom de la nouvelle machine"
    read -p "> " machine
    if [ -z "`grep "^$machine:.*$" vlan`" ];then
      echo "$machine:" >> vlan
      echo "Création de la machine $machine"
    else
      echo "La machine est déjà dans le vlan"
    fi
  elif [ "$cmd" = "del" ];then
  # Detailler les machines existantes pour choisir celle à supprimer
      echo "Machine à supprimer :"
      read -p "> " machine
    if [ -n "`grep "^$machine:.*$" vlan`" ];then
      sed -i "/^$machine:.*$/d" vlan
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
# Le if redirigera vers la fonction appropriée
# Le nom d'utilisateur et le mdp seront passé en paramètre
  clear
  echo "------ Gestion des utilisateurs : Utilisateurs, Droits et Mot de passe ------"
  local cmd=null
  echo -e "
  Ajouter un utilisateur      \033[1m> add\033[0m
  Supprimer un utilisateur    \033[1m> del\033[0m
  Gestion de droits           \033[1m> droits\033[0m
  Changement de Mot de Passe  \033[1m> pass\033[0m
  
  Entrer la commande :"
  read -p "> " cmd
  
  if [ "$cmd" = "pass" ];then
    clear
    echo "------------------ Gestion des utilisateurs : Mot de passe ------------------
    
    
    "
    local user=null
    echo "Indiquer l'utilisateur concerné :"
    read -p "> " user
    filtre $user
    user=$f
    
    if [ -n "`grep "^$user:" passwd`" ];then
      local mdp=null
      echo "Indiquer le mot de passe :"
      read -s -p "> " mdp
      filtre $mdp
      mdp=$f
      if [ -n "$mdp" ];then
        passwd $user $mdp
      fi
    else
      echo "L'utilisateur n'éxiste pas"
    fi
    
  elif [ "$cmd" = "droits" ];then
    clear
    echo "------------------ Gestion des utilisateurs : Droits ------------------
    
    
    "
    local opt=null
    echo "Indiquer supprimer (del) ou ajouter (add) :"
    read -p "> " opt
    if [ "$opt" = "add" -o "$opt" = "del" ];then
      local machine=null
      echo "Indiquer la machine concernée :"
      read -p "> " machine
    
      if [ -n "`grep "^$machine:.*$" vlan`" ];then
        local user=null
        echo "Indiquer l'utilisateur concerné :"
        read -p "> " user
        if [ -n "`grep "^$user:" passwd`" ];then
          right $opt $machine $user
        else
            echo "Cet utilisateur n'éxiste pas"
        fi
      else
        echo "Cette machine n'éxiste pas"
      fi
    else 
        echo "Veuillez choisir entre add ou del"
    fi

  elif [ "$cmd" = "add" ];then
    clear
    echo "------------------ Gestion des utilisateurs : Ajout de compte ------------------
    
    "
    add
  elif [ "$cmd" = "del" ];then
    clear
    echo "------------ Gestion des utilisateurs : Suppression de compte -----------
    
    "
    del
  else
    echo "Argument de users invalide"
  fi
}
function afinger {
# Admin renseigne sur un utilisateur, accès avec finger
# Donne toutes les info nom, pass, mail..
  clear
  local opt=null  
  local user=null
  echo "--------------------- Informations sur utilisateurs ---------------------"
  echo "Indiquer supprimer (del) ou ajouter (add) :"
  read -p "> " opt
  if [ "$opt" = "add" -a "$opt" = "del" ];then
      echo "Veuillez choisir entre add ou del"
      return 1
  fi
  echo "Indiquer l'utilisateur concerné :"
  read -p "> " user
  if [ -z "`grep "$user:" passwd`" ];then
    echo "Cet utilisateur n'existe pas"
    return 1
  fi
  if [ "$opt" = "add" ];then
    if [ -n "`grep "$user:.*:.*:" passwd`" ];then
      local rep=null
      echo "Cet utilisateur a déjà des informations :"
      echo "`grep "$user:" passwd|sed "s/$user:.*:\(.*\):/\1/"`"
      echo "Voulez vous les remplacer ? (oui/non)"
      read -p "> " rep
      while [ "$rep" != "oui" -a "$rep" != "non" ]
      do
        echo "Veuillez respecter la casse et répondre par oui ou non"
        read -p ">" rep
      done
      if [ "$rep" = "non" ];then
        echo "Retour au menu principal"
      return 1
      fi
    fi
    local info=null
    echo "Entrez vos informations"
    read -p "> " info
    filtre $info
    info=$f
    sed -i "s/^\($user:.*:\).*:$/\1$info:/" passwd
    echo "Modifications des informations de $user faites"
  fi
  if [ "$opt" = "del" ];then
    if [ -z "`grep "$user:.*:.*:" passwd`" ];then
      echo "Cet utilisateur n'a pas d'informations à supprimer"
      return 1
    fi
    sed -i "s/^\($user:.*:\).*:$/\1/" passwd
    echo "Info de l'utilisateur $user supprimées"
  fi
}
function right {
# Gère la distribution des droits 
  local opt=$1
  local machine=$2
  local user=$3
# On regarde si on veut ajouter ou retirer des droits
  if [ "$opt" = "add" ];then
    checkright $machine $user
# On vérifie que l'utilisateur n'a pas déjà le droit à ajouter
    if [ "$?" -ne '2' ];then
      sed -i "s/^\($machine:.*\)$/\1$user:/" vlan
      echo "Ajout du droit d'accès de $user sur $machine"
    else
      echo "Cet utilisateur a déjà le droit d'accès à $machine"
    fi
  elif [ "$opt" = "del" ];then
# On vérifie que l'utilisateur a bien les droits à retirer
    checkright $machine $user
    if [ "$?" -eq '2' ];then
      sed -i "s/\(.*:\)$user:\(.*\)/\1\2/" vlan
      echo "Suppression du droit d'accès de $user sur $machine"
    else
      echo "Cet utilisateur n'a pas encore le droit d'accès à $machine"
    fi
  else
    echo "Commande erronée"
  fi
}
function add {
# Permet l'ajout d'un utilisateur avec son mdp si cet
# utilisateur n'est pas encore dans la base de donnée
  local flag=0
  local user=null
  local mdp=null
  
  read -p "Nouveau nom d'utilisateur > " user
  filtre $user
  user=$f
# Vérification de l'absence de l'utilisateur
  while read line
  do
    if [ -n "`echo $line|grep "^$user:"`" ];then 
# L'utilisateur éxiste déjà si on rentre dans ce if
      local flag=1
    fi
  done < passwd

  if [ "$flag" -eq '0' ];then
    read -s -p "Nouveau mot de passe > " mdp
    echo ""
    echo "$user:$mdp:" >> passwd
    echo "Utilisateur $user créé avec $mdp comme mot de passe"
  else
    echo "Cet utilisateur éxiste déjà"
  fi
}
function del {
# Permet la suppression d'un utilisateur de la base de donnée
# On passera le nom d'utilisateur en paramètre
  local $user
  echo "Entrer le nom de l'utilisateur à supprimer :"
  read -p "> " user
  if [ -n "`grep "^$user:" passwd`" ];then
    while read line 
    do
      if [ -n "`echo $line|grep "$user:"`" ];then
        `sed -i "/^$user:/d" passwd`
        echo "Utilisateur supprimé"
      fi
    done < passwd   
    while read line 
    do
      if [ -n "`echo $line|grep ":$user:.*$"`" ];then
        sed -i "s/\(.*:\)$user:\(.*\)/\1\2/" vlan
        echo "Droits de l'utilisateur supprimé"
      fi
   done < vlan  
 else
    echo "L'utilisateur n'éxiste pas"
 fi
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
  if [ -z "`grep "^$machine:.*$" vlan`" ];then
    return 1
  fi
  if [ -z "`grep "^$user:" passwd`" ];then
    return 3
  fi
  while read line 
  do
    if [ -n "`echo $line|grep "^$machine:"|grep "^.*:$user:"`" ];then
        return 2
    fi
  done < vlan
  }
function checkpasswd {
# Permet de vérifier sur le mdp fourni est correct
# Retourne 0 si le mdp est correct, 1 sinon
# On passera l'utilisateur puis le mdp en paramètre

# On vérifie déjà si l'utilisateur est bien dans la base de données 
  local user=$1
  if [ -z "`grep "^$user:" passwd`" ];then
    return 1
  fi
  read -s -p "Mot de passe : " passwd
  echo ""

# On Cherche l'utilisateur ligne par ligne puis
# Une fois la ligne correspondante on vérifie le mdp
  while read line
  do
    if [ -n "`echo $line|grep "^$user:$passwd:"`" ];then
      return 2
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
    if [ -n "`echo $line|grep "^$machine .*"|grep "^.* $user .*$"`" ];then
      local flag=1
    fi
  done < log

# Si le flag est à 0 on crée un nouveau log, sinon on actualise

  if [ "$flag" -eq "0" ];then
    log $machine $user
  else
    sed -i "s/\($machine $user .*\)..:..:.*/\1${heure}connecté/" log
  fi
  local flag=0
  
# Gestion du prompt

  while [ "$cmd" != "exit" ]
  do
# Vérification si aucun message n'a été reçu
      if [ -n  "`ls './Message'|grep "^$user@$machine$"`" ];then
        echo "`cat ./Message/$user@$machine`"
        `rm "./Message/$user@$machine"`
      fi

    read -p "$2@$1 > " cmd arg1 arg2
    case $cmd in
    who*)
        who $machine;;
    rusers*)
      rusers;;
    rhost*)
      rhost;;
    connect*)
      if [ -n "$arg1" ];then
        connect $arg1 $user
      else
        echo "Syntaxe : > connect machine"
      fi;;
    su*)
      if [ -n "$arg1" ];then
        su $machine $arg1
      else
        echo "Argument de la commande invalide"
        echo "Syntaxe : > su user"
      fi;;
    passwd*)
      if [ -n "$arg1" ];then
        passwd $user $arg1
      else
        echo "Argument de la commande invalide"
        echo "Syntaxe : > passwd motDePasse"
      fi;;
    write*)
      write;;
    help*)
      help $arg1;;
    finger*)
      finger $user;;
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

  clear
  local cmd=null
  while [ "$cmd" != "exit" ]
  do
# Nettoyage des lignes vides dans vlan et passwd dûes aux 
# effacements de comptes/machines

    sed -i '/^$/d' passwd vlan
    echo -e "--------------------------- Réseau Virtuel RVSH -------------------
    
    Commandes admin :
    Gestion des utilisateurs/droits :        \033[1musers\033[0m     
    Informations sur un utilisateur :        \033[1mafinger + nom user\033[0m
    Gestion des machines :                   \033[1mhost\033[0m 
    "

    read -p "rvsh > " cmd arg1 arg2 arg3 arg4

    filtre $cmd
    cmd=$f
    filtre $arg1
    arg1=$f
    filtre $arg2
    arg2=$f

    case $cmd in
    host*)
      host;;
    users*)
      users;;
    afinger*)
      afinger;;
    help*)
      help $arg1;;
    add*)
      add;;
    write*)
      write;;
    exit*)
      exit;;
    *)
      echo "La commande entrée n'est pas correcte.";;
    esac
  done
}
function filtre {

    f="`echo $1|sed 's/[^a-zA-Z0-9]//g'`"
}

# DEBUT DU SCRIPT

# Création du fichier log, passwd, vlan
# et du répertoire à message si ces derniers n'éxistent pas

if [ ! -w 'log' ];then
    touch 'log'
fi

if [ ! -w 'passwd' ];then
    touch 'passwd'
fi

if [ ! -w 'vlan' ];then
    touch 'vlan'
fi

if [ ! -r "Message" ];then
  mkdir 'Message'
fi


# Création des comptes et machines par défaut
# Prise en compte du cas où seul l'admin est dans la base de donnée

# Si aucun compte user n'existe alors on en créé un par défaut

if [ -z "`cat passwd`" -o "`cut -f1 -d ':' passwd`" = 'admin' ];then
  echo "user:pass:" >> passwd
  echo "Création du compte utilisateur par défaut"
fi

if [ -z "`grep '^admin:' passwd`" ];then
  echo "admin:admin:" >> passwd
  echo "Création du compte admin par défaut"
fi

if [ -z "`cat vlan`" ];then
  echo "machine:user:" >> vlan
  echo "Création de la machine par défaut et de son droit d'accès par l'utilisateur par défaut"
fi

# Détection du mode invoqué 

if [ "$1" = "-connect" ];then
    read -p "Nom d'utilisateur > " USER
    read -p "Machine > " MACHINE
    checkright $MACHINE $USER
    r=$?
    if [ "$r" -eq '2' ];then
      checkpasswd $USER
      p=$?
      if [ "$p" -eq '2' ];then
        virtualisation $MACHINE $USER
      elif [ "$p" -eq '1' ];then
        echo "L'utilisateur n'est pas dans la base de donnée"
      else
        echo "Problème d'autentification : mot de passe incorrect"
      fi
    elif [ "$r" -eq '1' ];then
      echo "La machine demandée n'éxiste pas"
    elif [ "$r" -eq '0' ];then 
      echo "Vous n'avez pas les droit d'accès à cette machine"
    fi
elif [ "$1" = "-admin" ];then
  checkpasswd admin
  if [ "$?" -eq '2' ];then
    admin
  else
    echo "Mot de passe incorrect"
  fi
else
  echo "Préciser l'option -connect ou -admin"
fi

# comparer les hashs plutôt que les mdp en clair sur le dossier passwd
# Gérer la double connexion
# Verifier la machine destinataire

