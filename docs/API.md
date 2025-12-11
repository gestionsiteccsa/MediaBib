# Documentation API

Documentation de l'API REST de MediaBib.

> **Note** : L'API REST sera implémentée dans une version future avec Django REST Framework.

---

## Vue d'ensemble

L'API MediaBib permet d'interagir avec le système de gestion de bibliothèque de manière programmatique. Elle est **principalement destinée au front-end OPAC** (portail public), mais peut également être utilisée pour créer des applications personnalisées ou des intégrations tierces.

### Architecture API

MediaBib expose deux types d'endpoints :

1. **Endpoints OPAC (Public)** : Accessibles aux visiteurs et lecteurs pour le portail public
2. **Endpoints Admin (Privés)** : Réservés aux bibliothécaires et administrateurs pour la gestion du système

### Base URL

```
https://votre-instance.com/api/v1/
```

**Endpoints OPAC** :
```
https://votre-instance.com/api/v1/opac/
```

**Endpoints Admin** :
```
https://votre-instance.com/api/v1/admin/
```

**```

### Authentification

L'API utilise **deux méthodes d'authentification** selon le contexte :

#### 1. Authentification OPAC (Front-end public)

**Méthode** : JWT (JSON Web Tokens) pour les lecteurs

**Obtenir un token pour un lecteur** :

```http
POST /api/v1/opac/auth/login/
Content-Type: application/json

{
    "email": "lecteur@example.com",
    "password": "mot_de_passe"
}
```

**Réponse :**

```json
{
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
        "id": 42,
        "email": "lecteur@example.com",
        "first_name": "Marie",
        "last_name": "Dupont"
    }
}
```

**Utiliser le token** :

```http
GET /api/v1/opac/loans/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

#### 2. Authentification Admin (Back-end)

**Méthode** : Sessions Django (cookies) pour les bibliothécaires

Les endpoints admin utilisent l'authentification Django classique avec sessions. L'accès se fait via l'interface web d'administration.

**Note** : Les endpoints admin peuvent également supporter l'authentification JWT pour les intégrations tierces (API keys).

---

## Endpoints

### Import/Export

#### Import PMB XML UNIMARC

Import de notices et exemplaires depuis PMB au format XML UNIMARC.

```http
POST /api/v1/catalog/import/pmb/
Content-Type: multipart/form-data
Authorization: Bearer {token}

{
    "file": <fichier_xml>,
    "library_id": 1,
    "options": {
        "detect_duplicates": true,
        "preserve_barcodes": true,
        "generate_barcodes": true
    }
}
```

**Paramètres :**
- `file` (requis) : Fichier XML UNIMARC exporté depuis PMB
- `library_id` (requis) : ID de la médiathèque cible dans MediaBib
- `options` (optionnel) :
  - `detect_duplicates` : Détection de doublons par ISBN (défaut: true)
  - `preserve_barcodes` : Conservation des codes-barres PMB (défaut: true)
  - `generate_barcodes` : Génération automatique si absent (défaut: true)

**Réponse :**

```json
{
    "status": "success",
    "import_id": 123,
    "statistics": {
        "notices_processed": 500,
        "notices_created": 380,
        "notices_enriched": 120,
        "items_added": 850,
        "authorities_created": 250,
        "errors": 5
    },
    "errors": [
        {
            "notice_index": 123,
            "isbn": "9781234567890",
            "error": "ISBN invalide"
        }
    ]
}
```

**Logique de traitement :**
- Pour chaque notice dans le fichier XML :
  - Extraction de l'ISBN (champ UNIMARC 010$a)
  - Recherche de notice existante par ISBN
  - Si trouvée : ajout des exemplaires uniquement à la médiathèque cible
  - Si non trouvée : création complète de la notice + exemplaires

#### Statut d'import

Consulter le statut d'un import en cours ou terminé.

```http
GET /api/v1/catalog/import/{import_id}/
Authorization: Bearer {token}
```

**Réponse :**

```json
{
    "import_id": 123,
    "status": "completed",
    "progress": 100,
    "statistics": {
        "notices_processed": 500,
        "notices_created": 380,
        "notices_enriched": 120,
        "items_added": 850,
        "errors": 5
    },
    "started_at": "2024-12-15T10:00:00Z",
    "completed_at": "2024-12-15T10:05:30Z"
}
```

#### Export multi-formats

Export de notices et exemplaires dans différents formats.

```http
POST /api/v1/catalog/export/
Content-Type: application/json
Authorization: Bearer {token}

{
    "format": "xml_unimarc",
    "library_ids": [1, 2, 3],
    "filters": {
        "record_type": "book",
        "date_from": "2024-01-01",
        "date_to": "2024-12-31"
    },
    "options": {
        "include_items": true,
        "include_authorities": true
    }
}
```

**Paramètres :**
- `format` (requis) : Format d'export (`xml_unimarc`, `csv`, `json`, `iso2709`)
- `library_ids` (optionnel) : Liste des IDs de médiathèques à exporter (toutes si omis)
- `filters` (optionnel) :
  - `record_type` : Type de document (book, cd, dvd, etc.)
  - `date_from` / `date_to` : Période de création des notices
  - `availability` : Disponibilité (available, loaned, reserved)
