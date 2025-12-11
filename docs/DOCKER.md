# Guide Docker - MediaBib

Ce guide explique comment installer et utiliser MediaBib avec Docker et Docker Compose.

## Prérequis

- [Docker](https://www.docker.com/get-started) (version 20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0+)

### Vérifier l'installation

```bash
docker --version
docker-compose --version
```

---

## Installation rapide

### 1. Cloner le projet

```bash
git clone https://github.com/votre-repo/mediabib.git
cd mediabib
```

### 2. Configurer les variables d'environnement

```bash
# Windows
copy docker.env.example docker.env

# Linux/macOS
cp docker.env.example docker.env
```

### 3. Modifier `docker.env`

Ouvrez `docker.env` et modifiez au minimum :

```ini
SECRET_KEY=votre-cle-secrete-unique
POSTGRES_PASSWORD=votre-mot-de-passe-securise
DJANGO_SUPERUSER_PASSWORD=votre-mot-de-passe-admin
```

**Générer une SECRET_KEY :**
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 4. Lancer les conteneurs

```bash
docker-compose up -d
```

Cette commande va :
- Construire l'image Docker de l'application
- Démarrer PostgreSQL
- Démarrer l'application Django
- Appliquer les migrations
- Collecter les fichiers statiques

### 5. Accéder à l'application

- **Application** : http://localhost:8000
- **Admin Django** : http://localhost:8000/admin
  - Utilisateur : `admin` (ou celui défini dans `docker.env`)
  - Mot de passe : celui défini dans `DJANGO_SUPERUSER_PASSWORD`

---

## Commandes utiles

### Démarrer les services

```bash
docker-compose up -d
```

### Arrêter les services

```bash
docker-compose down
```

### Voir les logs

```bash
# Tous les services
docker-compose logs -f

# Uniquement l'application web
docker-compose logs -f web

# Uniquement la base de données
docker-compose logs -f db
```

### Redémarrer un service

```bash
docker-compose restart web
```

### Reconstruire l'image

```bash
docker-compose build --no-cache
docker-compose up -d
```

### Accéder au shell Django

```bash
docker-compose exec web python manage.py shell
```

### Créer un superutilisateur

```bash
docker-compose exec web python manage.py createsuperuser
```

### Appliquer les migrations

```bash
docker-compose exec web python manage.py migrate
```

### Collecter les fichiers statiques

```bash
docker-compose exec web python manage.py collectstatic --no-input
```

### Accéder à la base de données PostgreSQL

```bash
docker-compose exec db psql -U mediabib_user -d mediabib
```

---

## Structure des fichiers Docker

| Fichier | Description |
|---------|-------------|
| `Dockerfile` | Image Docker de l'application |
| `docker-compose.yml` | Orchestration des services |
| `docker.env` | Variables d'environnement (à créer) |
| `docker.env.example` | Template des variables |
| `docker-entrypoint.sh` | Script d'initialisation |
| `.dockerignore` | Fichiers exclus du build |

---

## Services Docker

### web (Application Django)

- **Port** : 8000
- **Image** : Construite depuis `Dockerfile`
- **Commande** : Gunicorn avec 3 workers
- **Volumes** :
  - Code source (montage pour développement)
  - `staticfiles` : Fichiers statiques
  - `media` : Fichiers uploadés

### db (PostgreSQL)

- **Port** : 5432
- **Image** : `postgres:15-alpine`
- **Base de données** : `mediabib`
- **Utilisateur** : `mediabib_user`
- **Volume** : `postgres_data` (persistance)

---

## Développement avec Docker

### Mode développement (avec hot-reload)

Pour le développement, montez le code en volume :

```yaml
# Dans docker-compose.yml, le volume est déjà configuré :
volumes:
  - .:/app
```

Modifiez le code localement, les changements sont visibles immédiatement.

### Lancer les tests

```bash
docker-compose exec web pytest
```

### Formater le code

```bash
docker-compose exec web black .
docker-compose exec web isort .
```

### Linting

```bash
docker-compose exec web flake8 .
```

---

## Production

### Configuration recommandée

1. **Modifier `docker.env`** :
   ```ini
   DEBUG=False
   SECRET_KEY=cle-secrete-tres-longue-et-securisee
   ALLOWED_HOSTS=votre-domaine.com,www.votre-domaine.com
   ```

2. **Utiliser un reverse proxy** (Nginx) :
   - Décommenter le service `nginx` dans `docker-compose.yml`
   - Configurer SSL/TLS avec Let's Encrypt

3. **Sauvegardes** :
   ```bash
   # Sauvegarder la base de données
   docker-compose exec db pg_dump -U mediabib_user mediabib > backup.sql
   ```

### Optimisations production

- Augmenter le nombre de workers Gunicorn
- Utiliser un cache Redis
- Configurer les volumes nommés pour les données
- Activer les logs structurés

---

## Dépannage

### Les conteneurs ne démarrent pas

```bash
# Vérifier les logs
docker-compose logs

# Vérifier l'état des conteneurs
docker-compose ps
```

### Erreur de connexion à PostgreSQL

```bash
# Vérifier que le service db est prêt
docker-compose exec db pg_isready -U mediabib_user

# Vérifier les variables d'environnement
docker-compose exec web env | grep DATABASE
```

### Erreur de permissions

```bash
# Réinitialiser les permissions
docker-compose down
docker-compose up -d
```

### Nettoyer complètement

```bash
# Arrêter et supprimer les conteneurs, volumes et images
docker-compose down -v --rmi all
```

---

## Volumes et données

### Volumes créés

| Volume | Description |
|--------|-------------|
| `postgres_data` | Données PostgreSQL (persistantes) |
| `static_volume` | Fichiers statiques collectés |
| `media_volume` | Fichiers uploadés par les utilisateurs |

### Sauvegarder les données

```bash
# Sauvegarder PostgreSQL
docker-compose exec db pg_dump -U mediabib_user mediabib > backup_$(date +%Y%m%d).sql

# Sauvegarder les volumes
docker run --rm -v mediabib_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz /data
```

### Restaurer les données

```bash
# Restaurer PostgreSQL
docker-compose exec -T db psql -U mediabib_user mediabib < backup_20241206.sql
```

---

## Sécurité

### Checklist production

- [ ] `SECRET_KEY` unique et sécurisée
- [ ] `DEBUG=False`
- [ ] `ALLOWED_HOSTS` configuré avec votre domaine
- [ ] `POSTGRES_PASSWORD` fort
- [ ] `DJANGO_SUPERUSER_PASSWORD` fort
- [ ] HTTPS activé (via Nginx)
- [ ] Fichier `docker.env` non versionné (déjà dans `.gitignore`)

### Variables sensibles

Ne jamais commiter `docker.env` ! Il est déjà dans `.gitignore`.

---

## Support

Pour toute question :
- Consultez la [documentation principale](../README.md)
- Consultez le [guide d'installation](INSTALLATION.md)
- Ouvrez une [Issue GitHub](https://github.com/votre-repo/mediabib/issues)

---

*Dernière mise à jour : Décembre 2024*

