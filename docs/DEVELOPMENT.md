# Guide du Développeur

Guide pour les développeurs contribuant à MediaBib.

---

## Configuration de l'environnement

### Prérequis

- Python 3.10+
- Git
- VS Code ou Cursor (recommandé)

### Installation

```powershell
# Cloner le projet
git clone https://github.com/votre-repo/mediabib.git
cd mediabib

# Créer l'environnement virtuel
python -m venv env
.\env\Scripts\activate

# Installer les dépendances
.\dev.ps1 install-dev
# ou
pip install -r requirements.txt
pip install pre-commit
pre-commit install

# Configurer l'environnement
copy env.example .env

# Appliquer les migrations
.\dev.ps1 migrate
```

---

## Commandes utiles

### Script PowerShell (Windows)

```powershell
.\dev.ps1 help          # Afficher l'aide
.\dev.ps1 run           # Lancer le serveur
.\dev.ps1 test          # Lancer les tests
.\dev.ps1 test-cov      # Tests avec couverture
.\dev.ps1 lint          # Vérifier le code
.\dev.ps1 format        # Formater le code
.\dev.ps1 check         # Vérification complète
```

### Commandes directes

```bash
# Serveur
python manage.py runserver

# Tests
pytest
pytest --cov=. --cov-report=html

# Linting
flake8 .
black .
isort .
```

---

## Standards de code

### Python (PEP 8)

- Ligne max : 88 caractères (Black)
- 4 espaces pour l'indentation
- 2 lignes vides entre les classes
- 1 ligne vide entre les méthodes

### Formatage automatique

```powershell
# Formater tout le code
.\dev.ps1 format

# Vérifier sans modifier
.\dev.ps1 format-check
```

### Docstrings

Format Google obligatoire :

```python
def calculate_fine(loan: Loan, return_date: date) -> Decimal:
    """
    Calcule l'amende pour un prêt en retard.

    Args:
        loan: L'objet Loan concerné.
        return_date: La date de retour effective.

    Returns:
        Le montant de l'amende en euros.

    Raises:
        ValueError: Si la date de retour est antérieure à la date de prêt.
    """
    pass
```

---

## Architecture des applications

### Structure standard

```
app_name/
├── __init__.py
├── admin.py           # Configuration admin Django
├── apps.py            # Configuration de l'app
├── forms.py           # Formulaires
├── models.py          # Modèles de données
├── services.py        # Logique métier
├── urls.py            # Routes
├── views.py           # Vues
├── managers.py        # Managers personnalisés
├── signals.py         # Signaux Django
├── templates/
│   └── app_name/
│       ├── list.html
│       ├── detail.html
│       └── form.html
├── static/
│   └── app_name/
│       ├── css/
│       └── js/
├── tests/
│   ├── __init__.py
│   ├── test_models.py
│   ├── test_views.py
│   ├── test_forms.py
│   └── test_services.py
└── migrations/
```

### Créer une nouvelle application

```bash
python manage.py startapp nom_app
```

Puis ajouter dans `settings.py` :

```python
INSTALLED_APPS = [
    ...
    "nom_app",
]
```

---

## Modèles

### Conventions

```python
from django.db import models


class MonModele(models.Model):
    """Description du modèle."""

    # Champs
    nom = models.CharField(
        max_length=100,
        verbose_name="Nom",
        help_text="Le nom du document"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Mon modèle"
        verbose_name_plural = "Mes modèles"
        ordering = ["-created_at"]

    def __str__(self):
        return self.nom

    def save(self, *args, **kwargs):
        """Logique personnalisée avant sauvegarde."""
        # Traitement
        super().save(*args, **kwargs)
```

### Optimisation des requêtes

```python
# ❌ Mauvais : N+1 requêtes
loans = Loan.objects.all()
for loan in loans:
    print(loan.reader.name)

# ✅ Bon : 1 requête
loans = Loan.objects.select_related('reader').all()
for loan in loans:
    print(loan.reader.name)
```

