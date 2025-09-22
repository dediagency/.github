# Deploy Actions

Composite actions GitHub pour déployer les projets Sylius et WordPress/Bedrock de Dedi Agency.

- **Deploy Sylius** : `dediagency/.github/actions/deploy/sylius@v1`
- **Deploy WordPress** : `dediagency/.github/actions/deploy/wordpress@v1`

Chaque action embarque son propre `deploy.sh` (copié sur le serveur) ainsi qu'une librairie partagée (`shared/lib`) pour les helpers communs. Les paramètres restent identiques et le scénario de déploiement est le même : releases horodatées, dossiers partagés, symlink `current`.

## Fonctionnalités principales

- ✅ Checkout automatique du dépôt
- ✅ Script de déploiement copié sur le serveur et exécuté en SSH
- ✅ Déploiement atomique avec releases + symlink `current`
- ✅ Defaults intelligents basés sur *environment* + *ssh_username*
- ✅ Gestion spécifique Sylius/WordPress dans `config.sh`
- ✅ Binaires PHP / Node / NPM configurables
- ✅ Permissions configurables (`chmod` ou `setfacl`)
- ✅ Répertoires / fichiers partagés via symlinks
- ✅ Opérations base de données / cache / assets optionnelles
- ✅ Support `post-deploy-cmd` Composer et commandes post-déploiement
- ✅ Nettoyage des anciennes releases + reload de services

## Usage rapide

### Sylius
```yaml
jobs:
  deploy-recette:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Sylius
        uses: dediagency/.github/actions/deploy/sylius@v1
        with:
          ssh_host: preprod.dediagency.net
          ssh_username: monprojet-sylius
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          environment: recette
          branch: env/recette
```

### WordPress / Bedrock
```yaml
jobs:
  deploy-recette:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy WordPress
        uses: dediagency/.github/actions/deploy/wordpress@v1
        with:
          ssh_host: recette.dediagency.net
          ssh_username: monprojet-wp
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          environment: recette
          branch: env/recette
```

## Paramètres communs

### Infrastructure

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `ssh_host` ⚠️ | Serveur de déploiement | — |
| `ssh_username` ⚠️ | Utilisateur SSH | — |
| `ssh_private_key` ⚠️ | Clé privée (déploiement) | — |
| `ssh_port` | Port SSH | `22` |

### Environnement

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `environment` ⚠️ | Nom fonctionnel (`recette`, `preproduction`, `production`) | — |
| `branch` ⚠️ | Branche Git à déployer | — |
| `deploy_path` | Dossier distant | `$HOME/{environment}-{ssh_username}` |
| `site_url` | URL d’environnement | `https://{environment}-{ssh_username}.dediagency.dev` |
| `app_env` | Valeur `APP_ENV` | `recette→test`, `preprod→staging`, `prod→prod` |

### Binaires / build

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `php_version` | Version PHP (informative) | `8.3` |
| `php_binary` | Binaire PHP | `php8.3` |
| `composer_path` | Binaire Composer | `/usr/bin/composer` |
| `node_version` | Version Node requise | `18` |
| `node_binary` | Binaire Node | `node` |
| `npm_binary` | Binaire NPM | `npm` |
| `composer_install_args` | Arguments `composer install` | `--no-dev --optimize-autoloader --no-interaction --no-scripts` |
| `npm_install_command` | Commande NPM | *(auto pour Sylius, vide sinon)* |
| `build_command` | Commande de build | *(auto pour Sylius, vide sinon)* |

> Pour désactiver le build front Sylius : `npm_install_command: skip` et/ou `build_command: skip`.

### Opérations applicatives

| Paramètre | Sylius | WordPress |
|-----------|--------|-----------|
| `db_operations` | `recette`: create/schema/fixtures<br>`preprod`/`prod`: migrations | `[]` |
| `cache_commands` | `['cache:clear', 'cache:warmup']` | `[]` |
| `asset_commands` | `['assets:install ...']` | `[]` |
| `shared_dirs` | `var/log`, `var/storage`, `public/media`, `public/uploads` | `web/app/uploads`, `web/app/cache`, `web/app/languages` |
| `shared_files` | `.env.local` | `.env`, `web/.htaccess` |

Ces valeurs peuvent être surchargées via les entrées JSON.

### Permissions & post-déploiement

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `permission_method` | `chmod` ou `setfacl` | `chmod` |
| `file_permissions` | Valeur chmod générale | `755` |
| `var_permissions` | Valeur chmod pour `var` | `775` |
| `setfacl_user` / `setfacl_group` | Obligatoire si `setfacl` | — |
| `run_post_deploy_cmd` | Exécuter `composer post-deploy-cmd` | `true` |
| `post_deploy_commands` | Commandes supplémentaires | `[]` |
| `reload_services` | Services à recharger (`sudo service ... reload`) | `['php8.3-fpm']` |

### Repository

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `repository` | Repo GitHub (`owner/name`) cloné sur le serveur | `github.repository` |

## Structure générée sur le serveur

```
$DEPLOY_PATH
├── releases/
│   ├── 20240910121500/
│   ├── 20240910134500/
│   └── ...
├── shared/
│   ├── ... (fichiers/dossiers partagés)
└── current -> releases/<timestamp>
```

## Prérequis & bonnes pratiques

- Ajouter la clé publique du runner comme *Deploy key* dans GitHub (lecture seule)
- Créer manuellement les fichiers partagés critiques (`.env.local`, `.env`, etc.) lors du premier déploiement
- Vérifier la présence des binaires requis sur le serveur (`git`, `php`, `composer`, `node`, `npm`, `setfacl`, `service`/`systemctl`…)

## Aller plus loin

La logique partagée vit dans `shared/lib` tandis que chaque plateforme gère ses defaults dans `actions/deploy/<plateforme>/lib/config.sh`. Pour en ajouter une nouvelle, dupliquez une action existante, ajustez son script et implémentez les defaults nécessaires dans son `lib/config.sh`.
