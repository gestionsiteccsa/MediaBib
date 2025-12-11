# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## Guide des catégories

- **Added** : Nouvelles fonctionnalités
- **Changed** : Modifications de fonctionnalités existantes
- **Deprecated** : Fonctionnalités qui seront supprimées prochainement
- **Removed** : Fonctionnalités supprimées
- **Fixed** : Corrections de bugs
- **Security** : Corrections de vulnérabilités

---

## [Unreleased]

### Added

- Configuration Docker complète pour installation facile :
  - `Dockerfile` : Image Docker pour l'application Django
  - `docker-compose.yml` : Orchestration Django + PostgreSQL
  - `docker-entrypoint.sh` : Script d'initialisation automatique
  - `docker.env.example` : Template des variables d'environnement
  - `.dockerignore` : Optimisation du build Docker
  - `docs/DOCKER.md` : Documentation complète Docker
- Ajout de `psycopg2-binary` dans `requirements.txt` pour PostgreSQL
- Script `dev.ps1` pour Windows PowerShell (remplace Makefile)
- Fichier `.flake8` pour la configuration du linter
- Documentation complète dans `docs/` :
  - `README.md` : Index de la documentation
  - `INSTALLATION.md` : Guide d'installation
  - `DOCKER.md` : Guide Docker
  - `ARCHITECTURE.md` : Architecture technique
  - `USER_GUIDE.md` : Manuel utilisateur
  - `ADMIN_GUIDE.md` : Guide d'administration
  - `DEVELOPMENT.md` : Guide du développeur
  - `API.md` : Documentation de l'API REST
  - `ACCESSIBILITY.md` : Conformité accessibilité WCAG/RGAA

### Changed

- Formatage du code avec Black et isort
- Correction des erreurs de linting (flake8)
- Amélioration des docstrings dans les fichiers Python

### Fixed

- Correction des espaces blancs dans les docstrings (`conftest.py`)
- Ajout des commentaires `noqa` pour les imports non utilisés (`admin.py`, `models.py`)

---

## [0.1.0] - 2024-12-06

### Added

- Création initiale du projet MediaBib
- Structure Django de base
- Configuration de l'environnement de développement
- README.md avec documentation d'installation
- Fichier requirements.txt avec dépendances de base
- Fichier env.example pour la configuration

---

## Versioning

Ce projet utilise le **Semantic Versioning** :

- **MAJOR** (X.0.0) : Changements incompatibles avec les versions précédentes
- **MINOR** (0.X.0) : Nouvelles fonctionnalités rétrocompatibles
- **PATCH** (0.0.X) : Corrections de bugs rétrocompatibles

### Exemples :

| Version | Signification |
|---------|---------------|
| 0.1.0 | Première version de développement |
| 0.2.0 | Ajout du module Catalogue |
| 0.2.1 | Correction d'un bug dans le catalogue |
| 1.0.0 | Première version stable (MVP) |
| 1.1.0 | Ajout du module OPAC |
| 2.0.0 | Refonte majeure de l'API |

---

## Roadmap

### Version 0.2.0 (Prévue)
- [ ] Module d'authentification complet
- [ ] Modèle utilisateur personnalisé
- [ ] Gestion des rôles et permissions

### Version 0.3.0 (Prévue)
- [ ] Module Catalogue (notices UNIMARC)
- [ ] Gestion des exemplaires
- [ ] Recherche simple

### Version 0.4.0 (Prévue)
- [ ] Module Lecteurs
- [ ] Inscription et gestion des abonnés
- [ ] Compte lecteur en ligne

### Version 0.5.0 (Prévue)
- [ ] Module Circulation
- [ ] Prêts et retours
- [ ] Réservations

### Version 1.0.0 (MVP)
- [ ] OPAC public
- [ ] Interface responsive complète
- [ ] Accessibilité WCAG 2.1 AA
- [ ] Documentation utilisateur

---

## Liens

- [Unreleased]: https://github.com/votre-repo/mediabib/compare/v0.1.0...HEAD
- [0.1.0]: https://github.com/votre-repo/mediabib/releases/tag/v0.1.0

---

*Ce fichier est mis à jour à chaque modification notable du projet.*

