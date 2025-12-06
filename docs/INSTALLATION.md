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
git clone https://github.com/votre-repo/mediabib.git
cd mediabib
```

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

### 6. Créer un superutilisateur

```bash
python manage.py createsuperuser
```

### 7. Lancer le serveur

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

