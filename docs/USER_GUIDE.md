# Manuel Utilisateur

Guide d'utilisation de MediaBib pour les bibliothécaires.

---

## Connexion

### Se connecter

1. Accédez à l'URL de votre instance MediaBib
2. Cliquez sur **Connexion** dans le menu
3. Entrez votre identifiant et mot de passe
4. Cliquez sur **Se connecter**

### Mot de passe oublié

1. Cliquez sur **Mot de passe oublié ?**
2. Entrez votre adresse email
3. Vérifiez votre boîte mail
4. Suivez le lien pour réinitialiser

### Se déconnecter

1. Cliquez sur votre nom d'utilisateur en haut à droite
2. Sélectionnez **Déconnexion**

---

## Navigation

### Menu principal

| Élément | Description | Raccourci |
|---------|-------------|-----------|
| Accueil | Page d'accueil | `Alt + 1` |
| Catalogue | Recherche et catalogage | `Alt + 2` |
| Circulation | Prêts et retours | `Alt + 3` |
| Lecteurs | Gestion des abonnés | `Alt + 4` |
| Rapports | Statistiques | `Alt + 5` |

### Navigation au clavier

- `Tab` : Naviguer entre les éléments
- `Entrée` : Activer l'élément sélectionné
- `Échap` : Fermer les menus/modales
- `Alt + M` : Aller au menu principal
- `Alt + C` : Aller au contenu principal

---

## Module Catalogue

### Rechercher un document

1. Accédez à **Catalogue** > **Rechercher**
2. Entrez vos critères de recherche
3. Cliquez sur **Rechercher** ou appuyez sur `Entrée`

**Types de recherche :**

| Type | Description |
|------|-------------|
| Simple | Recherche dans tous les champs |
| Avancée | Recherche par champ spécifique |
| ISBN | Recherche par ISBN/ISSN |

### Créer une notice

1. Accédez à **Catalogue** > **Nouvelle notice**
2. Sélectionnez le type de document
3. Remplissez les champs obligatoires (marqués *)
4. Cliquez sur **Enregistrer**

**Champs UNIMARC principaux :**

| Zone | Champ | Description |
|------|-------|-------------|
| 200 | Titre | Titre principal |
| 700 | Auteur | Auteur principal |
| 010 | ISBN | Numéro ISBN |
| 210 | Éditeur | Éditeur et date |

### Ajouter un exemplaire

1. Ouvrez la notice du document
2. Cliquez sur **Ajouter un exemplaire**
3. Remplissez les informations :
   - Code-barres
   - Localisation
   - Cote
   - État
4. Cliquez sur **Enregistrer**

---

## Module Circulation

### Effectuer un prêt

1. Accédez à **Circulation** > **Prêt**
2. Scannez ou entrez la carte du lecteur
3. Vérifiez les informations du lecteur
4. Scannez ou entrez le code-barres du document
5. Confirmez le prêt

**Informations affichées :**
- Nom du lecteur
- Nombre de prêts en cours
- Prêts en retard (si applicable)
- Date de retour prévue

### Effectuer un retour

1. Accédez à **Circulation** > **Retour**
2. Scannez le code-barres du document
3. Le système affiche :
   - Nom du lecteur
   - Date de prêt
   - Retard éventuel
   - Amende à payer (si applicable)
4. Confirmez le retour

### Gérer les réservations

1. Accédez à **Circulation** > **Réservations**
2. Visualisez la liste des réservations
3. Actions disponibles :
   - **Notifier** : Envoyer un email au lecteur
   - **Annuler** : Supprimer la réservation
   - **Valider** : Marquer comme retirée

---

## Module Lecteurs

### Inscrire un lecteur

1. Accédez à **Lecteurs** > **Nouvelle inscription**
2. Remplissez les informations :
   - Nom et prénom (obligatoires)
   - Adresse
   - Email
   - Téléphone
   - Date de naissance
3. Sélectionnez la catégorie (Enfant, Adulte, etc.)
4. Choisissez le type d'abonnement
5. Cliquez sur **Enregistrer**

### Rechercher un lecteur

1. Accédez à **Lecteurs** > **Rechercher**
2. Entrez le nom, numéro de carte ou email
3. Cliquez sur le lecteur pour voir son dossier

### Dossier lecteur

Le dossier lecteur affiche :

| Section | Information |
|---------|-------------|
| Identité | Nom, adresse, contact |
| Abonnement | Type, date d'expiration |
| Prêts en cours | Documents empruntés |
| Historique | Anciens prêts |
| Réservations | Documents réservés |
| Amendes | Montant dû |

---

## Raccourcis clavier

### Navigation globale

| Raccourci | Action |
|-----------|--------|
| `Alt + 1` à `Alt + 5` | Accès rapide aux modules |
| `Alt + S` | Focus sur la recherche |
| `Alt + H` | Aide contextuelle |
| `Échap` | Fermer la fenêtre active |

### Formulaires

| Raccourci | Action |
|-----------|--------|
| `Tab` | Champ suivant |
| `Shift + Tab` | Champ précédent |
| `Entrée` | Soumettre le formulaire |
| `Échap` | Annuler |

### Tableaux

| Raccourci | Action |
|-----------|--------|
| `↑` / `↓` | Naviguer dans les lignes |
| `Entrée` | Ouvrir l'élément |
| `Suppr` | Supprimer (avec confirmation) |

---

## Résolution des problèmes

### Le scanner ne fonctionne pas

1. Vérifiez la connexion USB du scanner
2. Assurez-vous que le curseur est dans le bon champ
3. Testez le scanner dans un éditeur de texte

### Erreur lors du prêt

**"Lecteur bloqué"** : Le lecteur a des amendes impayées ou un abonnement expiré.

**"Quota atteint"** : Le lecteur a atteint son nombre maximum de prêts.

**"Document non disponible"** : Le document est déjà emprunté ou réservé.

### Page lente à charger

1. Vérifiez votre connexion internet
2. Videz le cache du navigateur
3. Contactez l'administrateur si le problème persiste

---

## Support

Pour toute question ou problème :

1. Consultez cette documentation
2. Contactez votre administrateur système
3. Ouvrez un ticket de support

