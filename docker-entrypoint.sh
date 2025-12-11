#!/bin/bash
# =============================================================================
# docker-entrypoint.sh - Script d'initialisation MediaBib
# =============================================================================

set -e

echo "=========================================="
echo "MediaBib - Initialisation du conteneur"
echo "=========================================="

# Fonction pour attendre que PostgreSQL soit prêt
wait_for_postgres() {
    echo "Attente de PostgreSQL..."
    until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
        echo "PostgreSQL n'est pas encore prêt, attente..."
        sleep 1
    done
    echo "PostgreSQL est prêt !"
}

# Vérifier si on utilise PostgreSQL
if [ -n "$DATABASE_URL" ] && [[ "$DATABASE_URL" == postgres* ]]; then
    # Extraire les informations de connexion depuis DATABASE_URL
    # Format: postgres://user:password@host:port/dbname
    if [ -z "$POSTGRES_HOST" ]; then
        POSTGRES_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
    fi
    if [ -z "$POSTGRES_USER" ]; then
        POSTGRES_USER=$(echo $DATABASE_URL | sed -n 's|postgres://\([^:]*\):.*|\1|p')
    fi
    if [ -z "$POSTGRES_PASSWORD" ]; then
        POSTGRES_PASSWORD=$(echo $DATABASE_URL | sed -n 's|postgres://[^:]*:\([^@]*\)@.*|\1|p')
    fi
    if [ -z "$POSTGRES_DB" ]; then
        POSTGRES_DB=$(echo $DATABASE_URL | sed -n 's|.*/\([^?]*\).*|\1|p')
    fi
    
    # Attendre PostgreSQL si les variables sont définies
    if [ -n "$POSTGRES_HOST" ] && [ -n "$POSTGRES_USER" ] && [ -n "$POSTGRES_DB" ]; then
        wait_for_postgres
    fi
fi

# Appliquer les migrations
echo "Application des migrations..."
python manage.py migrate --no-input

# Collecter les fichiers statiques
echo "Collecte des fichiers statiques..."
python manage.py collectstatic --no-input

# Créer un superutilisateur si la variable est définie
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ] && [ -n "$DJANGO_SUPERUSER_EMAIL" ]; then
    echo "Création du superutilisateur..."
    python manage.py createsuperuser \
        --noinput \
        --username "$DJANGO_SUPERUSER_USERNAME" \
        --email "$DJANGO_SUPERUSER_EMAIL" || true
    # Note: Le || true permet de continuer si l'utilisateur existe déjà
fi

echo "=========================================="
echo "Initialisation terminée !"
echo "=========================================="

# Exécuter la commande passée en argument
exec "$@"

