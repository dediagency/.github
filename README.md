# Dedi Agency - GitHub Organization

Repository centralisé des GitHub Actions et templates communs aux projets Dedi Agency.

## 🛠️ Actions (`actions/`)

- **deploy/sylius** : action de déploiement Sylius (`dediagency/.github/actions/deploy/sylius@v1`)
- **deploy/wordpress** : action de déploiement WordPress/Bedrock (`dediagency/.github/actions/deploy/wordpress@v1`)

## 📋 Templates (`workflow-templates/`)

- **deploy-sylius.yml** : workflow prêt à l'emploi pour un projet Sylius
- **deploy-wordpress.yml** : workflow prêt à l'emploi pour un projet WordPress/Bedrock

## 🚀 Exemple rapide (usage direct de l'action)

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Sylius
        uses: dediagency/.github/actions/deploy/sylius@v1
        with:
          ssh_host: my-host.example.com
          ssh_username: project-sylius
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          environment: recette
          branch: env/recette
```

Pour WordPress remplacez simplement l'action par `deploy/wordpress@v1` ou partez du template correspondant.

La documentation détaillée des paramètres se trouve dans `actions/deploy/README.md`.
