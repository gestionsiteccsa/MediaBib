# MediaBib - Spécifications complètes du SIGB

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture des modules](#architecture-des-modules)
3. [Tableau des modules principaux](#tableau-des-modules-principaux)
4. [Détail des sous-fonctionnalités](#détail-des-sous-fonctionnalités)
5. [Schémas d'architecture](#schémas-darchitecture)
6. [Applications Django](#applications-django)
7. [Phases de développement](#phases-de-développement)
8. [Intégrations externes](#intégrations-externes)
9. [Normes et conformité](#normes-et-conformité)

---

## Vue d'ensemble

**MediaBib** est un Système Intégré de Gestion de Bibliothèque (SIGB) open source développé en Django, conçu pour les réseaux de lecture publique. Il est compatible avec le format UNIMARC et permet l'import de données depuis PMB.

### Caractéristiques principales

- **Multi-sites** : Gestion de 1 à N médiathèques avec transferts inter-sites
- **Tous types de documents** : Livres, CD, DVD, revues, jeux, partitions, ressources numériques
- **Public visé** : Bibliothèques publiques (tout public)
- **Capacité** : Plus de 70 000 notices bibliographiques
- **OPAC** : Portail public avec compte lecteur, réservations en ligne
- **RFID** : Support des automates de prêt/retour
- **Normes** : UNIMARC, Z39.50, SRU/SRW, SIP2, NCIP

---

## Architecture des modules

```mermaid
graph TB
    subgraph "Noyau"
        ADMIN[Administration]
        DROITS[Droits/Rôles]
        LOGS[Logs/Audit]
        SITES[Multi-sites]
    end

    subgraph "Catalogue"
        NOTICES[Notices bibliographiques]
        AUTORITES[Autorités]
        EXEMPLAIRES[Exemplaires]
        IMPORT[Import/Export]
        Z3950[Z39.50/SRU]
    end

    subgraph "Circulation"
        LECTEURS[Lecteurs/Abonnés]
        PRETS[Prêts/Retours]
        RESERVATIONS[Réservations]
        AMENDES[Amendes/Pénalités]
        QUOTAS[Quotas]
    end

    subgraph "Acquisitions"
        ACQU[Acquisitions]
        SUGGEST[Suggestions]
        PERIOD[Périodiques]
        FOURN[Fournisseurs]
    end

    subgraph "Services publics"
        OPAC[OPAC]
        PANIERS[Paniers/Sélections]
        DSI[DSI]
        NOTIF[Notifications]
        EVENTS[Animations]
    end

    subgraph "Technique"
        RFID[RFID/Automates]
        STATS[Statistiques]
        DIGITAL[Ressources numériques]
        TRANSFERTS[Transferts inter-sites]
    end

    subgraph "Maintenance"
        INVENTAIRE[Inventaire]
        DESHERBAGE[Désherbage/Pilon]
    end

    NOTICES --> EXEMPLAIRES
    NOTICES --> AUTORITES
    EXEMPLAIRES --> SITES
    EXEMPLAIRES --> PRETS
    LECTEURS --> PRETS
    PRETS --> RESERVATIONS
    PRETS --> AMENDES
    LECTEURS --> QUOTAS
    SITES --> TRANSFERTS
    NOTICES --> OPAC
    LECTEURS --> OPAC
    ACQU --> NOTICES
    SUGGEST --> ACQU
    PERIOD --> NOTICES
    EXEMPLAIRES --> RFID
    PRETS --> RFID
    ADMIN --> DROITS
    DROITS --> LOGS
```

---

## Tableau des modules principaux

| # | Module | Description | Modules liés |
|---|--------|-------------|--------------|
| 1 | **Notices bibliographiques** | Gestion du catalogue des œuvres (livres, CD, DVD, etc.) au format UNIMARC | Exemplaires, Autorités, Import/Export, Z39.50 |
| 2 | **Exemplaires** | Gestion physique des documents (cotes, localisations, états) | Notices, Sites, Prêts, RFID |
| 3 | **Autorités** | Gestion des auteurs, éditeurs, collections, sujets, indexations | Notices, Import/Export |
| 4 | **Lecteurs/Abonnés** | Gestion des comptes utilisateurs et abonnements | Prêts, Réservations, Amendes, Sites, Quotas |
| 5 | **Circulation/Prêts** | Gestion des emprunts, retours, prolongations | Exemplaires, Lecteurs, Réservations, Amendes, RFID |
| 6 | **Réservations** | Gestion des réservations et files d'attente | Prêts, Exemplaires, Lecteurs, Notifications |
| 7 | **Acquisitions** | Commandes, budgets, fournisseurs, réception | Notices, Suggestions, Budgets, Fournisseurs |
| 8 | **Périodiques** | Gestion des abonnements, bulletinage, état des collections | Notices, Exemplaires, Acquisitions, Fournisseurs |
| 9 | **OPAC** | Catalogue public en ligne avec compte lecteur | Notices, Lecteurs, Réservations, Suggestions |
| 10 | **Multi-sites** | Gestion du réseau de bibliothèques | Tous les modules |
| 11 | **Transferts inter-sites** | Navettes et transferts de documents entre sites | Sites, Exemplaires, Réservations |
| 12 | **Statistiques** | Tableaux de bord, rapports, exports | Tous les modules |
| 13 | **RFID/Automates** | Intégration automates de prêt/retour, antivol | Exemplaires, Prêts, Retours |
| 14 | **Import/Export** | UNIMARC, CSV, XML, migrations | Notices, Exemplaires, Autorités, Lecteurs |
| 15 | **Z39.50 / SRU-SRW** | Récupération de notices externes | Notices, Import/Export |
| 16 | **Amendes/Pénalités** | Gestion financière des retards et pertes | Lecteurs, Prêts, Comptabilité |
| 17 | **Suggestions** | Propositions d'achat par les lecteurs | OPAC, Acquisitions, Lecteurs |
| 18 | **DSI** | Diffusion Sélective de l'Information | Lecteurs, Notices, Notifications |
| 19 | **Ressources numériques** | E-books, PNB, ressources en ligne | Notices, OPAC, Lecteurs, Intégrations externes |
| 20 | **Animations/Événements** | Gestion des activités culturelles | OPAC, Lecteurs, Sites |
| 21 | **Paniers/Sélections** | Listes thématiques, coups de cœur | Notices, OPAC |
| 22 | **Notifications** | Emails, SMS, alertes | Lecteurs, Prêts, Réservations, DSI |
| 23 | **Administration** | Configuration système, paramétrage | Tous les modules |
| 24 | **Droits/Rôles** | Gestion des permissions utilisateurs | Administration, Sites |
| 25 | **Quotas** | Règles de prêt par catégorie | Lecteurs, Prêts, Types documents |
| 26 | **Logs/Audit** | Traçabilité des actions | Tous les modules |
| 27 | **Inventaire** | Récolement des collections | Exemplaires, Sites |
| 28 | **Désherbage/Pilon** | Retrait des documents obsolètes | Exemplaires, Notices, Statistiques |

---

## Détail des sous-fonctionnalités

### 1. Module Notices bibliographiques

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Création de notice | Saisie manuelle complète UNIMARC | Autorités |
| Duplication de notice | Copie d'une notice existante | - |
| Modification de notice | Édition des champs UNIMARC | Autorités |
| Suppression de notice | Avec vérification des exemplaires liés | Exemplaires |
| Fusion de notices | Dédoublonnage | Exemplaires, Autorités |
| Recherche multicritères | Recherche avancée dans le catalogue | - |
| Gestion des types de documents | Livres, CD, DVD, jeux, partitions, etc. | Quotas |
| Champs personnalisés | Ajout de zones UNIMARC locales | Administration |
| Liens entre notices | Relations (suite de, accompagne, etc.) | - |
| Vignettes/Images | Couvertures des documents | OPAC |
| Résumés/4e de couverture | Enrichissement éditorial | OPAC |
| Table des matières | Sommaire détaillé | OPAC |
| Validation UNIMARC | Contrôle de conformité | Import/Export |
| Historique des modifications | Traçabilité des changements | Logs |
| Verrouillage concurrent | Édition multi-utilisateur | Administration |

### 2. Module Exemplaires

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Création d'exemplaire | Rattachement à une notice | Notices, Sites |
| Code-barres | Génération et gestion | RFID |
| Cote | Cotation et rangement | Sites |
| Localisation | Site, section, rayon | Sites |
| Statut d'exemplaire | Disponible, prêté, en réparation, etc. | Prêts |
| État physique | Neuf, bon, usé, à réparer | Désherbage |
| Date d'acquisition | Historique d'entrée | Acquisitions |
| Prix d'achat | Valorisation du fonds | Statistiques, Acquisitions |
| Notes internes | Commentaires staff | - |
| Étiquettes | Génération codes-barres, cotes | Impressions |
| Historique des prêts | Traçabilité par exemplaire | Prêts, Statistiques |
| Transfert de site | Mutation inter-sites | Sites, Transferts |
| Réservation sur exemplaire | Réservation spécifique | Réservations |
| Blocage de prêt | Exclusion temporaire | Prêts |
| Puce RFID | Association tag RFID | RFID |

### 3. Module Autorités

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Auteurs personnes | Gestion des auteurs physiques | Notices |
| Auteurs collectivités | Organisations, institutions | Notices |
| Éditeurs | Maisons d'édition | Notices, Acquisitions |
| Collections éditoriales | Séries éditeur | Notices |
| Catégories/Genres | Classification thématique | Notices, OPAC |
| Sujets/Mots-clés | Indexation matière | Notices, OPAC |
| Indexation Dewey | Classification décimale | Notices |
| Indexation RAMEAU | Vocabulaire contrôlé | Notices |
| Langues | Gestion des langues | Notices |
| Pays | Gestion des pays | Notices |
| Fonctions auteurs | Rôles (auteur, illustrateur, etc.) | Notices |
| Formes rejetées | Renvois et variantes | Notices, OPAC |
| Fusion d'autorités | Dédoublonnage | Notices |
| Import autorités | BnF, VIAF, etc. | Import/Export |
| Liens entre autorités | Relations hiérarchiques | - |

### 4. Module Lecteurs/Abonnés

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Création de compte | Inscription nouveau lecteur | Sites, Quotas |
| Fiche lecteur | Informations personnelles | RGPD |
| Catégories de lecteurs | Adultes, enfants, scolaires, etc. | Quotas, Statistiques |
| Carte de lecteur | Génération et impression | Impressions |
| Code-barres lecteur | Identification | Prêts |
| Abonnement/Cotisation | Tarification annuelle | Comptabilité |
| Date d'expiration | Validité de l'inscription | Prêts |
| Renouvellement | Prolongation abonnement | Comptabilité |
| Rattachement familial | Comptes liés | - |
| Adresses multiples | Domicile, travail | Notifications |
| Coordonnées | Email, téléphone, SMS | Notifications |
| Mot de passe OPAC | Accès compte en ligne | OPAC |
| Photo | Identification visuelle | - |
| Notes lecteur | Commentaires staff | - |
| Blocage de compte | Suspension temporaire | Prêts |
| Historique lecteur | Prêts passés, réservations | Statistiques |
| Anonymisation | Conformité RGPD | Administration |
| Groupe/Collectivité | Inscriptions groupées | - |
| Site de rattachement | Bibliothèque principale | Sites |
| Restrictions | Limitations spécifiques | Quotas |
| Exports lecteurs | Pour publipostage | Export |

### 5. Module Circulation/Prêts

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Prêt standard | Enregistrement d'emprunt | Exemplaires, Lecteurs |
| Retour | Enregistrement de restitution | Exemplaires, Réservations |
| Prolongation | Extension de durée | Quotas |
| Prolongation en ligne | Via OPAC | OPAC |
| Prêt express | Mode simplifié | - |
| Retour express | Mode simplifié tous sites | Sites |
| Prêt en lot | Plusieurs documents | - |
| Retour en lot | Plusieurs documents | - |
| Vérification compte | État lecteur avant prêt | Lecteurs, Amendes |
| Alertes au prêt | Retards, blocages, réservations | Notifications |
| Ticket de prêt | Impression récapitulatif | Impressions |
| Durée de prêt | Par type de document | Quotas |
| Nombre max de prêts | Par catégorie lecteur | Quotas |
| Prêts en cours | Liste temps réel | Lecteurs |
| Documents en retard | Liste et relances | Notifications, Amendes |
| Lettres de rappel | Génération automatique | Notifications |
| Prêt inter-bibliothèques | PEB externe | Transferts |
| Mode hors-ligne | Fonctionnement dégradé | - |
| Synchronisation | Après mode hors-ligne | - |

### 6. Module Réservations

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Réservation sur titre | Tous exemplaires confondus | Notices, Lecteurs |
| Réservation sur exemplaire | Exemplaire spécifique | Exemplaires, Lecteurs |
| File d'attente | Ordre de priorité | - |
| Notification disponibilité | Alerte au lecteur | Notifications |
| Délai de retrait | Durée de mise à disposition | Quotas |
| Annulation réservation | Par lecteur ou bibliothécaire | - |
| Réservation en ligne | Via OPAC | OPAC |
| Réservation inter-sites | Sur autre bibliothèque | Sites, Transferts |
| Mise de côté | Sortie du rayon | Exemplaires |
| Quotas de réservation | Nombre max par lecteur | Quotas |
| Historique réservations | Par lecteur/exemplaire | Statistiques |
| Réservations en attente | Tableau de bord | - |
| Réservations à traiter | Documents arrivés | - |
| Réservation de périodique | Numéros spécifiques | Périodiques |

### 7. Module Acquisitions

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Suggestions internes | Propositions bibliothécaires | - |
| Devis | Demandes de prix | Fournisseurs |
| Commandes | Bons de commande | Fournisseurs, Budgets |
| Lignes de commande | Détail des documents | Notices |
| Suivi de commande | État d'avancement | - |
| Réception | Livraison et vérification | Exemplaires |
| Réclamations | Relances fournisseurs | Fournisseurs, Notifications |
| Factures | Enregistrement comptable | Comptabilité |
| Budgets | Enveloppes financières | Comptabilité |
| Lignes budgétaires | Ventilation par poste | - |
| Engagements | Montants réservés | Budgets |
| Mandatements | Ordres de paiement | Comptabilité |
| Fournisseurs | Carnet d'adresses | - |
| Catalogues fournisseurs | Import Electre, etc. | Import/Export |
| Dons | Enregistrement donations | Exemplaires |
| Dépôts | Documents en dépôt | Exemplaires |
| Offices | Envois automatiques | Fournisseurs |
| Statistiques achats | Suivi budgétaire | Statistiques |

### 8. Module Périodiques

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Abonnements | Gestion des souscriptions | Fournisseurs, Acquisitions |
| Modèles de périodicité | Quotidien, hebdo, mensuel, etc. | - |
| Bulletinage | Enregistrement des numéros | Exemplaires |
| Bulletinage prévisionnel | Numéros attendus | - |
| Réclamations | Numéros manquants | Fournisseurs, Notifications |
| État des collections | Lacunes, reliure | - |
| Circulation | Prêt de périodiques | Prêts |
| Réservation de numéros | Sur numéro spécifique | Réservations |
| Dépouillement | Articles/sommaires | Notices |
| Routage | Circuit interne | - |
| Archivage | Conservation/élimination | Désherbage |
| Reliure | Envoi chez le relieur | Fournisseurs |
| Suppléments | Gestion des hors-série | - |
| Multi-sites | Abonnements par site | Sites |

### 9. Module OPAC (Catalogue Public)

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Recherche simple | Tous champs | Notices |
| Recherche avancée | Multicritères | Notices |
| Recherche par facettes | Filtres dynamiques | Notices, Autorités |
| Affichage notice | Détail du document | Notices |
| Disponibilité | État temps réel | Exemplaires, Sites |
| Localisation | Où trouver le document | Sites |
| Compte lecteur | Espace personnel | Lecteurs |
| Prêts en cours | Consultation | Prêts |
| Historique prêts | Emprunts passés | Prêts |
| Réservation en ligne | Demande de réservation | Réservations |
| Prolongation en ligne | Extension de prêt | Prêts |
| Suggestion d'achat | Proposition | Suggestions |
| Paniers/Listes | Sélections personnelles | Paniers |
| Nouveautés | Dernières acquisitions | Notices |
| Coups de cœur | Sélections bibliothèque | Paniers |
| Commentaires/Avis | Critiques lecteurs | - |
| Tags | Mots-clés lecteurs | - |
| Partage réseaux sociaux | Liens externes | - |
| Responsive design | Mobile/tablette | - |
| Accessibilité | Normes WCAG | - |
| Multi-sites | Vue par bibliothèque | Sites |
| Flux RSS | Abonnement nouveautés | - |
| QR codes | Accès mobile | - |
| Authentification | Login/mdp | Lecteurs |
| Pré-inscription | Formulaire en ligne | Lecteurs |
| Contact | Formulaire | Notifications |

### 10. Module Multi-sites

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Gestion des sites | Création/modification | Administration |
| Informations site | Adresse, horaires, contact | OPAC |
| Sections/Espaces | Subdivision du site | Exemplaires |
| Rayonnages | Localisation fine | Exemplaires |
| Paramétrage par site | Règles spécifiques | Quotas, Administration |
| Catalogue global | Vue réseau | Notices |
| Catalogue local | Vue site | Notices, Exemplaires |
| Lecteurs multi-sites | Inscription réseau | Lecteurs |
| Prêt tous sites | Emprunt n'importe où | Prêts |
| Retour tous sites | Restitution n'importe où | Prêts |
| Statistiques par site | Indicateurs locaux | Statistiques |
| Droits par site | Permissions locales | Droits/Rôles |
| Calendrier par site | Jours d'ouverture | Prêts, Quotas |

### 11. Module Transferts inter-sites

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Demande de transfert | Initiation navette | Réservations, Exemplaires |
| Préparation navette | Liste des documents | - |
| Bordereau de navette | Document d'accompagnement | Impressions |
| Expédition | Départ du site | - |
| Réception navette | Arrivée au site | - |
| Affectation définitive | Mutation permanente | Exemplaires |
| Affectation temporaire | Prêt entre sites | Exemplaires |
| Suivi des transferts | État en temps réel | - |
| Historique navettes | Traçabilité | Logs |
| Planification | Calendrier des navettes | - |

### 12. Module Statistiques

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Tableau de bord | Vue synthétique | Tous |
| Prêts par période | Évolution temporelle | Prêts |
| Prêts par type document | Répartition | Prêts, Notices |
| Prêts par catégorie lecteur | Analyse public | Prêts, Lecteurs |
| Prêts par site | Comparaison réseau | Prêts, Sites |
| Top des emprunts | Documents populaires | Prêts, Notices |
| Inscriptions | Évolution abonnés | Lecteurs |
| Réservations | Taux et délais | Réservations |
| Acquisitions | Achats par budget | Acquisitions |
| Fonds | Taille des collections | Exemplaires |
| Taux de rotation | Activité du fonds | Prêts, Exemplaires |
| Retards | Documents en retard | Prêts |
| Fréquentation OPAC | Connexions, recherches | OPAC |
| Rapports personnalisés | Requêtes SQL | Administration |
| Export CSV/Excel | Données brutes | - |
| Graphiques | Visualisation | - |
| Statistiques ES | Envoi ministère culture | - |
| Indicateurs SLL | Normes bibliothèques | - |

### 13. Module RFID/Automates

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Encodage puces | Association tag/exemplaire | Exemplaires |
| Lecture puces | Identification | Exemplaires |
| Automate de prêt | Self-service emprunt | Prêts |
| Automate de retour | Self-service restitution | Prêts |
| Boîte de retour | Retour 24/7 | Prêts |
| Portiques antivol | Détection non désactivée | Sécurité |
| Inventaire RFID | Récolement rapide | Inventaire |
| Recherche étagères | Localisation document | Exemplaires |
| Protocole SIP2 | Communication automates | - |
| Protocole NCIP | Interopérabilité | - |
| Gestion multi-marques | Nedap, 3M, Bibliotheca, etc. | Administration |
| Supervision automates | État temps réel | Administration |
| Statistiques automates | Usage self-service | Statistiques |

### 14. Module Import/Export

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Import UNIMARC | Notices ISO 2709 | Notices |
| Export UNIMARC | Notices ISO 2709 | Notices |
| Import exemplaires | CSV/Excel | Exemplaires |
| Export exemplaires | CSV/Excel | Exemplaires |
| Import lecteurs | CSV/Excel | Lecteurs |
| Export lecteurs | CSV/Excel | Lecteurs |
| Import autorités | CSV/UNIMARC | Autorités |
| Export autorités | CSV/UNIMARC | Autorités |
| Migration PMB | Import complet | Tous |
| Import Electre | Catalogue commercial | Acquisitions, Notices |
| Import BnF | Récupération notices | Notices, Z39.50 |
| Mapping de champs | Correspondance import | Administration |
| Gestion des doublons | Détection/fusion | Notices |
| Logs d'import | Rapport erreurs | Logs |
| Import programmé | Automatisation | Administration |
| Export programmé | Automatisation | Administration |
| Dublin Core | Interopérabilité | Notices |
| METS/MODS | Métadonnées | Ressources numériques |
| EAD | Archives | Notices |

### 15. Module Z39.50 / SRU-SRW

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Client Z39.50 | Interrogation serveurs | Notices |
| Serveur Z39.50 | Exposition catalogue | Notices |
| Client SRU/SRW | Protocole HTTP | Notices |
| Serveur SRU/SRW | API REST | Notices |
| Cibles préconfigurées | BnF, LOC, WorldCat, etc. | Administration |
| Récupération de notices | Import à la volée | Notices |
| Dérivation catalogographique | Copie et adaptation | Notices |
| Recherche fédérée | Multi-cibles | - |
| Profils de recherche | Paramétrage cibles | Administration |
| Conversion UNIMARC/MARC21 | Mapping formats | Import/Export |

### 16. Module Amendes/Pénalités

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Calcul automatique | Retards | Prêts, Quotas |
| Tarifs retard | Par type document | Quotas |
| Plafond d'amende | Maximum par document | Quotas |
| Encaissement | Perception paiement | Comptabilité |
| Remise d'amende | Annulation/réduction | - |
| Blocage pour impayés | Suspension prêt | Lecteurs, Prêts |
| Seuil de blocage | Montant limite | Quotas |
| Documents perdus | Facturation remplacement | Exemplaires |
| Documents détériorés | Facturation dommages | Exemplaires |
| Reçus de paiement | Impression | Impressions |
| Historique paiements | Par lecteur | Lecteurs |
| Relance impayés | Lettres de rappel | Notifications |
| Statistiques amendes | Montants perçus | Statistiques |
| Export comptable | Vers logiciel externe | Export |

### 17. Module Suggestions

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Suggestion en ligne | Via OPAC | OPAC, Lecteurs |
| Suggestion en interne | Par bibliothécaire | - |
| Statut suggestion | En cours, accepté, refusé | - |
| Workflow validation | Circuit d'approbation | Droits/Rôles |
| Notification lecteur | Réponse à suggestion | Notifications |
| Transformation en commande | Création bon | Acquisitions |
| Historique suggestions | Par lecteur | Lecteurs |
| Statistiques suggestions | Taux acceptation | Statistiques |
| Recherche doublons | Éviter redondance | Notices |
| Attribution budget | Imputation | Budgets |

### 18. Module DSI (Diffusion Sélective de l'Information)

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Profils thématiques | Centres d'intérêt | Lecteurs |
| Alertes nouveautés | Notifications auto | Notifications, Notices |
| Bannettes thématiques | Sélections périodiques | Notices |
| Envoi programmé | Automatisation | - |
| Personnalisation | Par lecteur | Lecteurs |
| Désabonnement | Opt-out | - |
| Statistiques DSI | Taux ouverture | Statistiques |
| Lien vers OPAC | Accès notices | OPAC |

### 19. Module Ressources numériques

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Notices numériques | Catalogage ressources en ligne | Notices |
| Liens d'accès | URL ressources | - |
| Authentification proxy | SSO, Shibboleth | Lecteurs |
| PNB | Prêt Numérique en Bibliothèque | Intégrations externes |
| E-books | Livres numériques | Prêts |
| Presse en ligne | Accès périodiques | Périodiques |
| Autoformation | Accès plateformes | - |
| Streaming musique/vidéo | Accès médias | - |
| Statistiques usage | Consultations | Statistiques |
| Gestion des licences | Droits d'accès | - |
| Hub numérique | Intégration Dilicom | Intégrations externes |
| Gestion DRM | Verrous numériques | - |
| Téléchargement | Emprunt fichiers | Prêts |
| Lecture en ligne | Streaming | - |

### 20. Module Animations/Événements

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Création événement | Ateliers, conférences, etc. | Sites |
| Calendrier | Planning activités | OPAC |
| Inscriptions | Réservation places | Lecteurs |
| Jauge | Limitation participants | - |
| Notifications | Rappels événement | Notifications |
| Historique participant | Par lecteur | Lecteurs |
| Lien documents | Bibliographie liée | Notices, Paniers |
| Statistiques fréquentation | Présence | Statistiques |
| Affichage OPAC | Promotion | OPAC |
| Export agenda | iCal, Google Calendar | - |

### 21. Module Paniers/Sélections

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Paniers bibliothécaire | Sélections thématiques | Notices |
| Coups de cœur | Recommandations | OPAC |
| Bibliographies | Listes de lecture | OPAC |
| Tables thématiques | Mise en valeur | - |
| Paniers lecteur | Sélections personnelles | OPAC, Lecteurs |
| Partage de paniers | Envoi/export | - |
| Impression liste | Bibliographie papier | Impressions |
| Publication OPAC | Affichage public | OPAC |
| QR code panier | Accès mobile | - |
| Durée de validité | Paniers temporaires | - |

### 22. Module Notifications

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Emails | Envoi automatique | Tous |
| SMS | Notifications mobiles | Tous |
| Modèles de messages | Templates personnalisables | Administration |
| Variables dynamiques | Personnalisation | - |
| Lettres de rappel | Retards | Prêts, Amendes |
| Avis de disponibilité | Réservations prêtes | Réservations |
| Confirmation inscription | Nouveau compte | Lecteurs |
| Préavis d'échéance | Prêts bientôt dus | Prêts |
| Newsletters | Information générale | DSI |
| Historique envois | Traçabilité | Logs |
| Statistiques | Taux délivrabilité | Statistiques |
| Gestion erreurs | Bounce, spam | - |
| Programmation | Envois différés | - |
| Opt-in/Opt-out | Préférences lecteur | Lecteurs |

### 23. Module Administration

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Paramètres généraux | Configuration système | Tous |
| Gestion utilisateurs | Comptes staff | Droits/Rôles |
| Sauvegarde | Backup base de données | - |
| Restauration | Récupération données | - |
| Maintenance | Optimisation base | - |
| Mise à jour | Upgrades logiciel | - |
| Personnalisation interface | Thèmes, logos | - |
| Configuration OPAC | Paramétrage public | OPAC |
| Configuration prêt | Règles par défaut | Prêts, Quotas |
| Configuration notices | Grilles de saisie | Notices |
| Paramétrage UNIMARC | Zones, sous-zones | Notices |
| Tables de paramètres | Listes de valeurs | Tous |
| Scheduler | Tâches programmées | - |
| Monitoring | Supervision système | - |
| Gestion API | Clés, endpoints | Intégrations |

### 24. Module Droits/Rôles

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Rôles prédéfinis | Admin, catalogueur, etc. | - |
| Rôles personnalisés | Création sur mesure | - |
| Permissions modules | Accès fonctionnalités | Tous |
| Permissions actions | CRUD par module | Tous |
| Permissions sites | Restriction géographique | Sites |
| Affectation utilisateurs | Attribution rôles | Administration |
| Héritage de droits | Rôles hiérarchiques | - |
| Audit des droits | Qui peut faire quoi | Logs |
| Authentification externe | LDAP, SSO | - |
| Double authentification | 2FA | - |
| Politique mot de passe | Règles sécurité | - |
| Sessions | Timeout, déconnexion | - |

### 25. Module Quotas

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Durées de prêt | Par type document | Prêts |
| Nombre de prêts | Par catégorie lecteur | Prêts, Lecteurs |
| Nombre de réservations | Maximum par lecteur | Réservations, Lecteurs |
| Prolongations | Nombre autorisé | Prêts |
| Tarifs amendes | Par type document | Amendes |
| Plafond amendes | Maximum document | Amendes |
| Seuil blocage | Montant impayés | Amendes, Lecteurs |
| Délai réservation | Durée mise à disposition | Réservations |
| Règles par site | Paramétrage local | Sites |
| Règles par type | Document spécifique | Notices |
| Exceptions | Dérogations | - |
| Calendrier | Jours ouvrés | Prêts |

### 26. Module Logs/Audit (Système AuditLog complet)

Le système AuditLog trace **toutes** les actions des utilisateurs dans MediaBib. C'est un composant central pour la traçabilité, la sécurité et la conformité RGPD.

#### 26.1 Catégories d'actions tracées

| Catégorie | Actions tracées | Priorité |
|-----------|-----------------|----------|
| **Authentification** | Connexion, déconnexion, échec de connexion, changement de mot de passe, réinitialisation, verrouillage de compte | Critique |
| **Notices bibliographiques** | Création, modification, suppression, consultation, fusion, duplication, verrouillage | Haute |
| **Exemplaires** | Création, modification, suppression, transfert inter-sites, changement de statut, équipement RFID | Haute |
| **Autorités** | Création, modification, suppression, fusion, import | Moyenne |
| **Lecteurs/Abonnés** | Inscription, modification, suppression, blocage/déblocage, renouvellement, anonymisation RGPD | Critique |
| **Circulation** | Prêt, retour, prolongation, réservation, annulation réservation, mise de côté | Haute |
| **Amendes** | Calcul d'amende, encaissement, remise, blocage pour impayé | Haute |
| **Acquisitions** | Création commande, modification, réception, facturation, annulation | Moyenne |
| **Suggestions** | Création, validation, refus, transformation en commande | Basse |
| **Périodiques** | Bulletinage, réclamation, modification abonnement | Moyenne |
| **Administration** | Changement de configuration, création d'utilisateur staff, modification de droits/rôles | Critique |
| **Import/Export** | Import de notices, export de données, migration | Haute |
| **OPAC** | Réservations en ligne, prolongations en ligne, modifications de compte lecteur | Moyenne |
| **Système** | Tâches planifiées, erreurs, maintenance, sauvegardes | Critique |

#### 26.2 Informations enregistrées par action

| Champ | Description | Exemple |
|-------|-------------|---------|
| **Horodatage** | Date et heure précise (UTC) | 2025-01-15T14:32:45.123Z |
| **Utilisateur** | Identifiant de l'utilisateur | jean.dupont@biblio.fr |
| **Type d'action** | Catégorie de l'action | CREATE, UPDATE, DELETE, LOGIN |
| **Objet concerné** | Type et identifiant de l'objet | Notice #12345, Lecteur #67890 |
| **Représentation** | Description lisible de l'objet | "Les Misérables - Victor Hugo" |
| **Données avant** | État de l'objet avant modification | JSON des champs modifiés |
| **Données après** | État de l'objet après modification | JSON des nouveaux champs |
| **Adresse IP** | IP de l'utilisateur | 192.168.1.45 |
| **User-Agent** | Navigateur/Application | Mozilla/5.0... |
| **Site/Bibliothèque** | Contexte géographique | Médiathèque Centrale |
| **Session** | Identifiant de session | abc123def456 |

#### 26.3 Sous-fonctionnalités détaillées

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Journal des connexions | Succès, échecs, avec IP, user-agent, géolocalisation | Droits/Rôles, Administration |
| Journal CRUD complet | Création, lecture, modification, suppression sur tous les modèles | Tous |
| Historique avec diff | Comparaison avant/après pour chaque modification | Notices, Exemplaires, Lecteurs |
| Alertes de sécurité | Tentatives d'intrusion, actions suspectes, échecs répétés | Administration, Notifications |
| Recherche avancée | Filtres par utilisateur, date, type d'action, objet | - |
| Export des logs | CSV, JSON, PDF pour archivage ou analyse | - |
| Tableau de bord | Visualisation temps réel de l'activité | Statistiques |
| Anonymisation RGPD | Suppression/anonymisation automatique selon durée de rétention | Administration |
| Archivage | Conservation longue durée des logs critiques | Administration |

#### 26.4 Niveaux de criticité

| Niveau | Description | Exemples | Rétention |
|--------|-------------|----------|-----------|
| **Critique** | Actions sensibles nécessitant une traçabilité maximale | Connexions, modifications admin, suppressions | 10 ans |
| **Haute** | Actions métier importantes | Prêts, modifications notices, encaissements | 5 ans |
| **Moyenne** | Actions courantes | Consultations, suggestions, bulletinage | 2 ans |
| **Basse** | Actions informatives | Recherches OPAC, affichages | 90 jours |

#### 26.5 Conformité RGPD

| Fonctionnalité | Description |
|----------------|-------------|
| **Anonymisation automatique** | Remplacement des données personnelles après expiration de la durée de rétention |
| **Droit à l'oubli** | Procédure d'anonymisation manuelle sur demande |
| **Export des données** | Inclusion des logs dans l'export des données personnelles (portabilité) |
| **Minimisation** | Stockage uniquement des données nécessaires |
| **Sécurité** | Chiffrement des logs, accès restreint aux administrateurs |

#### 26.6 Alertes automatiques

| Alerte | Déclencheur | Destinataires |
|--------|-------------|---------------|
| Tentatives de connexion échouées | 5 échecs en 15 minutes | Administrateurs |
| Suppression massive | Plus de 10 suppressions en 1 heure | Administrateurs |
| Accès hors horaires | Connexion entre 22h et 6h | Responsable sécurité |
| Modification de droits | Tout changement de permissions | Super-administrateurs |
| Export volumineux | Export de plus de 1000 enregistrements | Administrateurs |

#### 26.7 Interface de consultation

| Vue | Description | Accès |
|-----|-------------|-------|
| **Tableau de bord temps réel** | Activité en cours, dernières actions | Administrateurs |
| **Recherche par utilisateur** | Historique complet d'un utilisateur | Administrateurs |
| **Recherche par objet** | Historique complet d'une notice, lecteur, etc. | Bibliothécaires (lecture), Admins |
| **Journal des connexions** | Liste des connexions/déconnexions | Administrateurs |
| **Alertes de sécurité** | Incidents et anomalies détectées | Administrateurs, Responsable sécurité |
| **Rapports statistiques** | Synthèses périodiques d'activité | Direction, Administrateurs |

### 27. Module Inventaire

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Création inventaire | Par site, section, rayon | Sites, Exemplaires |
| Inventaire RFID | Scan massif | RFID |
| Inventaire manuel | Douchette code-barres | Exemplaires |
| Liste attendus | Documents à contrôler | Exemplaires |
| Pointage | Validation présence | - |
| Anomalies | Documents non trouvés | Exemplaires |
| Rapport inventaire | Synthèse récolement | Statistiques |
| Mise à jour statut | Documents perdus | Exemplaires |
| Clôture inventaire | Fin de campagne | - |
| Historique inventaires | Archives | - |

### 28. Module Désherbage/Pilon

| Sous-fonctionnalité | Description | Modules liés |
|---------------------|-------------|--------------|
| Critères désherbage | Âge, état, emprunts | Exemplaires, Statistiques |
| Listes candidates | Documents à examiner | - |
| Workflow validation | Circuit d'approbation | Droits/Rôles |
| Motifs de sortie | Usure, doublon, etc. | - |
| Don/Vente | Destination documents | - |
| Pilon | Destruction | - |
| Mise à jour catalogue | Suppression notices | Notices, Exemplaires |
| Statistiques | Volumes traités | Statistiques |
| Conservation | Documents à garder | - |
| Archivage | Envoi en réserve | Exemplaires |

---

## Schémas d'architecture

### Diagramme Entité-Relation simplifié

```mermaid
erDiagram
    SITE ||--o{ SECTION : contient
    SECTION ||--o{ RAYON : contient
    
    NOTICE ||--o{ EXEMPLAIRE : possede
    NOTICE }o--o{ AUTEUR : ecrit_par
    NOTICE }o--o{ EDITEUR : publie_par
    NOTICE }o--o{ COLLECTION : appartient
    NOTICE }o--o{ SUJET : traite_de
    NOTICE ||--o{ CATEGORIE : type
    
    EXEMPLAIRE ||--|| SITE : localise
    EXEMPLAIRE ||--o| SECTION : range
    EXEMPLAIRE ||--o{ PRET : concerne
    EXEMPLAIRE ||--o{ RESERVATION : reserve
    
    LECTEUR ||--|| CATEGORIE_LECTEUR : type
    LECTEUR ||--|| SITE : rattache
    LECTEUR ||--o{ PRET : emprunte
    LECTEUR ||--o{ RESERVATION : demande
    LECTEUR ||--o{ AMENDE : doit
    LECTEUR ||--o{ SUGGESTION : propose
    
    PRET ||--|| EXEMPLAIRE : document
    PRET ||--|| LECTEUR : emprunteur
    PRET ||--o| AMENDE : genere
    
    RESERVATION ||--|| NOTICE : titre
    RESERVATION ||--o| EXEMPLAIRE : specifique
    RESERVATION ||--|| LECTEUR : demandeur
    RESERVATION ||--|| SITE : retrait
    
    COMMANDE ||--|| FOURNISSEUR : aupres
    COMMANDE ||--o{ LIGNE_COMMANDE : contient
    COMMANDE ||--|| BUDGET : impute
    LIGNE_COMMANDE ||--o| NOTICE : concerne
    
    ABONNEMENT ||--|| FOURNISSEUR : aupres
    ABONNEMENT ||--|| NOTICE : periodique
    ABONNEMENT ||--o{ BULLETIN : genere
    BULLETIN ||--|| EXEMPLAIRE : devient
    
    UTILISATEUR ||--o{ ROLE : possede
    ROLE ||--o{ PERMISSION : accorde
    UTILISATEUR ||--o| SITE : affecte
```

### Flux de circulation

```mermaid
flowchart TD
    subgraph Prêt
        A[Lecteur se présente] --> B{Compte valide?}
        B -->|Non| C[Blocage]
        B -->|Oui| D{Quota OK?}
        D -->|Non| C
        D -->|Oui| E[Scan exemplaire]
        E --> F{Disponible?}
        F -->|Non| G[Erreur]
        F -->|Oui| H{Réservé autre?}
        H -->|Oui| G
        H -->|Non| I[Enregistrer prêt]
        I --> J[Imprimer ticket]
    end
    
    subgraph Retour
        K[Scan exemplaire] --> L[Identifier prêt]
        L --> M{En retard?}
        M -->|Oui| N[Calculer amende]
        N --> O[Enregistrer retour]
        M -->|Non| O
        O --> P{Réservation?}
        P -->|Oui| Q[Mise de côté]
        Q --> R[Notifier lecteur]
        P -->|Non| S[Retour rayon]
    end
    
    subgraph Réservation
        T[Demande réservation] --> U{Exemplaire dispo?}
        U -->|Oui| V[Mise de côté immédiate]
        V --> W[Notifier lecteur]
        U -->|Non| X[Ajouter file attente]
        X --> Y[Attendre retour]
        Y --> Q
    end
```

### Workflow d'acquisition

```mermaid
flowchart LR
    subgraph Suggestion
        A[Suggestion lecteur] --> B[Validation bibliothécaire]
        C[Suggestion interne] --> B
        B --> D{Acceptée?}
        D -->|Non| E[Refus notifié]
        D -->|Oui| F[Création commande]
    end
    
    subgraph Commande
        F --> G[Sélection fournisseur]
        G --> H[Envoi bon commande]
        H --> I[Attente livraison]
        I --> J[Réception]
        J --> K{Conforme?}
        K -->|Non| L[Réclamation]
        L --> I
        K -->|Oui| M[Enregistrement facture]
    end
    
    subgraph Catalogage
        M --> N[Création notice]
        N --> O[Création exemplaire]
        O --> P[Équipement]
        P --> Q[Mise en rayon]
        Q --> R[Disponible au prêt]
    end
```

### Architecture multi-sites

```mermaid
flowchart TB
    subgraph Réseau
        CENTRAL[(Base centrale)]
    end
    
    subgraph Site_A[Médiathèque A]
        A_STAFF[Postes staff]
        A_OPAC[OPAC]
        A_AUTO[Automates]
    end
    
    subgraph Site_B[Médiathèque B]
        B_STAFF[Postes staff]
        B_OPAC[OPAC]
        B_AUTO[Automates]
    end
    
    subgraph Site_C[Médiathèque C]
        C_STAFF[Postes staff]
        C_OPAC[OPAC]
    end
    
    A_STAFF --> CENTRAL
    A_OPAC --> CENTRAL
    A_AUTO --> CENTRAL
    B_STAFF --> CENTRAL
    B_OPAC --> CENTRAL
    B_AUTO --> CENTRAL
    C_STAFF --> CENTRAL
    C_OPAC --> CENTRAL
    
    subgraph Navettes
        N1[Navette A-B]
        N2[Navette B-C]
        N3[Navette A-C]
    end
    
    Site_A <--> N1
    N1 <--> Site_B
    Site_B <--> N2
    N2 <--> Site_C
    Site_A <--> N3
    N3 <--> Site_C
```

### Architecture technique Django

```mermaid
flowchart TB
    subgraph Django_Apps[Applications Django]
        CORE[core]
        SITES_APP[sites]
        CATALOG[catalog]
        ITEMS[items]
        PATRONS[patrons]
        CIRCULATION[circulation]
        ACQUISITIONS[acquisitions]
        SERIALS[serials]
        OPAC[opac]
        RFID[rfid]
        DIGITAL[digital]
        EVENTS[events]
        REPORTS[reports]
        NOTIFICATIONS[notifications]
    end
    
    subgraph Dependencies[Dépendances]
        CORE --> SITES_APP
        CATALOG --> CORE
        ITEMS --> CATALOG
        ITEMS --> SITES_APP
        PATRONS --> CORE
        PATRONS --> SITES_APP
        CIRCULATION --> ITEMS
        CIRCULATION --> PATRONS
        ACQUISITIONS --> CATALOG
        SERIALS --> CATALOG
        SERIALS --> ACQUISITIONS
        OPAC --> CATALOG
        OPAC --> PATRONS
        OPAC --> CIRCULATION
        RFID --> ITEMS
        RFID --> CIRCULATION
        DIGITAL --> CATALOG
        EVENTS --> SITES_APP
        EVENTS --> PATRONS
        REPORTS --> CIRCULATION
        REPORTS --> CATALOG
        NOTIFICATIONS --> PATRONS
        NOTIFICATIONS --> CIRCULATION
    end
```

---

## Applications Django

### Tableau de correspondance Modules/Applications

| Application Django | Modules couverts | Description | Modèles principaux |
|-------------------|------------------|-------------|-------------------|
| `core` | Administration, Droits/Rôles, Logs | Configuration système, utilisateurs staff, audit | `StaffUser`, `Role`, `Permission`, `AuditLog`, `SystemConfig` |
| `sites` | Multi-sites, Transferts | Gestion du réseau de bibliothèques | `Library`, `Section`, `Shelf`, `Transfer`, `Shuttle` |
| `catalog` | Notices, Autorités, Import/Export, Z39.50 | Catalogue bibliographique UNIMARC | `Record`, `Author`, `Publisher`, `Collection`, `Subject`, `UnimarcField` |
| `items` | Exemplaires, Inventaire, Désherbage | Gestion physique des documents | `Item`, `ItemStatus`, `Inventory`, `InventoryLine`, `Weeding` |
| `patrons` | Lecteurs/Abonnés, Quotas | Gestion des usagers | `Patron`, `PatronCategory`, `Subscription`, `Quota`, `Family` |
| `circulation` | Prêts, Réservations, Amendes | Transactions de prêt | `Loan`, `Return`, `Hold`, `HoldQueue`, `Fine`, `FinePayment` |
| `acquisitions` | Acquisitions, Suggestions, Fournisseurs | Commandes et budgets | `Vendor`, `Order`, `OrderLine`, `Invoice`, `Budget`, `Suggestion` |
| `serials` | Périodiques | Bulletinage et abonnements | `Subscription`, `Issue`, `IssuePattern`, `Routing`, `Claim` |
| `opac` | OPAC, Paniers, DSI | Catalogue public en ligne | `SearchHistory`, `Basket`, `BasketItem`, `Review`, `Tag`, `DSIProfile` |
| `rfid` | RFID/Automates | Intégration SIP2/NCIP | `RFIDTag`, `SelfCheckStation`, `SIP2Transaction` |
| `digital` | Ressources numériques | E-books, PNB | `DigitalResource`, `License`, `DigitalLoan`, `PNBIntegration` |
| `events` | Animations/Événements | Activités culturelles | `Event`, `EventCategory`, `Registration`, `Attendance` |
| `reports` | Statistiques | Tableaux de bord et exports | `Report`, `ReportTemplate`, `Dashboard`, `Indicator` |
| `notifications` | Notifications | Emails, SMS, alertes | `NotificationTemplate`, `Notification`, `NotificationLog`, `Channel` |

### Structure détaillée des applications

```
MediaBib/
├── app/                          # Configuration Django principale
│   ├── settings.py
│   ├── urls.py
│   └── ...
│
├── core/                         # Noyau système
│   ├── models/
│   │   ├── user.py              # StaffUser, Role, Permission
│   │   ├── audit.py             # AuditLog
│   │   └── config.py            # SystemConfig
│   ├── views/
│   ├── admin.py
│   ├── middleware/
│   │   └── audit.py             # Middleware d'audit
│   └── management/commands/
│
├── sites/                        # Multi-sites
│   ├── models/
│   │   ├── library.py           # Library, Section, Shelf
│   │   ├── transfer.py          # Transfer, Shuttle
│   │   └── calendar.py          # OpeningHours
│   └── ...
│
├── catalog/                      # Catalogue bibliographique
│   ├── models/
│   │   ├── record.py            # Record, RecordType
│   │   ├── authority.py         # Author, Publisher, Collection, Subject
│   │   ├── unimarc.py           # UnimarcField, UnimarcSubfield
│   │   └── relation.py          # RecordRelation
│   ├── services/
│   │   ├── unimarc_parser.py
│   │   ├── z3950_client.py
│   │   └── import_export.py
│   └── ...
│
├── items/                        # Exemplaires
│   ├── models/
│   │   ├── item.py              # Item, ItemStatus
│   │   ├── inventory.py         # Inventory, InventoryLine
│   │   └── weeding.py           # WeedingCampaign, WeedingItem
│   └── ...
│
├── patrons/                      # Lecteurs
│   ├── models/
│   │   ├── patron.py            # Patron, PatronCategory
│   │   ├── subscription.py      # Subscription
│   │   ├── quota.py             # Quota, QuotaRule
│   │   └── family.py            # FamilyLink
│   └── ...
│
├── circulation/                  # Prêts et réservations
│   ├── models/
│   │   ├── loan.py              # Loan
│   │   ├── hold.py              # Hold, HoldQueue
│   │   └── fine.py              # Fine, FinePayment
│   ├── services/
│   │   ├── checkout.py
│   │   ├── checkin.py
│   │   └── renewal.py
│   └── ...
│
├── acquisitions/                 # Acquisitions
│   ├── models/
│   │   ├── vendor.py            # Vendor
│   │   ├── order.py             # Order, OrderLine
│   │   ├── invoice.py           # Invoice, InvoiceLine
│   │   ├── budget.py            # Budget, BudgetLine
│   │   └── suggestion.py        # Suggestion
│   └── ...
│
├── serials/                      # Périodiques
│   ├── models/
│   │   ├── subscription.py      # SerialSubscription
│   │   ├── issue.py             # Issue, IssuePattern
│   │   ├── routing.py           # RoutingList
│   │   └── claim.py             # Claim
│   └── ...
│
├── opac/                         # Catalogue public
│   ├── models/
│   │   ├── search.py            # SearchHistory, SavedSearch
│   │   ├── basket.py            # Basket, BasketItem
│   │   ├── review.py            # Review, Tag
│   │   └── dsi.py               # DSIProfile, DSIAlert
│   ├── views/
│   │   ├── search.py
│   │   ├── account.py
│   │   └── api.py
│   └── templates/opac/
│
├── rfid/                         # RFID et automates
│   ├── models/
│   │   ├── tag.py               # RFIDTag
│   │   └── station.py           # SelfCheckStation, SIP2Transaction
│   ├── services/
│   │   ├── sip2.py
│   │   └── ncip.py
│   └── ...
│
├── digital/                      # Ressources numériques
│   ├── models/
│   │   ├── resource.py          # DigitalResource
│   │   ├── license.py           # License
│   │   └── pnb.py               # PNBIntegration
│   └── ...
│
├── events/                       # Animations
│   ├── models/
│   │   ├── event.py             # Event, EventCategory
│   │   └── registration.py      # Registration, Attendance
│   └── ...
│
├── reports/                      # Statistiques
│   ├── models/
│   │   ├── report.py            # Report, ReportTemplate
│   │   └── dashboard.py         # Dashboard, Indicator
│   ├── services/
│   │   └── generator.py
│   └── ...
│
├── notifications/                # Notifications
│   ├── models/
│   │   ├── template.py          # NotificationTemplate
│   │   ├── notification.py      # Notification, NotificationLog
│   │   └── channel.py           # Channel (email, SMS)
│   ├── services/
│   │   ├── email.py
│   │   └── sms.py
│   └── ...
│
├── docs/                         # Documentation
│   ├── SIGB_SPECIFICATIONS.md
│   └── SIGB_SPECIFICATIONS.pdf
│
├── static/                       # Fichiers statiques
├── templates/                    # Templates globaux
├── locale/                       # Traductions
├── manage.py
└── requirements.txt
```

### Commandes de création des applications

```bash
# Depuis le répertoire racine du projet
python manage.py startapp core
python manage.py startapp sites
python manage.py startapp catalog
python manage.py startapp items
python manage.py startapp patrons
python manage.py startapp circulation
python manage.py startapp acquisitions
python manage.py startapp serials
python manage.py startapp opac
python manage.py startapp rfid
python manage.py startapp digital
python manage.py startapp events
python manage.py startapp reports
python manage.py startapp notifications
```

### Configuration INSTALLED_APPS

```python
# app/settings.py

INSTALLED_APPS = [
    # Django apps
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    
    # Third-party apps
    "rest_framework",
    "django_filters",
    "corsheaders",
    "celery",
    
    # MediaBib apps - Core (ordre important pour les dépendances)
    "core",
    "sites",
    
    # MediaBib apps - Catalogue
    "catalog",
    "items",
    
    # MediaBib apps - Usagers
    "patrons",
    
    # MediaBib apps - Circulation
    "circulation",
    
    # MediaBib apps - Acquisitions
    "acquisitions",
    "serials",
    
    # MediaBib apps - Services publics
    "opac",
    "events",
    
    # MediaBib apps - Technique
    "rfid",
    "digital",
    "reports",
    "notifications",
]
```

---

## Phases de développement

### Phase 1 - Noyau (MVP) - 6 mois

| Priorité | Application | Fonctionnalités |
|----------|-------------|-----------------|
| 1 | `core` | Utilisateurs staff, rôles, permissions, audit |
| 2 | `sites` | Gestion des bibliothèques, sections |
| 3 | `catalog` | Notices UNIMARC, autorités de base |
| 4 | `items` | Exemplaires, statuts |
| 5 | `catalog` | Import UNIMARC (migration PMB) |

```mermaid
gantt
    title Phase 1 - Noyau (6 mois - 1 développeur)
    dateFormat  YYYY-MM-DD
    section Core
    Modèles utilisateurs/rôles    :a1, 2026-01-05, 4w
    Système de permissions        :a2, after a1, 3w
    Audit logging                 :a3, after a2, 2w
    section Sites
    Modèles bibliothèques         :b1, after a3, 3w
    Sections et rayons            :b2, after b1, 2w
    section Catalog
    Modèles notices UNIMARC       :c1, after b2, 5w
    Autorités de base             :c2, after c1, 3w
    section Items
    Modèles exemplaires           :d1, after c2, 3w
    section Import
    Parser UNIMARC                :e1, after d1, 3w
    Migration PMB                 :e2, after e1, 3w
```

### Phase 2 - Circulation - 4 mois

| Priorité | Application | Fonctionnalités |
|----------|-------------|-----------------|
| 1 | `patrons` | Lecteurs, catégories, abonnements |
| 2 | `patrons` | Quotas et règles de prêt |
| 3 | `circulation` | Prêts et retours |
| 4 | `circulation` | Réservations |
| 5 | `circulation` | Amendes basiques |

```mermaid
gantt
    title Phase 2 - Circulation (4 mois - 1 développeur)
    dateFormat  YYYY-MM-DD
    section Patrons
    Modèles lecteurs              :a1, 2026-07-01, 3w
    Catégories et quotas          :a2, after a1, 3w
    section Circulation
    Prêts/Retours                 :b1, after a2, 5w
    Réservations                  :b2, after b1, 3w
    Amendes                       :b3, after b2, 2w
```

### Phase 3 - Services publics - 4 mois

| Priorité | Application | Fonctionnalités |
|----------|-------------|-----------------|
| 1 | `opac` | Recherche simple et avancée |
| 2 | `opac` | Compte lecteur en ligne |
| 3 | `opac` | Réservations et prolongations en ligne |
| 4 | `notifications` | Emails automatiques |
| 5 | `opac` | Paniers et suggestions |

### Phase 4 - Enrichissements - 4 mois

| Priorité | Application | Fonctionnalités |
|----------|-------------|-----------------|
| 1 | `reports` | Statistiques de base |
| 2 | `acquisitions` | Commandes, fournisseurs, budgets |
| 3 | `serials` | Périodiques et bulletinage |
| 4 | `catalog` | Client Z39.50 |
| 5 | `acquisitions` | Suggestions |

### Phase 5 - Avancé - 6 mois

| Priorité | Application | Fonctionnalités |
|----------|-------------|-----------------|
| 1 | `rfid` | Intégration SIP2 |
| 2 | `sites` | Transferts inter-sites |
| 3 | `digital` | Ressources numériques |
| 4 | `opac` | DSI |
| 5 | `events` | Animations |

### Phase 6 - Finalisation - 4 mois

| Priorité | Application | Fonctionnalités |
|----------|-------------|-----------------|
| 1 | `items` | Inventaire |
| 2 | `items` | Désherbage |
| 3 | `digital` | Intégration PNB |
| 4 | `reports` | Statistiques avancées |
| 5 | Tous | Tests, documentation, déploiement |

---

## Intégrations externes

| Intégration | Protocole/Format | Application Django | Description |
|-------------|------------------|-------------------|-------------|
| BnF (Catalogue) | Z39.50 / SRU | `catalog` | Récupération de notices |
| Electre/Dilicom | API REST | `acquisitions` | Données commerciales |
| PNB/Hub numérique | API Dilicom | `digital` | Prêt numérique |
| LDAP/Active Directory | LDAP | `core` | Authentification externe |
| SSO/CAS/Shibboleth | SAML/OAuth | `core` | Authentification unique |
| Google Books API | REST | `catalog` | Enrichissement |
| Open Library | REST | `catalog` | Enrichissement |
| OCLC WorldCat | Z39.50 | `catalog` | Catalogage partagé |
| Automates | SIP2/NCIP | `rfid` | Self-service |
| SMS Gateway | API | `notifications` | Envoi SMS |
| SMTP | Email | `notifications` | Envoi emails |

---

## Normes et conformité

### Formats bibliographiques

| Norme | Usage | Application |
|-------|-------|-------------|
| UNIMARC | Format de notices | `catalog` |
| ISO 2709 | Échange de notices | `catalog` |
| Dublin Core | Interopérabilité | `catalog` |
| METS/MODS | Ressources numériques | `digital` |
| EAD | Archives | `catalog` |

### Protocoles de communication

| Protocole | Usage | Application |
|-----------|-------|-------------|
| Z39.50 | Recherche fédérée | `catalog` |
| SRU/SRW | API de recherche | `catalog` |
| SIP2 | Automates de prêt | `rfid` |
| NCIP | Interopérabilité ILS | `rfid` |
| OAI-PMH | Moissonnage | `catalog` |

### Accessibilité et conformité

| Norme | Description |
|-------|-------------|
| WCAG 2.1 AA | Accessibilité web OPAC |
| RGPD | Protection des données personnelles |
| RGS | Référentiel Général de Sécurité |
| RGAA | Référentiel Général d'Accessibilité |

---

## Annexes

### Dépendances Python recommandées

```txt
# requirements.txt

# Framework
Django>=5.0
djangorestframework>=3.14
django-filter>=23.0
django-cors-headers>=4.0

# Base de données
psycopg2-binary>=2.9  # PostgreSQL
mysqlclient>=2.2      # MySQL (optionnel)

# Tâches asynchrones
celery>=5.3
redis>=5.0
django-celery-beat>=2.5

# UNIMARC / Z39.50
pymarc>=5.0
PyZ3950>=3.0

# PDF / Exports
weasyprint>=60.0
openpyxl>=3.1
python-docx>=1.0

# Emails / SMS
django-anymail>=10.0

# Sécurité
django-axes>=6.0
django-otp>=1.2

# Monitoring
sentry-sdk>=1.30
django-prometheus>=2.3

# Tests
pytest-django>=4.5
factory-boy>=3.3
```

### Variables d'environnement

```bash
# .env

# Django
SECRET_KEY=your-secret-key
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DATABASE_URL=postgres://user:pass@localhost:5432/mediabib

# Redis / Celery
REDIS_URL=redis://localhost:6379/0
CELERY_BROKER_URL=redis://localhost:6379/1

# Email
EMAIL_HOST=smtp.example.com
EMAIL_PORT=587
EMAIL_HOST_USER=noreply@example.com
EMAIL_HOST_PASSWORD=password

# SMS (Twilio example)
TWILIO_ACCOUNT_SID=xxx
TWILIO_AUTH_TOKEN=xxx
TWILIO_FROM_NUMBER=+33...

# Z39.50 targets
BNF_Z3950_HOST=z3950.bnf.fr
BNF_Z3950_PORT=2211
BNF_Z3950_DATABASE=TOUT

# PNB / Dilicom
DILICOM_API_URL=https://hub-dilicom.centprod.com
DILICOM_API_KEY=xxx
```

---

*Document généré pour le projet MediaBib - Clone SIGB open source*
*Version 1.0 - Décembre 2024*

