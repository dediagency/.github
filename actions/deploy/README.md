# Deploy Action

GitHub Action réutilisable pour le déploiement d'applications PHP (Sylius, WordPress, Symfony) développée par Dedi Agency.

**Repository** : `dediagency/.github`
**Usage** : `uses: dediagency/.github/actions/deploy@v0`

## Fonctionnalités

- ✅ **Checkout automatique** du code source
- ✅ **Script de déploiement externe** (`.github/actions/deploy/deploy.sh`)
- ✅ **Déploiement atomique** avec releases et symlinks
- ✅ **Smart defaults** basés sur l'environnement et ssh_username
- ✅ **Support multi-plateforme** (Sylius, WordPress, Symfony)
- ✅ **Binaires configurables** (PHP, Node, NPM)
- ✅ **Permissions configurables** (chmod ou setfacl)
- ✅ **Fichiers partagés** avec symlinks
- ✅ **Opérations de base de données** personnalisables
- ✅ **Commandes de cache et assets** personnalisables
- ✅ **Exécution de composer post-deploy-cmd**
- ✅ **Commandes post-déploiement** personnalisables
- ✅ **Nettoyage automatique** des anciennes releases
- ✅ **Rechargement de services** configurable

## Usage de base (configuration minimale)

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy using organizational action
        uses: dediagency/.github/actions/deploy@v0
        with:
          # Seulement 4 paramètres requis !
          platform: sylius
          ssh_host: preprod.dediagency.net
          ssh_username: monprojet-user
          environment: recette
          branch: env/recette
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}

          # Tous les autres paramètres sont auto-générés :
          # ✅ Checkout automatique du code
          # ✅ deploy_path: $HOME/recette-monprojet-user
          # ✅ site_url: https://recette-monprojet-user.dediagency.dev
          # ✅ app_env: test (pour recette)
          # ✅ db_operations: Création DB + Schema + Fixtures (selon platform)
          # ✅ cache_commands: Clear + Warmup cache (selon platform)
          # ✅ asset_commands: Installation assets (selon platform)
```

**Note :** Plus besoin d'ajouter une step `actions/checkout@v4` séparément, c'est inclus automatiquement dans l'action !

## Paramètres

### Infrastructure (requis)

| Paramètre | Description | Auto-défaut | Exemple |
|-----------|-------------|-------------|---------|
| `ssh_host` ⚠️ | Serveur SSH | - | `preprod.dediagency.net` |
| `ssh_username` ⚠️ | Utilisateur SSH | - | `monprojet-user` |
| `ssh_private_key` | Clé SSH privée | `${{ secrets.SSH_PRIVATE_KEY }}` | Clé SSH privée |
| `ssh_port` | Port SSH | `22` | Port SSH |

### Environment (requis)

| Paramètre | Description | Auto-généré | Exemple |
|-----------|-------------|-------------|---------|
| `environment` ⚠️ | Nom de l'environnement | - | `recette`, `preproduction`, `production` |
| `branch` ⚠️ | Branche à déployer | - | `env/recette`, `master` |
| `deploy_path` | Chemin de déploiement | `$HOME/{environment}-{ssh_username}` | `$HOME/recette-monprojet` |
| `site_url` | URL du site | `https://{environment}-{ssh_username}.dediagency.dev` | `https://recette-monprojet.dediagency.dev` |
| `app_env` | Environment applicatif | Basé sur environment | `recette`→`test`, `preproduction`→`staging`, `production`→`prod` |

⚠️ = Paramètres obligatoires (seulement 3 !)

### Configuration plateforme (optionnel)

| Paramètre | Description | Requis |
|-----------|-------------|--------|
| `platform` ⚠️ | Type de plateforme | Oui |
| `php_version` | Version PHP | `8.3` |
| `php_binary` | Binaire PHP à utiliser | `php8.3` |
| `composer_path` | Chemin vers composer | `/usr/bin/composer` |
| `node_version` | Version Node.js | `18` |
| `node_binary` | Binaire Node à utiliser | `node` |
| `npm_binary` | Binaire NPM à utiliser | `npm` |

### Commandes de build (optionnel)

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `composer_install_args` | Arguments pour composer install | `--no-dev --optimize-autoloader --no-interaction --no-scripts` |
| `npm_install_command` | Commande d'installation NPM | `npm install --silent` |
| `build_command` | Commande de build des assets | `npm run build:prod` |

### Opérations de base de données (auto-configurées)

**Valeurs par défaut selon l'environnement :**

| Environment | Opérations par défaut |
|-------------|----------------------|
| `recette` | Création DB + Schema + Fixtures |
| `preproduction`/`production` | Migrations uniquement |

```yaml
# Exemple personnalisé (optionnel)
db_operations: |
  [
    "doctrine:database:create --if-not-exists --no-interaction",
    "doctrine:schema:update --force --no-interaction",
    "sylius:fixtures:load --no-interaction"
  ]
```

### Commandes de cache (auto-configurées)

**Valeurs par défaut selon la plateforme :**

| Plateforme | Commandes par défaut |
|------------|---------------------|
| `sylius`/`symfony` | Clear + Warmup cache |
| `wordpress` | Aucune |

```yaml
# Exemple personnalisé (optionnel)
cache_commands: |
  [
    "cache:clear --env=prod --no-interaction",
    "cache:warmup --env=prod --no-interaction"
  ]
```

### Commandes d'assets (auto-configurées)

**Valeurs par défaut selon la plateforme :**

| Plateforme | Commandes par défaut |
|------------|---------------------|
| `sylius`/`symfony` | Installation assets avec symlinks |
| `wordpress` | Aucune |