- `options` (optionnel) :
  - `include_items` : Inclure les exemplaires (défaut: true)
  - `include_authorities` : Inclure les autorités (défaut: true)

**Réponse :**

```json
{
    "status": "processing",
    "export_id": 456,
    "download_url": "/api/v1/catalog/export/456/download/",
    "estimated_time": 120
}
```

**Téléchargement du fichier :**

```http
GET /api/v1/catalog/export/{export_id}/download/
Authorization: Bearer {token}
```

Retourne le fichier d'export dans le format demandé.

---

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

## Front-end personnalisé

MediaBib fournit un **squelette de base** pour le front-end OPAC (Django Templates + JavaScript), mais vous pouvez créer votre propre front-end avec n'importe quelle technologie en utilisant uniquement l'API REST.

### Technologies supportées

Vous pouvez créer votre front-end avec :

- **Frameworks JavaScript** : React, Vue.js, Angular, Svelte, Next.js, Nuxt.js
- **Frameworks CSS** : Tailwind CSS, Bootstrap, Material-UI, Chakra UI
- **Langages** : TypeScript, JavaScript (ES6+)
- **Outils de build** : Webpack, Vite, Parcel, Rollup
- **Applications mobiles** : React Native, Flutter, Ionic

### Exemple d'intégration React

```jsx
// components/Search.jsx
import React, { useState } from 'react';
import { searchRecords } from '../services/api';

function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleSearch = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const data = await searchRecords(query);
      setResults(data.results);
    } catch (error) {
      console.error('Erreur de recherche:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSearch}>
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Rechercher dans le catalogue..."
      />
      <button type="submit" disabled={loading}>
        {loading ? 'Recherche...' : 'Rechercher'}
      </button>
      <ul>
        {results.map(record => (
          <li key={record.id}>
            <h3>{record.title}</h3>
            <p>{record.author}</p>
          </li>
        ))}
      </ul>
    </form>
  );
}
```

### Exemple d'intégration Vue.js

```vue
<!-- components/Search.vue -->
<template>
  <form @submit.prevent="handleSearch">
    <input
      v-model="query"
      type="text"
      placeholder="Rechercher dans le catalogue..."
    />
    <button type="submit" :disabled="loading">
      {{ loading ? 'Recherche...' : 'Rechercher' }}
    </button>
    <ul>
      <li v-for="record in results" :key="record.id">
        <h3>{{ record.title }}</h3>
        <p>{{ record.author }}</p>
      </li>
    </ul>
  </form>
</template>

<script>
import { searchRecords } from '@/services/api';

export default {
  data() {
    return {
      query: '',
      results: [],
      loading: false
    };
  },
  methods: {
    async handleSearch() {
      this.loading = true;
      try {
        const data = await searchRecords(this.query);
        this.results = data.results;
      } catch (error) {
        console.error('Erreur de recherche:', error);
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>
```

### Client API réutilisable

```javascript
// services/api.js
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://mediabib.example.com/api/v1/opac';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Intercepteur pour ajouter le token JWT
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('jwt_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Gestion des erreurs
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expiré, rediriger vers la page de connexion
      localStorage.removeItem('jwt_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Fonctions API
export const searchRecords = (query, filters = {}) => {
  return apiClient.get('/search/', {
    params: { q: query, ...filters }
  }).then(res => res.data);
};

export const getRecord = (id) => {
  return apiClient.get(`/records/${id}/`).then(res => res.data);
};

export const login = (email, password) => {
  return apiClient.post('/auth/login/', {
    email,
    password
  }).then(res => {
    localStorage.setItem('jwt_token', res.data.access);
    return res.data;
  });
};

export const getCurrentLoans = () => {
  return apiClient.get('/loans/').then(res => res.data);
};

export const createHold = (recordId) => {
  return apiClient.post('/holds/', {
    record_id: recordId
  }).then(res => res.data);
};

export const renewLoan = (loanId) => {
  return apiClient.post(`/loans/${loanId}/renew/`).then(res => res.data);
};
```

### Configuration CORS

Pour permettre les requêtes depuis un front-end personnalisé, configurez CORS dans Django :

```python
# settings.py
CORS_ALLOWED_ORIGINS = [
    "https://votre-frontend.com",
    "http://localhost:3000",  # Développement
]

CORS_ALLOW_CREDENTIALS = True
```

### Documentation OpenAPI/Swagger

La documentation complète de l'API est disponible au format OpenAPI :

```
GET /api/schema/
```

Cela permet de générer automatiquement des clients API pour différents langages et frameworks.

### Bonnes pratiques

1. **Gestion des tokens** : Stocker le JWT de manière sécurisée (localStorage ou httpOnly cookies)
2. **Refresh token** : Implémenter le renouvellement automatique du token
3. **Gestion des erreurs** : Gérer les erreurs 401, 403, 404, 500 de manière appropriée
4. **Cache** : Mettre en cache les données statiques (notices, bibliothèques)
5. **Pagination** : Gérer correctement la pagination pour les grandes listes
6. **Accessibilité** : Respecter WCAG 2.1 AA dans votre front-end personnalisé

---

## Support

- Documentation Swagger : `/api/docs/`
- Schéma OpenAPI : `/api/schema/`
- Contact : api@example.com

