# Architecture Technique

Ce document décrit l'architecture technique de MediaBib.

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                         NAVIGATEUR                               │
│                    (HTML/CSS/JavaScript)                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         NGINX                                    │
│                   (Reverse Proxy + SSL)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        GUNICORN                                  │
│                    (Serveur WSGI)                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DJANGO 5.2                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │   home   │  │ catalog  │  │circulation│  │  readers │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │   opac   │  │ reports  │  │  sites   │  │ accounts │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────┐
│   PostgreSQL     │ │    Redis     │ │   Celery     │
│   (Base de       │ │   (Cache +   │ │   (Tâches    │
│    données)      │ │   Sessions)  │ │   async)     │
└──────────────────┘ └──────────────┘ └──────────────┘
```

---

## Stack technique

### Backend

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Framework | Django | 5.2+ |
| Langage | Python | 3.10+ |
| Base de données | PostgreSQL | 14+ |
| Cache | Redis | 7+ |
| Tâches async | Celery | 5.3+ |
| Serveur WSGI | Gunicorn | 21+ |

### Frontend

| Composant | Technologie |
|-----------|-------------|
| HTML | HTML5 sémantique |
| CSS | Tailwind CSS / Bootstrap 5 |
| JavaScript | Vanilla JS (ES6+) |
| Accessibilité | WCAG 2.1 AA |

### Infrastructure

| Composant | Technologie |
|-----------|-------------|
| Reverse Proxy | Nginx |
| SSL | Let's Encrypt |
| CI/CD | GitHub Actions |
| Monitoring | Sentry |

---

## Structure du projet

```
MediaBib/
├── app/                      # Configuration Django principale
│   ├── __init__.py
│   ├── settings.py           # Paramètres (via .env)
│   ├── urls.py               # Routes principales
│   ├── wsgi.py               # Point d'entrée WSGI
│   └── asgi.py               # Point d'entrée ASGI
│
├── home/                     # Application page d'accueil
│   ├── templates/home/
│   ├── tests.py
│   ├── urls.py
│   └── views.py
│
├── catalog/                  # Module Catalogue (à créer)
│   ├── models.py             # Notices, Autorités, Exemplaires
│   ├── views.py
│   ├── forms.py
│   ├── services.py           # Logique métier
│   └── tests/
│
├── circulation/              # Module Circulation (à créer)
│   ├── models.py             # Prêts, Retours, Réservations
│   └── ...
│
├── readers/                  # Module Lecteurs (à créer)
│   ├── models.py             # Lecteurs, Abonnements
│   └── ...
│
├── opac/                     # Module OPAC (à créer)
│   └── ...
│
├── templates/                # Templates globaux
│   └── base.html
│
├── static/                   # Fichiers statiques
│   ├── css/
│   ├── js/
│   └── images/
│
├── docs/                     # Documentation
│
├── tests/                    # Tests globaux
│
├── manage.py
├── requirements.txt
├── .env.example
├── pytest.ini
├── pyproject.toml
└── dev.ps1                   # Script de développement Windows
```

---

## Applications Django

### home
Page d'accueil et pages statiques.

### catalog (à développer)
- **Modèles** : `BibliographicRecord`, `Authority`, `Item`
- **Fonctionnalités** : Catalogage UNIMARC, recherche, import/export

### circulation (à développer)
- **Modèles** : `Loan`, `Reservation`, `Fine`
- **Fonctionnalités** : Prêts, retours, réservations, amendes

### readers (à développer)
- **Modèles** : `Reader`, `Subscription`, `Category`
- **Fonctionnalités** : Gestion des abonnés, quotas

### opac (à développer)
- Catalogue public en ligne
- Compte lecteur

### reports (à développer)
- Statistiques et tableaux de bord

### sites (à développer)
- Gestion multi-sites

---

## Flux de données

### Prêt d'un document

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Lecteur  │───▶│ Scanner  │───▶│   Vue    │───▶│ Service  │
│          │    │ (RFID)   │    │ prêt     │    │ prêt     │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                                                      │
                                                      ▼
                                               ┌──────────┐
                                               │  Modèle  │
                                               │   Loan   │
                                               └──────────┘
                                                      │
                                                      ▼
                                               ┌──────────┐
                                               │   Base   │
                                               │ données  │
                                               └──────────┘
```

### Recherche dans le catalogue

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│Utilisateur│───▶│ Formulaire│───▶│  Vue     │───▶│ QuerySet │
│          │    │ recherche │    │ search   │    │ optimisé │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                                                      │
                                                      ▼
                                               ┌──────────┐
                                               │ Résultats│
                                               │ paginés  │
                                               └──────────┘
```

---

## Sécurité

### Couches de sécurité

1. **HTTPS** : Chiffrement SSL/TLS
2. **CSRF** : Protection contre les attaques CSRF
3. **XSS** : Échappement automatique Django
4. **SQL Injection** : ORM Django paramétré
5. **Authentication** : Django auth + sessions sécurisées
6. **Authorization** : Permissions par groupe/utilisateur

### Headers de sécurité

```python
# settings.py (production)
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "DENY"
```

---

## Performance

### Optimisations

1. **Requêtes SQL**
   - `select_related()` pour les ForeignKey
   - `prefetch_related()` pour les ManyToMany
   - Index sur les champs recherchés

2. **Cache**
   - Redis pour le cache applicatif
   - Cache des templates en production
   - Cache des sessions

3. **Assets**
   - Minification CSS/JS
   - Compression Gzip/Brotli
   - CDN pour les fichiers statiques

---

## Normes et standards

| Norme | Description | Usage |
|-------|-------------|-------|
| UNIMARC | Format de notices bibliographiques | Catalogage |
| ISO 2709 | Échange de notices | Import/Export |
| Z39.50 | Protocole de recherche fédérée | Recherche externe |
| SRU/SRW | API de recherche | Web services |
| SIP2 | Communication automates | RFID |
| WCAG 2.1 | Accessibilité web | Interface |
| RGPD | Protection des données | Conformité |

