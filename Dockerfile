# =============================================================================
# Dockerfile - MediaBib
# Système Intégré de Gestion de Bibliothèque
# =============================================================================

# Image de base Python 3.11 slim (optimisée pour la taille)
FROM python:3.11-slim

# Métadonnées
LABEL maintainer="MediaBib Team"
LABEL description="MediaBib - SIGB open source"
LABEL version="0.1.0"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Répertoire de travail
WORKDIR /app

# Installation des dépendances système
# - libpq-dev : Client PostgreSQL
# - gcc : Compilation de certaines dépendances Python
# - postgresql-client : Utilitaires PostgreSQL (optionnel)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Création d'un utilisateur non-root pour la sécurité
RUN useradd -m -u 1000 mediabib && \
    chown -R mediabib:mediabib /app

# Copie et installation des dépendances Python
COPY requirements.txt /app/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copie du code de l'application
COPY . /app/

# Changement de propriétaire
RUN chown -R mediabib:mediabib /app

# Utilisateur non-root
USER mediabib

# Port exposé
EXPOSE 8000

# Script d'entrée
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Commande par défaut (Gunicorn)
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "--timeout", "120", "app.wsgi:application"]