---

## Vues

### Class-Based Views (recommandé)

```python
from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.views.generic import CreateView, ListView


class DocumentListView(LoginRequiredMixin, ListView):
    """Liste des documents."""

    model = Document
    template_name = "catalog/document_list.html"
    context_object_name = "documents"
    paginate_by = 25

    def get_queryset(self):
        """Filtre les documents selon la recherche."""
        queryset = super().get_queryset()
        query = self.request.GET.get("q")
        if query:
            queryset = queryset.filter(title__icontains=query)
        return queryset.select_related("author")


class DocumentCreateView(LoginRequiredMixin, PermissionRequiredMixin, CreateView):
    """Création d'un document."""

    model = Document
    form_class = DocumentForm
    template_name = "catalog/document_form.html"
    permission_required = "catalog.add_document"

    def form_valid(self, form):
        """Ajoute l'utilisateur créateur."""
        form.instance.created_by = self.request.user
        return super().form_valid(form)
```

---

## Tests

### Structure des tests

```python
import pytest
from django.urls import reverse


@pytest.mark.django_db
class TestDocumentListView:
    """Tests pour la vue liste des documents."""

    def test_anonymous_user_redirected(self, client):
        """Un utilisateur non connecté est redirigé."""
        url = reverse("catalog:document-list")
        response = client.get(url)
        assert response.status_code == 302
        assert "/login/" in response.url

    def test_authenticated_user_can_view(self, client, user):
        """Un utilisateur connecté peut voir la liste."""
        client.force_login(user)
        url = reverse("catalog:document-list")
        response = client.get(url)
        assert response.status_code == 200

    def test_search_filters_results(self, client, user, document_factory):
        """La recherche filtre les résultats."""
        document_factory(title="Python Programming")
        document_factory(title="Java Basics")

        client.force_login(user)
        url = reverse("catalog:document-list")
        response = client.get(url, {"q": "Python"})

        assert response.status_code == 200
        assert len(response.context["documents"]) == 1
```

### Fixtures avec Factory Boy

```python
# conftest.py
import factory
from django.contrib.auth import get_user_model


class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = get_user_model()

    username = factory.Sequence(lambda n: f"user{n}")
    email = factory.LazyAttribute(lambda o: f"{o.username}@example.com")
    password = factory.PostGenerationMethodCall("set_password", "password123")


@pytest.fixture
def user():
    return UserFactory()
```

### Couverture de code

```powershell
# Avec rapport HTML
.\dev.ps1 test-cov

# Ouvrir le rapport
start htmlcov/index.html
```

---

## Accessibilité

### Règles obligatoires

- Attributs ARIA sur tous les éléments interactifs
- Navigation clavier fonctionnelle
- Contraste minimum 4.5:1
- Labels sur tous les champs de formulaire

### Exemple de formulaire accessible

```html
<div class="form-group">
    <label for="email">
        Adresse email
        <span aria-hidden="true">*</span>
    </label>
    <input
        type="email"
        id="email"
        name="email"
        aria-required="true"
        aria-describedby="email-help email-error"
    >
    <p id="email-help" class="help-text">
        Format : exemple@domaine.fr
    </p>
    <p id="email-error" class="error-text" role="alert" hidden></p>
</div>
```

---

## Git Workflow

### Format des commits

```
type(scope): description courte

Corps du message (optionnel)

Refs: #123
```

Types : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Processus de contribution

1. Créer une branche depuis `develop`
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/ma-feature
   ```

2. Développer avec commits réguliers

3. Avant de push :
   ```powershell
   .\dev.ps1 check
   ```

4. Créer une Pull Request vers `develop`

---

## Ressources

- [Documentation Django](https://docs.djangoproject.com/)
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)
- [PEP 8](https://peps.python.org/pep-0008/)
- [Guide de contribution](../CONTRIBUTING.md)

