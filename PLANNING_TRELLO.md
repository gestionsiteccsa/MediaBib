# 📋 Planning Trello - MediaBib

**Projet** : Clone de PMB - Système Intégré de Gestion de Bibliothèque  
**Date de création** : Décembre 2024  
**Durée estimée totale** : 6-9 mois

---

## 🏗️ LISTE 1 : Infrastructure & Configuration

### 📦 Carte 1.1 : Configuration Base de Données
**Étiquettes** : `backend`, `base de données`, `priorité haute`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Installer et configurer PostgreSQL
- [ ] Créer le schéma de base de données
- [ ] Configurer les backups automatiques
- [ ] Mettre en place les index de performance
- [ ] Documenter la stratégie de migration

---

### 📦 Carte 1.2 : Configuration CI/CD
**Étiquettes** : `devops`, `automatisation`, `priorité haute`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Créer le fichier `.github/workflows/ci.yml`
- [ ] Configurer les tests automatiques sur chaque PR
- [ ] Ajouter le linting (flake8, black, isort)
- [ ] Configurer la vérification de couverture de code (minimum 80%)
- [ ] Ajouter les tests d'accessibilité automatisés (pa11y)
- [ ] Configurer le déploiement automatique (staging/production)

---

### 📦 Carte 1.3 : Structure des Applications Django
**Étiquettes** : `backend`, `architecture`, `priorité haute`  
**Durée estimée** : 2-3 jours

**Sous-tâches :**
- [ ] Créer l'application `accounts` (utilisateurs)
- [ ] Créer l'application `catalog` (notices/exemplaires)
- [ ] Créer l'application `circulation` (prêts/retours)
- [ ] Créer l'application `readers` (lecteurs/abonnés)
- [ ] Créer l'application `acquisitions` (commandes/budgets)
- [ ] Créer l'application `periodicals` (périodiques)
- [ ] Créer l'application `opac` (catalogue public)
- [ ] Créer l'application `reports` (statistiques)
- [ ] Créer l'application `sites` (multi-sites)

---

## 🔐 LISTE 2 : Authentification & Autorisation

### 📦 Carte 2.1 : Système de Connexion
**Étiquettes** : `backend`, `sécurité`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le modèle `CustomUser` héritant de `AbstractUser`
- [ ] Ajouter le champ `role` (admin, bibliothécaire, lecteur)
- [ ] Implémenter la page de login avec validation
  - Minimum 3 caractères pour l'identifiant
  - Minimum 8 caractères pour le mot de passe
  - Message d'erreur accessible (role="alert")
- [ ] Ajouter le formulaire "Mot de passe oublié"
- [ ] Implémenter la vérification par email
- [ ] Ajouter la déconnexion avec confirmation
- [ ] Créer les tests unitaires pour chaque cas

---

### 📦 Carte 2.2 : Sécurité Authentification
**Étiquettes** : `backend`, `sécurité`, `priorité haute`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Installer et configurer `django-axes` (blocage après 5 tentatives)
- [ ] Implémenter le rate limiting (5 tentatives / 15 minutes)
- [ ] Ajouter les logs de connexion (succès/échec)
- [ ] Configurer l'expiration de session (30 min d'inactivité)
- [ ] Implémenter la double authentification optionnelle (django-otp)
- [ ] Créer les tests de sécurité

---

### 📦 Carte 2.3 : Gestion des Rôles et Permissions
**Étiquettes** : `backend`, `sécurité`, `priorité moyenne`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Définir les groupes : Admin, Bibliothécaire, Lecteur
- [ ] Créer les permissions par module
- [ ] Implémenter les décorateurs de vérification d'accès
- [ ] Créer le middleware de vérification des droits
- [ ] Ajouter l'interface d'administration des rôles
- [ ] Créer les tests d'autorisation

---

## 📚 LISTE 3 : Module Catalogue

### 📦 Carte 3.1 : Modèle Notice Bibliographique (UNIMARC)
**Étiquettes** : `backend`, `métier`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le modèle `BibliographicRecord` avec champs UNIMARC
  - Titre (200$a) - obligatoire, max 500 caractères
  - Auteur(s) (700/701/702)
  - ISBN/ISSN (010/011)
  - Éditeur (210$c)
  - Date de publication (210$d)
  - Type de document (sélection)
