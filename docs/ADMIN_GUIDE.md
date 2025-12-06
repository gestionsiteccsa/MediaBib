# Guide d'Administration

Guide pour les administrateurs système de MediaBib.

---

## Administration Django

### Accéder à l'interface d'administration

1. Connectez-vous avec un compte superutilisateur
2. Accédez à `/admin/`
3. Ou cliquez sur **Administration** dans le menu (si disponible)

### Créer un utilisateur

1. Allez dans **Utilisateurs** > **Ajouter**
2. Remplissez les champs :
   - Nom d'utilisateur
   - Mot de passe (minimum 8 caractères)
   - Email
3. Assignez les permissions ou groupes
4. Enregistrez

### Groupes et permissions

#### Groupes par défaut

| Groupe | Description | Permissions |
|--------|-------------|-------------|
| Administrateur | Accès complet | Toutes |
| Bibliothécaire | Gestion quotidienne | Catalogue, Circulation, Lecteurs |
| Lecteur | Compte OPAC | Consultation, Réservation |

#### Créer un groupe

1. Allez dans **Groupes** > **Ajouter**
2. Nommez le groupe
3. Sélectionnez les permissions
4. Enregistrez

---

## Configuration du système

### Variables d'environnement

Fichier `.env` à la racine du projet :

```ini
# Sécurité
SECRET_KEY=votre-cle-secrete-unique-et-longue
DEBUG=False

# Base de données
DATABASE_URL=postgres://user:password@localhost:5432/mediabib

# Hôtes autorisés
ALLOWED_HOSTS=mediabib.example.com,www.mediabib.example.com

# Email
EMAIL_HOST=smtp.example.com
EMAIL_PORT=587
EMAIL_HOST_USER=noreply@example.com
EMAIL_HOST_PASSWORD=motdepasse
EMAIL_USE_TLS=True

# Sécurité SSL
SECURE_SSL_REDIRECT=True

# Cache Redis
REDIS_URL=redis://localhost:6379/0

# Monitoring
SENTRY_DSN=https://xxx@sentry.io/xxx
```

### Paramètres importants

#### Sécurité (settings.py)

```python
# En production, ces paramètres sont automatiquement activés
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

#### Sessions

```python
# Expiration de session (30 minutes d'inactivité)
SESSION_COOKIE_AGE = 1800
SESSION_SAVE_EVERY_REQUEST = True
```

---

## Gestion de la base de données

### Sauvegardes

#### Sauvegarde manuelle PostgreSQL

```bash
pg_dump -U mediabib_user -d mediabib > backup_$(date +%Y%m%d).sql
```

#### Restauration

```bash
psql -U mediabib_user -d mediabib < backup_20241206.sql
```

#### Sauvegarde automatique (cron)

```bash
# Éditer crontab
crontab -e

# Ajouter (sauvegarde quotidienne à 2h00)
0 2 * * * pg_dump -U mediabib_user mediabib > /backups/mediabib_$(date +\%Y\%m\%d).sql
```

### Migrations

#### Appliquer les migrations

```bash
python manage.py migrate
```

#### Voir les migrations en attente

```bash
python manage.py showmigrations
```

#### Créer une migration

```bash
python manage.py makemigrations --name description_changement
```

---

## Déploiement

### Checklist pré-déploiement

```
□ DEBUG = False
□ SECRET_KEY unique et sécurisée
□ ALLOWED_HOSTS configuré
□ Base de données PostgreSQL
□ HTTPS activé
□ Sauvegardes automatiques configurées
□ Monitoring activé (Sentry)
□ Tests passent en staging
```

### Mise à jour de l'application

```bash
# 1. Sauvegarder la base
pg_dump -U user mediabib > backup_avant_maj.sql

# 2. Mettre à jour le code
git pull origin main

# 3. Installer les dépendances
pip install -r requirements.txt

# 4. Appliquer les migrations
python manage.py migrate --no-input

# 5. Collecter les fichiers statiques
python manage.py collectstatic --no-input

# 6. Redémarrer les services
sudo systemctl restart gunicorn
sudo systemctl restart nginx
```

### Rollback en cas de problème

```bash
# 1. Revenir au commit précédent
git checkout HEAD~1

# 2. Restaurer la base
psql -U user mediabib < backup_avant_maj.sql

# 3. Redémarrer
sudo systemctl restart gunicorn
```

---

## Monitoring

### Logs

#### Emplacement des logs

| Log | Emplacement |
|-----|-------------|
| Django | `/var/log/mediabib/django.log` |
| Gunicorn | `/var/log/mediabib/gunicorn.log` |
| Nginx | `/var/log/nginx/access.log` |
| Nginx errors | `/var/log/nginx/error.log` |

#### Consulter les logs en temps réel

```bash
tail -f /var/log/mediabib/django.log
```

### Sentry (Monitoring d'erreurs)

1. Créez un compte sur sentry.io
2. Créez un projet Django
3. Ajoutez le DSN dans `.env` :
   ```
   SENTRY_DSN=https://xxx@sentry.io/xxx
   ```

### Vérifications périodiques

#### Hebdomadaire

- [ ] Vérifier les logs d'erreurs
- [ ] Vérifier l'espace disque
- [ ] Vérifier les sauvegardes

#### Mensuel

- [ ] Mettre à jour les dépendances
- [ ] Vérifier les certificats SSL
- [ ] Tester la restauration des sauvegardes

---

## Performances

### Optimisations Django

```python
# Cache Redis
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://localhost:6379/0',
    }
}

# Sessions en cache
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
```

### Optimisations Nginx

```nginx
# Compression
gzip on;
gzip_types text/plain text/css application/json application/javascript;

# Cache des fichiers statiques
location /static/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Optimisations PostgreSQL

```sql
-- Analyser les tables
ANALYZE;

-- Nettoyer les tables
VACUUM ANALYZE;
```

---

## Sécurité

### Audit de sécurité

```bash
# Vérifier les vulnérabilités Python
pip-audit

# Vérifier les dépendances
safety check
```

### Blocage d'IP

En cas d'attaque, bloquer une IP avec Nginx :

```nginx
# Dans /etc/nginx/conf.d/block.conf
deny 192.168.1.100;
```

### Rotation des secrets

1. Générer une nouvelle SECRET_KEY
2. Mettre à jour `.env`
3. Redémarrer Gunicorn

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

---

## Contacts

### Support technique

- Documentation : `/docs/`
- Issues : GitHub Issues
- Email : support@example.com

### Urgences

En cas de problème critique :
1. Mettre le site en maintenance
2. Contacter l'équipe technique
3. Ne pas tenter de corrections hasardeuses

