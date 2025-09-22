# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.2.0] - 2025-09-23

### Ajouté
- Workflows réutilisables pour Sylius et WordPress
- Wrappers d'action `deploy/sylius` et `deploy/wordpress` minimalistes
- Templates GitHub par plateforme (Sylius, WordPress) basés sur les nouvelles actions

### Modifié
- Simplification des actions: moins de variables intermédiaires, defaults gérés dans `config.sh`
- Commandes npm/build par défaut pour Sylius gérées automatiquement (désactivation possible via `skip`)
- Aucune opération de base de données automatique pour WordPress par défaut
- Retrait du workflow réutilisable générique au profit de templates dédiés

### Supprimé
- Action composite générique (`actions/deploy/action.yml`) au profit des actions Sylius/WordPress dédiées
- Dossier `actions/deploy/examples` (les guides vivent désormais dans la documentation)

## [v0.1.0] - 2024-09-19

### Ajouté
- **Deploy Action** : Action GitHub réutilisable pour le déploiement d'applications PHP
- **Smart defaults** : Configuration automatique basée sur l'environnement et ssh_username
- **Multi-plateforme** : Support Sylius, WordPress, Symfony
- **Permissions configurables** : Support chmod et setfacl
- **Fichiers partagés** : Symlinks automatiques
- **Post-deployment** : Support composer post-deploy-cmd et commandes personnalisées
- **Exemples** : Workflows prêts à l'emploi pour chaque plateforme

### Fonctionnalités
- ✅ Checkout automatique du code source
- ✅ Script de déploiement externe (`deploy.sh`)
- ✅ Déploiement atomique avec releases et symlinks
- ✅ Configuration ultra-simple (3 paramètres minimum)
- ✅ Nettoyage automatique des anciennes releases
- ✅ Rechargement de services configurable

### Exemples inclus
- `examples/sylius-recette.yml` - Déploiement Sylius en recette
- `examples/wordpress-staging.yml` - Déploiement WordPress/Bedrock
- `examples/symfony-production.yml` - Déploiement Symfony en production

## [Unreleased]

### Modifié
- Scripts de déploiement scindés par plateforme avec runtime partagé (`shared/lib`)
- Actions SSH simplifiées grâce au passage d'environnement via `envs`

### Vers v1.0.0 (Stable Release)
- Tests en production sur plusieurs projets
- Feedback et améliorations basées sur l'usage réel
- Documentation complète et guide de migration

### Futures versions
- Support pour d'autres plateformes (Laravel, etc.)
- Intégration avec d'autres services de déploiement
- Métriques et monitoring intégrés