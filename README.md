# Dedi Agency - GitHub Organization

Repository centralisé des GitHub Actions, workflows réutilisables et templates pour les projets Dedi Agency.

## 🛠️ Structure

### 📦 Actions (`actions/`)
Actions GitHub réutilisables de bas niveau.

- **Deploy Action** : Action pour déploiement d'applications PHP
  - Usage : `dediagency/.github/actions/deploy@v1`
  - Documentation : [actions/deploy/README.md](actions/deploy/README.md)

### 🔄 Workflows réutilisables (`.github/workflows/`)
Workflows réutilisables de niveau intermédiaire.

- **deploy-sylius.yml** : Workflow optimisé pour Sylius
- **deploy-wordpress.yml** : Workflow optimisé pour WordPress/Bedrock
- **deploy-reusable.yml** : Workflow générique configurable

### 📋 Templates de workflow (`workflow-templates/`)
Templates de démarrage pour nouveaux projets.

- **deploy-sylius** : Template prêt à l'emploi pour projets Sylius
- **deploy-wordpress** : Template prêt à l'emploi pour projets WordPress
- **deploy-custom** : Template flexible pour projets custom

## 🚀 Démarrage rapide

1. **Nouveau projet Sylius** : Utilisez le template `deploy-sylius`
2. **Nouveau projet WordPress** : Utilisez le template `deploy-wordpress`
3. **Projet custom** : Utilisez le template `deploy-custom` ou les workflows réutilisables

---

Pour plus d'informations, consultez la documentation de chaque composant.