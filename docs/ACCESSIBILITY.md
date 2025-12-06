# Conformité Accessibilité

MediaBib s'engage à respecter les standards d'accessibilité WCAG 2.1 niveau AA et le RGAA (Référentiel Général d'Amélioration de l'Accessibilité).

---

## Engagement

MediaBib vise à être accessible à tous les utilisateurs, y compris les personnes en situation de handicap :

- Déficience visuelle (cécité, malvoyance, daltonisme)
- Déficience auditive
- Déficience motrice
- Déficience cognitive

---

## Standards respectés

| Standard | Niveau | Conformité |
|----------|--------|------------|
| WCAG 2.1 | AA | Cible |
| RGAA 4.1 | - | Cible |
| Section 508 | - | Compatible |

---

## Fonctionnalités d'accessibilité

### Navigation

- **Skip links** : Lien "Aller au contenu principal" en haut de chaque page
- **Navigation au clavier** : Tous les éléments interactifs accessibles via Tab
- **Focus visible** : Indicateur visuel sur l'élément focusé
- **Ordre de tabulation** : Ordre logique et prévisible

### Structure

- **Titres hiérarchiques** : Structure h1 > h2 > h3 respectée
- **Landmarks ARIA** : `<main>`, `<nav>`, `<header>`, `<footer>`
- **Listes** : Utilisation sémantique des listes
- **Tableaux** : En-têtes de colonnes associés aux cellules

### Formulaires

- **Labels explicites** : Chaque champ a un label associé
- **Messages d'erreur** : Liés au champ via `aria-describedby`
- **Champs obligatoires** : Marqués avec `aria-required="true"`
- **Instructions** : Texte d'aide disponible

### Médias

- **Images** : Texte alternatif descriptif
- **Images décoratives** : `alt=""` pour être ignorées
- **Icônes** : `aria-hidden="true"` ou `aria-label` descriptif

### Couleurs et contraste

- **Contraste texte** : Ratio minimum 4.5:1
- **Contraste grands textes** : Ratio minimum 3:1
- **Pas uniquement la couleur** : Indicateurs supplémentaires (icônes, texte)

---

## Raccourcis clavier

### Navigation globale

| Raccourci | Action |
|-----------|--------|
| `Tab` | Élément suivant |
| `Shift + Tab` | Élément précédent |
| `Entrée` | Activer l'élément |
| `Échap` | Fermer modale/menu |
| `Alt + 1` à `Alt + 5` | Accès rapide aux modules |

### Formulaires

| Raccourci | Action |
|-----------|--------|
| `Espace` | Cocher/décocher une case |
| `↑` / `↓` | Naviguer dans une liste |
| `Entrée` | Soumettre |

### Tableaux

| Raccourci | Action |
|-----------|--------|
| `↑` / `↓` | Ligne précédente/suivante |
| `←` / `→` | Colonne précédente/suivante |
| `Ctrl + Home` | Première cellule |
| `Ctrl + End` | Dernière cellule |

---

## Technologies d'assistance testées

| Technologie | Navigateur | Statut |
|-------------|------------|--------|
| NVDA | Firefox, Chrome | ✅ Compatible |
| JAWS | Chrome, Edge | ✅ Compatible |
| VoiceOver | Safari (macOS/iOS) | ✅ Compatible |
| TalkBack | Chrome (Android) | ✅ Compatible |
| Lecteur Windows | Edge | ✅ Compatible |

---

## Déclaration de conformité

### Pages testées

| Page | Conformité WCAG 2.1 AA |
|------|------------------------|
| Accueil | ✅ Conforme |
| Recherche | ✅ Conforme |
| Formulaire de prêt | ✅ Conforme |
| Liste des lecteurs | ✅ Conforme |
| Compte lecteur | ✅ Conforme |

### Non-conformités connues

> Aucune non-conformité majeure identifiée à ce jour.

### Dérogations

> Aucune dérogation en vigueur.

---

## Tests d'accessibilité

### Outils automatisés

| Outil | Usage |
|-------|-------|
| axe-core | Tests automatisés dans les tests unitaires |
| pa11y | Tests CI/CD |
| WAVE | Vérification manuelle |
| Lighthouse | Audit global |

### Tests manuels

Effectués avec :
- Navigation clavier uniquement
- Lecteurs d'écran (NVDA, VoiceOver)
- Zoom 200%
- Mode contraste élevé

---

## Signaler un problème d'accessibilité

Si vous rencontrez une difficulté d'accès :

1. **Email** : accessibilite@example.com
2. **Formulaire** : `/contact/accessibilite/`
3. **Téléphone** : +33 1 XX XX XX XX

### Informations à fournir

- URL de la page concernée
- Description du problème
- Technologie d'assistance utilisée
- Navigateur et version
- Système d'exploitation

### Délai de réponse

- Accusé de réception : 48h
- Réponse détaillée : 15 jours ouvrés
- Correction si applicable : selon complexité

---

## Plan d'amélioration

### Actions en cours

1. ✅ Mise en place des skip links
2. ✅ Audit ARIA des formulaires
3. 🔄 Tests avec lecteurs d'écran
4. 📅 Formation de l'équipe

### Actions prévues

| Action | Échéance |
|--------|----------|
| Audit complet RGAA | T1 2025 |
| Sous-titrage des vidéos | T2 2025 |
| Mode contraste élevé | T2 2025 |

---

## Ressources

### Documentation

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [RGAA 4.1](https://accessibilite.numerique.gouv.fr/)
- [MDN - Accessibilité](https://developer.mozilla.org/fr/docs/Web/Accessibility)

### Outils

- [axe DevTools](https://www.deque.com/axe/devtools/)
- [WAVE](https://wave.webaim.org/)
- [Contrast Checker](https://webaim.org/resources/contrastchecker/)

---

## Historique

| Date | Action |
|------|--------|
| 2024-12 | Création de cette déclaration |
| 2024-12 | Implémentation des standards ARIA |

---

*Dernière mise à jour : Décembre 2024*