- [ ] Créer le modèle `Authority` (auteurs, sujets, éditeurs)
- [ ] Créer le modèle `Item` (exemplaires physiques)
- [ ] Implémenter les relations many-to-many
- [ ] Ajouter les validations métier
- [ ] Créer les tests des modèles

---

### 📦 Carte 3.2 : Interface de Catalogage
**Étiquettes** : `frontend`, `backend`, `priorité haute`  
**Durée estimée** : 7-10 jours

**Sous-tâches :**
- [ ] Créer le formulaire de création de notice
- [ ] Implémenter la validation côté client (JavaScript accessible)
- [ ] Ajouter l'autocomplétion pour les autorités
- [ ] Créer l'interface de modification
- [ ] Implémenter la suppression avec confirmation
- [ ] Ajouter le mode d'édition rapide (inline editing)
- [ ] Créer les tests d'interface

---

### 📦 Carte 3.3 : Recherche et Filtrage
**Étiquettes** : `backend`, `frontend`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Implémenter la recherche simple (tous champs)
- [ ] Créer la recherche avancée (par champ)
- [ ] Ajouter les filtres (type, date, disponibilité)
- [ ] Implémenter la pagination accessible
- [ ] Optimiser les requêtes avec `select_related`/`prefetch_related`
- [ ] Ajouter l'export des résultats (CSV, Excel)
- [ ] Créer les tests de recherche

---

### 📦 Carte 3.4 : Import/Export de Données
**Étiquettes** : `backend`, `métier`, `priorité moyenne`  
**Durée estimée** : 7-10 jours

**Sous-tâches :**
- [ ] Créer l'import UNIMARC (ISO 2709)
- [ ] Implémenter l'import depuis PMB (SQL)
- [ ] Ajouter l'export UNIMARC
- [ ] Créer l'import/export CSV
- [ ] Implémenter la gestion des doublons
- [ ] Ajouter les rapports d'import
- [ ] Créer les tests d'import/export

---

## 🔄 LISTE 4 : Module Circulation

### 📦 Carte 4.1 : Gestion des Prêts
**Étiquettes** : `backend`, `métier`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le modèle `Loan` (prêt)
  - Lecteur (FK)
  - Exemplaire (FK)
  - Date de prêt (auto)
  - Date de retour prévue (calculée)
  - Date de retour effective
  - Statut (en cours, retourné, en retard)
- [ ] Implémenter les règles de prêt par catégorie
- [ ] Créer le formulaire de prêt (scan code-barres)
- [ ] Ajouter les notifications de rappel
- [ ] Créer les tests du module prêt

---

### 📦 Carte 4.2 : Gestion des Retours
**Étiquettes** : `backend`, `métier`, `priorité haute`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Créer le formulaire de retour
- [ ] Implémenter le calcul automatique des retards
- [ ] Ajouter la gestion des amendes
- [ ] Créer le système de quittance
- [ ] Implémenter la réintégration en rayon
- [ ] Créer les tests du module retour

---

### 📦 Carte 4.3 : Système de Réservation
**Étiquettes** : `backend`, `métier`, `priorité moyenne`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le modèle `Reservation`
- [ ] Implémenter la file d'attente
- [ ] Ajouter les notifications de disponibilité
- [ ] Créer le formulaire de réservation en ligne
- [ ] Implémenter l'annulation de réservation
- [ ] Gérer l'expiration des réservations
- [ ] Créer les tests de réservation

---

## 👤 LISTE 5 : Module Lecteurs

### 📦 Carte 5.1 : Gestion des Abonnés
**Étiquettes** : `backend`, `métier`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le modèle `Reader` (extension du User)
  - Nom, prénom (obligatoires, min 2 caractères)
  - Adresse complète
  - Email (validation format)
  - Téléphone (validation format FR)
  - Date de naissance (18+ pour adulte)
  - Catégorie (enfant, ado, adulte, senior, professionnel)
- [ ] Implémenter la génération de numéro de carte
- [ ] Créer le formulaire d'inscription
- [ ] Ajouter la photo du lecteur (optionnel)
- [ ] Créer les tests du modèle

---

