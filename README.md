# MediaBib

**Système Intégré de Gestion de Bibliothèque (SIGB) open source**

MediaBib est un SIGB moderne développé en Django, conçu pour les réseaux de lecture publique. Compatible avec le format UNIMARC, il permet l'import de données depuis PMB et d'autres systèmes.

---

## Caractéristiques principales

- **Multi-sites** : Gestion de 1 à N médiathèques avec transferts inter-sites
- **Tous types de documents** : Livres, CD, DVD, revues, jeux, partitions, ressources numériques
- **Public visé** : Bibliothèques publiques (tout public)
- **Capacité** : Plus de 70 000 notices bibliographiques
- **OPAC** : Portail public avec compte lecteur, réservations en ligne
- **RFID** : Support des automates de prêt/retour
- **Normes** : UNIMARC, Z39.50, SRU/SRW, SIP2, NCIP

---

## Modules

| Module | Description |
|--------|-------------|
| **Catalogue** | Notices bibliographiques UNIMARC, autorités, exemplaires |
| **Circulation** | Prêts, retours, réservations, amendes |
| **Lecteurs** | Gestion des abonnés, catégories, quotas |
| **Acquisitions** | Commandes, budgets, fournisseurs |
| **Périodiques** | Abonnements, bulletinage |
| **OPAC** | Catalogue public en ligne |
| **Statistiques** | Tableaux de bord, rapports |
| **Multi-sites** | Réseau de bibliothèques, transferts |

---

## Prérequis

- **Python** 3.10 ou supérieur
- **Django** 5.2+
- **Base de données** : SQLite (développement) / PostgreSQL (production)

---

## Installation

### 1. Cloner le projet

```bash
git clone git@github.com:gestionsiteccsa/MediaBib.git
cd MediaBib
```

**Note** : Le clonage crée automatiquement le dossier `MediaBib`. Le `Dockerfile` est déjà présent dans le projet cloné.

### 2. Créer un environnement virtuel

```bash
# Windows
python -m venv env
env\Scripts\activate

# Linux / macOS
python3 -m venv env
source env/bin/activate
```

### 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 4. Configurer l'environnement

Copier le fichier de configuration exemple à la racine du projet :

```bash
# Windows
copy env.example .env

# Linux / macOS
cp env.example .env
```

**Important** : Le fichier `.env` doit être créé à la racine du projet (dans le dossier `MediaBib`).

Modifier le fichier `.env` avec vos paramètres :

```bash
# Générer une nouvelle SECRET_KEY
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 5. Appliquer les migrations

```bash
python manage.py migrate
```

### 6. Lancer le serveur de développement

```bash
python manage.py runserver
```

### 7. Configuration initiale (Formulaire web)

Accédez à l'application : http://localhost:8000

**Le système détecte automatiquement** que c'est la première installation et vous redirige vers le formulaire de configuration initiale.

#### Créer le compte coordonnateur

Le formulaire web d'installation vous permet de créer le **coordonnateur** (superutilisateur initial) avec :

- **Email** : Adresse email (utilisée pour la connexion)
- **Nom et Prénom** : Informations du coordonnateur
- **Nom du réseau** : Optionnel, pour réseaux de bibliothèques
- **Mot de passe** : Mot de passe sécurisé avec confirmation

Après la création du compte, vous êtes automatiquement connecté et pouvez :
- Ajouter vos médiathèques
- Configurer les paramètres système
- Créer d'autres utilisateurs

**Note** : Le formulaire d'installation n'est accessible que lors de la première installation. Après cela, utilisez la page de connexion normale.

---

## Configuration

### Variables d'environnement

| Variable | Description | Défaut |
|----------|-------------|--------|
| `SECRET_KEY` | Clé secrète Django | *requis en production* |
| `DEBUG` | Mode debug | `False` |
| `ALLOWED_HOSTS` | Hôtes autorisés (séparés par des virgules) | `localhost,127.0.0.1` |
| `DATABASE_URL` | URL de connexion à la base de données | SQLite local |

### Base de données PostgreSQL (production)

```bash
DATABASE_URL=postgres://user:password@localhost:5432/mediabib
```

---

## Structure du projet

```
MediaBib/
├── app/                    # Configuration Django principale
│   ├── settings.py         # Paramètres (sécurisés via .env)
│   ├── urls.py
│   └── wsgi.py
├── home/                   # Application principale
├── templates/              # Templates globaux
├── static/                 # Fichiers statiques
├── manage.py
├── requirements.txt
├── env.example             # Template de configuration
├── .gitignore
└── README.md
```

---

## Développement

### Lancer les tests

```bash
python manage.py test
```

### Collecter les fichiers statiques (production)

```bash
python manage.py collectstatic
```

---

## Déploiement en production

1. Configurer `DEBUG=False` dans `.env`
2. Générer une nouvelle `SECRET_KEY`
3. Configurer `ALLOWED_HOSTS` avec votre domaine
4. Utiliser PostgreSQL (`DATABASE_URL`)
5. Configurer un serveur WSGI (Gunicorn) avec Nginx
6. Activer HTTPS

### Exemple avec Gunicorn

```bash
gunicorn app.wsgi:application --bind 0.0.0.0:8000
```

---

## Normes et conformité

| Norme | Description |
|-------|-------------|
| **UNIMARC** | Format de notices bibliographiques |
| **ISO 2709** | Échange de notices |
| **Z39.50** | Protocole de recherche fédérée |
| **SRU/SRW** | API de recherche |
| **SIP2** | Communication avec automates de prêt |
| **NCIP** | Interopérabilité ILS |
| **RGPD** | Protection des données personnelles |
| **WCAG 2.1** | Accessibilité web |

---

## Licence

Ce projet est distribué sous licence open source.

---

## Contribuer

Les contributions sont les bienvenues ! Veuillez consulter les issues ouvertes ou créer une nouvelle issue pour discuter des changements proposés.

---

## Documentation

### Documentation complète

Pour une présentation détaillée du projet, consultez le **[Cahier des Charges](CAHIER_DES_CHARGES.md)** qui inclut :
- Vue d'ensemble fonctionnelle complète
- Workflows détaillés pour chaque type d'utilisateur (administrateur, bibliothécaire, lecteur)
- Exemples concrets d'utilisation
- Architecture technique simplifiée
- Planning et phases de développement

### Autres documents

- **[APPLICATIONS.md](APPLICATIONS.md)** : Détails complets des 14 applications Django
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** : Architecture technique détaillée
- **[docs/API.md](docs/API.md)** : Documentation de l'API REST
- **[docs/USER_GUIDE.md](docs/USER_GUIDE.md)** : Guide d'utilisation pour les bibliothécaires
- **[docs/ADMIN_GUIDE.md](docs/ADMIN_GUIDE.md)** : Guide d'administration système

## Contact

Pour toute question, veuillez ouvrir une issue sur GitHub.

