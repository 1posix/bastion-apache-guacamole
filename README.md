
<div align="center">

# Bastion Apache Guacamole

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker&logoColor=white)
![Guacamole](https://img.shields.io/badge/Apache_Guacamole-Latest-D22128?style=flat-square&logo=apache&logoColor=white)
![Security](https://img.shields.io/badge/Security-Hardened-success?style=flat-square&logo=shield&logoColor=white)
![MFA](https://img.shields.io/badge/MFA-TOTP_Ready-orange?style=flat-square&logo=googleauthenticator&logoColor=white)
![Bash](https://img.shields.io/badge/Scripting-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)

</div>

<div align="center">
  <strong>Serveur bastion sécurisé (Gateway) Clientless pour RDP, SSH, VNC & Kubernetes.</strong>
</div>

---

<div>

Serveur bastion sécurisé (Gateway) basé sur **Apache Guacamole**, conteneurisé pour un déploiement rapide et reproductible.

Cette solution offre une passerelle web **Clientless (HTML5)** pour l'administration sécurisée de l'infrastructure via **RDP, SSH, VNC, et Kubernetes**, centralisant l'accès et garantissant une traçabilité complète (Recording & Logs).

</div>

## Fonctionnalités

* **Zero-Client :** Tout se passe dans le navigateur, aucun plugin requis.
* **Sécurité Renforcée :**
  * Support natif du **MFA / TOTP** (Google Authenticator, etc.).
  * **Hardening Tomcat** : Suppression des bannières de version et pages d'erreurs par défaut (Anti-Reconnaissance).
* **Traçabilité & Audit :** Enregistrement vidéo des sessions (SSH/RDP) stocké localement.

## Installation et Démarrage

### 1. Cloner le dépôt

```bash
git clone https://github.com/1posix/bastion-apache-guacamole.git
cd bastion-apache-guacamole
```

### 2. Configuration de l'environnement

Créez le fichier `.env` à partir de l'exemple et ajustez les mots de passe **(OBLIGATOIRE)**.

```bash
cp .env.example .env
# Editez le fichier avec vos propres mots de passe forts
nano .env
```

### 3. Lancement de la stack

```bash
docker-compose up -d --build
```

> **Note :** Le conteneur `guacamole_init` va préparer la base de données et les extensions au premier lancement. Attendez que le conteneur `guacamole_frontend` soit "Healthy" ou démarré.



## Configuration (.env)

Les variables principales à définir dans votre fichier `.env` :

| Variables           | Description                              | Valeur par défaut    |
|---------------------|------------------------------------------|----------------------|
| `GUACAMOLE_PORT`    | Port d'exposition local                  | `8080`               |
| `POSTGRES_PASSWORD` | Mot de passe BDD (Changez-le !)          | `guacamole_password` |
| `POSTGRES_USER`     | Utilisateur par défaut Postgres          | `guacamole_user`     |
| `POSTGRESQL_AUTO_CREATE_ACCOUNTS`| Création d'un utilisateur par défaut | `true`      |
| `GUACAMOLE_HOME`    | Répertoire interne au docker pour les données du bastion| `/opt/guacamole_home` |
| `TOTP_ENABLED`      | Active l'authentification double facteur | `true` |


## Premier Accès

Une fois la stack démarrée :

1. Accédez à : `http://VOTRE_IP:8080/guacamole/`
2. Identifiants par défaut **(À CHANGER IMMÉDIATEMENT)** :
   * **User :** `guacadmin`
   * **Pass :** `guacadmin`

> **Note de Sécurité :** Allez immédiatement dans **Paramètres → Utilisateurs → guacadmin** pour changer le mot de passe.


## Structure des Volumes

Les données sont persistantes dans le dossier `./volumes` de l'hôte :

* `./volumes/data` : Données PostgreSQL (Utilisateurs, connexions).
* `./volumes/record` : Enregistrements vidéos des sessions (Audit).
* `./volumes/drive` : Dossier pour le transfert de fichiers (Drive virtuel).
* `./volumes/server.xml` : Configuration durcie de Tomcat.

## ⚠️ Avertissement de Production (Security Best Practices)

Cette stack expose le service sur le port `8080` sans chiffrement SSL (HTTP).
Dans un environnement de production, il est **impératif** de ne pas exposer ce port directement sur Internet.

**Recommandation :** Placez un Reverse Proxy (Nginx, Traefik, HAProxy) en amont pour :
1.  Gérer la terminaison **SSL/HTTPS** (ex: Let's Encrypt).
2.  Sécuriser les headers HTTP (HSTS, X-Frame-Options).
3.  Interdire l'accès direct aux ports Docker depuis l'extérieur.


## Ressources

Pour une configuration avancée ou pour comprendre le fonctionnement interne, référez-vous à la documentation officielle :

<div align="center">

[![Documentation Officielle](https://img.shields.io/badge/Documentation_Officielle-Apache_Guacamole-D22128?style=for-the-badge&logo=apache&logoColor=white)](https://guacamole.apache.org/doc/gug/index.html)

</div>


---

<div align="center">

[![Maintenu par 1posix](https://img.shields.io/badge/Maintenu_par-1posix-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/1posix)

</div>