### 📦 Carte 5.2 : Gestion des Abonnements
**Étiquettes** : `backend`, `métier`, `priorité moyenne`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Créer le modèle `Subscription`
- [ ] Implémenter les tarifs par catégorie
- [ ] Ajouter le renouvellement automatique
- [ ] Créer les rappels d'expiration
- [ ] Implémenter les quotas de prêt
- [ ] Créer les tests d'abonnement

---

### 📦 Carte 5.3 : Compte Lecteur en Ligne
**Étiquettes** : `frontend`, `backend`, `priorité moyenne`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le tableau de bord lecteur
- [ ] Afficher l'historique des prêts
- [ ] Permettre le renouvellement en ligne
- [ ] Afficher les réservations en cours
- [ ] Ajouter la liste de souhaits
- [ ] Implémenter la modification du profil
- [ ] Créer les tests du compte en ligne

---

## 🎨 LISTE 6 : Interface Utilisateur & Accessibilité

### 📦 Carte 6.1 : Design Système Responsive
**Étiquettes** : `frontend`, `UI/UX`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Choisir et intégrer un framework CSS (Tailwind CSS / Bootstrap 5)
- [ ] Créer le système de grille responsive
- [ ] Définir les breakpoints (mobile: 320px, tablet: 768px, desktop: 1024px)
- [ ] Créer les composants de base (boutons, formulaires, cartes)
- [ ] Implémenter le menu responsive (hamburger menu)
- [ ] Tester sur différents appareils (Chrome DevTools)
- [ ] Créer la documentation du design système

---

### 📦 Carte 6.2 : Accessibilité WCAG 2.1 AA
**Étiquettes** : `frontend`, `accessibilité`, `priorité haute`  
**Durée estimée** : 7-10 jours

**Sous-tâches :**
- [ ] Ajouter les attributs ARIA sur tous les éléments interactifs
- [ ] Implémenter la navigation au clavier (Tab, Enter, Escape)
- [ ] Créer les skip links ("Aller au contenu principal")
- [ ] Assurer le contraste minimum (4.5:1 pour texte normal)
- [ ] Ajouter les textes alternatifs sur toutes les images
- [ ] Implémenter les annonces pour lecteurs d'écran (aria-live)
- [ ] Créer les tests automatisés d'accessibilité (axe-core)
- [ ] Effectuer les tests manuels avec NVDA/VoiceOver

---

### 📦 Carte 6.3 : Formulaires Accessibles
**Étiquettes** : `frontend`, `accessibilité`, `priorité haute`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Associer chaque champ à son label (for/id)
- [ ] Ajouter les messages d'erreur accessibles (aria-describedby)
- [ ] Implémenter la validation en temps réel accessible
- [ ] Créer les indications de champs obligatoires (aria-required)
- [ ] Ajouter les instructions contextuelles
- [ ] Tester avec lecteur d'écran

---

### 📦 Carte 6.4 : Templates de Base
**Étiquettes** : `frontend`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le template `base.html` complet
  - Header avec navigation accessible
  - Breadcrumb
  - Zone de contenu principal (main)
  - Footer avec liens légaux
- [ ] Créer les templates de liste (pagination accessible)
- [ ] Créer les templates de formulaire
- [ ] Créer les templates de détail
- [ ] Créer les templates d'erreur (404, 500)
- [ ] Créer les tests de rendu

---

## 🌐 LISTE 7 : OPAC (Catalogue Public)

### 📦 Carte 7.1 : Page d'Accueil Publique
**Étiquettes** : `frontend`, `OPAC`, `priorité moyenne`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le design de la page d'accueil
- [ ] Ajouter le carrousel des nouveautés (accessible)
- [ ] Implémenter la barre de recherche principale
- [ ] Afficher les statistiques publiques
- [ ] Ajouter les horaires et informations pratiques
- [ ] Créer les tests d'intégration

---

### 📦 Carte 7.2 : Recherche Publique
**Étiquettes** : `frontend`, `backend`, `OPAC`, `priorité moyenne`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer la recherche simple
- [ ] Implémenter les suggestions de recherche
- [ ] Ajouter la recherche avancée
- [ ] Créer la page de résultats (avec facettes)
- [ ] Implémenter la fiche détaillée d'un document
- [ ] Ajouter le "Trouver des documents similaires"
- [ ] Créer les tests de recherche publique

---

