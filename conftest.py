"""
Configuration globale des fixtures pytest pour MediaBib.

Ce fichier contient les fixtures partagées entre tous les tests.
"""

from django.test import Client

import pytest


@pytest.fixture
def client():
    """
    Client de test Django.

    Returns:
        Client: Instance du client de test Django.
    """
    return Client()


@pytest.fixture
def authenticated_client(client, django_user_model):
    """
    Client de test authentifié avec un utilisateur standard.

    Args:
        client: Client de test Django.
        django_user_model: Modèle utilisateur Django.

    Returns:
        Client: Client authentifié.
    """
    user = django_user_model.objects.create_user(
        username="testuser", email="testuser@example.com", password="testpass123"
    )
    client.force_login(user)
    return client


@pytest.fixture
def admin_client(client, django_user_model):
    """
    Client de test authentifié avec un superutilisateur.

    Args:
        client: Client de test Django.
        django_user_model: Modèle utilisateur Django.

    Returns:
        Client: Client authentifié en tant qu'admin.
    """
    admin_user = django_user_model.objects.create_superuser(
        username="admin", email="admin@example.com", password="adminpass123"
    )
    client.force_login(admin_user)
    return client