```yaml
# Exemple personnalisé (optionnel)
asset_commands: |
  [
    "assets:install public --symlink --relative --no-interaction"
  ]
```

### Répertoires et fichiers partagés (JSON array)

```yaml
shared_dirs: |
  ["var/log", "var/storage", "public/media", "public/uploads"]

shared_files: |
  [".env.local"]
```

**Note :** Les fichiers partagés sont maintenant créés avec des **symlinks** au lieu d'être copiés.

### Permissions

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `permission_method` | Méthode de permissions (chmod ou setfacl) | `chmod` |
| `file_permissions` | Permissions des fichiers (mode chmod) | `755` |
| `var_permissions` | Permissions du répertoire var (mode chmod) | `775` |
| `setfacl_user` | Utilisateur pour setfacl (requis si setfacl) | `` |
| `setfacl_group` | Groupe pour setfacl (requis si setfacl) | `` |

#### Exemple avec setfacl :
```yaml
permission_method: setfacl
setfacl_user: www-data
setfacl_group: www-data
```

### Post-déploiement

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `run_post_deploy_cmd` | Exécuter composer post-deploy-cmd | `true` |
| `post_deploy_commands` | Commandes post-déploiement supplémentaires (JSON array) | `[]` |

#### Exemple de commandes post-déploiement :
```yaml
post_deploy_commands: |
  [
    "echo 'Deployment completed'",
    "curl -f http://localhost/health-check || echo 'Health check failed'"
  ]
```

### Services à recharger (JSON array)

```yaml
reload_services: |
  ["php8.3-fpm", "nginx"]
```

## Exemples d'usage

### Projet Sylius (configuration minimale)

```yaml
- name: Deploy Sylius
  uses: ./.github/actions/deploy
  with:
    # Configuration minimale avec smart defaults
    ssh_host: preprod.dediagency.net
    ssh_username: monprojet-sylius
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
    environment: recette
    branch: env/recette

    # Smart defaults utilisés :
    # ✅ deploy_path: $HOME/recette-monprojet-sylius
    # ✅ site_url: https://recette-monprojet-sylius.dediagency.dev
    # ✅ app_env: test
    # ✅ platform: sylius
    # ✅ db_operations: ["doctrine:database:create --if-not-exists --no-interaction", "doctrine:schema:update --force --no-interaction", "sylius:fixtures:load --no-interaction || true"]
    # ✅ cache_commands: ["cache:clear --env=prod --no-interaction", "cache:warmup --env=prod --no-interaction"]
    # ✅ asset_commands: ["assets:install public --symlink --relative --no-interaction"]
```

### Projet Sylius (configuration avancée)

```yaml
- name: Deploy Sylius Advanced
  uses: ./.github/actions/deploy
  with:
    ssh_host: preprod.dediagency.net
    ssh_username: monprojet-sylius
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
    environment: recette
    branch: env/recette

    # Surcharge des smart defaults
    permission_method: setfacl
    setfacl_user: www-data
    setfacl_group: www-data
    post_deploy_commands: |
      [
        "curl -f https://recette-monprojet-sylius.dediagency.dev/health || echo 'Health check failed'"
      ]
```

### Projet WordPress (avec Bedrock)

```yaml
- name: Deploy WordPress
  uses: ./.github/actions/deploy
  with:
    ssh_host: preprod.dediagency.net
    ssh_username: monprojet-wp
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
    environment: staging
    branch: develop
    deploy_path: $HOME/staging-monprojet
    platform: wordpress
    php_version: "8.2"
    php_binary: "php8.2"
    build_command: "npm run build"
    permission_method: chmod
    file_permissions: "755"
    var_permissions: "775"
    shared_dirs: |
      ["web/app/uploads"]
    shared_files: |
      [".env"]
    cache_commands: |
      []
    asset_commands: |
      []
    run_post_deploy_cmd: false
    post_deploy_commands: |
      [
        "wp cache flush --path=web/wp || echo 'WordPress CLI not available'"
      ]
```

### Projet Symfony

```yaml
- name: Deploy Symfony
  uses: ./.github/actions/deploy
  with:
    ssh_host: preprod.dediagency.net
    ssh_username: monprojet-symfony
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
    environment: staging
    branch: develop
    deploy_path: $HOME/staging-monprojet
    platform: symfony
    php_version: "8.3"
    db_operations: |
      [
        "doctrine:migrations:migrate --no-interaction"
      ]
    cache_commands: |
      [
        "cache:clear --env=prod --no-interaction"
      ]
    asset_commands: |
      [
        "assets:install public --symlink --relative --no-interaction"
      ]
```

## Structure de déploiement

## Structure de l'action

```
.github/actions/deploy/
├── action.yml          # Configuration de l'action GitHub
├── deploy.sh          # Script de déploiement principal
└── README.md          # Documentation
```

L'action créé la structure suivante sur le serveur :

```
deploy_path/
├── releases/
│   ├── 20240315120000/
│   ├── 20240315130000/
│   └── 20240315140000/  (release courante)
├── shared/
│   ├── var/log/
│   ├── var/storage/
│   ├── public/media/
│   ├── public/uploads/
│   └── .env.local
└── current -> releases/20240315140000/
```

## Prérequis

- Le serveur doit avoir accès SSH aux repositories GitHub
- Les répertoires partagés et fichiers de configuration doivent être créés manuellement la première fois
- Le fichier `.env.local` (ou équivalent) doit être présent dans le répertoire `shared/`

## Sécurité

- Utilise des clés SSH pour l'authentification
- Déploiement atomique avec symlinks
- Nettoyage automatique des anciennes releases
- Validation des prérequis avant déploiement