### 📦 Carte 7.3 : Services en Ligne
**Étiquettes** : `frontend`, `backend`, `OPAC`, `priorité moyenne`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer la connexion lecteur OPAC
- [ ] Implémenter la réservation en ligne
- [ ] Ajouter le renouvellement de prêts
- [ ] Créer les alertes personnalisées
- [ ] Implémenter les suggestions d'achat
- [ ] Créer les tests des services

---

## 🔗 LISTE 8 : API & Intégrations

### 📦 Carte 8.1 : API REST
**Étiquettes** : `backend`, `API`, `priorité moyenne`  
**Durée estimée** : 7-10 jours

**Sous-tâches :**
- [ ] Installer Django REST Framework
- [ ] Créer les serializers pour chaque modèle
- [ ] Implémenter les ViewSets
- [ ] Ajouter l'authentification JWT
- [ ] Créer la documentation OpenAPI/Swagger
- [ ] Implémenter le rate limiting
- [ ] Créer les tests API

---

### 📦 Carte 8.2 : Protocole Z39.50/SRU
**Étiquettes** : `backend`, `intégration`, `priorité basse`  
**Durée estimée** : 7-10 jours

**Sous-tâches :**
- [ ] Implémenter le client Z39.50 (recherche fédérée)
- [ ] Créer le serveur SRU/SRW
- [ ] Ajouter la recherche dans BNF, Sudoc, etc.
- [ ] Implémenter l'import de notices depuis sources externes
- [ ] Créer les tests d'interopérabilité

---

### 📦 Carte 8.3 : Intégration RFID/SIP2
**Étiquettes** : `backend`, `intégration`, `priorité basse`  
**Durée estimée** : 7-10 jours

**Sous-tâches :**
- [ ] Implémenter le protocole SIP2
- [ ] Créer l'interface avec les automates
- [ ] Ajouter le support des portiques antivol
- [ ] Implémenter la boîte de retour automatique
- [ ] Créer les tests d'intégration RFID

---

## 🧪 LISTE 9 : Tests & Qualité

### 📦 Carte 9.1 : Tests Unitaires
**Étiquettes** : `tests`, `qualité`, `priorité haute`  
**Durée estimée** : Continu + 5-7 jours finals

**Sous-tâches :**
- [ ] Installer pytest + pytest-django
- [ ] Créer les fixtures avec factory-boy
- [ ] Écrire les tests pour chaque modèle
- [ ] Écrire les tests pour chaque vue
- [ ] Écrire les tests pour chaque formulaire
- [ ] Atteindre 80% de couverture minimum

---

### 📦 Carte 9.2 : Tests d'Intégration
**Étiquettes** : `tests`, `qualité`, `priorité moyenne`  
**Durée estimée** : Continu + 3-5 jours finals

**Sous-tâches :**
- [ ] Créer les tests de scénarios utilisateur
- [ ] Tester les workflows complets (inscription → prêt → retour)
- [ ] Tester les permissions entre rôles
- [ ] Créer les tests de performance (locust)

---

### 📦 Carte 9.3 : Tests d'Accessibilité
**Étiquettes** : `tests`, `accessibilité`, `priorité haute`  
**Durée estimée** : Continu + 3-5 jours finals

**Sous-tâches :**
- [ ] Configurer pa11y-ci
- [ ] Créer les tests automatisés pour chaque page
- [ ] Effectuer les audits manuels RGAA
- [ ] Documenter les résultats et corrections

---

### 📦 Carte 9.4 : Tests de Sécurité
**Étiquettes** : `tests`, `sécurité`, `priorité haute`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Scanner avec bandit (vulnérabilités Python)
- [ ] Vérifier les dépendances avec safety
- [ ] Tester les injections SQL
- [ ] Vérifier la protection CSRF
- [ ] Tester l'authentification (brute force)

---

## 📊 LISTE 10 : Multi-Sites & Statistiques

### 📦 Carte 10.1 : Gestion Multi-Sites
**Étiquettes** : `backend`, `métier`, `priorité basse`  
**Durée estimée** : 7-10 jours

**Sous-tâches :**
- [ ] Créer le modèle `Library` (site/médiathèque)
- [ ] Implémenter le changement de site
- [ ] Créer les transferts inter-sites
- [ ] Ajouter les quotas par site
- [ ] Implémenter les statistiques par site
- [ ] Créer les tests multi-sites

