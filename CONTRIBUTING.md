# Guide de Contribution - MediaBib

Merci de votre intérêt pour contribuer à MediaBib ! Ce document explique comment participer au projet.

## Table des matières

- [Code de Conduite](#code-de-conduite)
- [Comment Contribuer](#comment-contribuer)
- [Processus de Développement](#processus-de-développement)
- [Standards de Code](#standards-de-code)
- [Soumission de Pull Request](#soumission-de-pull-request)

---

## Code de Conduite

Ce projet adhère à un code de conduite inclusif et respectueux. En participant, vous vous engagez à :

- Utiliser un langage accueillant et inclusif
- Respecter les différents points de vue et expériences
- Accepter gracieusement les critiques constructives
- Se concentrer sur ce qui est le mieux pour la communauté
- Faire preuve d'empathie envers les autres membres

---

## Comment Contribuer

### Signaler un Bug

1. Vérifiez que le bug n'a pas déjà été signalé dans les [Issues](https://github.com/votre-repo/mediabib/issues)
2. Créez une nouvelle issue avec :
   - Un titre clair et descriptif
   - Les étapes pour reproduire le bug
   - Le comportement attendu vs. le comportement observé
   - Votre environnement (OS, Python, Django versions)
   - Des captures d'écran si applicable

### Proposer une Fonctionnalité

1. Ouvrez une issue de type "Feature Request"
2. Décrivez clairement la fonctionnalité
3. Expliquez pourquoi elle serait utile pour le projet
4. Attendez la validation avant de commencer le développement

### Soumettre du Code

1. Forkez le repository
2. Créez une branche depuis `develop`
3. Développez votre fonctionnalité
4. Soumettez une Pull Request

---

## Processus de Développement

### Installation de l'environnement de développement

```bash
# 1. Cloner le repository
git clone https://github.com/votre-repo/mediabib.git
cd mediabib

# 2. Créer l'environnement virtuel
python -m venv env
source env/bin/activate  # Linux/macOS
# ou
env\Scripts\activate     # Windows

# 3. Installer les dépendances
make install-dev
# ou
pip install -r requirements.txt
pip install pre-commit
pre-commit install

# 4. Configurer l'environnement
cp env.example .env
# Modifier .env selon vos besoins

# 5. Appliquer les migrations
make migrate
# ou
python manage.py migrate

# 6. Lancer le serveur
make run
# ou
python manage.py runserver
```

### Workflow Git

```
main ────────────────────────────────────────────►
       │                                    ▲
       └─► develop ────────────────────────►│
              │              ▲               │
              └─► feature/x ─┘               │
              └─► fix/y ─────────────────────┘
```

1. **main** : Branche de production stable
2. **develop** : Branche de développement
3. **feature/xxx** : Nouvelles fonctionnalités
4. **fix/xxx** : Corrections de bugs

### Créer une branche

```bash
# Pour une nouvelle fonctionnalité
git checkout develop
git pull origin develop
git checkout -b feature/nom-de-la-feature

# Pour une correction
git checkout develop
git pull origin develop
git checkout -b fix/nom-du-bug
```

---

## Standards de Code

### Python / Django

- **PEP 8** : Suivre strictement les conventions Python
- **Black** : Formatage automatique (ligne max : 88 caractères)
- **isort** : Tri automatique des imports
- **flake8** : Linting

```bash
# Formater le code
make format

# Vérifier le code
make lint
```

### Documentation

- Docstrings obligatoires sur toutes les fonctions et classes
- Format Google/NumPy pour les docstrings

```python
def ma_fonction(param1: str, param2: int) -> bool:
    """
    Description courte de la fonction.

    Description longue si nécessaire.

    Args:
        param1: Description du premier paramètre.
        param2: Description du second paramètre.

    Returns:
        Description de la valeur retournée.

    Raises:
        ValueError: Description de l'exception.
    """
    pass
```

### Tests

- **Obligatoires** pour toute nouvelle fonctionnalité
- **Couverture minimum** : 80%
- Utiliser pytest

```bash
# Lancer les tests
make test

# Avec couverture
make test-cov
```

### Commits

Format des messages de commit :

```
type(scope): description courte

Description détaillée si nécessaire.

Refs: #123
```

Types autorisés :
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation
- `style` : Formatage (pas de changement de code)
- `refactor` : Refactoring
- `test` : Ajout de tests
- `chore` : Maintenance

Exemple :
```
feat(catalog): ajouter la recherche par ISBN

- Ajout du champ ISBN dans le formulaire
- Validation du format ISBN-10 et ISBN-13
- Tests unitaires inclus

Refs: #42
```

### Accessibilité

Toute interface utilisateur doit respecter **WCAG 2.1 niveau AA** :

- Attributs ARIA appropriés
- Navigation au clavier
- Contraste suffisant (4.5:1 minimum)
- Labels sur tous les champs de formulaire

---

## Soumission de Pull Request

### Checklist avant soumission

- [ ] Code formaté avec Black et isort
- [ ] Linting passé (flake8)
- [ ] Tests écrits et passants
- [ ] Couverture ≥ 80%
- [ ] Documentation mise à jour
- [ ] CHANGELOG.md mis à jour
- [ ] Commits propres et bien formatés

### Créer la Pull Request

1. Pushez votre branche
   ```bash
   git push origin feature/ma-feature
   ```

2. Créez la PR sur GitHub vers `develop`

3. Remplissez le template :
   - Description des changements
   - Lien vers l'issue concernée
   - Captures d'écran si UI modifiée
   - Checklist validée

4. Attendez la review

### Review de Code

Un reviewer vérifiera :

- Qualité du code
- Tests suffisants
- Accessibilité respectée
- Documentation à jour
- Pas de régression

---

## Besoin d'Aide ?

- Ouvrez une [Discussion](https://github.com/votre-repo/mediabib/discussions)
- Consultez la [Documentation](docs/)
- Lisez le [README](README.md)

---

Merci de contribuer à MediaBib ! 🎉
