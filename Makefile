# =============================================================================
# Makefile - Commandes utiles pour MediaBib
# =============================================================================
# Usage: make <commande>

.PHONY: help install install-dev run test lint format clean migrate shell

# Variables
PYTHON = python
PIP = pip
MANAGE = $(PYTHON) manage.py

# Couleurs pour l'affichage
GREEN = \033[0;32m
NC = \033[0m

help: ## Afficher l'aide
	@echo "Commandes disponibles:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

# =============================================================================
# Installation
# =============================================================================

install: ## Installer les dépendances de production
	$(PIP) install -r requirements.txt

install-dev: install ## Installer les dépendances de développement
	$(PIP) install pre-commit
	pre-commit install

setup: install-dev migrate ## Installation complète (dépendances + migrations)
	@echo "$(GREEN)Installation terminée !$(NC)"
	@echo "Lancez 'make run' pour démarrer le serveur"

# =============================================================================
# Développement
# =============================================================================

run: ## Lancer le serveur de développement
	$(MANAGE) runserver

shell: ## Ouvrir le shell Django
	$(MANAGE) shell

dbshell: ## Ouvrir le shell de base de données
	$(MANAGE) dbshell

# =============================================================================
# Base de données
# =============================================================================

migrate: ## Appliquer les migrations
	$(MANAGE) migrate

migrations: ## Créer les migrations
	$(MANAGE) makemigrations

migrate-show: ## Afficher les migrations en attente
	$(MANAGE) showmigrations

# =============================================================================
# Tests
# =============================================================================

test: ## Lancer tous les tests
	pytest

test-v: ## Lancer les tests en mode verbose
	pytest -v

test-cov: ## Lancer les tests avec couverture
	pytest --cov=. --cov-report=html --cov-report=term-missing
	@echo "$(GREEN)Rapport de couverture généré dans htmlcov/index.html$(NC)"

test-fast: ## Lancer les tests (arrêt au premier échec)
	pytest -x

# =============================================================================
# Qualité du code
# =============================================================================

lint: ## Vérifier le code (flake8 + bandit)
	flake8 .
	bandit -r . -c pyproject.toml

format: ## Formater le code (black + isort)
	black .
	isort .

format-check: ## Vérifier le formatage sans modifier
	black --check .
	isort --check-only .

check: format-check lint test ## Vérification complète (format + lint + tests)
	@echo "$(GREEN)Toutes les vérifications passées !$(NC)"

pre-commit: ## Exécuter les hooks pre-commit
	pre-commit run --all-files

# =============================================================================
# Production
# =============================================================================

collectstatic: ## Collecter les fichiers statiques
	$(MANAGE) collectstatic --no-input

gunicorn: ## Lancer avec Gunicorn
	gunicorn app.wsgi:application --bind 0.0.0.0:8000

# =============================================================================
# Utilitaires
# =============================================================================

clean: ## Nettoyer les fichiers temporaires
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".coverage" -delete

superuser: ## Créer un superutilisateur
	$(MANAGE) createsuperuser

# =============================================================================
# Documentation
# =============================================================================

docs: ## Générer la documentation (si configuré)
	@echo "Documentation non configurée"

