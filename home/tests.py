"""
Tests pour l'application home.

Ce module contient les tests unitaires et d'intégration
pour la page d'accueil de MediaBib.
"""

from django.urls import reverse

import pytest


@pytest.mark.django_db
class TestIndexView:
    """Tests pour la vue index (page d'accueil)."""

    def test_index_returns_200(self, client):
        """La page d'accueil retourne un code 200."""
        url = reverse("home:index")
        response = client.get(url)
        assert response.status_code == 200

    def test_index_uses_correct_template(self, client):
        """La page d'accueil utilise le bon template."""
        url = reverse("home:index")
        response = client.get(url)
        assert "home/index.html" in [t.name for t in response.templates]

    def test_index_contains_title(self, client):
        """La page d'accueil contient un titre."""
        url = reverse("home:index")
        response = client.get(url)
        content = response.content.decode("utf-8")
        assert "<h1>" in content or "Accueil" in content

    def test_index_accessible_without_login(self, client):
        """La page d'accueil est accessible sans authentification."""
        url = reverse("home:index")
        response = client.get(url)
        # Pas de redirection vers le login
        assert response.status_code == 200
        assert "login" not in response.url if hasattr(response, "url") else True


class TestHomeUrls:
    """Tests pour les URLs de l'application home."""

    def test_index_url_resolves(self):
        """L'URL de la page d'accueil est correctement configurée."""
        url = reverse("home:index")
        assert url == "/"

    def test_home_app_namespace(self):
        """L'application home a le bon namespace."""
        url = reverse("home:index")
        assert url is not None
