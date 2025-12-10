# MediaBib - Contraintes Techniques

## Table des matières

1. [Vue d'ensemble technique](#vue-densemble-technique)
2. [Architecture système](#architecture-système)
3. [Base de données](#base-de-données)
4. [Sécurité](#sécurité)
5. [Performance et optimisation](#performance-et-optimisation)
6. [Intégrations et protocoles](#intégrations-et-protocoles)
7. [Infrastructure et déploiement](#infrastructure-et-déploiement)
8. [Scalabilité](#scalabilité)
9. [Normes et standards de développement](#normes-et-standards-de-développement)
10. [Tests et qualité](#tests-et-qualité)
11. [Monitoring et observabilité](#monitoring-et-observabilité)
12. [Exigences matérielles](#exigences-matérielles)

---

## Vue d'ensemble technique

### Stack technologique

| Composant | Technologie | Version minimale |
|-----------|-------------|------------------|
| **Backend** | Django | 5.0+ |
| **API** | Django REST Framework | 3.14+ |
| **Base de données** | PostgreSQL | 15+ |
| **Cache** | Redis | 7.0+ |
| **Files d'attente** | Celery + Redis | 5.3+ |
| **Recherche** | Elasticsearch (optionnel) | 8.0+ |
| **Frontend OPAC** | Django Templates + HTMX | - |
| **CSS** | Tailwind CSS | 3.0+ |
| **Serveur WSGI** | Gunicorn | 21.0+ |
| **Serveur ASGI** | Uvicorn (WebSockets) | 0.24+ |
| **Reverse Proxy** | Nginx | 1.24+ |
| **Conteneurisation** | Docker | 24.0+ |
| **Orchestration** | Docker Compose / Kubernetes | - |

### Schéma d'architecture globale

```mermaid
flowchart TB
    subgraph Internet
        USERS[Utilisateurs OPAC]
        STAFF[Bibliothécaires]
        AUTOMATES[Automates RFID]
        EXTERNAL[Services externes]
    end

    subgraph "Load Balancer"
        LB[Nginx / HAProxy]
    end

    subgraph "Application Layer"
        subgraph "Web Servers"
            WEB1[Gunicorn #1]
            WEB2[Gunicorn #2]
            WEB3[Gunicorn #N]
        end
        
        subgraph "Background Workers"
            CELERY1[Celery Worker #1]
            CELERY2[Celery Worker #2]
            BEAT[Celery Beat]
        end
    end

    subgraph "Data Layer"
        subgraph "Primary Storage"
            PG_PRIMARY[(PostgreSQL Primary)]
            PG_REPLICA[(PostgreSQL Replica)]
        end
        
        subgraph "Cache & Queue"
            REDIS_CACHE[(Redis Cache)]
            REDIS_QUEUE[(Redis Queue)]
        end
        
        subgraph "Search"
            ES[(Elasticsearch)]
        end
        
        subgraph "File Storage"
            S3[(S3 / MinIO)]
        end
    end

    subgraph "External Services"
        SMTP[Serveur SMTP]
        SMS[Gateway SMS]
        Z3950[Serveurs Z39.50]
        SIP2[Serveurs SIP2]
        PNB[Hub PNB Dilicom]
    end

    USERS --> LB
    STAFF --> LB
    AUTOMATES --> LB
    EXTERNAL --> LB

    LB --> WEB1
    LB --> WEB2
    LB --> WEB3

    WEB1 --> PG_PRIMARY
    WEB2 --> PG_PRIMARY
    WEB3 --> PG_PRIMARY
    
    WEB1 --> REDIS_CACHE
    WEB2 --> REDIS_CACHE
    WEB3 --> REDIS_CACHE

    WEB1 --> REDIS_QUEUE
    WEB2 --> REDIS_QUEUE
    WEB3 --> REDIS_QUEUE

    CELERY1 --> REDIS_QUEUE
    CELERY2 --> REDIS_QUEUE
    BEAT --> REDIS_QUEUE

    CELERY1 --> PG_PRIMARY
    CELERY2 --> PG_PRIMARY

    PG_PRIMARY --> PG_REPLICA

    WEB1 --> ES
    WEB2 --> ES
    WEB3 --> ES

    WEB1 --> S3
    CELERY1 --> S3

    CELERY1 --> SMTP
    CELERY1 --> SMS
    WEB1 --> Z3950
    WEB1 --> SIP2
    WEB1 --> PNB
```

---

## Architecture système

### Architecture Django MVT

```mermaid
flowchart LR
    subgraph "Client"
        BROWSER[Navigateur]
        API_CLIENT[Client API]
    end

    subgraph "Django Application"
        subgraph "URL Routing"
            URLS[urls.py]
        end

        subgraph "Views Layer"
            VIEWS[Views / ViewSets]
            SERIALIZERS[Serializers DRF]
        end

        subgraph "Business Logic"
            SERVICES[Services]
            MANAGERS[Managers]
        end

        subgraph "Data Layer"
            MODELS[Models]
            QUERYSETS[QuerySets]
        end

        subgraph "Templates"
            TEMPLATES[Templates HTML]
            STATIC[Static Files]
        end
    end

    subgraph "Database"
        DB[(PostgreSQL)]
    end

    BROWSER --> URLS
    API_CLIENT --> URLS
    URLS --> VIEWS
    VIEWS --> SERIALIZERS
    VIEWS --> SERVICES
    SERVICES --> MANAGERS
    MANAGERS --> MODELS
    MODELS --> QUERYSETS
    QUERYSETS --> DB
    VIEWS --> TEMPLATES
    TEMPLATES --> STATIC
```

### Structure des applications Django

```mermaid
flowchart TB
    subgraph "Core Layer"
        CORE[core]
        SITES[sites]
    end

    subgraph "Catalog Layer"
        CATALOG[catalog]
        ITEMS[items]
    end

    subgraph "Users Layer"
        PATRONS[patrons]
    end

    subgraph "Transaction Layer"
        CIRCULATION[circulation]
        ACQUISITIONS[acquisitions]
        SERIALS[serials]
    end

    subgraph "Public Layer"
        OPAC[opac]
        EVENTS[events]
    end

    subgraph "Integration Layer"
        RFID[rfid]
        DIGITAL[digital]
    end

    subgraph "Support Layer"
        REPORTS[reports]
        NOTIFICATIONS[notifications]
    end

    CORE --> SITES
    SITES --> CATALOG
    CATALOG --> ITEMS
    CORE --> PATRONS
    SITES --> PATRONS
    ITEMS --> CIRCULATION
    PATRONS --> CIRCULATION
    CATALOG --> ACQUISITIONS
    CATALOG --> SERIALS
    ACQUISITIONS --> SERIALS
    CATALOG --> OPAC
    PATRONS --> OPAC
    CIRCULATION --> OPAC
    SITES --> EVENTS
    PATRONS --> EVENTS
    ITEMS --> RFID
    CIRCULATION --> RFID
    CATALOG --> DIGITAL
    CIRCULATION --> REPORTS
    CATALOG --> REPORTS
    PATRONS --> NOTIFICATIONS
    CIRCULATION --> NOTIFICATIONS
```

### Architecture API REST

| Endpoint | Méthode | Description | Auth |
|----------|---------|-------------|------|
| `/api/v1/records/` | GET, POST | Notices bibliographiques | Staff |
| `/api/v1/records/{id}/` | GET, PUT, DELETE | Détail notice | Staff |
| `/api/v1/items/` | GET, POST | Exemplaires | Staff |
| `/api/v1/patrons/` | GET, POST | Lecteurs | Staff |
| `/api/v1/loans/` | GET, POST | Prêts | Staff |
| `/api/v1/loans/{id}/return/` | POST | Retour | Staff |
| `/api/v1/holds/` | GET, POST | Réservations | Staff/Patron |
| `/api/v1/opac/search/` | GET | Recherche OPAC | Public |
| `/api/v1/opac/account/` | GET | Compte lecteur | Patron |
| `/api/v1/sip2/` | POST | Protocole SIP2 | Automate |

```mermaid
sequenceDiagram
    participant Client
    participant API Gateway
    participant Auth
    participant View
    participant Service
    participant Database
    participant Cache

    Client->>API Gateway: Request + Token
    API Gateway->>Auth: Validate Token
    Auth-->>API Gateway: User Context
    API Gateway->>View: Authorized Request
    View->>Cache: Check Cache
    alt Cache Hit
        Cache-->>View: Cached Data
    else Cache Miss
        View->>Service: Business Logic
        Service->>Database: Query
        Database-->>Service: Data
        Service-->>View: Processed Data
        View->>Cache: Store in Cache
    end
    View-->>Client: JSON Response
```

---

## Base de données

### Choix du SGBD

| Critère | PostgreSQL | MySQL | SQLite |
|---------|------------|-------|--------|
| **Production** | ✅ Recommandé | ⚠️ Acceptable | ❌ Non |
| **Développement** | ✅ | ✅ | ✅ |
| **Full-text search** | ✅ Natif | ⚠️ Limité | ❌ |
| **JSON/JSONB** | ✅ Excellent | ⚠️ Basique | ❌ |
| **Transactions** | ✅ ACID | ✅ ACID | ✅ ACID |
| **Réplication** | ✅ Native | ✅ Native | ❌ |
| **Extensions** | ✅ pg_trgm, unaccent | ⚠️ | ❌ |

### Modèle de données principal (ERD)

```mermaid
erDiagram
    LIBRARY ||--o{ SECTION : contains
    LIBRARY ||--o{ STAFF_USER : employs
    LIBRARY {
        uuid id PK
        string name
        string code
        text address
        string phone
        string email
        json opening_hours
        boolean is_active
        datetime created_at
    }

    SECTION ||--o{ SHELF : contains
    SECTION {
        uuid id PK
        uuid library_id FK
        string name
        string code
        integer order
    }

    SHELF {
        uuid id PK
        uuid section_id FK
        string name
        string code
    }

    RECORD ||--o{ ITEM : has
    RECORD ||--o{ RECORD_AUTHOR : written_by
    RECORD ||--o{ RECORD_SUBJECT : about
    RECORD {
        uuid id PK
        string record_type
        string title
        string isbn
        string issn
        integer year
        json unimarc_data
        text summary
        string cover_url
        datetime created_at
        datetime updated_at
    }

    AUTHOR ||--o{ RECORD_AUTHOR : writes
    AUTHOR {
        uuid id PK
        string name
        string first_name
        date birth_date
        date death_date
        string authority_id
    }

    RECORD_AUTHOR {
        uuid id PK
        uuid record_id FK
        uuid author_id FK
        string role
        integer order
    }

    SUBJECT ||--o{ RECORD_SUBJECT : describes
    SUBJECT {
        uuid id PK
        string term
        string authority_type
        string authority_id
    }

    RECORD_SUBJECT {
        uuid id PK
        uuid record_id FK
        uuid subject_id FK
    }

    ITEM ||--|| LIBRARY : located_in
    ITEM ||--o| SECTION : placed_in
    ITEM ||--o{ LOAN : borrowed
    ITEM ||--o{ HOLD : reserved
    ITEM {
        uuid id PK
        uuid record_id FK
        uuid library_id FK
        uuid section_id FK
        string barcode UK
        string call_number
        string status
        string condition
        decimal price
        date acquisition_date
        string rfid_tag
        datetime created_at
    }

    PATRON ||--|| LIBRARY : registered_at
    PATRON ||--o{ LOAN : borrows
    PATRON ||--o{ HOLD : requests
    PATRON ||--o{ FINE : owes
    PATRON {
        uuid id PK
        uuid library_id FK
        uuid category_id FK
        string barcode UK
        string last_name
        string first_name
        date birth_date
        string email
        string phone
        text address
        date expiry_date
        boolean is_blocked
        decimal balance
        datetime created_at
    }

    PATRON_CATEGORY {
        uuid id PK
        string name
        integer loan_duration
        integer max_loans
        integer max_holds
        decimal fine_per_day
    }

    LOAN ||--|| ITEM : concerns
    LOAN ||--|| PATRON : made_by
    LOAN ||--o| FINE : generates
    LOAN {
        uuid id PK
        uuid item_id FK
        uuid patron_id FK
        uuid checkout_library_id FK
        uuid checkin_library_id FK
        datetime checkout_date
        datetime due_date
        datetime checkin_date
        integer renewals
        string status
    }

    HOLD ||--|| RECORD : on_title
    HOLD ||--o| ITEM : on_item
    HOLD ||--|| PATRON : requested_by
    HOLD ||--|| LIBRARY : pickup_at
    HOLD {
        uuid id PK
        uuid record_id FK
        uuid item_id FK
        uuid patron_id FK
        uuid pickup_library_id FK
        datetime request_date
        datetime expiry_date
        datetime notify_date
        integer queue_position
        string status
    }

    FINE ||--|| PATRON : charged_to
    FINE ||--o| LOAN : from_loan
    FINE {
        uuid id PK
        uuid patron_id FK
        uuid loan_id FK
        decimal amount
        string reason
        datetime created_at
        datetime paid_at
        string status
    }

    STAFF_USER ||--o{ ROLE : has
    STAFF_USER {
        uuid id PK
        uuid library_id FK
        string username UK
        string email UK
        string password_hash
        string first_name
        string last_name
        boolean is_active
        datetime last_login
    }

    ROLE ||--o{ PERMISSION : grants
    ROLE {
        uuid id PK
        string name
        string description
    }

    PERMISSION {
        uuid id PK
        string codename
        string name
        string module
    }
```

### Indexation et optimisation

```sql
-- Index pour la recherche de notices
CREATE INDEX idx_record_title_trgm ON record USING gin (title gin_trgm_ops);
CREATE INDEX idx_record_isbn ON record (isbn) WHERE isbn IS NOT NULL;
CREATE INDEX idx_record_year ON record (year);

-- Index pour les exemplaires
CREATE INDEX idx_item_barcode ON item (barcode);
CREATE INDEX idx_item_status ON item (status);
CREATE INDEX idx_item_library ON item (library_id);

-- Index pour les lecteurs
CREATE INDEX idx_patron_barcode ON patron (barcode);
CREATE INDEX idx_patron_email ON patron (email);
CREATE INDEX idx_patron_name ON patron (last_name, first_name);
CREATE INDEX idx_patron_expiry ON patron (expiry_date) WHERE NOT is_blocked;

-- Index pour les prêts
CREATE INDEX idx_loan_status ON loan (status);
CREATE INDEX idx_loan_due_date ON loan (due_date) WHERE status = 'active';
CREATE INDEX idx_loan_patron ON loan (patron_id);
CREATE INDEX idx_loan_item ON loan (item_id);

-- Index pour les réservations
CREATE INDEX idx_hold_status ON hold (status);
CREATE INDEX idx_hold_patron ON hold (patron_id);
CREATE INDEX idx_hold_record ON hold (record_id);

-- Extension pour la recherche full-text en français
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Configuration du français
CREATE TEXT SEARCH CONFIGURATION french_unaccent (COPY = french);
ALTER TEXT SEARCH CONFIGURATION french_unaccent
    ALTER MAPPING FOR hword, hword_part, word WITH unaccent, french_stem;
```

### Stratégie de migration

```mermaid
flowchart TD
    A[Code modifié] --> B[makemigrations]
    B --> C{Migration créée?}
    C -->|Oui| D[Review migration]
    D --> E{Migration OK?}
    E -->|Non| F[Modifier migration]
    F --> D
    E -->|Oui| G[Tests locaux]
    G --> H{Tests OK?}
    H -->|Non| I[Corriger]
    I --> B
    H -->|Oui| J[Commit]
    J --> K[CI/CD]
    K --> L[Deploy Staging]
    L --> M[migrate staging]
    M --> N{Staging OK?}
    N -->|Non| O[Rollback]
    O --> I
    N -->|Oui| P[Deploy Production]
    P --> Q[migrate production]
    Q --> R[Monitoring]
```

---

## Sécurité

### Authentification

```mermaid
flowchart TD
    subgraph "Méthodes d'authentification"
        A[Session Django] --> AUTH
        B[JWT Token] --> AUTH
        C[API Key] --> AUTH
        D[LDAP/AD] --> AUTH
        E[SSO/SAML] --> AUTH
        F[OAuth2] --> AUTH
    end

    AUTH[Authentification] --> G{Utilisateur valide?}
    G -->|Oui| H[Créer session/token]
    G -->|Non| I[Erreur 401]
    H --> J[Vérifier permissions]
    J --> K{Autorisé?}
    K -->|Oui| L[Accès ressource]
    K -->|Non| M[Erreur 403]
```

### Matrice des rôles et permissions (RBAC)

| Permission | Admin | Catalogueur | Circulation | Lecteur | OPAC |
|------------|-------|-------------|-------------|---------|------|
| **Notices** |
| Créer | ✅ | ✅ | ❌ | ❌ | ❌ |
| Modifier | ✅ | ✅ | ❌ | ❌ | ❌ |
| Supprimer | ✅ | ❌ | ❌ | ❌ | ❌ |
| Voir | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Exemplaires** |
| Créer | ✅ | ✅ | ❌ | ❌ | ❌ |
| Modifier | ✅ | ✅ | ✅ | ❌ | ❌ |
| Supprimer | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Lecteurs** |
| Créer | ✅ | ❌ | ✅ | ❌ | ❌ |
| Modifier | ✅ | ❌ | ✅ | ❌ | ❌ |
| Voir tous | ✅ | ❌ | ✅ | ❌ | ❌ |
| Voir soi-même | ✅ | ❌ | ✅ | ✅ | ✅ |
| **Prêts** |
| Créer | ✅ | ❌ | ✅ | ❌ | ❌ |
| Retour | ✅ | ❌ | ✅ | ❌ | ❌ |
| Prolonger | ✅ | ❌ | ✅ | ✅ | ✅ |
| **Réservations** |
| Créer | ✅ | ❌ | ✅ | ✅ | ✅ |
| Annuler | ✅ | ❌ | ✅ | ✅* | ✅* |
| **Administration** |
| Configuration | ✅ | ❌ | ❌ | ❌ | ❌ |
| Utilisateurs | ✅ | ❌ | ❌ | ❌ | ❌ |
| Statistiques | ✅ | ✅ | ✅ | ❌ | ❌ |

*Uniquement ses propres réservations

### Protection contre les attaques

| Attaque | Protection | Implémentation Django |
|---------|------------|----------------------|
| **CSRF** | Token CSRF | `{% csrf_token %}`, `@csrf_protect` |
| **XSS** | Échappement auto | Templates Django, DRF |
| **SQL Injection** | ORM paramétré | QuerySet, `F()`, `Q()` |
| **Clickjacking** | X-Frame-Options | `XFrameOptionsMiddleware` |
| **MITM** | HTTPS obligatoire | `SECURE_SSL_REDIRECT = True` |
| **Brute Force** | Rate limiting | `django-axes`, `django-ratelimit` |
| **Session Hijacking** | Cookies sécurisés | `SESSION_COOKIE_SECURE = True` |

### Conformité RGPD

```mermaid
flowchart LR
    subgraph "Données personnelles"
        A[Nom, Prénom]
        B[Email, Téléphone]
        C[Adresse]
        D[Historique prêts]
    end

    subgraph "Mesures RGPD"
        E[Consentement explicite]
        F[Droit à l'oubli]
        G[Portabilité]
        H[Anonymisation]
        I[Chiffrement]
        J[Logs d'accès]
    end

    subgraph "Actions"
        K[Export données]
        L[Suppression compte]
        M[Anonymisation historique]
    end

    A --> E
    B --> E
    C --> E
    D --> H

    E --> F
    F --> L
    F --> M
    
    E --> G
    G --> K

    A --> I
    B --> I
    C --> I
```

### Configuration sécurité Django

```python
# settings/production.py

# HTTPS
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Cookies
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_SECURE = True
CSRF_COOKIE_HTTPONLY = True

# Headers de sécurité
SECURE_HSTS_SECONDS = 31536000  # 1 an
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# Mots de passe
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
     'OPTIONS': {'min_length': 12}},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Rate limiting
AXES_FAILURE_LIMIT = 5
AXES_COOLOFF_TIME = timedelta(minutes=30)
AXES_LOCKOUT_TEMPLATE = 'auth/lockout.html'
```

---

## Système d'audit et traçabilité

Le système AuditLog est un composant central de MediaBib qui trace **toutes** les actions des utilisateurs pour assurer la traçabilité, la sécurité et la conformité RGPD.

### Architecture du système d'audit

```mermaid
flowchart TB
    subgraph Application [Application Django]
        REQ[Requête HTTP]
        MW[AuditMiddleware]
        VIEW[Vue / API]
        SIGNAL[Django Signals]
        SERVICE[Services métier]
    end
    
    subgraph AuditSystem [Système AuditLog]
        CONTEXT[AuditContext Thread-Local]
        HANDLER[AuditHandler]
        QUEUE[Celery Queue]
        LOG[AuditLog Model]
    end
    
    subgraph Storage [Stockage]
        DB[(PostgreSQL)]
        ARCHIVE[(Archive Long Terme)]
    end
    
    subgraph Maintenance [Maintenance RGPD]
        ANON[Tâche Anonymisation]
        CLEANUP[Tâche Nettoyage]
        EXPORT[Export RGPD]
    end
    
    REQ --> MW
    MW --> CONTEXT
    MW --> VIEW
    VIEW --> SERVICE
    SERVICE --> SIGNAL
    SIGNAL --> HANDLER
    HANDLER --> QUEUE
    QUEUE --> LOG
    LOG --> DB
    
    ANON --> DB
    ANON --> ARCHIVE
    CLEANUP --> DB
    EXPORT --> DB
```

### Modèle AuditLog complet

```python
# core/models/audit.py

from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.utils import timezone
import uuid


class AuditLog(models.Model):
    """
    Journal d'audit centralisé pour tracer toutes les actions utilisateurs.
    
    Ce modèle enregistre :
    - Qui a fait l'action (utilisateur, IP, session)
    - Quoi (type d'action)
    - Sur quoi (objet concerné avec son état avant/après)
    - Quand (horodatage précis)
    - Où (site/bibliothèque, contexte)
    """
    
    class ActionType(models.TextChoices):
        """Types d'actions tracées dans le système."""
        
        # Authentification
        LOGIN = 'login', 'Connexion'
        LOGOUT = 'logout', 'Déconnexion'
        LOGIN_FAILED = 'login_failed', 'Échec de connexion'
        PASSWORD_CHANGE = 'password_change', 'Changement de mot de passe'
        PASSWORD_RESET = 'password_reset', 'Réinitialisation mot de passe'
        ACCOUNT_LOCKED = 'account_locked', 'Compte verrouillé'
        ACCOUNT_UNLOCKED = 'account_unlocked', 'Compte déverrouillé'
        
        # CRUD générique
        CREATE = 'create', 'Création'
        READ = 'read', 'Consultation'
        UPDATE = 'update', 'Modification'
        DELETE = 'delete', 'Suppression'
        
        # Actions sur les notices
        RECORD_MERGE = 'record_merge', 'Fusion de notices'
        RECORD_DUPLICATE = 'record_duplicate', 'Duplication de notice'
        RECORD_LOCK = 'record_lock', 'Verrouillage de notice'
        RECORD_UNLOCK = 'record_unlock', 'Déverrouillage de notice'
        
        # Circulation
        CHECKOUT = 'checkout', 'Prêt'
        CHECKIN = 'checkin', 'Retour'
        RENEWAL = 'renewal', 'Prolongation'
        HOLD_PLACE = 'hold_place', 'Réservation'
        HOLD_CANCEL = 'hold_cancel', 'Annulation réservation'
        HOLD_PICKUP = 'hold_pickup', 'Retrait réservation'
        
        # Lecteurs
        PATRON_BLOCK = 'patron_block', 'Blocage lecteur'
        PATRON_UNBLOCK = 'patron_unblock', 'Déblocage lecteur'
        PATRON_RENEW = 'patron_renew', 'Renouvellement abonnement'
        PATRON_ANONYMIZE = 'patron_anonymize', 'Anonymisation lecteur'
        
        # Amendes
        FINE_CREATE = 'fine_create', 'Création amende'
        FINE_PAY = 'fine_pay', 'Paiement amende'
        FINE_WAIVE = 'fine_waive', 'Remise amende'
        
        # Exemplaires
        ITEM_TRANSFER = 'item_transfer', 'Transfert exemplaire'
        ITEM_STATUS_CHANGE = 'item_status', 'Changement statut exemplaire'
        
        # Acquisitions
        ORDER_CREATE = 'order_create', 'Création commande'
        ORDER_RECEIVE = 'order_receive', 'Réception commande'
        ORDER_CANCEL = 'order_cancel', 'Annulation commande'
        INVOICE_CREATE = 'invoice_create', 'Création facture'
        
        # Import/Export
        IMPORT = 'import', 'Import de données'
        EXPORT = 'export', 'Export de données'
        
        # Administration
        CONFIG_CHANGE = 'config_change', 'Modification configuration'
        PERMISSION_CHANGE = 'permission_change', 'Modification permissions'
        ROLE_ASSIGN = 'role_assign', 'Attribution de rôle'
        
        # Système
        SCHEDULED_TASK = 'scheduled_task', 'Tâche planifiée'
        SYSTEM_ERROR = 'system_error', 'Erreur système'
        BACKUP = 'backup', 'Sauvegarde'
    
    class Severity(models.TextChoices):
        """Niveau de criticité de l'action."""
        CRITICAL = 'critical', 'Critique'
        HIGH = 'high', 'Haute'
        MEDIUM = 'medium', 'Moyenne'
        LOW = 'low', 'Basse'
        INFO = 'info', 'Information'
    
    # Identifiant unique
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    # Qui a effectué l'action
    user = models.ForeignKey(
        'core.StaffUser',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='audit_logs',
        verbose_name="Utilisateur"
    )
    user_repr = models.CharField(
        max_length=255,
        blank=True,
        verbose_name="Représentation utilisateur",
        help_text="Conservé même après anonymisation"
    )
    
    # Type d'action
    action = models.CharField(
        max_length=50,
        choices=ActionType.choices,
        db_index=True,
        verbose_name="Action"
    )
    severity = models.CharField(
        max_length=20,
        choices=Severity.choices,
        default=Severity.MEDIUM,
        db_index=True,
        verbose_name="Criticité"
    )
    
    # Objet concerné (relation générique)
    content_type = models.ForeignKey(
        ContentType,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        verbose_name="Type d'objet"
    )
    object_id = models.CharField(
        max_length=255,
        null=True,
        blank=True,
        verbose_name="ID de l'objet"
    )
    content_object = GenericForeignKey('content_type', 'object_id')
    object_repr = models.CharField(
        max_length=500,
        blank=True,
        verbose_name="Représentation de l'objet",
        help_text="Description lisible conservée même après suppression"
    )
    
    # Données avant/après modification
    data_before = models.JSONField(
        null=True,
        blank=True,
        verbose_name="Données avant",
        help_text="État de l'objet avant l'action"
    )
    data_after = models.JSONField(
        null=True,
        blank=True,
        verbose_name="Données après",
        help_text="État de l'objet après l'action"
    )
    changes = models.JSONField(
        null=True,
        blank=True,
        verbose_name="Changements",
        help_text="Liste des champs modifiés avec anciennes/nouvelles valeurs"
    )
    
    # Contexte de la requête
    ip_address = models.GenericIPAddressField(
        null=True,
        blank=True,
        verbose_name="Adresse IP"
    )
    user_agent = models.TextField(
        blank=True,
        verbose_name="User-Agent"
    )
    session_key = models.CharField(
        max_length=255,
        blank=True,
        verbose_name="Clé de session"
    )
    request_id = models.CharField(
        max_length=255,
        blank=True,
        verbose_name="ID de requête",
        help_text="Pour tracer les actions liées"
    )
    
    # Contexte métier
    library = models.ForeignKey(
        'sites.Library',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        verbose_name="Bibliothèque"
    )
    
    # Message descriptif
    message = models.TextField(
        blank=True,
        verbose_name="Message",
        help_text="Description détaillée de l'action"
    )
    
    # Métadonnées supplémentaires
    extra_data = models.JSONField(
        null=True,
        blank=True,
        verbose_name="Données supplémentaires"
    )
    
    # Horodatage
    timestamp = models.DateTimeField(
        auto_now_add=True,
        db_index=True,
        verbose_name="Horodatage"
    )
    
    # RGPD - Gestion de la rétention
    is_anonymized = models.BooleanField(
        default=False,
        db_index=True,
        verbose_name="Anonymisé"
    )
    anonymized_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Date d'anonymisation"
    )
    retention_until = models.DateTimeField(
        null=True,
        blank=True,
        db_index=True,
        verbose_name="Conserver jusqu'au",
        help_text="Date après laquelle l'entrée peut être anonymisée"
    )
    
    class Meta:
        verbose_name = "Entrée d'audit"
        verbose_name_plural = "Journal d'audit"
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['user', '-timestamp']),
            models.Index(fields=['action', '-timestamp']),
            models.Index(fields=['content_type', 'object_id']),
            models.Index(fields=['library', '-timestamp']),
            models.Index(fields=['severity', '-timestamp']),
            models.Index(fields=['-timestamp', 'is_anonymized']),
        ]
    
    def __str__(self):
        return f"{self.timestamp} | {self.user_repr} | {self.get_action_display()} | {self.object_repr}"
    
    def get_changes_display(self):
        """Retourne une représentation lisible des changements."""
        if not self.changes:
            return []
        return [
            {
                'field': change.get('field'),
                'old': change.get('old'),
                'new': change.get('new'),
            }
            for change in self.changes
        ]


class AuditLogManager(models.Manager):
    """Manager personnalisé pour AuditLog avec méthodes utilitaires."""
    
    def for_user(self, user):
        """Retourne tous les logs d'un utilisateur."""
        return self.filter(user=user)
    
    def for_object(self, obj):
        """Retourne tous les logs concernant un objet."""
        ct = ContentType.objects.get_for_model(obj)
        return self.filter(content_type=ct, object_id=str(obj.pk))
    
    def critical_actions(self, since=None):
        """Retourne les actions critiques depuis une date."""
        qs = self.filter(severity=AuditLog.Severity.CRITICAL)
        if since:
            qs = qs.filter(timestamp__gte=since)
        return qs
    
    def failed_logins(self, since=None, ip_address=None):
        """Retourne les échecs de connexion."""
        qs = self.filter(action=AuditLog.ActionType.LOGIN_FAILED)
        if since:
            qs = qs.filter(timestamp__gte=since)
        if ip_address:
            qs = qs.filter(ip_address=ip_address)
        return qs
```

### Middleware d'audit automatique

```python
# core/middleware/audit.py

import threading
import uuid
from django.utils.deprecation import MiddlewareMixin

# Thread-local storage pour le contexte d'audit
_audit_context = threading.local()


def get_audit_context():
    """Récupère le contexte d'audit du thread courant."""
    return getattr(_audit_context, 'context', {})


def set_audit_context(**kwargs):
    """Définit le contexte d'audit pour le thread courant."""
    if not hasattr(_audit_context, 'context'):
        _audit_context.context = {}
    _audit_context.context.update(kwargs)


def clear_audit_context():
    """Nettoie le contexte d'audit du thread courant."""
    _audit_context.context = {}


class AuditMiddleware(MiddlewareMixin):
    """
    Middleware qui capture automatiquement le contexte de la requête
    pour l'utiliser dans les entrées d'audit.
    """
    
    def process_request(self, request):
        """Capture les informations de contexte au début de la requête."""
        # Générer un ID unique pour cette requête
        request_id = str(uuid.uuid4())
        
        # Extraire l'adresse IP (gestion des proxies)
        ip_address = self.get_client_ip(request)
        
        # Récupérer le user-agent
        user_agent = request.META.get('HTTP_USER_AGENT', '')
        
        # Récupérer la clé de session
        session_key = request.session.session_key if hasattr(request, 'session') else ''
        
        # Récupérer la bibliothèque active (si disponible)
        library_id = request.session.get('active_library_id') if hasattr(request, 'session') else None
        
        # Stocker dans le contexte thread-local
        set_audit_context(
            request_id=request_id,
            ip_address=ip_address,
            user_agent=user_agent,
            session_key=session_key,
            library_id=library_id,
            user=request.user if hasattr(request, 'user') and request.user.is_authenticated else None,
        )
        
        # Attacher aussi à la requête pour accès direct
        request.audit_context = get_audit_context()
    
    def process_response(self, request, response):
        """Nettoie le contexte à la fin de la requête."""
        clear_audit_context()
        return response
    
    def get_client_ip(self, request):
        """Extrait l'adresse IP réelle du client (gestion des proxies)."""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            # Prendre la première IP de la chaîne
            ip = x_forwarded_for.split(',')[0].strip()
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
```

### Mixin pour les modèles audités

```python
# core/mixins/audit.py

from django.db.models.signals import pre_save, post_save, pre_delete, post_delete
from django.dispatch import receiver
from django.forms.models import model_to_dict


class AuditableMixin:
    """
    Mixin à ajouter aux modèles pour activer l'audit automatique.
    
    Usage:
        class Record(AuditableMixin, models.Model):
            audit_fields = ['title', 'author', 'status']  # ou '__all__'
            audit_exclude = ['updated_at']  # champs à exclure
            audit_read = False  # tracer les consultations (False par défaut)
            
            title = models.CharField(max_length=255)
            ...
    """
    
    # Configuration par défaut
    audit_fields = '__all__'  # '__all__' ou liste de champs
    audit_exclude = []  # champs à exclure de l'audit
    audit_read = False  # tracer les lectures/consultations
    
    def get_audit_fields(self):
        """Retourne la liste des champs à auditer."""
        if self.audit_fields == '__all__':
            fields = [f.name for f in self._meta.get_fields() if f.concrete]
        else:
            fields = list(self.audit_fields)
        
        # Exclure les champs spécifiés
        return [f for f in fields if f not in self.audit_exclude]
    
    def get_audit_data(self):
        """Retourne les données auditables du modèle."""
        fields = self.get_audit_fields()
        data = {}
        for field in fields:
            value = getattr(self, field, None)
            # Convertir les objets en représentation sérialisable
            if hasattr(value, 'pk'):
                data[field] = str(value.pk)
            elif hasattr(value, 'isoformat'):
                data[field] = value.isoformat()
            else:
                data[field] = value
        return data
    
    def get_audit_repr(self):
        """Retourne une représentation lisible pour l'audit."""
        return str(self)


def connect_audit_signals(model_class):
    """Connecte les signals d'audit pour un modèle."""
    from core.services.audit import AuditService
    
    @receiver(pre_save, sender=model_class)
    def audit_pre_save(sender, instance, **kwargs):
        """Capture l'état avant sauvegarde."""
        if instance.pk:
            try:
                old_instance = sender.objects.get(pk=instance.pk)
                instance._audit_old_data = old_instance.get_audit_data()
            except sender.DoesNotExist:
                instance._audit_old_data = None
        else:
            instance._audit_old_data = None
    
    @receiver(post_save, sender=model_class)
    def audit_post_save(sender, instance, created, **kwargs):
        """Enregistre l'action après sauvegarde."""
        action = 'create' if created else 'update'
        old_data = getattr(instance, '_audit_old_data', None)
        new_data = instance.get_audit_data()
        
        AuditService.log(
            action=action,
            obj=instance,
            data_before=old_data,
            data_after=new_data,
        )
    
    @receiver(pre_delete, sender=model_class)
    def audit_pre_delete(sender, instance, **kwargs):
        """Capture l'état avant suppression."""
        instance._audit_old_data = instance.get_audit_data()
    
    @receiver(post_delete, sender=model_class)
    def audit_post_delete(sender, instance, **kwargs):
        """Enregistre la suppression."""
        AuditService.log(
            action='delete',
            obj=instance,
            data_before=getattr(instance, '_audit_old_data', None),
        )
```

### Service d'audit

```python
# core/services/audit.py

from django.contrib.contenttypes.models import ContentType
from django.utils import timezone
from datetime import timedelta

from core.models.audit import AuditLog
from core.middleware.audit import get_audit_context


class AuditService:
    """Service centralisé pour la gestion des logs d'audit."""
    
    # Durées de rétention par type d'action (en jours)
    RETENTION_DAYS = {
        'critical': 3650,  # 10 ans
        'high': 1825,      # 5 ans
        'medium': 730,     # 2 ans
        'low': 90,         # 90 jours
        'info': 30,        # 30 jours
    }
    
    # Mapping action -> criticité
    ACTION_SEVERITY = {
        # Critique
        'login': 'critical',
        'logout': 'critical',
        'login_failed': 'critical',
        'password_change': 'critical',
        'password_reset': 'critical',
        'account_locked': 'critical',
        'config_change': 'critical',
        'permission_change': 'critical',
        'patron_anonymize': 'critical',
        'backup': 'critical',
        
        # Haute
        'create': 'high',
        'update': 'high',
        'delete': 'high',
        'checkout': 'high',
        'checkin': 'high',
        'fine_pay': 'high',
        'import': 'high',
        'export': 'high',
        
        # Moyenne
        'renewal': 'medium',
        'hold_place': 'medium',
        'hold_cancel': 'medium',
        'patron_block': 'medium',
        'patron_unblock': 'medium',
        'order_create': 'medium',
        
        # Basse
        'read': 'low',
        
        # Info
        'scheduled_task': 'info',
    }
    
    @classmethod
    def log(cls, action, obj=None, user=None, message='', 
            data_before=None, data_after=None, extra_data=None,
            severity=None):
        """
        Enregistre une entrée d'audit.
        
        Args:
            action: Type d'action (voir AuditLog.ActionType)
            obj: Objet concerné (optionnel)
            user: Utilisateur (auto-détecté si non fourni)
            message: Message descriptif
            data_before: Données avant modification
            data_after: Données après modification
            extra_data: Données supplémentaires
            severity: Criticité (auto-déterminée si non fournie)
        """
        # Récupérer le contexte de la requête
        context = get_audit_context()
        
        # Déterminer l'utilisateur
        if user is None:
            user = context.get('user')
        
        # Déterminer la criticité
        if severity is None:
            severity = cls.ACTION_SEVERITY.get(action, 'medium')
        
        # Calculer la date de rétention
        retention_days = cls.RETENTION_DAYS.get(severity, 730)
        retention_until = timezone.now() + timedelta(days=retention_days)
        
        # Calculer les changements
        changes = None
        if data_before and data_after:
            changes = cls._compute_changes(data_before, data_after)
        
        # Préparer les données de l'objet
        content_type = None
        object_id = None
        object_repr = ''
        if obj is not None:
            content_type = ContentType.objects.get_for_model(obj)
            object_id = str(obj.pk) if obj.pk else None
            object_repr = str(obj)[:500]
        
        # Créer l'entrée d'audit
        audit_log = AuditLog.objects.create(
            user=user,
            user_repr=str(user) if user else 'Anonyme',
            action=action,
            severity=severity,
            content_type=content_type,
            object_id=object_id,
            object_repr=object_repr,
            data_before=data_before,
            data_after=data_after,
            changes=changes,
            ip_address=context.get('ip_address'),
            user_agent=context.get('user_agent', ''),
            session_key=context.get('session_key', ''),
            request_id=context.get('request_id', ''),
            library_id=context.get('library_id'),
            message=message,
            extra_data=extra_data,
            retention_until=retention_until,
        )
        
        return audit_log
    
    @classmethod
    def _compute_changes(cls, before, after):
        """Calcule les différences entre deux états."""
        changes = []
        all_keys = set(before.keys()) | set(after.keys())
        
        for key in all_keys:
            old_val = before.get(key)
            new_val = after.get(key)
            if old_val != new_val:
                changes.append({
                    'field': key,
                    'old': old_val,
                    'new': new_val,
                })
        
        return changes if changes else None
    
    @classmethod
    def log_login(cls, user, success=True, ip_address=None, user_agent=''):
        """Enregistre une tentative de connexion."""
        action = 'login' if success else 'login_failed'
        message = f"Connexion {'réussie' if success else 'échouée'} pour {user}"
        
        return cls.log(
            action=action,
            user=user if success else None,
            message=message,
            extra_data={
                'username': str(user),
                'success': success,
            }
        )
    
    @classmethod
    def log_logout(cls, user):
        """Enregistre une déconnexion."""
        return cls.log(
            action='logout',
            user=user,
            message=f"Déconnexion de {user}",
        )
```

### Conformité RGPD - Anonymisation automatique

```python
# core/tasks/audit.py

from celery import shared_task
from django.utils import timezone
from django.db import transaction

from core.models.audit import AuditLog


@shared_task(name='core.anonymize_audit_logs')
def anonymize_audit_logs():
    """
    Tâche Celery pour anonymiser les logs d'audit expirés.
    
    Exécutée quotidiennement pour :
    1. Anonymiser les entrées dont la date de rétention est dépassée
    2. Supprimer les données personnelles (IP, user-agent)
    3. Remplacer l'utilisateur par "Utilisateur anonyme"
    """
    now = timezone.now()
    
    # Sélectionner les entrées à anonymiser
    entries_to_anonymize = AuditLog.objects.filter(
        is_anonymized=False,
        retention_until__lte=now,
    )
    
    count = entries_to_anonymize.count()
    
    if count == 0:
        return "Aucune entrée à anonymiser"
    
    with transaction.atomic():
        # Anonymiser par lot
        entries_to_anonymize.update(
            is_anonymized=True,
            anonymized_at=now,
            user=None,
            user_repr='Utilisateur anonyme',
            ip_address=None,
            user_agent='',
            session_key='',
            # Conserver les données métier mais anonymiser si nécessaire
            extra_data=None,
        )
    
    return f"{count} entrées anonymisées"


@shared_task(name='core.archive_old_audit_logs')
def archive_old_audit_logs(days_old=3650):
    """
    Archive les très anciens logs (plus de 10 ans par défaut).
    
    Les logs archivés sont exportés puis supprimés de la base principale.
    """
    cutoff_date = timezone.now() - timezone.timedelta(days=days_old)
    
    old_logs = AuditLog.objects.filter(
        timestamp__lt=cutoff_date,
        is_anonymized=True,
    )
    
    count = old_logs.count()
    
    if count > 0:
        # Exporter vers un fichier d'archive avant suppression
        # (Implémentation selon les besoins d'archivage)
        old_logs.delete()
    
    return f"{count} entrées archivées"


@shared_task(name='core.gdpr_anonymize_user')
def gdpr_anonymize_user(user_id):
    """
    Anonymise tous les logs d'un utilisateur spécifique (droit à l'oubli).
    
    Appelée sur demande explicite pour conformité RGPD.
    """
    now = timezone.now()
    
    with transaction.atomic():
        count = AuditLog.objects.filter(user_id=user_id).update(
            is_anonymized=True,
            anonymized_at=now,
            user=None,
            user_repr='Utilisateur anonyme (RGPD)',
            ip_address=None,
            user_agent='',
            session_key='',
        )
    
    return f"{count} entrées anonymisées pour l'utilisateur {user_id}"
```

### Configuration Celery Beat

```python
# app/celery.py (extrait)

from celery.schedules import crontab

CELERY_BEAT_SCHEDULE = {
    # Anonymisation quotidienne des logs expirés
    'anonymize-audit-logs': {
        'task': 'core.anonymize_audit_logs',
        'schedule': crontab(hour=3, minute=0),  # Tous les jours à 3h
    },
    # Archivage mensuel des très anciens logs
    'archive-old-audit-logs': {
        'task': 'core.archive_old_audit_logs',
        'schedule': crontab(day_of_month=1, hour=4, minute=0),  # 1er du mois à 4h
    },
}
```

### Durées de rétention RGPD

| Type d'action | Criticité | Durée de rétention | Anonymisation |
|---------------|-----------|-------------------|---------------|
| Connexions (succès/échec) | Critique | 10 ans | Suppression IP, user-agent, remplacement utilisateur |
| Modifications de configuration | Critique | 10 ans | Conservation anonymisée |
| Actions sur les droits | Critique | 10 ans | Conservation anonymisée |
| Créations/Modifications/Suppressions | Haute | 5 ans | Remplacement utilisateur par "Anonyme" |
| Prêts/Retours | Haute | 5 ans | Anonymisation lecteur et utilisateur |
| Paiements amendes | Haute | 10 ans | Conservation légale obligatoire |
| Réservations/Prolongations | Moyenne | 2 ans | Anonymisation complète |
| Consultations | Basse | 90 jours | Suppression complète |
| Tâches système | Info | 30 jours | Suppression complète |

### Signaux d'authentification

```python
# core/signals/auth.py

from django.contrib.auth.signals import user_logged_in, user_logged_out, user_login_failed
from django.dispatch import receiver

from core.services.audit import AuditService


@receiver(user_logged_in)
def audit_user_logged_in(sender, request, user, **kwargs):
    """Trace les connexions réussies."""
    AuditService.log_login(user, success=True)


@receiver(user_logged_out)
def audit_user_logged_out(sender, request, user, **kwargs):
    """Trace les déconnexions."""
    if user:
        AuditService.log_logout(user)


@receiver(user_login_failed)
def audit_user_login_failed(sender, credentials, request, **kwargs):
    """Trace les échecs de connexion."""
    username = credentials.get('username', 'inconnu')
    AuditService.log(
        action='login_failed',
        message=f"Échec de connexion pour '{username}'",
        extra_data={'username': username},
        severity='critical',
    )
```

### Interface d'administration des logs

```python
# core/admin.py (extrait)

from django.contrib import admin
from django.utils.html import format_html
from core.models.audit import AuditLog


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    """Administration du journal d'audit."""
    
    list_display = [
        'timestamp', 'user_repr', 'action_display', 'severity_badge',
        'object_repr_short', 'ip_address', 'library',
    ]
    list_filter = [
        'action', 'severity', 'is_anonymized', 'library',
        ('timestamp', admin.DateFieldListFilter),
    ]
    search_fields = [
        'user_repr', 'object_repr', 'message', 'ip_address',
    ]
    readonly_fields = [
        'id', 'timestamp', 'user', 'user_repr', 'action', 'severity',
        'content_type', 'object_id', 'object_repr',
        'data_before', 'data_after', 'changes',
        'ip_address', 'user_agent', 'session_key', 'request_id',
        'library', 'message', 'extra_data',
        'is_anonymized', 'anonymized_at', 'retention_until',
    ]
    date_hierarchy = 'timestamp'
    ordering = ['-timestamp']
    
    def has_add_permission(self, request):
        return False  # Logs créés automatiquement uniquement
    
    def has_change_permission(self, request, obj=None):
        return False  # Logs immuables
    
    def has_delete_permission(self, request, obj=None):
        return request.user.is_superuser  # Suppression réservée aux super-admins
    
    def action_display(self, obj):
        return obj.get_action_display()
    action_display.short_description = "Action"
    
    def severity_badge(self, obj):
        colors = {
            'critical': '#dc3545',
            'high': '#fd7e14',
            'medium': '#ffc107',
            'low': '#28a745',
            'info': '#17a2b8',
        }
        color = colors.get(obj.severity, '#6c757d')
        return format_html(
            '<span style="background-color: {}; color: white; padding: 2px 8px; '
            'border-radius: 4px; font-size: 11px;">{}</span>',
            color, obj.get_severity_display()
        )
    severity_badge.short_description = "Criticité"
    
    def object_repr_short(self, obj):
        return obj.object_repr[:50] + '...' if len(obj.object_repr) > 50 else obj.object_repr
    object_repr_short.short_description = "Objet"
```

### Exemple d'utilisation dans les vues

```python
# catalog/views.py (exemple)

from django.views.generic import DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin

from catalog.models import Record
from core.services.audit import AuditService


class RecordDeleteView(LoginRequiredMixin, PermissionRequiredMixin, DeleteView):
    """Vue de suppression d'une notice avec audit."""
    
    model = Record
    permission_required = 'catalog.delete_record'
    success_url = '/catalog/'
    
    def form_valid(self, form):
        """Enregistre l'action dans le journal d'audit avant suppression."""
        record = self.get_object()
        
        # Log manuel pour actions critiques avec message personnalisé
        AuditService.log(
            action='delete',
            obj=record,
            message=f"Suppression de la notice '{record.title}' par {self.request.user}",
            data_before=record.get_audit_data(),
        )
        
        return super().form_valid(form)
```

---

## Performance et optimisation

### Stratégie de cache

```mermaid
flowchart TD
    subgraph "Niveaux de cache"
        L1[Browser Cache]
        L2[CDN Cache]
        L3[Nginx Cache]
        L4[Application Cache - Redis]
        L5[Database Cache - PostgreSQL]
    end

    REQ[Request] --> L1
    L1 -->|Miss| L2
    L2 -->|Miss| L3
    L3 -->|Miss| L4
    L4 -->|Miss| L5
    L5 --> DB[(Database)]

    DB --> L5
    L5 --> L4
    L4 --> L3
    L3 --> L2
    L2 --> L1
    L1 --> RES[Response]
```

### Configuration Redis

| Cache | TTL | Usage |
|-------|-----|-------|
| `sessions` | 24h | Sessions utilisateurs |
| `views` | 15min | Pages OPAC statiques |
| `records` | 1h | Notices bibliographiques |
| `availability` | 5min | Disponibilité exemplaires |
| `search_results` | 10min | Résultats de recherche |
| `patron_data` | 30min | Données lecteur |

```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://localhost:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'SERIALIZER': 'django_redis.serializers.json.JSONSerializer',
            'COMPRESSOR': 'django_redis.compressors.zlib.ZlibCompressor',
        },
        'KEY_PREFIX': 'mediabib',
        'TIMEOUT': 300,  # 5 minutes par défaut
    },
    'sessions': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://localhost:6379/2',
        'TIMEOUT': 86400,  # 24 heures
    }
}

# Cache par vue
CACHE_MIDDLEWARE_SECONDS = 900  # 15 minutes
```

### Optimisation des requêtes

```python
# ❌ Mauvais - N+1 queries
def get_loans():
    loans = Loan.objects.filter(status='active')
    for loan in loans:
        print(loan.item.record.title)  # 2 requêtes par itération

# ✅ Bon - Prefetch
def get_loans():
    loans = Loan.objects.filter(status='active').select_related(
        'item__record', 'patron'
    ).prefetch_related(
        'item__record__authors'
    )
    for loan in loans:
        print(loan.item.record.title)  # Tout préchargé

# ✅ Utiliser only() pour limiter les champs
records = Record.objects.only('id', 'title', 'year').filter(year__gte=2020)

# ✅ Utiliser defer() pour exclure les gros champs
records = Record.objects.defer('unimarc_data', 'summary').all()

# ✅ Utiliser values() pour des dictionnaires
stats = Loan.objects.values('status').annotate(count=Count('id'))

# ✅ Pagination efficace avec curseur
from django.core.paginator import Paginator
paginator = Paginator(Record.objects.all().order_by('id'), 25)
```

### Tâches asynchrones Celery

```mermaid
flowchart LR
    subgraph "Application"
        A[Django View]
    end

    subgraph "Message Queue"
        B[Redis Queue]
    end

    subgraph "Workers"
        C[Celery Worker 1]
        D[Celery Worker 2]
        E[Celery Worker N]
    end

    subgraph "Tâches"
        F[Emails]
        G[SMS]
        H[Import UNIMARC]
        I[Rapports]
        J[Relances]
    end

    A -->|async| B
    B --> C
    B --> D
    B --> E
    C --> F
    C --> G
    D --> H
    D --> I
    E --> J
```

```python
# tasks.py
from celery import shared_task

@shared_task(bind=True, max_retries=3, default_retry_delay=60)
def send_reminder_email(self, patron_id, loan_ids):
    """Envoie un email de rappel pour les prêts."""
    try:
        patron = Patron.objects.get(id=patron_id)
        loans = Loan.objects.filter(id__in=loan_ids)
        send_email(patron.email, 'reminder', {'loans': loans})
    except Exception as exc:
        raise self.retry(exc=exc)

@shared_task
def import_unimarc_file(file_path, user_id):
    """Import asynchrone de notices UNIMARC."""
    from catalog.services import UnimarcImporter
    importer = UnimarcImporter(file_path)
    result = importer.run()
    notify_user(user_id, f"Import terminé: {result.success} notices")

# Tâches planifiées (Celery Beat)
CELERY_BEAT_SCHEDULE = {
    'send-overdue-reminders': {
        'task': 'circulation.tasks.send_overdue_reminders',
        'schedule': crontab(hour=8, minute=0),  # Tous les jours à 8h
    },
    'expire-holds': {
        'task': 'circulation.tasks.expire_holds',
        'schedule': crontab(hour=0, minute=0),  # Minuit
    },
    'cleanup-sessions': {
        'task': 'core.tasks.cleanup_sessions',
        'schedule': crontab(hour=3, minute=0),  # 3h du matin
    },
}
```

---

## Intégrations et protocoles

### Z39.50 / SRU-SRW

```mermaid
sequenceDiagram
    participant User
    participant MediaBib
    participant Z3950Client
    participant BnF

    User->>MediaBib: Recherche ISBN 978-2070612758
    MediaBib->>Z3950Client: search(isbn="978-2070612758")
    Z3950Client->>BnF: Z39.50 Search Request
    BnF-->>Z3950Client: Search Response (hits=1)
    Z3950Client->>BnF: Z39.50 Present Request
    BnF-->>Z3950Client: UNIMARC Record
    Z3950Client-->>MediaBib: Parsed Record
    MediaBib->>MediaBib: Convert to internal format
    MediaBib-->>User: Notice récupérée
```

```python
# catalog/services/z3950_client.py
from PyZ3950 import zoom

class Z3950Client:
    TARGETS = {
        'bnf': {
            'host': 'z3950.bnf.fr',
            'port': 2211,
            'database': 'TOUT-UTF8',
            'syntax': 'UNIMARC',
        },
        'loc': {
            'host': 'z3950.loc.gov',
            'port': 7090,
            'database': 'VOYAGER',
            'syntax': 'MARC21',
        },
    }

    def search(self, target: str, query: str) -> list[dict]:
        config = self.TARGETS[target]
        conn = zoom.Connection(config['host'], config['port'])
        conn.databaseName = config['database']
        conn.preferredRecordSyntax = config['syntax']
        
        query = zoom.Query('CCL', query)
        results = conn.search(query)
        
        records = []
        for record in results:
            records.append(self.parse_record(record, config['syntax']))
        
        conn.close()
        return records
```

### SIP2 (Standard Interchange Protocol)

```mermaid
sequenceDiagram
    participant Automate
    participant MediaBib
    participant Database

    Note over Automate,MediaBib: Connexion SIP2

    Automate->>MediaBib: 93 Login (AID, PWD)
    MediaBib->>Database: Verify credentials
    Database-->>MediaBib: OK
    MediaBib-->>Automate: 94 Login Response (OK)

    Automate->>MediaBib: 63 Patron Information (barcode)
    MediaBib->>Database: Get patron data
    Database-->>MediaBib: Patron record
    MediaBib-->>Automate: 64 Patron Info Response

    Automate->>MediaBib: 11 Checkout (patron, item)
    MediaBib->>Database: Create loan
    Database-->>MediaBib: Loan created
    MediaBib-->>Automate: 12 Checkout Response (OK)

    Automate->>MediaBib: 09 Checkin (item)
    MediaBib->>Database: Process return
    Database-->>MediaBib: Return processed
    MediaBib-->>Automate: 10 Checkin Response (OK)
```

```python
# rfid/services/sip2.py
class SIP2Server:
    """Serveur SIP2 pour automates de prêt."""
    
    COMMANDS = {
        '09': 'checkin',
        '11': 'checkout',
        '17': 'item_information',
        '23': 'patron_status',
        '63': 'patron_information',
        '93': 'login',
    }
    
    def handle_message(self, message: str) -> str:
        command = message[:2]
        handler = getattr(self, f'handle_{self.COMMANDS[command]}')
        return handler(message)
    
    def handle_checkout(self, message: str) -> str:
        """11 - Checkout request."""
        patron_barcode = self.extract_field(message, 'AA')
        item_barcode = self.extract_field(message, 'AB')
        
        try:
            loan = LoanService.checkout(patron_barcode, item_barcode)
            return self.format_response('12', ok=True, due_date=loan.due_date)
        except CheckoutError as e:
            return self.format_response('12', ok=False, message=str(e))
```

### UNIMARC Parser

```python
# catalog/services/unimarc_parser.py
from pymarc import MARCReader

class UnimarcParser:
    """Parse et convertit les notices UNIMARC."""
    
    FIELD_MAPPING = {
        '200': {'a': 'title', 'f': 'author_statement'},
        '210': {'a': 'publisher_place', 'c': 'publisher', 'd': 'year'},
        '215': {'a': 'physical_description'},
        '225': {'a': 'series'},
        '300': {'a': 'notes'},
        '330': {'a': 'summary'},
        '700': {'a': 'author_name', 'b': 'author_firstname'},
        '010': {'a': 'isbn'},
        '011': {'a': 'issn'},
    }
    
    def parse_file(self, filepath: str) -> Generator[dict, None, None]:
        with open(filepath, 'rb') as f:
            reader = MARCReader(f, to_unicode=True)
            for record in reader:
                yield self.parse_record(record)
    
    def parse_record(self, marc_record) -> dict:
        data = {
            'unimarc_raw': marc_record.as_marc().decode('utf-8', errors='replace')
        }
        
        for tag, subfields in self.FIELD_MAPPING.items():
            field = marc_record.get_fields(tag)
            for f in field:
                for code, attr in subfields.items():
                    value = f.get_subfields(code)
                    if value:
                        data[attr] = value[0] if len(value) == 1 else value
        
        return data
```

### API REST OpenAPI

```yaml
# openapi.yaml
openapi: 3.0.3
info:
  title: MediaBib API
  version: 1.0.0
  description: API REST du SIGB MediaBib

servers:
  - url: https://api.mediabib.example.com/v1

security:
  - bearerAuth: []

paths:
  /records:
    get:
      summary: Liste des notices
      parameters:
        - name: q
          in: query
          description: Recherche full-text
          schema:
            type: string
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: Liste paginée
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/RecordList'

  /loans:
    post:
      summary: Créer un prêt
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - patron_barcode
                - item_barcode
              properties:
                patron_barcode:
                  type: string
                item_barcode:
                  type: string
      responses:
        '201':
          description: Prêt créé
        '400':
          description: Erreur de validation
        '409':
          description: Conflit (exemplaire non disponible)

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    Record:
      type: object
      properties:
        id:
          type: string
          format: uuid
        title:
          type: string
        authors:
          type: array
          items:
            $ref: '#/components/schemas/Author'
        isbn:
          type: string
        year:
          type: integer
```

---

## Infrastructure et déploiement

### Architecture Docker

```mermaid
flowchart TB
    subgraph "Docker Network"
        subgraph "Frontend"
            NGINX[nginx:alpine]
        end

        subgraph "Application"
            WEB[django:gunicorn]
            CELERY[django:celery]
            BEAT[django:celery-beat]
        end

        subgraph "Data"
            PG[(postgres:15)]
            REDIS[(redis:7-alpine)]
        end

        subgraph "Volumes"
            V_STATIC[static_files]
            V_MEDIA[media_files]
            V_PG[postgres_data]
            V_REDIS[redis_data]
        end
    end

    NGINX --> WEB
    WEB --> PG
    WEB --> REDIS
    CELERY --> PG
    CELERY --> REDIS
    BEAT --> REDIS

    NGINX --> V_STATIC
    WEB --> V_MEDIA
    PG --> V_PG
    REDIS --> V_REDIS
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    build: .
    command: gunicorn app.wsgi:application --bind 0.0.0.0:8000 --workers 4
    volumes:
      - static_volume:/app/static
      - media_volume:/app/media
    environment:
      - DATABASE_URL=postgres://mediabib:${DB_PASSWORD}@db:5432/mediabib
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY}
      - DEBUG=False
    depends_on:
      - db
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
      interval: 30s
      timeout: 10s
      retries: 3

  celery:
    build: .
    command: celery -A app worker -l INFO --concurrency=4
    environment:
      - DATABASE_URL=postgres://mediabib:${DB_PASSWORD}@db:5432/mediabib
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    restart: unless-stopped

  celery-beat:
    build: .
    command: celery -A app beat -l INFO --scheduler django_celery_beat.schedulers:DatabaseScheduler
    environment:
      - DATABASE_URL=postgres://mediabib:${DB_PASSWORD}@db:5432/mediabib
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=mediabib
      - POSTGRES_USER=mediabib
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mediabib"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - static_volume:/app/static:ro
      - media_volume:/app/media:ro
      - ./certbot/conf:/etc/letsencrypt:ro
    depends_on:
      - web
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  static_volume:
  media_volume:
```

### Pipeline CI/CD

```mermaid
flowchart LR
    subgraph "Development"
        A[Git Push] --> B[GitHub Actions]
    end

    subgraph "CI Pipeline"
        B --> C[Lint - Ruff/Black]
        C --> D[Tests - pytest]
        D --> E[Coverage > 80%]
        E --> F[Security - Bandit]
        F --> G[Build Docker]
    end

    subgraph "CD Pipeline"
        G --> H{Branch?}
        H -->|develop| I[Deploy Staging]
        H -->|main| J[Deploy Production]
        I --> K[Smoke Tests]
        J --> L[Smoke Tests]
        K --> M[Notify Slack]
        L --> M
    end
```

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7-alpine

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install ruff pytest-cov bandit
          
      - name: Lint with Ruff
        run: ruff check .
        
      - name: Run tests
        run: pytest --cov=. --cov-report=xml
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost/test
          
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        
      - name: Security scan
        run: bandit -r . -ll

  deploy-staging:
    needs: test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to staging
        run: |
          # Deploy commands

  deploy-production:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production
        run: |
          # Deploy commands
```

---

## Scalabilité

### Stratégie de scaling horizontal

```mermaid
flowchart TB
    subgraph "Load Balancer"
        LB[HAProxy / Nginx]
    end

    subgraph "Web Tier - Stateless"
        WEB1[Web Server 1]
        WEB2[Web Server 2]
        WEB3[Web Server 3]
        WEBN[Web Server N]
    end

    subgraph "Worker Tier"
        W1[Celery Worker 1]
        W2[Celery Worker 2]
        WN[Celery Worker N]
    end

    subgraph "Data Tier"
        subgraph "Primary"
            PG1[(PostgreSQL Primary)]
        end
        subgraph "Read Replicas"
            PG2[(Replica 1)]
            PG3[(Replica 2)]
        end
        subgraph "Cache Cluster"
            R1[(Redis 1)]
            R2[(Redis 2)]
            R3[(Redis 3)]
        end
    end

    LB --> WEB1
    LB --> WEB2
    LB --> WEB3
    LB --> WEBN

    WEB1 --> PG1
    WEB2 --> PG2
    WEB3 --> PG3
    
    WEB1 --> R1
    WEB2 --> R2
    WEB3 --> R3

    W1 --> PG1
    W2 --> PG1
    WN --> PG1

    PG1 --> PG2
    PG1 --> PG3
```

### Métriques de dimensionnement

| Charge | Web Servers | Celery Workers | PostgreSQL | Redis |
|--------|-------------|----------------|------------|-------|
| **Petite** (<1000 lecteurs) | 1 | 1 | 1 (2 CPU, 4GB) | 1 (1GB) |
| **Moyenne** (1k-10k) | 2-3 | 2 | 1+replica (4 CPU, 8GB) | 1 (2GB) |
| **Grande** (10k-50k) | 4-6 | 4-6 | 1+2 replicas (8 CPU, 16GB) | Cluster 3 nodes |
| **Très grande** (50k+) | 8+ | 8+ | 1+3 replicas (16 CPU, 32GB) | Cluster 6 nodes |

### Configuration pour haute disponibilité

```python
# settings/production.py

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'mediabib',
        'HOST': 'pg-primary.internal',
        'PORT': '5432',
        'CONN_MAX_AGE': 60,
        'OPTIONS': {
            'connect_timeout': 10,
        },
    },
    'replica': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'mediabib',
        'HOST': 'pg-replica.internal',
        'PORT': '5432',
        'CONN_MAX_AGE': 60,
    },
}

# Router pour lecture sur replica
DATABASE_ROUTERS = ['core.routers.PrimaryReplicaRouter']

# Celery avec Redis Cluster
CELERY_BROKER_URL = 'redis://redis-cluster.internal:6379/0'
CELERY_RESULT_BACKEND = 'redis://redis-cluster.internal:6379/1'

# Sessions sur Redis
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'sessions'
```

---

## Normes et standards de développement

### Structure de code

```
mediabib/
├── app/                          # Configuration Django
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py              # Settings communs
│   │   ├── development.py
│   │   ├── staging.py
│   │   └── production.py
│   ├── urls.py
│   └── celery.py
│
├── core/                         # Application core
│   ├── models/
│   │   ├── __init__.py
│   │   ├── base.py              # BaseModel avec UUID, timestamps
│   │   └── user.py
│   ├── services/                # Business logic
│   │   └── __init__.py
│   ├── views/
│   ├── serializers/
│   ├── permissions.py
│   ├── exceptions.py
│   ├── utils.py
│   └── tests/
│       ├── __init__.py
│       ├── test_models.py
│       ├── test_services.py
│       └── test_api.py
│
├── catalog/                      # Même structure
├── circulation/
├── ...
│
├── templates/
│   ├── base.html
│   └── components/
│
├── static/
│   ├── css/
│   ├── js/
│   └── img/
│
├── locale/                       # Traductions
│   └── fr/
│
├── docs/
├── scripts/
├── docker/
├── .github/
├── manage.py
├── pyproject.toml
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   └── production.txt
└── README.md
```

### Conventions de code

```python
# pyproject.toml
[tool.ruff]
line-length = 100
target-version = "py312"
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # Pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "DJ",  # flake8-django
]
ignore = ["E501"]

[tool.ruff.isort]
known-first-party = ["core", "catalog", "circulation", "patrons"]

[tool.black]
line-length = 100
target-version = ['py312']

[tool.mypy]
python_version = "3.12"
plugins = ["mypy_django_plugin.main"]
strict = true

[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "app.settings.test"
python_files = ["test_*.py"]
addopts = "-v --tb=short"
```

### Modèle de base

```python
# core/models/base.py
import uuid
from django.db import models

class BaseModel(models.Model):
    """Modèle de base avec UUID et timestamps."""
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        abstract = True
        ordering = ['-created_at']


class SoftDeleteModel(BaseModel):
    """Modèle avec suppression logique."""
    
    deleted_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        abstract = True
    
    def delete(self, *args, **kwargs):
        self.deleted_at = timezone.now()
        self.save(update_fields=['deleted_at'])
    
    def hard_delete(self, *args, **kwargs):
        super().delete(*args, **kwargs)


class AuditModel(BaseModel):
    """Modèle avec audit trail."""
    
    created_by = models.ForeignKey(
        'core.StaffUser',
        on_delete=models.SET_NULL,
        null=True,
        related_name='+'
    )
    updated_by = models.ForeignKey(
        'core.StaffUser',
        on_delete=models.SET_NULL,
        null=True,
        related_name='+'
    )
    
    class Meta:
        abstract = True
```

---

## Tests et qualité

### Stratégie de tests

```mermaid
pyramid
    title Pyramide de tests
    "E2E" : 10
    "Integration" : 30
    "Unit" : 60
```

| Type | Couverture | Outils |
|------|------------|--------|
| **Unitaires** | 80%+ | pytest, factory_boy |
| **Intégration** | 60%+ | pytest-django |
| **API** | 100% endpoints | DRF test client |
| **E2E** | Parcours critiques | Playwright |

### Exemple de tests

```python
# circulation/tests/test_checkout.py
import pytest
from datetime import date, timedelta
from django.utils import timezone
from circulation.services import CheckoutService
from circulation.exceptions import CheckoutError

@pytest.fixture
def patron(db):
    return PatronFactory(is_blocked=False, expiry_date=date.today() + timedelta(days=30))

@pytest.fixture
def available_item(db):
    return ItemFactory(status='available')

@pytest.fixture
def checkout_service():
    return CheckoutService()


class TestCheckoutService:
    """Tests du service de prêt."""
    
    def test_checkout_success(self, checkout_service, patron, available_item):
        """Un prêt valide doit créer un Loan."""
        loan = checkout_service.checkout(patron, available_item)
        
        assert loan.id is not None
        assert loan.patron == patron
        assert loan.item == available_item
        assert loan.status == 'active'
        assert available_item.status == 'on_loan'
    
    def test_checkout_blocked_patron(self, checkout_service, available_item):
        """Un lecteur bloqué ne peut pas emprunter."""
        blocked_patron = PatronFactory(is_blocked=True)
        
        with pytest.raises(CheckoutError) as exc:
            checkout_service.checkout(blocked_patron, available_item)
        
        assert "bloqué" in str(exc.value)
    
    def test_checkout_unavailable_item(self, checkout_service, patron):
        """Un exemplaire non disponible ne peut pas être prêté."""
        on_loan_item = ItemFactory(status='on_loan')
        
        with pytest.raises(CheckoutError) as exc:
            checkout_service.checkout(patron, on_loan_item)
        
        assert "non disponible" in str(exc.value)
    
    def test_checkout_max_loans_reached(self, checkout_service, patron, available_item):
        """Impossible de dépasser le quota de prêts."""
        # Créer le maximum de prêts
        for _ in range(patron.category.max_loans):
            LoanFactory(patron=patron, status='active')
        
        with pytest.raises(CheckoutError) as exc:
            checkout_service.checkout(patron, available_item)
        
        assert "quota" in str(exc.value).lower()


# tests/factories.py
import factory
from factory.django import DjangoModelFactory

class PatronFactory(DjangoModelFactory):
    class Meta:
        model = 'patrons.Patron'
    
    barcode = factory.Sequence(lambda n: f'P{n:08d}')
    last_name = factory.Faker('last_name')
    first_name = factory.Faker('first_name')
    email = factory.Faker('email')
    expiry_date = factory.LazyFunction(
        lambda: date.today() + timedelta(days=365)
    )
    is_blocked = False


class ItemFactory(DjangoModelFactory):
    class Meta:
        model = 'items.Item'
    
    barcode = factory.Sequence(lambda n: f'I{n:012d}')
    record = factory.SubFactory('tests.factories.RecordFactory')
    library = factory.SubFactory('tests.factories.LibraryFactory')
    status = 'available'
```

---

## Monitoring et observabilité

### Stack de monitoring

```mermaid
flowchart TB
    subgraph "Application"
        APP[Django App]
        CELERY[Celery Workers]
    end

    subgraph "Collection"
        PROM[Prometheus]
        LOKI[Loki]
        JAEGER[Jaeger]
    end

    subgraph "Visualization"
        GRAFANA[Grafana]
    end

    subgraph "Alerting"
        ALERT[Alertmanager]
        SENTRY[Sentry]
        PD[PagerDuty/Slack]
    end

    APP -->|metrics| PROM
    APP -->|logs| LOKI
    APP -->|traces| JAEGER
    APP -->|errors| SENTRY
    CELERY -->|metrics| PROM
    CELERY -->|logs| LOKI

    PROM --> GRAFANA
    LOKI --> GRAFANA
    JAEGER --> GRAFANA

    PROM --> ALERT
    ALERT --> PD
    SENTRY --> PD
```

### Métriques clés

| Catégorie | Métrique | Seuil alerte |
|-----------|----------|--------------|
| **Latence** | p99 response time | > 500ms |
| **Erreurs** | Error rate | > 1% |
| **Saturation** | CPU usage | > 80% |
| **Saturation** | Memory usage | > 85% |
| **Database** | Connection pool | > 90% |
| **Database** | Query duration p99 | > 100ms |
| **Cache** | Hit rate | < 80% |
| **Queue** | Pending tasks | > 1000 |
| **Business** | Prêts/heure | Anomalie |
| **Business** | Erreurs SIP2 | > 5/min |

### Configuration Prometheus

```python
# core/middleware/metrics.py
from prometheus_client import Counter, Histogram

REQUEST_COUNT = Counter(
    'django_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'django_http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint'],
    buckets=[.01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10]
)

LOAN_COUNT = Counter(
    'mediabib_loans_total',
    'Total loans processed',
    ['library', 'type']
)

class PrometheusMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        start_time = time.time()
        response = self.get_response(request)
        
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            status=response.status_code
        ).inc()
        
        REQUEST_LATENCY.labels(
            method=request.method,
            endpoint=request.path
        ).observe(time.time() - start_time)
        
        return response
```

---

## Exigences matérielles

### Configuration minimale (développement)

| Composant | Minimum | Recommandé |
|-----------|---------|------------|
| CPU | 2 cores | 4 cores |
| RAM | 4 GB | 8 GB |
| Stockage | 20 GB SSD | 50 GB SSD |
| OS | Ubuntu 22.04 / Windows 11 | Ubuntu 22.04 |

### Configuration production (petite structure)

| Serveur | vCPU | RAM | Stockage | Rôle |
|---------|------|-----|----------|------|
| App Server | 4 | 8 GB | 50 GB SSD | Django + Celery |
| Database | 4 | 16 GB | 200 GB SSD | PostgreSQL |
| Cache | 2 | 4 GB | 20 GB SSD | Redis |

### Configuration production (réseau de bibliothèques)

| Serveur | Qty | vCPU | RAM | Stockage | Rôle |
|---------|-----|------|-----|----------|------|
| Load Balancer | 2 | 2 | 2 GB | 20 GB | HAProxy/Nginx |
| App Server | 3+ | 4 | 8 GB | 50 GB | Django |
| Worker Server | 2+ | 4 | 8 GB | 50 GB | Celery |
| DB Primary | 1 | 8 | 32 GB | 500 GB NVMe | PostgreSQL |
| DB Replica | 2 | 4 | 16 GB | 500 GB SSD | PostgreSQL Replica |
| Cache Cluster | 3 | 2 | 8 GB | 20 GB | Redis Cluster |
| Search | 3 | 4 | 16 GB | 200 GB SSD | Elasticsearch |
| Storage | 1 | 2 | 4 GB | 1 TB | MinIO/S3 |

### Estimation bande passante

| Usage | Bande passante |
|-------|----------------|
| OPAC (1000 req/h) | ~10 Mbps |
| Staff (100 users) | ~5 Mbps |
| Automates (10) | ~2 Mbps |
| Backups | ~50 Mbps (nuit) |
| **Total recommandé** | **100 Mbps symétrique** |

---

## Annexes

### Checklist de déploiement

- [ ] Variables d'environnement configurées
- [ ] Base de données migrée
- [ ] Fichiers statiques collectés
- [ ] Certificat SSL installé
- [ ] Backup configuré
- [ ] Monitoring actif
- [ ] Logs centralisés
- [ ] Alertes configurées
- [ ] Tests de charge effectués
- [ ] Documentation à jour
- [ ] Rollback testé

### Variables d'environnement requises

```bash
# Application
SECRET_KEY=
DEBUG=False
ALLOWED_HOSTS=

# Database
DATABASE_URL=postgres://user:pass@host:5432/db

# Redis
REDIS_URL=redis://host:6379/0
CELERY_BROKER_URL=redis://host:6379/1

# Email
EMAIL_HOST=
EMAIL_PORT=
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=

# Sentry (monitoring)
SENTRY_DSN=

# S3 Storage
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_STORAGE_BUCKET_NAME=

# Z39.50
BNF_Z3950_HOST=z3950.bnf.fr
BNF_Z3950_PORT=2211

# SIP2
SIP2_ENABLED=True
SIP2_PORT=6001
```

---

*Document technique MediaBib - Version 1.0*
*Décembre 2024*







