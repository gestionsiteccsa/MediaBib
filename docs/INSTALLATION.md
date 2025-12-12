# Guide d'Installation

Ce guide explique comment installer et configurer MediaBib sur votre système.

## Prérequis

### Logiciels requis

| Logiciel | Version minimum | Vérification |
|----------|-----------------|--------------|
| Python | 3.10+ | `python --version` |
| pip | 21.0+ | `pip --version` |
| Git | 2.30+ | `git --version` |
| PostgreSQL | 14+ (production) | `psql --version` |

### Systèmes d'exploitation supportés

- Windows 10/11
- macOS 12+
- Ubuntu 20.04+
- Debian 11+

---

## Installation rapide

### 1. Cloner le projet

```bash
git clone git@github.com:gestionsiteccsa/MediaBib.git
cd MediaBib
```

**Note** : Le clonage crée automatiquement le dossier `MediaBib`.

### 2. Créer l'environnement virtuel

**Windows (PowerShell)**
```powershell
python -m venv env
.\env\Scripts\activate
```

**Linux / macOS**
```bash
python3 -m venv env
source env/bin/activate
```

### 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 4. Configurer l'environnement

**Important** : Le fichier `.env` doit être créé à la racine du projet (dans le dossier `MediaBib`).

```bash
# Windows
copy env.example .env

# Linux/macOS
cp env.example .env
```

Modifier le fichier `.env` :

```ini
# Générer une nouvelle clé secrète
SECRET_KEY=votre-cle-secrete-unique

# Mode debug (False en production)
DEBUG=True

# Hôtes autorisés
ALLOWED_HOSTS=localhost,127.0.0.1
```

**Générer une clé secrète :**
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 5. Appliquer les migrations

```bash
python manage.py migrate
```

### 6. Configuration initiale (Formulaire web)

Après avoir appliqué les migrations, lancez le serveur :

```bash
python manage.py runserver
```

Accédez à l'application : http://localhost:8000

**Le système détecte automatiquement** que c'est la première installation et vous redirige vers le formulaire de configuration initiale.

#### Formulaire d'installation

Le formulaire web d'installation vous permet de créer le **coordonnateur** (superutilisateur initial) avec toutes les informations nécessaires :

**Champs du formulaire** :
- **Email** (obligatoire) : Adresse email du coordonnateur
  - Format email valide requis
  - Utilisé pour la connexion et les notifications
- **Nom** (obligatoire) : Nom de famille du coordonnateur
- **Prénom** (obligatoire) : Prénom du coordonnateur
- **Nom du réseau** (optionnel) : Nom du réseau de bibliothèques
  - Exemple : "Réseau des Médiathèques de la Ville"
  - Utile pour les réseaux multi-sites
- **Mot de passe** (obligatoire) : Mot de passe sécurisé
  - Minimum 8 caractères
  - Doit contenir des lettres et des chiffres
  - Confirmation du mot de passe requise
- **Conditions d'utilisation** : Acceptation des conditions (case à cocher)

**Processus** :
1. Remplissez tous les champs obligatoires
2. Vérifiez que le mot de passe respecte les critères de sécurité
3. Acceptez les conditions d'utilisation
4. Cliquez sur "Créer le compte coordonnateur"

**Après la création** :
- Le compte coordonnateur est créé avec tous les droits administrateur
- Vous êtes automatiquement connecté
- Redirection vers le tableau de bord administrateur
- Message de bienvenue avec guide de démarrage
- Possibilité immédiate d'ajouter des médiathèques

**Note** : Si vous accédez à l'application après l'installation complète, vous serez redirigé vers la page de connexion normale. Le formulaire d'installation n'est accessible que lors de la première installation.

### 7. Configuration post-installation

Une fois le coordonnateur créé, vous pouvez :

1. **Ajouter des médiathèques** :
   - Menu : Sites > Bibliothèques > Ajouter
   - Renseigner les informations de chaque médiathèque (nom, adresse, horaires, etc.)

2. **Configurer les paramètres système** :
   - Menu : Administration > Paramètres
   - Configurer les règles de prêt, quotas, amendes, etc.

3. **Créer d'autres utilisateurs** :
   - Menu : Administration > Utilisateurs > Ajouter
   - Attribuer des rôles et permissions

### 8. Lancer le serveur (si pas déjà fait)

```bash
python manage.py runserver
```

Accédez à l'application : http://localhost:8000

---

## Installation pour le développement

### Script PowerShell (Windows)

```powershell
# Installation complète
.\dev.ps1 setup

# Ou étape par étape
.\dev.ps1 install-dev
.\dev.ps1 migrate
.\dev.ps1 run
```

### Makefile (Linux/macOS)

```bash
# Installation complète
make setup

# Ou étape par étape
make install-dev
make migrate
make run
```

### Installer les hooks pre-commit

```bash
pip install pre-commit
pre-commit install
```

---

## Configuration PostgreSQL (Production)

### 1. Installer PostgreSQL

**Ubuntu/Debian**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

**Windows**
Télécharger depuis : https://www.postgresql.org/download/windows/

### 2. Créer la base de données

```bash
sudo -u postgres psql

CREATE DATABASE mediabib;
CREATE USER mediabib_user WITH PASSWORD 'votre_mot_de_passe';
ALTER ROLE mediabib_user SET client_encoding TO 'utf8';
ALTER ROLE mediabib_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE mediabib_user SET timezone TO 'Europe/Paris';
GRANT ALL PRIVILEGES ON DATABASE mediabib TO mediabib_user;
\q
```

### 3. Configurer Django

Dans `.env` :
```ini
DATABASE_URL=postgres://mediabib_user:votre_mot_de_passe@localhost:5432/mediabib
```

### 4. Installer le driver PostgreSQL

```bash
pip install psycopg2-binary
```

---

## Vérification de l'installation

### Lancer les tests

```powershell
# Windows
.\dev.ps1 test

# Linux/macOS
make test
# ou
pytest
```

### Vérifier la configuration Django

```bash
python manage.py check
```

### Vérifier les dépendances

```bash
pip check
```

---

## Résolution des problèmes

### Erreur : "Module not found"

```bash
# Vérifier que l'environnement virtuel est activé
# Windows
.\env\Scripts\activate
# Linux/macOS
source env/bin/activate

# Réinstaller les dépendances
pip install -r requirements.txt
```

### Erreur de migration

```bash
# Supprimer la base SQLite et recommencer
rm db.sqlite3
python manage.py migrate
```

### Port 8000 déjà utilisé

```bash
# Utiliser un autre port
python manage.py runserver 8080
```

---

## Prochaines étapes

- [Guide d'administration](ADMIN_GUIDE.md)
- [Guide du développeur](DEVELOPMENT.md)
- [Manuel utilisateur](USER_GUIDE.md)