---

### 📦 Carte 10.2 : Tableaux de Bord
**Étiquettes** : `frontend`, `backend`, `priorité moyenne`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le dashboard administrateur
- [ ] Implémenter les graphiques (Chart.js accessible)
- [ ] Ajouter les indicateurs clés (KPI)
- [ ] Créer les rapports personnalisables
- [ ] Implémenter l'export PDF/Excel
- [ ] Créer les tests des rapports

---

## 📚 LISTE 11 : Documentation

### 📦 Carte 11.1 : Documentation Utilisateur
**Étiquettes** : `documentation`, `priorité moyenne`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Créer le guide du bibliothécaire
- [ ] Créer le guide du lecteur (OPAC)
- [ ] Créer le guide administrateur
- [ ] Ajouter les captures d'écran
- [ ] Créer les vidéos tutorielles

---

### 📦 Carte 11.2 : Documentation Technique
**Étiquettes** : `documentation`, `priorité moyenne`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Documenter l'API (OpenAPI)
- [ ] Créer le guide d'installation
- [ ] Documenter l'architecture
- [ ] Créer le guide de contribution
- [ ] Documenter les procédures de maintenance

---

## 🚀 LISTE 12 : Déploiement

### 📦 Carte 12.1 : Environnement de Staging
**Étiquettes** : `devops`, `priorité moyenne`  
**Durée estimée** : 3-5 jours

**Sous-tâches :**
- [ ] Configurer le serveur staging
- [ ] Mettre en place le déploiement automatique
- [ ] Configurer les sauvegardes
- [ ] Implémenter le monitoring (Sentry)

---

### 📦 Carte 12.2 : Production
**Étiquettes** : `devops`, `priorité haute`  
**Durée estimée** : 5-7 jours

**Sous-tâches :**
- [ ] Configurer le serveur de production
- [ ] Mettre en place HTTPS (Let's Encrypt)
- [ ] Configurer le CDN pour les fichiers statiques
- [ ] Implémenter les alertes de monitoring
- [ ] Créer le plan de reprise d'activité (PRA)

---

## 📅 Récapitulatif des Durées

| Phase | Durée estimée | Priorité |
|-------|---------------|----------|
| Infrastructure & Configuration | 1-2 semaines | Haute |
| Authentification & Autorisation | 2-3 semaines | Haute |
| Module Catalogue | 4-6 semaines | Haute |
| Module Circulation | 3-4 semaines | Haute |
| Module Lecteurs | 2-3 semaines | Haute |
| Interface & Accessibilité | 3-4 semaines | Haute |
| OPAC (Catalogue Public) | 2-3 semaines | Moyenne |
| API & Intégrations | 3-4 semaines | Moyenne |
| Tests & Qualité | Continu + 2 semaines | Haute |
| Multi-Sites & Statistiques | 2-3 semaines | Basse |
| Documentation | 1-2 semaines | Moyenne |
| Déploiement | 1-2 semaines | Haute |

**Total estimé : 6-9 mois** pour un MVP fonctionnel complet.

---

## 🏷️ Légende des Étiquettes

| Couleur | Étiquette | Description |
|---------|-----------|-------------|
| 🔴 Rouge | `priorité haute` | À traiter en premier |
| 🟠 Orange | `priorité moyenne` | Important mais pas urgent |
| 🟡 Jaune | `priorité basse` | À planifier pour plus tard |
| 🔵 Bleu | `backend` | Développement côté serveur |
| 🟢 Vert | `frontend` | Développement côté client |
| 🟣 Violet | `sécurité` | Relatif à la sécurité |
| ⚪ Gris | `tests` | Tests et qualité |
| 🟤 Marron | `accessibilité` | Conformité WCAG/RGAA |

---

## 📌 Notes d'Import Trello

Pour importer dans Trello :
1. Créer un tableau "MediaBib"
2. Créer 12 listes correspondant aux sections
3. Créer une carte par section "📦 Carte X.X"
4. Ajouter les sous-tâches comme checklist
5. Assigner les étiquettes de couleur
6. Définir les dates d'échéance selon les estimations

---

*Document généré pour le projet MediaBib - Décembre 2024*

