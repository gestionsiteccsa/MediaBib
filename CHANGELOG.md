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

- Configuration complète des tests avec pytest et pytest-django
- Tests unitaires pour l'application `home` (couverture 100%)
- Fichier `pytest.ini` pour la configuration des tests
- Fichier `conftest.py` avec les fixtures globales
- Fichier `pyproject.toml` pour la configuration des outils (Black, isort, flake8, bandit, coverage)
- Fichier `.pre-commit-config.yaml` pour les hooks pre-commit
- Fichier `.editorconfig` pour la configuration universelle des éditeurs
- Fichier `Makefile` avec les commandes utiles (install, test, lint, run)
- Fichier `CONTRIBUTING.md` avec le guide de contribution
- Fichier `LICENSE` (AGPL-3.0)
- Dépendances de développement : pytest, pytest-django, pytest-cov, factory-boy, coverage, black, isort, flake8, bandit, pre-commit

### Changed

- Mise à jour de `requirements.txt` avec les dépendances de test et qualité de code

### Deprecated

- (Aucune dépréciation pour l'instant)

### Removed

- (Aucune suppression pour l'instant)

### Fixed

- (Aucune correction pour l'instant)

### Security

- (Aucune correction de sécurité pour l'instant)

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

