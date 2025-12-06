# Documentation API

Documentation de l'API REST de MediaBib.

> **Note** : L'API REST sera implémentée dans une version future avec Django REST Framework.

---

## Vue d'ensemble

L'API MediaBib permet d'interagir avec le système de gestion de bibliothèque de manière programmatique.

### Base URL

```
https://votre-instance.com/api/v1/
```

### Authentification

L'API utilise l'authentification JWT (JSON Web Tokens).

#### Obtenir un token

```http
POST /api/v1/auth/token/
Content-Type: application/json

{
    "username": "votre_utilisateur",
    "password": "votre_mot_de_passe"
}
```

**Réponse :**

```json
{
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### Utiliser le token

```http
GET /api/v1/documents/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

---

## Endpoints

### Documents

#### Liste des documents

```http
GET /api/v1/documents/
```

**Paramètres de requête :**

| Paramètre | Type | Description |
|-----------|------|-------------|
| `search` | string | Recherche dans le titre et l'auteur |
| `type` | string | Filtrer par type (book, dvd, cd) |
| `page` | integer | Numéro de page (défaut: 1) |
| `page_size` | integer | Éléments par page (défaut: 25, max: 100) |

**Exemple de réponse :**

```json
{
    "count": 150,
    "next": "https://api.example.com/api/v1/documents/?page=2",
    "previous": null,
    "results": [
        {
            "id": 1,
            "title": "Le Petit Prince",
            "author": "Antoine de Saint-Exupéry",
            "isbn": "978-2-07-040850-4",
            "type": "book",
            "available": true,
            "created_at": "2024-01-15T10:30:00Z"
        }
    ]
}
```

#### Détail d'un document

```http
GET /api/v1/documents/{id}/
```

**Exemple de réponse :**

```json
{
    "id": 1,
    "title": "Le Petit Prince",
    "author": "Antoine de Saint-Exupéry",
    "isbn": "978-2-07-040850-4",
    "publisher": "Gallimard",
    "publication_date": "1943",
    "type": "book",
    "description": "Un conte philosophique...",
    "items": [
        {
            "id": 101,
            "barcode": "BIB001234",
            "location": "Rayon Jeunesse",
            "status": "available"
        }
    ],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-20T14:00:00Z"
}
```

#### Créer un document

```http
POST /api/v1/documents/
Content-Type: application/json
Authorization: Bearer {token}

{
    "title": "Nouveau livre",
    "author": "Auteur",
    "isbn": "978-0-123456-78-9",
    "type": "book"
}
```

#### Modifier un document

```http
PATCH /api/v1/documents/{id}/
Content-Type: application/json
Authorization: Bearer {token}

{
    "title": "Titre modifié"
}
```

#### Supprimer un document

```http
DELETE /api/v1/documents/{id}/
Authorization: Bearer {token}
```

---

### Lecteurs

#### Liste des lecteurs

```http
GET /api/v1/readers/
Authorization: Bearer {token}
```

**Paramètres de requête :**

| Paramètre | Type | Description |
|-----------|------|-------------|
| `search` | string | Recherche par nom ou email |
| `category` | string | Filtrer par catégorie |
| `active` | boolean | Abonnement actif |

#### Détail d'un lecteur

```http
GET /api/v1/readers/{id}/
Authorization: Bearer {token}
```

**Exemple de réponse :**

```json
{
    "id": 42,
    "card_number": "LEC-2024-0042",
    "first_name": "Marie",
    "last_name": "Dupont",
    "email": "marie.dupont@example.com",
    "category": "adult",
    "subscription": {
        "type": "annual",
        "start_date": "2024-01-01",
        "end_date": "2024-12-31",
        "active": true
    },
    "current_loans": 3,
    "max_loans": 10
}
```

---

### Prêts

#### Liste des prêts

```http
GET /api/v1/loans/
Authorization: Bearer {token}
```

**Paramètres :**

| Paramètre | Type | Description |
|-----------|------|-------------|
| `reader` | integer | ID du lecteur |
| `status` | string | active, returned, overdue |

#### Créer un prêt

```http
POST /api/v1/loans/
Content-Type: application/json
Authorization: Bearer {token}

{
    "reader_id": 42,
    "item_barcode": "BIB001234"
}
```

**Réponse :**

```json
{
    "id": 1001,
    "reader": {
        "id": 42,
        "name": "Marie Dupont"
    },
    "item": {
        "id": 101,
        "barcode": "BIB001234",
        "title": "Le Petit Prince"
    },
    "loan_date": "2024-12-06T10:00:00Z",
    "due_date": "2024-12-20T23:59:59Z",
    "status": "active"
}
```

#### Retourner un prêt

```http
POST /api/v1/loans/{id}/return/
Authorization: Bearer {token}
```

---

### Réservations

#### Liste des réservations

```http
GET /api/v1/reservations/
Authorization: Bearer {token}
```

#### Créer une réservation

```http
POST /api/v1/reservations/
Content-Type: application/json
Authorization: Bearer {token}

{
    "reader_id": 42,
    "document_id": 1
}
```

#### Annuler une réservation

```http
DELETE /api/v1/reservations/{id}/
Authorization: Bearer {token}
```

---

## Codes d'erreur

| Code | Description |
|------|-------------|
| 200 | Succès |
| 201 | Ressource créée |
| 204 | Suppression réussie |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Accès refusé |
| 404 | Ressource non trouvée |
| 422 | Erreur de validation |
| 429 | Trop de requêtes (rate limit) |
| 500 | Erreur serveur |

### Format des erreurs

```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Les données fournies sont invalides",
        "details": {
            "isbn": ["Ce champ est requis."]
        }
    }
}
```

---

## Rate Limiting

L'API limite le nombre de requêtes :

| Type | Limite |
|------|--------|
| Anonyme | 100 requêtes/heure |
| Authentifié | 1000 requêtes/heure |
| Admin | 5000 requêtes/heure |

Headers de réponse :

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1699286400
```

---

## Pagination

Toutes les listes sont paginées par défaut.

```json
{
    "count": 150,
    "next": "https://api.example.com/api/v1/documents/?page=2",
    "previous": null,
    "results": [...]
}
```

---

## Filtres et recherche

### Recherche

```http
GET /api/v1/documents/?search=python
```

### Filtres multiples

```http
GET /api/v1/documents/?type=book&available=true
```

### Tri

```http
GET /api/v1/documents/?ordering=-created_at
GET /api/v1/documents/?ordering=title
```

---

## Webhooks (Futur)

Les webhooks permettront de recevoir des notifications en temps réel.

### Événements disponibles

| Événement | Description |
|-----------|-------------|
| `loan.created` | Nouveau prêt |
| `loan.returned` | Retour effectué |
| `loan.overdue` | Prêt en retard |
| `reservation.available` | Document disponible |

---

## SDKs et exemples

### Python

```python
import requests

API_URL = "https://mediabib.example.com/api/v1"
TOKEN = "votre_token"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

# Rechercher des documents
response = requests.get(
    f"{API_URL}/documents/",
    params={"search": "python"},
    headers=headers
)
documents = response.json()["results"]
```

### JavaScript

```javascript
const API_URL = 'https://mediabib.example.com/api/v1';
const TOKEN = 'votre_token';

// Rechercher des documents
const response = await fetch(`${API_URL}/documents/?search=python`, {
    headers: {
        'Authorization': `Bearer ${TOKEN}`,
        'Content-Type': 'application/json'
    }
});
const data = await response.json();
```

---

## Support

- Documentation Swagger : `/api/docs/`
- Contact : api@example.com

