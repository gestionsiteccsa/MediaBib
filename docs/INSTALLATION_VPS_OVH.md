# Guide d'Installation MediaBib sur VPS OVH Ubuntu

**Guide complet pour débutants - Installation sécurisée étape par étape**

Ce guide vous accompagne dans l'installation complète de MediaBib sur un serveur VPS Ubuntu chez OVH. Chaque commande est expliquée en détail pour que vous compreniez ce que vous faites.

---

## Table des matières

1. [Préparation et Connexion Initiale](#1-préparation-et-connexion-initiale)
2. [Sécurisation Initiale du Serveur](#2-sécurisation-initiale-du-serveur)
3. [Installation des Prérequis](#3-installation-des-prérequis)
4. [Configuration de la Base de Données](#4-configuration-de-la-base-de-données)
5. [Déploiement de MediaBib](#5-déploiement-de-mediabib)
6. [Configuration de Gunicorn](#6-configuration-de-gunicorn)
7. [Configuration de Nginx](#7-configuration-de-nginx)
8. [Sécurisation avec SSL/HTTPS](#8-sécurisation-avec-sslhttps)
9. [Configuration Finale et Optimisations](#9-configuration-finale-et-optimisations)
10. [Maintenance et Monitoring](#10-maintenance-et-monitoring)
11. [Checklist de Vérification](#11-checklist-de-vérification)
12. [Annexes](#12-annexes)

---

## 1. Préparation et Connexion Initiale

### 1.1 Récupération des identifiants OVH

**À quoi ça sert ?**
Vous avez besoin de ces informations pour vous connecter à votre VPS pour la première fois.

**Obligatoire ?** ✅ OUI - Sans ces identifiants, vous ne pouvez pas accéder au serveur

**Niveau de sécurité :** 🔴 CRITIQUE - Ces identifiants donnent un accès complet au serveur

**Risques :** Ne partagez JAMAIS ces identifiants. Stockez-les de manière sécurisée.

**Étapes :**

1. Connectez-vous à votre [espace client OVH](https://www.ovh.com/manager/)
2. Allez dans la section **"VPS"**
3. Cliquez sur votre VPS
4. Notez les informations suivantes :
   - **Adresse IP** : L'adresse IP publique de votre serveur (ex: `123.45.67.89`)
   - **Identifiant root** : Généralement `root`
   - **Mot de passe root** : Le mot de passe initial fourni par OVH (ou celui que vous avez défini)

**Important :** Si vous n'avez pas le mot de passe root, vous pouvez le réinitialiser depuis le manager OVH :
- Allez dans votre VPS > **"Réinitialiser le mot de passe root"**
- Un email vous sera envoyé avec le nouveau mot de passe

---

### 1.2 Connexion SSH au VPS

**À quoi ça sert ?**
SSH (Secure Shell) est le protocole qui vous permet de vous connecter à distance à votre serveur de manière sécurisée.

**Obligatoire ?** ✅ OUI - C'est la seule façon d'administrer votre serveur

**Niveau de sécurité :** ⚠️ IMPORTANT - La connexion est chiffrée, mais nous la renforcerons plus tard

**Risques :** Si vous perdez l'accès SSH et que le firewall bloque tout, vous ne pourrez plus accéder au serveur. C'est pourquoi nous configurons le firewall APRÈS avoir sécurisé SSH.

**Étapes selon votre système d'exploitation :**

#### Sur Windows

**Option 1 : Utiliser PowerShell (Windows 10/11)**

```powershell
ssh root@VOTRE_IP_OVH
```

**Explication :**
- `ssh` : Commande pour se connecter via SSH
- `root` : L'utilisateur avec lequel vous vous connectez (root = administrateur)
- `@VOTRE_IP_OVH` : L'adresse IP de votre serveur OVH

**Option 2 : Utiliser PuTTY (recommandé pour débutants)**

1. Téléchargez PuTTY depuis [putty.org](https://www.putty.org/)
2. Installez-le
3. Ouvrez PuTTY
4. Dans "Host Name (or IP address)", entrez votre adresse IP OVH
5. Port : `22` (port SSH par défaut)
6. Cliquez sur "Open"
7. Acceptez l'avertissement de sécurité (première connexion)
8. Entrez l'identifiant : `root`
9. Entrez le mot de passe (il ne s'affichera pas à l'écran, c'est normal)

#### Sur Linux / macOS

```bash
ssh root@VOTRE_IP_OVH
```

**Explication :**
- Même principe que Windows, mais directement dans le terminal

**Première connexion :**

Lors de la première connexion, vous verrez un message comme :

```
The authenticity of host '123.45.67.89 (123.45.67.89)' can't be established.
ECDSA key fingerprint is SHA256:xxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no)?
```

**Que faire ?**
- Tapez `yes` et appuyez sur Entrée
- C'est normal la première fois. Cela enregistre l'identité du serveur sur votre ordinateur

**Vérification :**

Si la connexion réussit, vous devriez voir quelque chose comme :

```
Welcome to Ubuntu 22.04 LTS (GNU/Linux 5.x.x-xx-generic x86_64)
...
root@vps123456:~#
```

Le `#` à la fin indique que vous êtes connecté en tant que root (administrateur).

**⚠️ ATTENTION :** Vous êtes maintenant connecté en tant que `root`. C'est l'utilisateur le plus puissant du système. Nous allons créer un utilisateur normal juste après pour des raisons de sécurité.

---

## 2. Sécurisation Initiale du Serveur

### 2.1 Mise à jour du système

**À quoi ça sert ?**
Les mises à jour corrigent des failles de sécurité et des bugs. Il est CRITIQUE de mettre à jour le système avant toute autre opération.

**Obligatoire ?** ✅ OUI - Obligatoire avant toute installation

**Niveau de sécurité :** 🔴 CRITIQUE - Les mises à jour incluent des correctifs de sécurité essentiels

**Risques :** Aucun - Ces commandes sont sûres. Elles ne modifient que les listes de paquets disponibles.

**Commandes :**

```bash
sudo apt update
```

**Explication :**
- `sudo` : Exécute la commande avec les droits administrateur (Super User DO)
- `apt` : Advanced Package Tool, le gestionnaire de paquets d'Ubuntu
- `update` : Met à jour la liste des paquets disponibles depuis les dépôts Ubuntu. Ne modifie PAS les logiciels installés, récupère juste les informations sur les versions disponibles.

**Vérification :**
```bash
echo $?  # Doit afficher 0 (succès)
```

Si vous voyez `0`, la commande a réussi. Si vous voyez un autre nombre, il y a eu une erreur.

**Ensuite :**

```bash
sudo apt upgrade -y
```

**Explication :**
- `upgrade` : Met à jour tous les paquets installés vers leurs dernières versions
- `-y` : Répond automatiquement "yes" à toutes les questions (évite d'avoir à confirmer)

**Durée :** Cette commande peut prendre plusieurs minutes selon le nombre de mises à jour disponibles.

**Vérification :**
```bash
echo $?  # Doit afficher 0
```

**Optionnel mais recommandé :**

```bash
sudo apt autoremove -y
```

**Explication :**
- `autoremove` : Supprime les paquets qui ne sont plus nécessaires (dépendances obsolètes)
- Nettoie le système et libère de l'espace disque

---

### 2.2 Création d'un utilisateur non-root

**À quoi ça sert ?**
Utiliser root pour tout est DANGEREUX. Une erreur peut détruire tout le système. Un utilisateur normal limite les dégâts en cas d'erreur.

**Obligatoire ?** ✅ OUI - Obligatoire pour la sécurité

**Niveau de sécurité :** 🔴 CRITIQUE - Empêche les erreurs catastrophiques

**Risques :** Si vous oubliez le mot de passe de cet utilisateur, vous devrez vous reconnecter en root pour le réinitialiser.

**Création de l'utilisateur :**

```bash
adduser mediabib
```

**Explication :**
- `adduser` : Crée un nouvel utilisateur avec un répertoire home et des paramètres par défaut
- `mediabib` : Le nom de l'utilisateur (vous pouvez choisir un autre nom si vous préférez)

**Ce qui va se passer :**
1. Vous serez invité à entrer un mot de passe (il ne s'affichera pas)
2. Vous devrez confirmer le mot de passe
3. Vous pouvez laisser les autres champs vides (nom complet, etc.) en appuyant sur Entrée

**⚠️ IMPORTANT :** Choisissez un mot de passe FORT :
- Minimum 12 caractères
- Mélange de majuscules, minuscules, chiffres et symboles
- Ne pas utiliser de mots du dictionnaire

**Ajouter l'utilisateur au groupe sudo :**

```bash
usermod -aG sudo mediabib
```

**Explication :**
- `usermod` : Modifie un utilisateur existant
- `-aG` : Ajoute (`-a`) l'utilisateur au groupe (`-G`) spécifié
- `sudo` : Le groupe qui permet d'exécuter des commandes avec les droits administrateur
- `mediabib` : L'utilisateur à modifier

**Pourquoi ?** Cela permet à l'utilisateur `mediabib` d'utiliser `sudo` pour les commandes nécessitant les droits administrateur, sans être root en permanence.

**Vérification :**

```bash
groups mediabib
```

Vous devriez voir `mediabib sudo` dans la sortie.

**Tester la connexion avec le nouvel utilisateur :**

Ouvrez un NOUVEAU terminal (gardez la session root ouverte au cas où) et testez :

```bash
ssh mediabib@VOTRE_IP_OVH
```

Connectez-vous avec le mot de passe que vous avez défini.

**Vérification que sudo fonctionne :**

```bash
sudo whoami
```

Vous devriez voir `root`. Cela confirme que sudo fonctionne.

**Note :** La première fois que vous utilisez `sudo`, vous devrez entrer votre mot de passe utilisateur (pas le mot de passe root).

---

### 2.3 Configuration SSH sécurisée

**À quoi ça sert ?**
Sécuriser SSH empêche les attaques par force brute et limite l'accès au serveur.

**Obligatoire ?** ✅ OUI - Obligatoire avant d'exposer le serveur

**Niveau de sécurité :** 🔴 CRITIQUE - SSH est la porte d'entrée de votre serveur

**Risques :** ⚠️ ATTENTION - Si vous vous déconnectez avant de tester, vous pourriez perdre l'accès. Testez TOUJOURS dans une deuxième session SSH avant de fermer la première.

**Étape 1 : Sauvegarder la configuration actuelle**

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
```

**Explication :**
- `cp` : Copie un fichier
- `/etc/ssh/sshd_config` : Le fichier de configuration SSH
- `/etc/ssh/sshd_config.backup` : La copie de sauvegarde

**Pourquoi ?** Si quelque chose ne va pas, vous pourrez restaurer la configuration originale.

**Étape 2 : Éditer la configuration SSH**

```bash
sudo nano /etc/ssh/sshd_config
```

**Explication :**
- `nano` : Un éditeur de texte simple pour débutants
- `/etc/ssh/sshd_config` : Le fichier de configuration SSH

**Navigation dans nano :**
- Utilisez les flèches pour vous déplacer
- `Ctrl + O` puis `Entrée` pour sauvegarder
- `Ctrl + X` pour quitter

**Modifications à apporter :**

Recherchez et modifiez les lignes suivantes (utilisez `Ctrl + W` pour rechercher) :

**1. Désactiver la connexion root :**

Trouvez :
```
#PermitRootLogin yes
```

Changez en :
```
PermitRootLogin no
```

**Explication :**
- `PermitRootLogin no` : Empêche les connexions SSH directes en tant que root
- Pourquoi ? Même si un attaquant trouve votre mot de passe, il ne pourra pas se connecter en root directement

**2. Désactiver l'authentification par mot de passe (optionnel mais recommandé) :**

Trouvez :
```
#PasswordAuthentication yes
```

Changez en :
```
PasswordAuthentication yes
```

**Note :** Pour l'instant, laissez `yes`. Nous pourrons passer à l'authentification par clé SSH plus tard (plus sécurisé mais plus complexe).

**3. Changer le port SSH (optionnel mais recommandé) :**

Trouvez :
```
#Port 22
```

Changez en :
```
Port 2222
```

**Explication :**
- `Port 2222` : Change le port SSH de 22 (par défaut) à 2222
- Pourquoi ? La plupart des attaques automatiques ciblent le port 22. Changer le port réduit le bruit des attaques
- **Important :** Notez ce numéro de port, vous en aurez besoin pour vous connecter

**4. Limiter les tentatives de connexion :**

Ajoutez à la fin du fichier :
```
MaxAuthTries 3
```

**Explication :**
- `MaxAuthTries 3` : Limite à 3 le nombre de tentatives de connexion avant déconnexion
- Empêche les attaques par force brute

**Sauvegarder et quitter :**
- `Ctrl + O` puis `Entrée`
- `Ctrl + X`

**Étape 3 : Tester la configuration**

```bash
sudo sshd -t
```

**Explication :**
- `sshd -t` : Teste la configuration SSH sans redémarrer le service
- Si vous voyez des erreurs, corrigez-les avant de continuer

**Vérification :**
```bash
echo $?  # Doit afficher 0
```

**Étape 4 : Redémarrer le service SSH**

```bash
sudo systemctl restart sshd
```

**Explication :**
- `systemctl` : Gère les services système
- `restart` : Redémarre le service
- `sshd` : Le service SSH

**⚠️ CRITIQUE :** Ne fermez PAS votre session actuelle ! Ouvrez un NOUVEAU terminal et testez la connexion :

```bash
ssh -p 2222 mediabib@VOTRE_IP_OVH
```

**Explication :**
- `-p 2222` : Spécifie le nouveau port SSH

Si la connexion fonctionne, vous pouvez continuer. Si elle ne fonctionne pas, reconnectez-vous avec l'ancienne session root et restaurez la configuration :

```bash
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart sshd
```

---

### 2.4 Installation et configuration du firewall UFW

**À quoi ça sert ?**
Un firewall contrôle le trafic réseau entrant et sortant, protégeant votre serveur des accès non autorisés.

**Obligatoire ?** ✅ OUI - Obligatoire avant d'exposer des services

**Niveau de sécurité :** 🔴 CRITIQUE - Sans firewall, votre serveur est exposé à tous

**Risques :** ⚠️ Si vous bloquez le port SSH par erreur, vous perdrez l'accès. C'est pourquoi nous autorisons SSH EN PREMIER.

**Installation d'UFW :**

```bash
sudo apt install ufw -y
```

**Explication :**
- `apt install` : Installe un paquet
- `ufw` : Uncomplicated Firewall, un firewall simple pour Ubuntu
- `-y` : Confirme automatiquement

**Configuration des règles de base :**

**1. Autoriser SSH (CRITIQUE - FAIRE EN PREMIER) :**

```bash
sudo ufw allow 2222/tcp
```

**Explication :**
- `ufw allow` : Autorise un trafic
- `2222/tcp` : Le port 2222 en TCP (le protocole SSH)
- **⚠️ Si vous avez changé le port SSH, utilisez VOTRE port ici !**

**2. Autoriser HTTP (pour le site web) :**

```bash
sudo ufw allow http
```

**Explication :**
- `http` : Autorise le port 80 (HTTP)
- Nécessaire pour que les visiteurs accèdent à votre site

**3. Autoriser HTTPS (pour le site web sécurisé) :**

```bash
sudo ufw allow https
```

**Explication :**
- `https` : Autorise le port 443 (HTTPS)
- Nécessaire pour le SSL/TLS

**Activation du firewall :**

```bash
sudo ufw enable
```

**Explication :**
- `enable` : Active le firewall
- Vous serez invité à confirmer. Tapez `y` et appuyez sur Entrée

**⚠️ ATTENTION :** Une fois activé, seuls les ports autorisés seront accessibles. C'est pourquoi nous avons autorisé SSH en premier !

**Vérification de l'état :**

```bash
sudo ufw status verbose
```

**Explication :**
- `status` : Affiche l'état du firewall
- `verbose` : Affiche plus de détails

Vous devriez voir quelque chose comme :

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
2222/tcp                   ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
```

**Vérification :**
- Le firewall est `active`
- Les ports 2222, 80 et 443 sont autorisés

---

### 2.5 Installation et configuration de Fail2Ban

**À quoi ça sert ?**
Fail2Ban surveille les journaux système et bloque automatiquement les adresses IP qui tentent de s'introduire (attaques par force brute).

**Obligatoire ?** ✅ OUI - Recommandé fortement pour la sécurité

**Niveau de sécurité :** ⚠️ IMPORTANT - Protège contre les attaques automatisées

**Risques :** Aucun - Fail2Ban est sûr à utiliser

**Installation :**

```bash
sudo apt install fail2ban -y
```

**Explication :**
- `fail2ban` : Outil de protection contre les attaques par force brute

**Création de la configuration personnalisée :**

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

**Explication :**
- `jail.conf` : Configuration par défaut
- `jail.local` : Configuration personnalisée (prioritaire sur .conf)

**Édition de la configuration :**

```bash
sudo nano /etc/fail2ban/jail.local
```

**Modifications à apporter :**

Trouvez la section `[sshd]` et modifiez :

```
[sshd]
enabled = true
port = 2222
maxretry = 5
bantime = 3600
findtime = 600
```

**Explication :**
- `enabled = true` : Active la protection SSH
- `port = 2222` : Le port SSH que vous utilisez (ajustez si différent)
- `maxretry = 5` : Nombre de tentatives échouées avant bannissement
- `bantime = 3600` : Durée du bannissement en secondes (1 heure)
- `findtime = 600` : Période pendant laquelle les tentatives sont comptabilisées (10 minutes)

**Démarrage et activation de Fail2Ban :**

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**Explication :**
- `enable` : Active le démarrage automatique au boot
- `start` : Démarre le service maintenant

**Vérification :**

```bash
sudo fail2ban-client status
```

Vous devriez voir :

```
Status
|- Number of jail:	1
`- Jail list:	sshd
```

**Vérification détaillée :**

```bash
sudo fail2ban-client status sshd
```

Cela affiche les statistiques de la protection SSH.

---

## 3. Installation des Prérequis

### 3.1 Installation de Python 3.10+ et pip

**À quoi ça sert ?**
MediaBib est une application Django (Python). Vous avez besoin de Python pour l'exécuter.

**Obligatoire ?** ✅ OUI - Obligatoire pour MediaBib

**Niveau de sécurité :** ✅ Normal - Installation standard

**Risques :** Aucun

**Vérification de la version Python :**

```bash
python3 --version
```

**Explication :**
- `python3` : Python 3 (Ubuntu 22.04 inclut Python 3.10+ par défaut)
- `--version` : Affiche la version

Vous devriez voir quelque chose comme `Python 3.10.12` ou supérieur.

**Si Python n'est pas installé (peu probable) :**

```bash
sudo apt install python3 python3-pip python3-venv -y
```

**Explication :**
- `python3` : L'interpréteur Python
- `python3-pip` : Le gestionnaire de paquets Python (pip)
- `python3-venv` : Outil pour créer des environnements virtuels

**Vérification de pip :**

```bash
pip3 --version
```

Vous devriez voir la version de pip.

**Mise à jour de pip :**

```bash
sudo pip3 install --upgrade pip
```

**Explication :**
- `--upgrade pip` : Met à jour pip vers la dernière version

---

### 3.2 Installation de PostgreSQL

**À quoi ça sert ?**
PostgreSQL est la base de données qui stockera toutes les données de MediaBib (notices, utilisateurs, prêts, etc.).

**Obligatoire ?** ✅ OUI - Obligatoire pour la production

**Niveau de sécurité :** ⚠️ IMPORTANT - La base de données contient des données sensibles

**Risques :** Aucun lors de l'installation

**Installation :**

```bash
sudo apt install postgresql postgresql-contrib -y
```

**Explication :**
- `postgresql` : Le serveur de base de données PostgreSQL
- `postgresql-contrib` : Extensions supplémentaires utiles

**Vérification de l'installation :**

```bash
sudo systemctl status postgresql
```

**Explication :**
- `status` : Affiche l'état du service

Vous devriez voir `active (running)` en vert.

**Activation du démarrage automatique :**

```bash
sudo systemctl enable postgresql
```

**Explication :**
- `enable` : Active le démarrage automatique au boot

**Vérification de la version :**

```bash
psql --version
```

Vous devriez voir la version de PostgreSQL (14+ recommandé).

---

### 3.3 Installation de Git

**À quoi ça sert ?**
Git permet de cloner le code source de MediaBib depuis GitHub.

**Obligatoire ?** ✅ OUI - Pour récupérer le code

**Niveau de sécurité :** ✅ Normal

**Risques :** Aucun

**Installation :**

```bash
sudo apt install git -y
```

**Vérification :**

```bash
git --version
```

---

### 3.4 Installation de Nginx

**À quoi ça sert ?**
Nginx est le serveur web qui servira votre application MediaBib. Il fait le lien entre les visiteurs et votre application Django.

**Obligatoire ?** ✅ OUI - Obligatoire pour servir l'application en production

**Niveau de sécurité :** ⚠️ IMPORTANT - Nginx est exposé à Internet

**Risques :** Aucun lors de l'installation

**Installation :**

```bash
sudo apt install nginx -y
```

**Démarrage et activation :**

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

**Vérification :**

```bash
sudo systemctl status nginx
```

Vous devriez voir `active (running)`.

**Test dans le navigateur :**

Ouvrez votre navigateur et allez à `http://VOTRE_IP_OVH`

Vous devriez voir la page par défaut de Nginx "Welcome to nginx!".

**Si vous ne voyez rien :**
- Vérifiez que le firewall autorise le port 80 : `sudo ufw status`
- Vérifiez que Nginx fonctionne : `sudo systemctl status nginx`

---

### 3.5 Installation des dépendances système

**À quoi ça sert ?**
Certaines bibliothèques Python nécessitent des outils système pour compiler.

**Obligatoire ?** ✅ OUI - Pour installer certaines dépendances Python

**Niveau de sécurité :** ✅ Normal

**Risques :** Aucun

**Installation :**

```bash
sudo apt install build-essential libpq-dev python3-dev -y
```

**Explication :**
- `build-essential` : Outils de compilation (gcc, make, etc.)
- `libpq-dev` : Bibliothèques de développement PostgreSQL (nécessaire pour psycopg2)
- `python3-dev` : En-têtes de développement Python

---

## 4. Configuration de la Base de Données

### 4.1 Création de l'utilisateur PostgreSQL

**À quoi ça sert ?**
Créer un utilisateur dédié pour MediaBib limite les risques en cas de compromission.

**Obligatoire ?** ✅ OUI - Obligatoire pour la sécurité

**Niveau de sécurité :** 🔴 CRITIQUE - L'utilisateur de la base de données doit avoir des permissions limitées

**Risques :** Si vous oubliez le mot de passe, vous devrez le réinitialiser depuis root PostgreSQL.

**Connexion à PostgreSQL :**

```bash
sudo -u postgres psql
```

**Explication :**
- `sudo -u postgres` : Exécute la commande en tant qu'utilisateur postgres
- `psql` : Le client PostgreSQL

Vous devriez voir un prompt comme `postgres=#`

**Création de l'utilisateur :**

Dans le prompt PostgreSQL, exécutez :

```sql
CREATE USER mediabib_user WITH PASSWORD 'VOTRE_MOT_DE_PASSE_FORT';
```

**Explication :**
- `CREATE USER` : Crée un nouvel utilisateur
- `mediabib_user` : Le nom de l'utilisateur (vous pouvez choisir un autre nom)
- `WITH PASSWORD` : Définit le mot de passe
- **⚠️ Remplacez `VOTRE_MOT_DE_PASSE_FORT` par un mot de passe fort (minimum 16 caractères, complexe)**

**Configuration de l'encodage et du fuseau horaire :**

```sql
ALTER ROLE mediabib_user SET client_encoding TO 'utf8';
ALTER ROLE mediabib_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE mediabib_user SET timezone TO 'Europe/Paris';
```

**Explication :**
- `client_encoding TO 'utf8'` : Utilise UTF-8 pour les caractères (nécessaire pour le français)
- `default_transaction_isolation TO 'read committed'` : Niveau d'isolation des transactions (standard)
- `timezone TO 'Europe/Paris'` : Fuseau horaire français

**Quitter PostgreSQL :**

```sql
\q
```

**Explication :**
- `\q` : Quitte le client PostgreSQL

**Vérification :**

```bash
sudo -u postgres psql -c "\du"
```

**Explication :**
- `-c` : Exécute une commande SQL
- `\du` : Liste tous les utilisateurs

Vous devriez voir `mediabib_user` dans la liste.

---

### 4.2 Création de la base de données

**À quoi ça sert ?**
La base de données stockera toutes les données de MediaBib.

**Obligatoire ?** ✅ OUI - Obligatoire

**Niveau de sécurité :** ⚠️ IMPORTANT - La base de données contient des données sensibles

**Risques :** Aucun

**Connexion à PostgreSQL :**

```bash
sudo -u postgres psql
```

**Création de la base de données :**

```sql
CREATE DATABASE mediabib OWNER mediabib_user;
```

**Explication :**
- `CREATE DATABASE` : Crée une nouvelle base de données
- `mediabib` : Le nom de la base de données
- `OWNER mediabib_user` : L'utilisateur propriétaire de la base

**Configuration de l'encodage :**

```sql
\c mediabib
```

**Explication :**
- `\c` : Se connecte à une base de données

```sql
ALTER DATABASE mediabib SET timezone TO 'Europe/Paris';
```

**Quitter :**

```sql
\q
```

**Vérification :**

```bash
sudo -u postgres psql -c "\l"
```

**Explication :**
- `\l` : Liste toutes les bases de données

Vous devriez voir `mediabib` dans la liste.

---

### 4.3 Configuration de la sécurité PostgreSQL

**À quoi ça sert ?**
Limiter l'accès à PostgreSQL uniquement aux connexions locales sécurise la base de données.

**Obligatoire ?** ✅ OUI - Recommandé fortement

**Niveau de sécurité :** 🔴 CRITIQUE - PostgreSQL ne doit pas être accessible depuis Internet

**Risques :** Si vous modifiez mal ce fichier, vous pourriez perdre l'accès à PostgreSQL. Faites une sauvegarde d'abord.

**Sauvegarde de la configuration :**

```bash
sudo cp /etc/postgresql/*/main/pg_hba.conf /etc/postgresql/*/main/pg_hba.conf.backup
```

**Explication :**
- `pg_hba.conf` : Fichier de configuration de l'authentification PostgreSQL
- Le `*` correspond à la version de PostgreSQL (ex: 14, 15)

**Vérification de la configuration actuelle :**

```bash
sudo cat /etc/postgresql/*/main/pg_hba.conf | grep -v "^#"
```

**Explication :**
- `cat` : Affiche le contenu d'un fichier
- `grep -v "^#"` : Affiche uniquement les lignes non commentées

**La configuration par défaut devrait déjà être sécurisée** (connexions locales uniquement). Si vous voyez des lignes avec `host` et une adresse IP autre que `127.0.0.1`, c'est un problème de sécurité.

**Redémarrage de PostgreSQL (si vous avez modifié) :**

```bash
sudo systemctl restart postgresql
```

---

## 5. Déploiement de MediaBib

### 5.1 Clonage du dépôt Git

**À quoi ça sert ?**
Récupère le code source de MediaBib depuis GitHub.

**Obligatoire ?** ✅ OUI - Pour obtenir le code

**Niveau de sécurité :** ✅ Normal

**Risques :** Aucun

**Création du répertoire pour l'application :**

```bash
sudo mkdir -p /var/www
cd /var/www
```

**Explication :**
- `mkdir -p` : Crée un répertoire (et les parents si nécessaire)
- `/var/www` : Emplacement standard pour les applications web
- `cd` : Change de répertoire

**Clonage du dépôt :**

```bash
sudo git clone https://github.com/gestionsiteccsa/MediaBib.git mediabib
```

**Explication :**
- `git clone` : Clone un dépôt Git
- `https://github.com/...` : L'URL du dépôt
- `mediabib` : Le nom du dossier de destination

**Si le dépôt est privé**, vous devrez utiliser SSH ou un token d'accès :

```bash
sudo git clone git@github.com:gestionsiteccsa/MediaBib.git mediabib
```

**Changement de propriétaire :**

```bash
sudo chown -R mediabib:mediabib /var/www/mediabib
```

**Explication :**
- `chown -R` : Change le propriétaire récursivement
- `mediabib:mediabib` : Utilisateur et groupe (votre utilisateur)
- `/var/www/mediabib` : Le répertoire de l'application

**Vérification :**

```bash
ls -la /var/www/mediabib
```

Vous devriez voir les fichiers du projet.

---

### 5.2 Création de l'environnement virtuel Python

**À quoi ça sert ?**
Un environnement virtuel isole les dépendances Python de votre projet du reste du système.

**Obligatoire ?** ✅ OUI - Bonne pratique obligatoire

**Niveau de sécurité :** ✅ Normal - Bonne pratique

**Risques :** Aucun

**Accès au répertoire :**

```bash
cd /var/www/mediabib
```

**Création de l'environnement virtuel :**

```bash
python3 -m venv venv
```

**Explication :**
- `python3 -m venv` : Crée un environnement virtuel
- `venv` : Le nom du dossier de l'environnement virtuel

**Activation de l'environnement virtuel :**

```bash
source venv/bin/activate
```

**Explication :**
- `source` : Exécute un script dans le shell actuel
- `venv/bin/activate` : Le script d'activation de l'environnement virtuel

**Vérification :**

Vous devriez voir `(venv)` au début de votre prompt, comme :

```
(venv) mediabib@vps123456:/var/www/mediabib$
```

**Important :** Chaque fois que vous vous reconnectez au serveur, vous devrez réactiver l'environnement virtuel avec cette commande.

---

### 5.3 Installation des dépendances Python

**À quoi ça sert ?**
Installe tous les paquets Python nécessaires pour MediaBib.

**Obligatoire ?** ✅ OUI - Obligatoire

**Niveau de sécurité :** ⚠️ IMPORTANT - Utilisez toujours les versions spécifiées dans requirements.txt

**Risques :** Aucun

**Mise à jour de pip :**

```bash
pip install --upgrade pip
```

**Installation des dépendances :**

```bash
pip install -r requirements.txt
```

**Explication :**
- `pip install` : Installe des paquets Python
- `-r requirements.txt` : Installe tous les paquets listés dans le fichier requirements.txt

**Durée :** Cette commande peut prendre plusieurs minutes.

**Vérification :**

```bash
pip list
```

Vous devriez voir tous les paquets installés, incluant Django, gunicorn, psycopg2-binary, etc.

---

### 5.4 Configuration du fichier .env

**À quoi ça sert ?**
Le fichier `.env` contient toutes les variables de configuration sensibles (mots de passe, clés secrètes, etc.).

**Obligatoire ?** ✅ OUI - Obligatoire

**Niveau de sécurité :** 🔴 CRITIQUE - Ce fichier contient des secrets. Ne le partagez JAMAIS.

**Risques :** Si ce fichier est compromis, votre application est compromise.

**Copie du fichier exemple :**

```bash
cp env.example .env
```

**Explication :**
- `cp` : Copie un fichier
- `env.example` : Le fichier exemple
- `.env` : Le fichier de configuration réel (le point au début le rend caché)

**Édition du fichier .env :**

```bash
nano .env
```

**Configuration minimale requise :**

```ini
# =================================
# Django Core Settings
# =================================

# SECURITY WARNING: Generate a new secret key for production!
SECRET_KEY=votre-cle-secrete-unique-generee

# Debug mode (False en production)
DEBUG=False

# Allowed hosts (votre domaine ou IP)
ALLOWED_HOSTS=votre-domaine.com,www.votre-domaine.com

# =================================
# Database Configuration
# =================================

DATABASE_URL=postgres://mediabib_user:VOTRE_MOT_DE_PASSE@localhost:5432/mediabib
```

**Génération d'une SECRET_KEY unique :**

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

**Explication :**
- Cette commande génère une clé secrète aléatoire unique
- Copiez le résultat et collez-le dans `SECRET_KEY=`

**Configuration de ALLOWED_HOSTS :**

Remplacez `votre-domaine.com` par :
- Votre nom de domaine (si vous en avez un)
- OU votre adresse IP OVH
- OU les deux, séparés par des virgules

**Exemple :**
```ini
ALLOWED_HOSTS=mediabib.example.com,123.45.67.89
```

**Configuration de DATABASE_URL :**

Remplacez `VOTRE_MOT_DE_PASSE` par le mot de passe que vous avez défini pour `mediabib_user` à l'étape 4.1.

**Format :** `postgres://utilisateur:mot_de_passe@localhost:5432/nom_base`

**Sauvegarde :**
- `Ctrl + O` puis `Entrée`
- `Ctrl + X`

**Sécurisation du fichier .env :**

```bash
chmod 600 .env
```

**Explication :**
- `chmod 600` : Donne les permissions lecture/écriture uniquement au propriétaire
- Empêche les autres utilisateurs de lire le fichier

**Vérification :**

```bash
ls -la .env
```

Vous devriez voir `-rw-------` (seul le propriétaire peut lire/écrire).

---

### 5.5 Application des migrations Django

**À quoi ça sert ?**
Les migrations créent la structure de la base de données (tables, colonnes, etc.).

**Obligatoire ?** ✅ OUI - Obligatoire avant le premier démarrage

**Niveau de sécurité :** ✅ Normal

**Risques :** Aucun

**Vérification de la configuration :**

```bash
python manage.py check
```

**Explication :**
- `check` : Vérifie la configuration Django sans modifier quoi que ce soit

Vous devriez voir "System check identified no issues".

**Application des migrations :**

```bash
python manage.py migrate
```

**Explication :**
- `migrate` : Applique toutes les migrations en attente
- Crée toutes les tables dans la base de données

**Durée :** Peut prendre quelques secondes.

**Vérification :**

```bash
python manage.py showmigrations
```

**Explication :**
- `showmigrations` : Affiche l'état de toutes les migrations

Toutes les migrations devraient avoir une `[X]` (appliquées).

---

### 5.6 Collecte des fichiers statiques

**À quoi ça sert ?**
Django collecte tous les fichiers statiques (CSS, JavaScript, images) dans un seul répertoire pour que Nginx puisse les servir efficacement.

**Obligatoire ?** ✅ OUI - Obligatoire en production

**Niveau de sécurité :** ✅ Normal

**Risques :** Aucun

**Collecte des fichiers statiques :**

```bash
python manage.py collectstatic --no-input
```

**Explication :**
- `collectstatic` : Collecte tous les fichiers statiques
- `--no-input` : Ne demande pas de confirmation (utile pour les scripts)

**Vérification :**

```bash
ls -la staticfiles/
```

Vous devriez voir des dossiers comme `admin`, `static`, etc.

---

## 6. Configuration de Gunicorn

### 6.1 Vérification de l'installation de Gunicorn

**À quoi ça sert ?**
Gunicorn est le serveur WSGI qui exécute votre application Django. Il fait le lien entre Nginx et Django.

**Obligatoire ?** ✅ OUI - Obligatoire pour servir Django en production

**Niveau de sécurité :** ⚠️ IMPORTANT - Gunicorn ne doit pas être exposé directement à Internet

**Risques :** Aucun

**Vérification :**

```bash
gunicorn --version
```

Vous devriez voir la version de Gunicorn.

Si Gunicorn n'est pas installé (il devrait l'être via requirements.txt), installez-le :

```bash
pip install gunicorn
```

---

### 6.2 Test de Gunicorn

**À quoi ça sert ?**
Tester Gunicorn avant de créer le service systemd permet de vérifier que tout fonctionne.

**Obligatoire ?** ⚠️ Recommandé - Pour vérifier que tout fonctionne

**Niveau de sécurité :** ✅ Normal

**Risques :** Aucun

**Test de démarrage :**

```bash
gunicorn --bind 127.0.0.1:8000 app.wsgi:application
```

**Explication :**
- `--bind 127.0.0.1:8000` : Écoute sur localhost port 8000 (pas accessible depuis Internet)
- `app.wsgi:application` : L'application WSGI Django

**Vérification :**

Dans un autre terminal, testez :

```bash
curl http://127.0.0.1:8000
```

Vous devriez voir du HTML (la page d'accueil de MediaBib).

**Arrêt de Gunicorn :**
- Appuyez sur `Ctrl + C` dans le terminal où Gunicorn tourne

---

### 6.3 Création du service systemd pour Gunicorn

**À quoi ça sert ?**
Un service systemd permet à Gunicorn de démarrer automatiquement au boot et de redémarrer en cas de crash.

**Obligatoire ?** ✅ OUI - Obligatoire pour la production

**Niveau de sécurité :** ⚠️ IMPORTANT - Le service doit tourner avec un utilisateur non-root

**Risques :** Aucun

**Création du fichier de service :**

```bash
sudo nano /etc/systemd/system/mediabib.service
```

**Contenu du fichier :**

```ini
[Unit]
Description=MediaBib Gunicorn daemon
After=network.target

[Service]
User=mediabib
Group=mediabib
WorkingDirectory=/var/www/mediabib
Environment="PATH=/var/www/mediabib/venv/bin"
ExecStart=/var/www/mediabib/venv/bin/gunicorn \
    --workers 3 \
    --timeout 120 \
    --bind 127.0.0.1:8000 \
    --access-logfile /var/log/mediabib/access.log \
    --error-logfile /var/log/mediabib/error.log \
    app.wsgi:application

[Install]
WantedBy=multi-user.target
```

**Explication ligne par ligne :**

- `[Unit]` : Section de description du service
- `Description` : Description du service
- `After=network.target` : Démarre après le réseau
- `[Service]` : Configuration du service
- `User=mediabib` : Exécute en tant qu'utilisateur mediabib (non-root)
- `Group=mediabib` : Groupe mediabib
- `WorkingDirectory` : Répertoire de travail
- `Environment="PATH=..."` : Chemin vers l'environnement virtuel
- `ExecStart` : Commande de démarrage
- `--workers 3` : 3 processus workers (ajustez selon votre VPS)
- `--timeout 120` : Timeout de 120 secondes
- `--bind 127.0.0.1:8000` : Écoute sur localhost (Nginx fera le proxy)
- `--access-logfile` : Fichier de log des accès
- `--error-logfile` : Fichier de log des erreurs
- `app.wsgi:application` : Application Django
- `[Install]` : Configuration d'installation
- `WantedBy=multi-user.target` : Démarre au boot

**Création du répertoire de logs :**

```bash
sudo mkdir -p /var/log/mediabib
sudo chown mediabib:mediabib /var/log/mediabib
```

**Rechargement de systemd :**

```bash
sudo systemctl daemon-reload
```

**Explication :**
- `daemon-reload` : Recharge la configuration systemd

**Activation du service :**

```bash
sudo systemctl enable mediabib
```

**Explication :**
- `enable` : Active le démarrage automatique

**Démarrage du service :**

```bash
sudo systemctl start mediabib
```

**Vérification du statut :**

```bash
sudo systemctl status mediabib
```

Vous devriez voir `active (running)` en vert.

**Vérification des logs :**

```bash
sudo journalctl -u mediabib -f
```

**Explication :**
- `journalctl` : Affiche les logs systemd
- `-u mediabib` : Logs du service mediabib
- `-f` : Suit les logs en temps réel (appuyez sur `Ctrl + C` pour quitter)

**Test de l'application :**

```bash
curl http://127.0.0.1:8000
```

Vous devriez voir du HTML.

---

## 7. Configuration de Nginx

### 7.1 Création de la configuration Nginx

**À quoi ça sert ?**
Nginx sert de reverse proxy : il reçoit les requêtes HTTP/HTTPS et les transmet à Gunicorn.

**Obligatoire ?** ✅ OUI - Obligatoire pour servir l'application

**Niveau de sécurité :** 🔴 CRITIQUE - Nginx est exposé à Internet

**Risques :** Si la configuration est incorrecte, le site ne fonctionnera pas.

**Création de la configuration :**

```bash
sudo nano /etc/nginx/sites-available/mediabib
```

**Contenu du fichier :**

```nginx
server {
    listen 80;
    server_name votre-domaine.com www.votre-domaine.com;

    # Redirection vers HTTPS (sera activé après installation SSL)
    # return 301 https://$server_name$request_uri;

    # Pour l'instant, on laisse HTTP fonctionner
    # (décommentez la ligne return 301 après avoir installé SSL)

    # Logs
    access_log /var/log/nginx/mediabib_access.log;
    error_log /var/log/nginx/mediabib_error.log;

    # Taille maximale des uploads
    client_max_body_size 100M;

    # Fichiers statiques
    location /static/ {
        alias /var/www/mediabib/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Fichiers média (uploads utilisateurs)
    location /media/ {
        alias /var/www/mediabib/media/;
        expires 7d;
        add_header Cache-Control "public";
    }

    # Proxy vers Gunicorn
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

**Explication des sections importantes :**

- `listen 80` : Écoute sur le port HTTP (80)
- `server_name` : Remplacez par votre domaine ou IP
- `location /static/` : Sert les fichiers statiques directement (plus rapide)
- `location /media/` : Sert les fichiers média
- `location /` : Toutes les autres requêtes vont à Gunicorn
- `proxy_pass` : Transmet les requêtes à Gunicorn sur localhost:8000
- `proxy_set_header` : Transmet les en-têtes HTTP nécessaires

**Remplacez `votre-domaine.com`** par :
- Votre nom de domaine (si vous en avez un)
- OU votre adresse IP OVH
- OU les deux

**Exemple :**
```nginx
server_name mediabib.example.com 123.45.67.89;
```

**Activation du site :**

```bash
sudo ln -s /etc/nginx/sites-available/mediabib /etc/nginx/sites-enabled/
```

**Explication :**
- `ln -s` : Crée un lien symbolique
- Active le site en créant un lien depuis `sites-enabled`

**Désactivation du site par défaut (optionnel) :**

```bash
sudo rm /etc/nginx/sites-enabled/default
```

**Test de la configuration Nginx :**

```bash
sudo nginx -t
```

**Explication :**
- `-t` : Teste la configuration sans redémarrer

Vous devriez voir :

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**Redémarrage de Nginx :**

```bash
sudo systemctl restart nginx
```

**Vérification :**

```bash
sudo systemctl status nginx
```

**Test dans le navigateur :**

Allez à `http://VOTRE_IP_OVH` ou `http://votre-domaine.com`

Vous devriez voir l'application MediaBib !

**Si vous voyez une erreur 502 Bad Gateway :**
- Vérifiez que Gunicorn fonctionne : `sudo systemctl status mediabib`
- Vérifiez les logs : `sudo journalctl -u mediabib -n 50`

---

## 8. Sécurisation avec SSL/HTTPS

### 8.1 Installation de Certbot

**À quoi ça sert ?**
Certbot est l'outil officiel pour obtenir des certificats SSL gratuits depuis Let's Encrypt.

**Obligatoire ?** ✅ OUI - Obligatoire pour HTTPS en production

**Niveau de sécurité :** 🔴 CRITIQUE - HTTPS est obligatoire pour sécuriser les communications

**Risques :** Aucun

**Installation :**

```bash
sudo apt install certbot python3-certbot-nginx -y
```

**Explication :**
- `certbot` : L'outil Certbot
- `python3-certbot-nginx` : Plugin Nginx pour Certbot

**Vérification :**

```bash
certbot --version
```

---

### 8.2 Obtention du certificat SSL

**À quoi ça sert ?**
Le certificat SSL permet de chiffrer les communications entre le navigateur et le serveur.

**Obligatoire ?** ✅ OUI - Obligatoire pour la production

**Niveau de sécurité :** 🔴 CRITIQUE - Sans HTTPS, les mots de passe et données sont en clair

**Risques :** ⚠️ Certbot modifie la configuration Nginx automatiquement. Faites une sauvegarde d'abord.

**Prérequis :**
- Votre domaine doit pointer vers l'IP du VPS (DNS configuré)
- Le port 80 doit être accessible (déjà fait avec UFW)

**Sauvegarde de la configuration Nginx :**

```bash
sudo cp /etc/nginx/sites-available/mediabib /etc/nginx/sites-available/mediabib.backup
```

**Obtention du certificat :**

```bash
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com
```

**Explication :**
- `--nginx` : Utilise le plugin Nginx
- `-d` : Spécifie le domaine (répétez pour plusieurs domaines)

**Ce qui va se passer :**
1. Certbot vous demandera votre email (pour les notifications d'expiration)
2. Vous devrez accepter les conditions d'utilisation
3. Certbot vérifiera que vous contrôlez le domaine
4. Certbot obtiendra et installera le certificat
5. Certbot modifiera automatiquement la configuration Nginx pour utiliser HTTPS

**Si vous n'avez pas de domaine :**

Vous ne pouvez pas utiliser Let's Encrypt sans domaine. Options :
- Utiliser un domaine gratuit (Freenom, etc.)
- Utiliser un sous-domaine
- Utiliser un certificat auto-signé (non recommandé pour la production)

**Vérification :**

```bash
sudo certbot certificates
```

Vous devriez voir votre certificat listé.

**Test dans le navigateur :**

Allez à `https://votre-domaine.com`

Vous devriez voir un cadenas vert dans la barre d'adresse.

---

### 8.3 Configuration du renouvellement automatique

**À quoi ça sert ?**
Les certificats Let's Encrypt expirent après 90 jours. Le renouvellement automatique évite l'expiration.

**Obligatoire ?** ✅ OUI - Obligatoire pour maintenir HTTPS

**Niveau de sécurité :** ⚠️ IMPORTANT - Sans renouvellement, le certificat expire

**Risques :** Aucun

**Test du renouvellement :**

```bash
sudo certbot renew --dry-run
```

**Explication :**
- `renew` : Renouvelle les certificats expirés ou proches de l'expiration
- `--dry-run` : Test sans réellement renouveler

**Vérification :**

Vous devriez voir "The dry run was successful".

**Le renouvellement automatique est déjà configuré** par Certbot via un cron job. Vérifiez :

```bash
sudo systemctl status certbot.timer
```

Vous devriez voir `active (waiting)`.

**Vérification du cron :**

```bash
sudo cat /etc/cron.d/certbot
```

Vous devriez voir une tâche cron qui renouvelle les certificats automatiquement.

---

### 8.4 Redirection HTTP vers HTTPS

**À quoi ça sert ?**
Forcer toutes les connexions HTTP à utiliser HTTPS sécurise toutes les communications.

**Obligatoire ?** ✅ OUI - Recommandé fortement

**Niveau de sécurité :** ⚠️ IMPORTANT - Force l'utilisation de HTTPS

**Risques :** Aucun

**Certbot a normalement déjà configuré la redirection** lors de l'installation du certificat. Vérifiez :

```bash
sudo cat /etc/nginx/sites-available/mediabib
```

Vous devriez voir deux blocs `server` :
- Un pour HTTP (port 80) qui redirige vers HTTPS
- Un pour HTTPS (port 443) avec le certificat SSL

**Si la redirection n'est pas configurée**, modifiez le fichier :

```bash
sudo nano /etc/nginx/sites-available/mediabib
```

**Le bloc HTTP devrait ressembler à :**

```nginx
server {
    listen 80;
    server_name votre-domaine.com www.votre-domaine.com;
    return 301 https://$server_name$request_uri;
}
```

**Test et redémarrage :**

```bash
sudo nginx -t
sudo systemctl restart nginx
```

**Test dans le navigateur :**

Allez à `http://votre-domaine.com`

Vous devriez être automatiquement redirigé vers `https://votre-domaine.com`.

---

## 9. Configuration Finale et Optimisations

### 9.1 Configuration des logs

**À quoi ça sert ?**
Des logs bien configurés permettent de diagnostiquer les problèmes et de surveiller l'activité.

**Obligatoire ?** ⚠️ Recommandé - Utile pour le débogage

**Niveau de sécurité :** ✅ Normal

**Risques :** Aucun

**Vérification des logs Gunicorn :**

```bash
sudo tail -f /var/log/mediabib/error.log
```

**Vérification des logs Nginx :**

```bash
sudo tail -f /var/log/nginx/mediabib_error.log
```

**Rotation des logs (déjà configurée par défaut) :**

Les logs sont automatiquement archivés par logrotate. Vérifiez :

```bash
sudo cat /etc/logrotate.d/nginx
```

---

### 9.2 Configuration des sauvegardes automatiques

**À quoi ça sert ?**
Les sauvegardes permettent de restaurer votre application en cas de problème.

**Obligatoire ?** ✅ OUI - Obligatoire pour la production

**Niveau de sécurité :** 🔴 CRITIQUE - Sans sauvegardes, une perte de données est irréversible

**Risques :** Aucun

**Création du script de sauvegarde :**

```bash
sudo nano /usr/local/bin/backup-mediabib.sh
```

**Contenu du script :**

```bash
#!/bin/bash

# Configuration
BACKUP_DIR="/var/backups/mediabib"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="mediabib"
DB_USER="mediabib_user"
APP_DIR="/var/www/mediabib"

# Création du répertoire de sauvegarde
mkdir -p $BACKUP_DIR

# Sauvegarde de la base de données
sudo -u postgres pg_dump -U $DB_USER $DB_NAME | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Sauvegarde des fichiers média
tar -czf $BACKUP_DIR/media_$DATE.tar.gz -C $APP_DIR media/

# Sauvegarde du fichier .env
cp $APP_DIR/.env $BACKUP_DIR/env_$DATE

# Suppression des sauvegardes de plus de 30 jours
find $BACKUP_DIR -type f -mtime +30 -delete

echo "Sauvegarde terminée : $DATE"
```

**Explication :**
- Sauvegarde la base de données PostgreSQL
- Sauvegarde les fichiers média
- Sauvegarde le fichier .env
- Supprime les sauvegardes de plus de 30 jours

**Rendre le script exécutable :**

```bash
sudo chmod +x /usr/local/bin/backup-mediabib.sh
```

**Création du répertoire de sauvegarde :**

```bash
sudo mkdir -p /var/backups/mediabib
sudo chown mediabib:mediabib /var/backups/mediabib
```

**Test du script :**

```bash
sudo -u mediabib /usr/local/bin/backup-mediabib.sh
```

**Configuration du cron pour les sauvegardes quotidiennes :**

```bash
sudo crontab -e -u mediabib
```

**Ajoutez cette ligne :**

```
0 2 * * * /usr/local/bin/backup-mediabib.sh >> /var/log/mediabib/backup.log 2>&1
```

**Explication :**
- `0 2 * * *` : Tous les jours à 2h du matin
- `>> /var/log/...` : Redirige la sortie vers un fichier de log

**Vérification :**

```bash
sudo -u mediabib crontab -l
```

Vous devriez voir la tâche cron.

---

### 9.3 Optimisations de sécurité Django

**À quoi ça sert ?**
Vérifier que toutes les options de sécurité Django sont activées.

**Obligatoire ?** ✅ OUI - Obligatoire pour la production

**Niveau de sécurité :** 🔴 CRITIQUE - Protège l'application

**Risques :** Aucun

**Vérification du fichier .env :**

```bash
cat .env | grep -E "DEBUG|SECRET_KEY|ALLOWED_HOSTS"
```

**Vérifications :**
- `DEBUG=False` ✅
- `SECRET_KEY` est défini et unique ✅
- `ALLOWED_HOSTS` contient votre domaine ✅

**Vérification de la configuration Django :**

```bash
python manage.py check --deploy
```

**Explication :**
- `--deploy` : Vérifie les paramètres de sécurité pour la production

Vous devriez voir "System check identified no issues".

**Si vous voyez des avertissements**, corrigez-les selon les recommandations.

---

### 9.4 Vérification finale de la sécurité

**À quoi ça sert ?**
Vérifier que toutes les mesures de sécurité sont en place.

**Obligatoire ?** ✅ OUI - Obligatoire avant la mise en production

**Niveau de sécurité :** 🔴 CRITIQUE

**Risques :** Aucun

**Checklist de vérification :**

**1. Firewall actif :**

```bash
sudo ufw status
```

✅ Doit être `active`

**2. Fail2Ban actif :**

```bash
sudo fail2ban-client status
```

✅ Doit montrer des jails actifs

**3. SSH sécurisé :**

```bash
sudo sshd -T | grep -E "PermitRootLogin|PasswordAuthentication|Port"
```

✅ `PermitRootLogin no`
✅ `Port` devrait être différent de 22 (si vous l'avez changé)

**4. HTTPS fonctionnel :**

Allez sur `https://votre-domaine.com` dans votre navigateur.

✅ Doit afficher un cadenas vert

**5. Application accessible :**

✅ L'application MediaBib doit être accessible et fonctionnelle

**6. Logs fonctionnels :**

```bash
sudo tail -n 20 /var/log/mediabib/error.log
```

✅ Les logs doivent être écrits

---

## 10. Maintenance et Monitoring

### 10.1 Commandes de maintenance courantes

**Redémarrer l'application :**

```bash
sudo systemctl restart mediabib
```

**Redémarrer Nginx :**

```bash
sudo systemctl restart nginx
```

**Voir les logs en temps réel :**

```bash
sudo journalctl -u mediabib -f
```

**Vérifier l'état des services :**

```bash
sudo systemctl status mediabib
sudo systemctl status nginx
sudo systemctl status postgresql
```

**Mettre à jour l'application :**

```bash
cd /var/www/mediabib
source venv/bin/activate
git pull
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --no-input
sudo systemctl restart mediabib
```

---

### 10.2 Surveillance des logs

**Logs Gunicorn :**

```bash
sudo tail -f /var/log/mediabib/error.log
sudo tail -f /var/log/mediabib/access.log
```

**Logs Nginx :**

```bash
sudo tail -f /var/log/nginx/mediabib_error.log
sudo tail -f /var/log/nginx/mediabib_access.log
```

**Logs système :**

```bash
sudo journalctl -xe
```

---

### 10.3 Mise à jour du système

**Mise à jour régulière (hebdomadaire recommandé) :**

```bash
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

**Redémarrage si nécessaire :**

```bash
sudo reboot
```

**⚠️ ATTENTION :** Redémarrez pendant une période de faible activité. Les services redémarreront automatiquement.

---

### 10.4 Procédure de sauvegarde/restauration

**Sauvegarde manuelle :**

```bash
sudo -u mediabib /usr/local/bin/backup-mediabib.sh
```

**Liste des sauvegardes :**

```bash
ls -lh /var/backups/mediabib/
```

**Restauration de la base de données :**

```bash
gunzip < /var/backups/mediabib/db_YYYYMMDD_HHMMSS.sql.gz | sudo -u postgres psql mediabib
```

**Restauration des fichiers média :**

```bash
cd /var/www/mediabib
tar -xzf /var/backups/mediabib/media_YYYYMMDD_HHMMSS.tar.gz
```

---

## 11. Checklist de Vérification

Utilisez cette checklist pour vérifier que tout est correctement configuré :

### Sécurité

- [ ] Firewall UFW actif et configuré
- [ ] Fail2Ban installé et actif
- [ ] SSH configuré (root désactivé, port changé si souhaité)
- [ ] Utilisateur non-root créé et utilisé
- [ ] HTTPS/SSL configuré et fonctionnel
- [ ] Redirection HTTP vers HTTPS active
- [ ] Certificat SSL valide et auto-renouvelable

### Application

- [ ] MediaBib accessible via HTTPS
- [ ] Formulaire d'installation accessible
- [ ] Base de données PostgreSQL fonctionnelle
- [ ] Migrations appliquées
- [ ] Fichiers statiques collectés et servis
- [ ] Gunicorn fonctionne et redémarre automatiquement
- [ ] Nginx fonctionne et sert l'application

### Configuration

- [ ] Fichier .env configuré (DEBUG=False, SECRET_KEY unique, ALLOWED_HOSTS)
- [ ] DATABASE_URL correctement configuré
- [ ] Logs configurés et accessibles
- [ ] Sauvegardes automatiques configurées
- [ ] Services systemd configurés et actifs

### Maintenance

- [ ] Script de sauvegarde testé
- [ ] Cron job de sauvegarde configuré
- [ ] Procédure de mise à jour documentée
- [ ] Accès aux logs vérifié

---

## 12. Annexes

### 12.1 Résolution des problèmes courants

**Erreur 502 Bad Gateway :**

```bash
# Vérifier que Gunicorn fonctionne
sudo systemctl status mediabib

# Vérifier les logs
sudo journalctl -u mediabib -n 50

# Redémarrer Gunicorn
sudo systemctl restart mediabib
```

**Erreur "Permission denied" :**

```bash
# Vérifier les permissions
ls -la /var/www/mediabib

# Corriger les permissions
sudo chown -R mediabib:mediabib /var/www/mediabib
```

**Erreur de connexion à la base de données :**

```bash
# Vérifier que PostgreSQL fonctionne
sudo systemctl status postgresql

# Tester la connexion
sudo -u postgres psql -U mediabib_user -d mediabib

# Vérifier le fichier .env
cat /var/www/mediabib/.env | grep DATABASE_URL
```

**Le site ne se charge pas :**

```bash
# Vérifier Nginx
sudo systemctl status nginx
sudo nginx -t

# Vérifier le firewall
sudo ufw status

# Vérifier les logs Nginx
sudo tail -f /var/log/nginx/mediabib_error.log
```

### 12.2 Commandes de référence rapide

```bash
# Services
sudo systemctl status mediabib
sudo systemctl restart mediabib
sudo systemctl status nginx
sudo systemctl restart nginx

# Logs
sudo journalctl -u mediabib -f
sudo tail -f /var/log/mediabib/error.log
sudo tail -f /var/log/nginx/mediabib_error.log

# Base de données
sudo -u postgres psql -U mediabib_user -d mediabib

# Sauvegardes
sudo -u mediabib /usr/local/bin/backup-mediabib.sh
ls -lh /var/backups/mediabib/

# Mises à jour
cd /var/www/mediabib
source venv/bin/activate
git pull
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --no-input
sudo systemctl restart mediabib
```

### 12.3 Fichiers de configuration importants

| Fichier | Emplacement | Description |
|---------|-------------|-------------|
| Configuration Django | `/var/www/mediabib/.env` | Variables d'environnement |
| Service Gunicorn | `/etc/systemd/system/mediabib.service` | Service systemd |
| Configuration Nginx | `/etc/nginx/sites-available/mediabib` | Configuration Nginx |
| Configuration SSH | `/etc/ssh/sshd_config` | Configuration SSH |
| Configuration Fail2Ban | `/etc/fail2ban/jail.local` | Configuration Fail2Ban |
| Script de sauvegarde | `/usr/local/bin/backup-mediabib.sh` | Script de sauvegarde |

### 12.4 Ressources et documentation

- **Documentation Django** : https://docs.djangoproject.com/
- **Documentation Nginx** : https://nginx.org/en/docs/
- **Documentation Gunicorn** : https://docs.gunicorn.org/
- **Documentation PostgreSQL** : https://www.postgresql.org/docs/
- **Documentation Let's Encrypt** : https://letsencrypt.org/docs/
- **Documentation OVH** : https://docs.ovh.com/

### 12.5 Support et assistance

Si vous rencontrez des problèmes :

1. Vérifiez les logs (section 10.2)
2. Consultez la section "Résolution des problèmes" (12.1)
3. Vérifiez la checklist (section 11)
4. Consultez la documentation officielle (section 12.4)

---

## Conclusion

Félicitations ! Vous avez maintenant installé et configuré MediaBib sur votre VPS OVH Ubuntu de manière sécurisée.

**Points importants à retenir :**

1. **Sécurité d'abord** : Firewall, Fail2Ban, HTTPS, utilisateur non-root
2. **Sauvegardes régulières** : Configurez et testez vos sauvegardes
3. **Mises à jour** : Maintenez le système à jour régulièrement
4. **Surveillance** : Surveillez les logs pour détecter les problèmes

**Prochaines étapes :**

1. Accédez à votre application via HTTPS
2. Complétez le formulaire d'installation initiale
3. Configurez votre première médiathèque
4. Testez toutes les fonctionnalités

Bonne utilisation de MediaBib !
